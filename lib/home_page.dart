import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shop_easy/cart.dart';
import 'package:shop_easy/login.dart';
import 'package:shop_easy/profile.dart';
import 'package:shop_easy/setting.dart';
import 'package:shop_easy/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _search = TextEditingController();
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));

  String _selectedCategory = 'all';
  int _selectedIndex = 0;

  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  int _currentPage = 1;
  final int _limit = 6;
  int _totalProducts = 0;

  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserAvatar();
    _fetchCategories();
    _fetchProducts();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _fetchUserAvatar() async {
    if (globalAccessToken == null) return;
    try {
      final response = await _dio.get(
        '/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $globalAccessToken',
          },
        ),
      );

      setState(() {
        _avatarUrl = response.data['image'];
      });
    } catch (e) {
      debugPrint('Lỗi lấy avatar user: $e');
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _dio.get('/products/categories');
      setState(() {
        _categories = [
          {'slug': 'all', 'name': 'Tất cả'},
          ...response.data,
        ];
      });
    } catch (e) {
      debugPrint('Lỗi lấy danh mục: $e');
    }
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);

    final int skip = (_currentPage - 1) * _limit;
    final String query = _search.text.trim();

    String endpoint = '/products';
    if (query.isNotEmpty) {
      endpoint = '/products/search';
    } else if (_selectedCategory != 'all') {
      endpoint = '/products/category/$_selectedCategory';
    }

    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'limit': _limit,
          'skip': skip,
          if (query.isNotEmpty) 'q': query,
        },
      );

      setState(() {
        _products = response.data['products'];
        _totalProducts = response.data['total'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Lỗi lấy sản phẩm: $e');
    }
  }

  int get _totalPages => (_totalProducts / _limit).ceil();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'ShopEasy',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A26) : Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Cart()),
              );
            },
            icon: const Icon(Icons.shopping_cart),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyProfile()),
                );
              },
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Colors.white24,
                backgroundImage:
                    _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                child: _avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) {
                  setState(() {
                    _currentPage = 1;
                    _selectedCategory = 'all';
                  });
                  _fetchProducts();
                },
                decoration: InputDecoration(
                  labelText: 'Tìm sản phẩm ...',
                  prefixIcon: const Icon(Icons.search_sharp),
                  suffixIcon: _search.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _search.clear();
                            setState(() => _currentPage = 1);
                            _fetchProducts();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(45),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              if (_categories.isNotEmpty)
                SizedBox(
                  height: 45,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final slug = cat['slug'];
                      final name = cat['name'];
                      return FilterChip(
                        label: Text(name),
                        selected: _selectedCategory == slug,
                        shape: const StadiumBorder(),
                        selectedColor: isDark
                            ? Colors.indigo.shade800
                            : Colors.indigo.shade100,
                        checkmarkColor: isDark
                            ? Colors.indigo.shade200
                            : Colors.indigo,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedCategory = slug;
                            _currentPage = 1;
                            _search.clear();
                          });
                          _fetchProducts();
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              if (_isLoading)
                const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_products.isEmpty)
                const SizedBox(
                  height: 200,
                  child: Center(child: Text('Không tìm thấy sản phẩm nào.')),
                )
              else ...[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final item = _products[index];

                    final Map<String, dynamic> product = {
                      ...item,
                      'name': item['title'],
                      'price': '\$${item['price']}',
                      'discount': '-${item['discountPercentage']}%',
                      'rating': '${item['rating']}',
                      'reviews': '${(item['reviews'] as List?)?.length ?? 0}',
                      'rawReviews': item['reviews'],
                    };

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(product: product),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      color: isDark
                                          ? const Color(0xFF282836)
                                          : Colors.grey[100],
                                      child: Image.network(
                                        item['thumbnail'] ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.image_outlined,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product['price'],
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${product['rating']} (${product['reviews']})',
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 32,
                                        child: ElevatedButton.icon(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.add_shopping_cart,
                                            size: 14,
                                          ),
                                          label: const Text(
                                            'Thêm',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDark
                                                ? Colors.indigo.shade700
                                                : Colors.indigo,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  product['discount'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.black45
                                      : Colors.white70,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  constraints: const BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 28,
                                  ),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.favorite_border,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                if (_totalPages > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentPage > 1
                            ? () {
                                setState(() => _currentPage--);
                                _fetchProducts();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trang $_currentPage / $_totalPages',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _currentPage < _totalPages
                            ? () {
                                setState(() => _currentPage++);
                                _fetchProducts();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });

            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Cart()),
              ).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            }

            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Setting()),
              ).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_applications_outlined),
              selectedIcon: Icon(Icons.settings_applications),
              label: 'Setting',
            ),
          ],
        ),
      ),
    );
  }
}

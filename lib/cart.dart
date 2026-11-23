import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'iPhone 15 Pro Max',
      'description': '256GB - Titan tự nhiên',
      'price': 27990000,
      'quantity': 1,
    },
    {
      'name': 'MacBook Pro M3',
      'description': 'RAM 16GB - SSD 512GB',
      'price': 38990000,
      'quantity': 1,
    },
  ];

  int get _counter =>
      _products.fold(0, (sum, item) => sum + (item['quantity'] as int));

  int get _subtotal => _products.fold(
    0,
    (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int),
  );

  int get _shipping => _subtotal > 0 ? 30000 : 0;

  int get _total => _subtotal + _shipping;

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ';
  }

  void _changeQuantity(int index, int value) {
    setState(() {
      int quantity = _products[index]['quantity'] as int;

      if (quantity + value >= 1) {
        _products[index]['quantity'] = quantity + value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Giỏ hàng ($_counter)',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A26) : Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _products.isEmpty
                ? const Center(
                    child: Text(
                      'Giỏ hàng trống',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> product = _products[index];

                      return Dismissible(
                        key: ValueKey(product['name']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Xác nhận xóa'),
                                    content: Text(
                                      'Bạn có chắc chắn muốn xóa ${product['name']} khỏi giỏ hàng không?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                        child: const Text(
                                          'Hủy',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Xóa'),
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;
                        },
                        onDismissed: (direction) {
                          final removedName = product['name'] as String;

                          setState(() {
                            _products.removeAt(index);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã xóa $removedName')),
                          );
                        },

                        child: Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 85,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF282836)
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.image_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        product['description'] as String,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              formatPrice(
                                                product['price'] as int,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 32,
                                                      minHeight: 32,
                                                    ),
                                                padding: EdgeInsets.zero,
                                                onPressed: () =>
                                                    _changeQuantity(index, -1),
                                                icon: Icon(
                                                  Icons.remove_circle_outline,
                                                  color: primaryColor,
                                                  size: 20,
                                                ),
                                              ),
                                              Text('${product['quantity']}'),
                                              IconButton(
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 32,
                                                      minHeight: 32,
                                                    ),
                                                padding: EdgeInsets.zero,
                                                onPressed: () =>
                                                    _changeQuantity(index, 1),
                                                icon: Icon(
                                                  Icons.add_circle_outline,
                                                  color: primaryColor,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Chi tiết thanh toán',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                _priceRow(context, 'Tạm tính', _subtotal),
                _priceRow(context, 'Phí vận chuyển', _shipping),
                const Divider(height: 20),
                _priceRow(context, 'Tổng cộng', _total, isTotal: true),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _products.isEmpty
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã thanh toán !')),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'THANH TOÁN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(BuildContext context, String title, int price, {bool isTotal = false}) {
    final textColor = isTotal
        ? Colors.red
        : (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            formatPrice(price),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

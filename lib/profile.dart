import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shop_easy/login.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));

  String? _avatarUrl;
  String _fullName = '';
  String _username = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
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

      final data = response.data;
      setState(() {
        _avatarUrl = data['image'];
        _fullName = '${data['firstName']} ${data['lastName']}';
        _username = '@${data['username']}';
      });
    } catch (e) {
      debugPrint('Lỗi lấy thông tin profile: $e');
    }
  }

  String getURLBackground() {
    return 'https://plus.unsplash.com/premium_photo-1692731797626-fa37b7fbfd91?q=80&w=1171&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            block1(context),
            const SizedBox(height: 55),
            block2(),
            const SizedBox(height: 4),
            block3(),
            const SizedBox(height: 20),
            block4(context),
            const SizedBox(height: 20),
            block5(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget block1(BuildContext context) {
    const double coverHeight = 200.0;
    const double avatarRadius = 50.0;
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: double.infinity,
          height: coverHeight,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(getURLBackground()),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: topPadding + 8,
          left: 12,
          child: CircleAvatar(
            backgroundColor: Colors.black45,
            radius: 18,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        Positioned(
          bottom: -avatarRadius,
          child: CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: CircleAvatar(
              radius: avatarRadius - 4,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
                  _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
              child: _avatarUrl == null
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget block2() {
    return Text(
      _fullName,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget block3() {
    return Text(
      _username,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    );
  }

  Widget block4(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(context, 'Bài viết', '120'),
        _buildStatItem(context, 'Người theo dõi', '1.5k'),
        _buildStatItem(context, 'Đang theo dõi', '350'),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget block5(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Theo dõi'),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Nhắn tin'),
        ),
      ],
    );
  }
}
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/database/app_database.dart';
import 'list_restaurant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamController<int> selected = StreamController<int>();

  @override
  void dispose() {
    selected.close();
    super.dispose();
  }

  // --- HÀM CHỈ ĐƯỜNG THÔNG MINH ---
  Future<void> _openMap(Restaurant res) async {
    String query = "";
    if (res.latitude != null && res.longitude != null) {
      query = "${res.latitude},${res.longitude}";
    } else if (res.address != null && res.address!.isNotEmpty) {
      query = res.address!;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quán này không có thông tin vị trí!")),
      );
      return;
    }

    // Link Universal của Google Maps
    final Uri googleUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );

    try {
      if (!await launchUrl(googleUrl, mode: LaunchMode.externalApplication)) {
        await launchUrl(googleUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      print("Lỗi mở map: $e");
    }
  }

  // --- HÀM HIỆN KẾT QUẢ (UI XỊN) ---
  void _showResult(Restaurant winner) {
    // Ảnh mặc định nếu không có link
    const defaultImage =
        "https://images.unsplash.com/photo-1546069901-ba9599a7e63c";
    final imageUrl = (winner.imageUrl != null && winner.imageUrl!.isNotEmpty)
        ? winner.imageUrl!
        : defaultImage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Triển thôi bạn ơi!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    winner.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    winner.address ?? winner.description ?? "Chưa có địa chỉ",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF27AE60),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _openMap(winner),
                          icon: const Icon(Icons.map_outlined, size: 20),
                          label: const Text("Chỉ đường"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE74C3C),
                            side: const BorderSide(
                              color: Color(0xFFE74C3C),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.favorite, size: 20),
                          label: const Text("Yêu thích"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Quay lại cái khác",
                      style: TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Trang trí icon
            Positioned(
              top: -20,
              left: -10,
              child: Icon(
                Icons.celebration,
                size: 50,
                color: Colors.orange.withOpacity(0.8),
              ),
            ),
            Positioned(
              bottom: -20,
              right: -10,
              child: Icon(
                Icons.fastfood,
                size: 50,
                color: Colors.blue.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hôm Nay Ăn Gì?"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ListRestaurantScreen()),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: database.getAllRestaurants(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.no_food, size: 80, color: Colors.grey),
                  const Text("Chưa có quán nào để quay!"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ListRestaurantScreen(),
                        ),
                      );
                      setState(() {});
                    },
                    child: const Text("Thêm quán ngay"),
                  ),
                ],
              ),
            );
          }
          final wheelItems = items.length == 1 ? [...items, ...items] : items;

          return Column(
            children: [
              const SizedBox(height: 50),
              const Text(
                "Đang thèm gì thì quay đi!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FortuneWheel(
                    selected: selected.stream,
                    items: [
                      for (var it in wheelItems)
                        FortuneItem(
                          child: Text(
                            it.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: FortuneItemStyle(
                            color:
                                Colors.primaries[wheelItems.indexOf(it) %
                                    Colors.primaries.length],
                            borderColor: Colors.white,
                            borderWidth: 3,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    final index = Random().nextInt(wheelItems.length);
                    selected.add(index);
                    Future.delayed(const Duration(seconds: 5), () {
                      _showResult(wheelItems[index]);
                    });
                  },
                  child: const Text(
                    "QUAY NGAY",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          );
        },
      ),
    );
  }
}

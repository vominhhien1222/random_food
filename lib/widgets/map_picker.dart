import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart'; // Để xử lý tọa độ

class MapPicker extends StatefulWidget {
  const MapPicker({super.key});

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  // Controller để điều khiển bản đồ
  final MapController _mapController = MapController();

  // Tọa độ mặc định (Ví dụ: Hồ Con Rùa, TP.HCM)
  // Bạn có thể đổi thành tọa độ khu vực bạn sống
  LatLng _currentCenter = const LatLng(10.7828, 106.6958);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chọn vị trí quán")),
      body: Stack(
        children: [
          // 1. Lớp bản đồ nền
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 15.0,
              // Khi lướt bản đồ, cập nhật tọa độ tâm
              onPositionChanged: (camera, hasGesture) {
                _currentCenter = camera.center;
              },
            ),
            children: [
              // Thay thế đoạn TileLayer cũ bằng đoạn này:
              TileLayer(
                // Dùng link bản đồ CartoDB (Đẹp, nhẹ, miễn phí và KHÔNG bị chặn)
                urlTemplate:
                    'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',

                // Khai báo các server con để load nhanh hơn
                subdomains: const ['a', 'b', 'c'],

                // Đặt tên package cho đúng chuẩn
                userAgentPackageName: 'com.example.random_food',
              ),
            ],
          ),

          // 2. Cái ghim cố định ở giữa (LUÔN NẰM TRÊN BẢN ĐỒ)
          const Center(
            child: Icon(Icons.location_on, color: Colors.red, size: 40),
          ),

          // 3. Nút xác nhận
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                // Trả tọa độ về màn hình trước
                Navigator.pop(context, _currentCenter);
              },
              child: const Text(
                "Lấy vị trí này",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

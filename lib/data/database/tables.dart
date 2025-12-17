import 'package:drift/drift.dart';

// Định nghĩa bảng 'Restaurants'
class Restaurants extends Table {
  // ID tự tăng (1, 2, 3...)
  IntColumn get id => integer().autoIncrement()();

  // Tên quán (bắt buộc)
  TextColumn get name => text()();

  // Mô tả (có thể bỏ trống - nullable)
  TextColumn get description => text().nullable()();

  // Tọa độ (có thể bỏ trống)
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
}

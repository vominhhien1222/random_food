import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import file bảng vừa tạo
import 'tables.dart';

// Dòng này báo cho máy biết file code sinh ra sẽ tên là gì
part 'app_database.g.dart';

@DriftDatabase(tables: [Restaurants])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- CÁC HÀM TRUY VẤN (QUERIES) ---

  // 1. Lấy danh sách tất cả quán
  Future<List<Restaurant>> getAllRestaurants() => select(restaurants).get();

  // 2. Thêm quán mới
  Future<int> insertRestaurant(RestaurantsCompanion entry) =>
      into(restaurants).insert(entry);

  // 3. Xóa quán theo ID
  Future<int> deleteRestaurant(int id) =>
      (delete(restaurants)..where((tbl) => tbl.id.equals(id))).go();
}

// Hàm kết nối tới file trong máy điện thoại
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    // File database sẽ tên là 'db_food.sqlite'
    final file = File(p.join(dbFolder.path, 'db_food.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

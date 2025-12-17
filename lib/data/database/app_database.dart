import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Restaurants])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- CÁC HÀM TRUY VẤN (QUERIES) ---

  // 1. Lấy danh sách (Chỉ 1 lần)
  Future<List<Restaurant>> getAllRestaurants() => select(restaurants).get();

  // 2. THEO DÕI DANH SÁCH (Tự động cập nhật - Realtime) -> Dùng cái này cho UI
  Stream<List<Restaurant>> watchAllRestaurants() => select(restaurants).watch();

  // 3. Thêm quán mới
  Future<int> insertRestaurant(RestaurantsCompanion entry) =>
      into(restaurants).insert(entry);

  // 4. Xóa quán theo ID
  Future<int> deleteRestaurant(int id) =>
      (delete(restaurants)..where((tbl) => tbl.id.equals(id))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db_food.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

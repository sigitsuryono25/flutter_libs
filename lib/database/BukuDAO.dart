import 'package:floor/floor.dart';

import 'model/Buku.dart';

@dao
abstract class BukuDAO {
  @insert
  Future<List<int>> insertBuku(List<Buku> buku);

  @Query("SELECT * FROM tb_buku")
  Future<List<Buku>> getAllBuku();

  @Query("DELETE FROM tb_buku WHERE id = (:id)")
  Future<void> deleteBuku(String id);
}

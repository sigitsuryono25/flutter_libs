import 'package:floor/floor.dart';

@Entity(tableName: "tb_buku")
class Buku {

  @PrimaryKey(autoGenerate: true)
  int? id;

  @ColumnInfo(name: "name")
  String? name;

  @ColumnInfo(name: "pengarang")
  String? pengarang;

  @ColumnInfo(name: "penerbit")
  String? penerbit;

  @ColumnInfo(name: "tahun_terbit")
  int? tahunTerbit;

  Buku({this.id, this.name, this.pengarang, this.penerbit, this.tahunTerbit});

  Buku.NoId(this.name, this.pengarang, this.penerbit, this.tahunTerbit);


}
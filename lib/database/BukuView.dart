import 'package:flutter/material.dart';
import 'package:flutter_libs/database/AppDatabase.dart';
import 'package:flutter_libs/database/DaftarBuku.dart';

import 'model/Buku.dart';

void main() {
  runApp(BukuViewApp());
}

class BukuViewApp extends StatelessWidget {
  const BukuViewApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Bukuview(),
      theme: ThemeData(primarySwatch: Colors.purple),
    );
  }
}

class Bukuview extends StatefulWidget {
  const Bukuview({Key? key, this.buku}) : super(key: key);
  final Buku? buku;

  @override
  _BukuviewState createState() => _BukuviewState();
}

class _BukuviewState extends State<Bukuview> {
  TextEditingController _judulController = new TextEditingController();
  TextEditingController _pengarangController = new TextEditingController();
  TextEditingController _penerbitController = new TextEditingController();
  TextEditingController _tahunTerbitController = new TextEditingController();

  var database;
  var title = "Tambah Buku";
  var isVisible = true;
  var id;

  @override
  void initState() {
    super.initState();
    initializeDb();
    if (widget.buku != null) {
      setToView(widget.buku!);
    }
  }

  Future<void> initializeDb() async {
    database = await $FloorAppDatabase.databaseBuilder("db_buku.db").build();
  }

  void getData() async {
    Buku b;
    if (id == null) {
      b = Buku.NoId(
          _judulController.text.toString(),
          _pengarangController.text.toString(),
          _penerbitController.text.toString(),
          int.parse(_tahunTerbitController.text.toString()));
    } else {
      b = Buku(
          id: id,
          name: _judulController.text.toString(),
          pengarang: _pengarangController.text.toString(),
          penerbit: _penerbitController.text.toString(),
          tahunTerbit: int.parse(_tahunTerbitController.text.toString()));
    }
    var status = await this.addBuku(b);
    if (status.first > 0) {
      var snackbar = SnackBar(
        content: Text("Buku berhasil ditambahkan"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<List<int>> addBuku(Buku buku) async {
    return await database.bukuDao.insertBuku([buku]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Judul Buku"),
            TextField(
              controller: _judulController,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text("Pengarang"),
            TextField(
              controller: _pengarangController,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text("Penerbit"),
            TextField(
              controller: _penerbitController,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text("Tahun Terbit"),
            TextField(
              controller: _tahunTerbitController,
            ),
            SizedBox(
              height: 20,
            ),
            Visibility(
              visible: isVisible,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DaftarBuku(
                              database: database,
                            )));
                  },
                  child: Text("Lihat Data")),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.amber,
        onPressed: () => {getData(), resetForm()},
      ),
    );
  }

  void resetForm() {
    setState(() {
      _judulController.text = "";
      _tahunTerbitController.text = "";
      _pengarangController.text = "";
      _penerbitController.text = "";
    });
  }

  void setToView(Buku buku) {
    setState(() {
      title = "Edit Data Buku";
      this.id = buku.id;
      print(this.id);
      isVisible = false;
      _judulController.text = buku.name!;
      _tahunTerbitController.text = buku.tahunTerbit.toString();
      _pengarangController.text = buku.pengarang!;
      _penerbitController.text = buku.penerbit!;
    });
  }
}

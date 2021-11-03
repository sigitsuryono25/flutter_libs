import 'package:flutter/material.dart';
import 'package:flutter_libs/LifecycleEventHandler.dart';
import 'package:flutter_libs/database/AppDatabase.dart';
import 'package:flutter_libs/database/BukuView.dart';
import 'package:flutter_libs/database/model/Buku.dart';

class DaftarBuku extends StatefulWidget {
  const DaftarBuku({Key? key, required this.database}) : super(key: key);
  final AppDatabase database;

  @override
  _DaftarBukuState createState() => _DaftarBukuState();
}

class _DaftarBukuState extends State<DaftarBuku> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(LifecycleEventHandler(
        resumeCallBack: () async => {refreshData()},
        suspendingCallBack: () async => {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daftar Buku"),
      ),
      body: buildFuture(),
    );
  }

  Widget buildFuture() {
    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot<List<Buku>?> data) {
        if (data.hasData) {
          return listViewBuilder(data);
        } else {
          print(data.error);
          return CircularProgressIndicator();
        }
      },
      future: getAllBuku(widget.database),
    );
  }

  Future<List<Buku>?> getAllBuku(AppDatabase database) async {
    return await database.bukuDao.getAllBuku();
  }

  getData(Buku? buku, BuildContext context) {
    var al = AlertDialog(
      title: Text("Konfirmasi"),
      content: Text("Pilih tindakan selanjutnya"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              hapusData(buku).then((value) => {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Berhasil di hapus"))),
                    refreshData()
                  });
            },
            child: Text("Hapus Data")),
        TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('dialog');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return Bukuview(
                      buku: buku,
                    );
                  },
                ),
              );
            },
            child: Text("Ubah Data")),
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return al;
        });
  }

  void refreshData() {
    setState(() {
      buildFuture();
    });
  }

  Widget listViewBuilder(AsyncSnapshot<List<Buku>?> data) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => {getData(data.data![index], context)},
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.data![index].name!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(data.data![index].penerbit!),
                    Icon(Icons.adjust),
                    Text(data.data![index].pengarang!),
                    Icon(Icons.adjust),
                    Text(data.data![index].tahunTerbit.toString()),
                  ],
                )
              ],
            ),
          ),
        );
      },
      itemCount: data.data?.length,
    );
  }

  Future<void> hapusData(Buku? buku) async {
    return await widget.database.bukuDao.deleteBuku(buku!.id.toString());
  }
}

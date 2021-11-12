import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(StorageInfoScreen());
}

class StorageInfoScreen extends StatelessWidget {
  const StorageInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StorageInfo(),
      theme: ThemeData.dark(),
    );
  }
}

class StorageInfo extends StatefulWidget {
  const StorageInfo({Key? key}) : super(key: key);

  @override
  _StorageInfoState createState() => _StorageInfoState();
}

class _StorageInfoState extends State<StorageInfo> {
  String? _storageInfo = "";

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory()
        .then((value) => updateUi(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("External Directory"),
      ),
      body: Center(
        child: Text(_storageInfo!),
      ),
    );
  }

  updateUi(Directory? value) {
    setState(() {
      _storageInfo = value?.absolute.path.toString();
    });
  }
}

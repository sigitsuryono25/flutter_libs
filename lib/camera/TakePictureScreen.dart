import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:flutter_libs/locations/GpsTracker.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front);

  runApp(MaterialApp(
    home: TakePictureScreen(
      camera: firstCamera,
    ),
    theme: ThemeData(primarySwatch: Colors.brown),
  ));
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);
  final CameraDescription camera;

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Widget body = Center(
    child: const CircularProgressIndicator(),
  );

  @override
  void initState() {
    super.initState();
    initializePermission();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Camera Handling"),
      ),
      body: body,
      floatingActionButton: takeAPicture(),
    );
  }

  Widget takeAPicture() {
    return FloatingActionButton(
      onPressed: () async {
        try {
          //wait until the camera is initialized
          await _initializeControllerFuture;
          //attempt to take a picture and get the file `image` where it was saved
          final image = await _controller.takePicture();
          var directory = "/storage/emulated/0/FlutterLibs/";
          var milis, path;
          milis = DateTime.now().millisecond;
          path = "$directory/$milis.jpg";
          new Directory(directory).create().then((value) => getExifInfo(path, image));
        } catch (e) {
          print(e);
        }
      },
      child: Icon(Icons.camera),
    );
  }

  Widget cameraBuidler() {
    _controller = CameraController(
        // get a specify camera
        widget.camera,
        //define a resolution to use
        ResolutionPreset.ultraHigh);

    //initialize controller
    _initializeControllerFuture = _controller.initialize();

    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_controller);
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
      future: _initializeControllerFuture,
    );
  }

  getExifInfo(path, XFile image) async {
    image.saveTo(path);
    final exif = FlutterExif.fromPath(path);
    GPSTracker().getLocation().then((value) => {
          if (value != null)
            {
              exif.setLatLong(value.latitude!, value.longitude!),
              exif.saveAttributes()
            }
        });
  }

  Future<void> initializePermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.accessMediaLocation,
      Permission.manageExternalStorage,
      Permission.storage,
      Permission.camera,
      Permission.microphone,
    ].request().then((value) => initializeBody(value));
    print(statuses.entries);
  }

  initializeBody(Map<Permission, PermissionStatus> result) {
    setState(() {
      this.body = cameraBuidler();
    });
  }
}

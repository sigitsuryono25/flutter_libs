import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:flutter_libs/locations/GpsTracker.dart';
import 'package:path_provider/path_provider.dart';
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
          var directory = getApplicationDocumentsDirectory();
          var milis, path, exif;

          directory.then((value) => {
                milis = DateTime.now().millisecond,
                path = "${value.path}/${milis}.jpg",
                image.saveTo(path),
                getExifInfo(path)
              });
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

  getExifInfo(path) async {
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
      Permission.storage,
    ].request().then((value) => initializeBody());
    print(statuses.entries);
  }

  initializeBody() {
    setState(() {
      this.body = cameraBuidler();
    });
  }
}

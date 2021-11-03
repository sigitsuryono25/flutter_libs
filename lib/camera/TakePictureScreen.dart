import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

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

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
        // get a specify camera
        widget.camera,
        //define a resolution to use
        ResolutionPreset.medium);

    //initialize controller
    _initializeControllerFuture = _controller.initialize();
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
      body: cameraBuidler(),
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
          var directory = getExternalStorageDirectory();
          var milis, path, exif;

          directory.then((value) => {
            milis = DateTime.now().millisecond,
            path = "${value!.path}/${milis}.jpg",
            image.saveTo(path),
            getExifInfo(path)
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("saved path")));
        } catch (e) {
          print(e);
        }
      },
      child: Icon(Icons.camera),
    );
  }

  Widget cameraBuidler() {
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

  getExifInfo(path) {
    final exif = FlutterExif.fromPath(path);
    exif.setLatLong(-7.7607095, 110.4121785);
// apply attributes
    exif.saveAttributes();
  }
}

import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera_overlay/flutter_camera_overlay.dart';
import 'package:flutter_camera_overlay/model.dart';
import 'package:permission_handler/permission_handler.dart';

class ExampleCameraOverlay extends StatefulWidget {
  const ExampleCameraOverlay({Key? key}) : super(key: key);

  @override
  ExampleCameraOverlayState createState() => ExampleCameraOverlayState();
}

class ExampleCameraOverlayState extends State<ExampleCameraOverlay> {
  OverlayFormat format = OverlayFormat.cardID3;

  @override
  void initState() {
    getCameraPermission();
    super.initState();
  }

  void getCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      print("Permission is denined.");
    } else if (status.isGranted) {
      //permission is already granted.
      print("Permission is already granted.");
    } else if (status.isPermanentlyDenied) {
      //permission is permanently denied.
      print("Permission is permanently denied");
    } else if (status.isRestricted) {
      //permission is OS restricted.
      print("Permission is OS restricted.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<CameraDescription>?>(
        future: availableCameras(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null) {
              return const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'No camera found',
                    style: TextStyle(color: Colors.black),
                  ));
            }
            return CameraOverlay(
                snapshot.data!.last, CardOverlay.byFormat(format),
                (XFile file) async {
              Uint8List fileImage = await file.readAsBytes();
              showDialog(
                context: context,
                barrierColor: Colors.black,
                builder: (context) {
                  CardOverlay overlay = CardOverlay.byFormat(format);
                  return AlertDialog(
                    actionsAlignment: MainAxisAlignment.center,
                    backgroundColor: Colors.black,
                    title: const Text('Capture',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center),
                    actions: [
                      OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close))
                    ],
                    content: SizedBox(
                      width: double.infinity,
                      child: AspectRatio(
                        aspectRatio: overlay.ratio!,
                        child: SizedBox(
                          child: Image.memory(fileImage, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
                info:
                    'Position your ID card within the rectangle and ensure the image is perfectly readable.',
                label: 'Scanning ID Card');
          } else {
            return const Align(
                alignment: Alignment.center,
                child: Text(
                  'Fetching cameras',
                  style: TextStyle(color: Colors.black),
                ));
          }
        },
      ),
    ));
  }
}

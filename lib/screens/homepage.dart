import 'package:attendit/apis.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  APIs apis = APIs();
  String? rollNumber = " ";
  String? name = "";
  late Position userLocation;
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? barcode;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString("rollno");
    String? value2 = prefs.getString("name");
    setState(() {
      rollNumber = value;
      name = value2;
    });
    userLocation = await _determinePosition();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        buildQrView(context),
      ],
    ));
  }

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQrViewCreated,
        overlay: QrScannerOverlayShape(
          borderLength: 30,
          borderWidth: 10,
          borderRadius: 10,
          borderColor: Colors.blue,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      );

  void onQrViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);
    controller.scannedDataStream.first.then((value) => {
          if (value.code != null)
            {
              apiCall(value),
            },
        });
  }

  void apiCall(Barcode link) async {
    try {
      apis.splitter(link.code).forEach((element) {
        print(element);
      });
      int attendanceStatus = 1;
      print("Trying attendance");
      if (apis.splitter(link.code).length == 6) {
        attendanceStatus =
            await apis.markOnlineAttendance(link.code, rollNumber, name);
      } else {
        attendanceStatus = await apis.markOfflineAttendance(
            userLocation, link.code, rollNumber, name);
      }
      print("Attendace status: $attendanceStatus");
      if (attendanceStatus == 0) {
        // alert dialog success
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Success"),
                content: Text("Attendance marked successfully"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      } else if (attendanceStatus == 100) {
        // alert error "Too far from class"
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text("You are too far from class to mark attendance!"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      } else if (attendanceStatus == 101) {
        // alert error "Too far from class"
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Error"),
                content: Text("You are too late for attendance!"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
      }
    } catch (e) {
      print("ERROR");
      print(e);
    }
  }
}

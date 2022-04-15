import 'package:attendit/apis.dart';
import 'package:attendit/constant.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

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

  void showBottomModal(status, arr, notifyParent) async {
    final result = await showSlidingBottomSheet(context, builder: (context1) {
      return SlidingSheetDialog(
          elevation: 8,
          cornerRadius: 16,
          footerBuilder: (context1, state) {
            return Material(
              child: GestureDetector(
                onTap: () {
                  status == 0 ? notifyParent() : "maa chuda";
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.07,
                  margin:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  decoration: BoxDecoration(
                      color: status == 0 ? blue : Colors.red,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: Center(
                    child: Text(
                      //switch with three parameteres
                      status == 0
                          ? "Mark Another attendance"
                          : status == 100
                              ? "Too Far From Class"
                              : "Too Late for attendance",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: whiteshade),
                    ),
                  ),
                ),
              ),
            );
          },
          snapSpec: const SnapSpec(
            snap: true,
            snappings: [0.4, 0.7, 1.0],
            positioning: SnapPositioning.relativeToAvailableSpace,
          ),
          builder: (context1, state) {
            return Material(
              child: Container(
                  padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    children: [
                      Text("Your Attendance for" + " " + arr[3],
                          style: GoogleFonts.roboto(
                              textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold))),
                      Row(
                        children: [
                          Text("of" + " " + arr[2] + " " + arr[1],
                              style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ))),
                        ],
                      ),
                      Center(
                        child: Text(
                          //switch with three parameteres
                          status == 0
                              ? "Attendance Marked Successfully"
                              : status == 100
                                  ? "Attendace Marked Successfully"
                                  : "Attendace Not Marked",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  )),
            );
          });
    });
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

  notifyparent() {
    setState(() {});
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
      showBottomModal(attendanceStatus, apis.splitter(link.code), notifyparent);

      print("Attendace status: $attendanceStatus");
    } catch (e) {
      print("ERROR");
      print(e);
    }
  }
}

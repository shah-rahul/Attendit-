import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'fingerprint_api.dart';
import 'homepage.dart';
import 'dart:developer' as developer;
class fingerPrintPage extends StatefulWidget {
  const fingerPrintPage({Key? key}) : super(key: key);

  @override
  _fingerPrintPageState createState() => _fingerPrintPageState();
}

class _fingerPrintPageState extends State<fingerPrintPage> { 
  var errorMsg = "";
  @override
  initState() {
    LocalAuthApi.authenticate().then((isAuthenticated) {
      if (isAuthenticated) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        setState(() {
          errorMsg = "Fingerprint is required to continue!";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attend-it")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () async {
                  developer.log("YI");
                  final isAuthenticated = await LocalAuthApi.authenticate();
                  if (isAuthenticated) {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => HomePage()));
                  }
                },
                child: Image(image: errorMsg=="" ? AssetImage("lib/assets/fingerprint_waiting.png") : AssetImage("lib/assets/fingerprint_fail.png"))),
            
            errorMsg == ""
                ? SizedBox()
                : Text(errorMsg,
                    style: GoogleFonts.roboto(
                        textStyle: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold))),
            SizedBox(height:30),
            errorMsg==""
            ? SizedBox()
            : TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.all(14), backgroundColor: Color(0xff00b9f1), primary: Colors.white, onSurface: Colors.red),
              onPressed: (){
                setState(() {
                  errorMsg="";
                });
LocalAuthApi.authenticate().then((isAuthenticated) {
      if (isAuthenticated) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        setState(() {
          errorMsg = "Fingerprint is required to continue!";
        });
      }
    });
            }, child: Text("Try again")),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
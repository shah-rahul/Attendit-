import 'package:attendit/screens/homepage.dart';
import 'package:attendit/screens/signupPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/fingerPrintPage.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
bool isRegistered = false;
  loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isRegisterd") == null) {
      prefs.setBool("isRegisterd", false);
    }
    setState(() {
      isRegistered = prefs.getBool("isRegisterd")!;
    });
  }
  // This widget is the root of your application.
  @override
  void initState() {
    // TODO: implement initState
    loadData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),  
      home: isRegistered ? fingerPrintPage() : Signup(),
    );
  }
}
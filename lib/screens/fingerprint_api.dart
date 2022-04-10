import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:developer' as developer;

class LocalAuthApi {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      developer.log("yi");
      return false;
    }
  }

  static Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) return false;

    try {
      return await _auth.authenticate(
          localizedReason: ' ',
          useErrorDialogs: true,
          biometricOnly: false,
          stickyAuth: true,
          androidAuthStrings: AndroidAuthMessages(
              biometricHint: "Verify your fingerprint to continue.",
              biometricSuccess: "Identity verified."));
    } on PlatformException catch (e) {
      return (false);
    }
  }
}

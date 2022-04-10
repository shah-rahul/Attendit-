import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ntp/ntp.dart';

final database = FirebaseDatabase.instance.ref();

class APIs {
  List<String> splitter(string) {
    var arr = string.split("/");
    return arr;
  }

  Future<bool> tellDiff(providedDate) async {
    DateTime _curr;
    DateTime _providedDate;
    _curr = await NTP.now();
    _providedDate = DateTime.fromMillisecondsSinceEpoch(providedDate);
    int scanTime = _curr.difference(_providedDate).inSeconds;
    if (scanTime <= 60) {
      return true;
    }
    return false;
  }

  bool tellDistance(Position pos, lat, lng) {
    print(pos.latitude);
    print(pos.longitude);
    var distance =
        Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, lng);
    if (distance <= 150) {
      return true;
    }
    return false;
  }

  void markOfflineAttendance(Position pos, str, rollNumber, name) async {
    print('offline attendance called');
    List<String> arr = splitter(str);
    int counter = 0;
    if (tellDistance(pos, double.parse(arr[5]), double.parse(arr[6]))) {
    await database
        .child('attend-it')
        .child(arr[0])
        .child('attendance')
        .child(arr[1])
        .child(arr[2])
        .child(arr[3])
        .child(arr[4])
        .child(rollNumber)
        .get()
        .then((value) {
      if (value.value == null) {
        counter = 1;
      } else {
        var data = value.value as Map;
        if (data['counter'] == null || data['counter'] == 0) {
          counter = 1;
        } else {
          counter = data['counter'];
        }
      }
    });
    database
        .child('attend-it')
        .child(arr[0])
        .child('attendance')
        .child(arr[1])
        .child(arr[2])
        .child(arr[3])
        .child(arr[4])
        .child(rollNumber)
        .set({
      "counter": counter + 1,
      "rollno": rollNumber,
      "name": name,
    });
    }
  }

  void markOnlineAttendance(str, rollNumber, name) async {
    print("called");
    var arr = splitter(str);
    int counter = 0;
    // if (await tellDiff(int.parse(arr[4]))) {
    await database
        .child('attend-it')
        .child(arr[0])
        .child('attendance')
        .child(arr[1])
        .child(arr[2])
        .child(arr[3])
        .child(arr[4])
        .child(rollNumber)
        .get()
        .then((value) {
      if (value.value == null) {
        counter = 1;
      } else {
        var data = value.value as Map;
        if (data['counter'] == null || data['counter'] == 0) {
          counter = 1;
        } else {
          counter = data['counter'];
        }
      }
    });
    database
        .child('attend-it')
        .child(arr[0])
        .child('attendance')
        .child(arr[1])
        .child(arr[2])
        .child(arr[3])
        .child(arr[4])
        .child(rollNumber)
        .set({
      "counter": counter + 1,
      "rollno": rollNumber,
      "name": name,
    });
    // }
  }
}

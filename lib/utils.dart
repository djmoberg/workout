import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

String covertTime(int time) {
  Duration d = Duration(milliseconds: time);
  double s = (time / 1000) % 60;
  // double m = (time / (1000 * 60)) % 60;
  return "${d.inMinutes} min, ${s.toStringAsFixed(0)} sec";
}

int totalTime(List<dynamic> list) {
  int total = 0;
  list.forEach((value) {
    total = total + value['time'];
  });
  return total;
}

String totalTimeString(List<dynamic> list) {
  return covertTime(totalTime(list));
}

String formatTime(int time) {
  DateTime dt = DateTime.fromMillisecondsSinceEpoch(time);
  // String h = (dt.hour - 1) < 10 ? "0${(dt.hour - 1)}" : "${(dt.hour - 1)}";
  String m = dt.minute < 10 ? "0${dt.minute}" : "${dt.minute}";
  String s = dt.second < 10 ? "0${dt.second}" : "${dt.second}";

  return "$m:$s";
}

Future<DocumentSnapshot> getExercise(id, uid) async {
  DocumentSnapshot snap = await Firestore.instance
      .collection('users')
      .document(uid)
      .collection('exercises')
      .document(id)
      .get();
  return snap;
}

// Future<int> workoutTime(List<dynamic> exercises, uid) async {
//   int total = 0;
//   exercises.forEach((exercise) async {
//     DocumentSnapshot snap = await getExercise(exercise, uid);
//     total = total + totalTime(snap.data['objects']);
//   });
//   return total;
// }

// Future<String> workoutTimeString(List<dynamic> list, uid) async {
//   int time = await workoutTime(list, uid);
//   return covertTime(time);
// }

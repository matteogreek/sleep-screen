import 'dart:async';

import 'package:device_policy_manager/device_policy_manager.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      home: Sleeptimer(),
    ));

class Sleeptimer extends StatefulWidget {
  @override
  State<Sleeptimer> createState() => _SleeptimerState();
}

class _SleeptimerState extends State<Sleeptimer> {
  Timer? timer;
  Duration? showtime = Duration(minutes: 10);
  late int showtimeInSeconds = showtime!.inSeconds;

  Future<void> startTimer() async {
    if (!await requestPermissions()) {
      showAlertDialog(context);
    } else {
      timer = Timer.periodic(Duration(seconds: 1), (_) async {
        if (showtimeInSeconds > 0) {
          setState(() {
            showtimeInSeconds--;
          });
        } else {
          stopTimer();
          await DevicePolicyManager.lockNow();
        }
      });
    }
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      showtimeInSeconds =
          showtime!.inSeconds; //sistema riportalo al max in secondi
    });
  }

  String getDuration(int totalSeconds) {
    String seconds = (totalSeconds % 60).toInt().toString().padLeft(2, '0');
    String minutes =
        ((totalSeconds / 60) % 60).toInt().toString().padLeft(2, '0');
    String hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    return "$hours\:$minutes\:$seconds";
  }

  Future<bool> requestPermissions() async {
    /// Return `true` if the given administrator component is currently active (enabled) in the system.
    bool permissionGranted = await DevicePolicyManager.isPermissionGranted();
    if (!permissionGranted) {
      permissionGranted = await DevicePolicyManager.requestPermession(
          "Your app is requesting the Adminstration permission");
    }
    return permissionGranted;
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Required permissions not granted"),
      content: Text("Please give required permissions"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            createTimer(),
            manageButtons(),
            timePickerButton(),
          ],
        ),
      ),
    );
  }

  Widget manageButtons() {
    bool isRunning = timer == null ? false : timer!.isActive;
    if (!isRunning || showtimeInSeconds == showtime!.inSeconds) {
      return ElevatedButton(
        child: Text("Start timer", style: TextStyle(fontSize: 20)),
        onPressed: () => startTimer(),
      );
    } else {
      return ElevatedButton(
        child: Icon(Icons.restart_alt),
        onPressed: () => stopTimer(),
      );
    }
  }

  Widget createTimer() {
    return Text(
      getDuration(showtimeInSeconds),
      style: TextStyle(
          color: Colors.white, fontSize: 80, fontWeight: FontWeight.bold),
    );
  }

  Widget timePickerButton() {
    return ElevatedButton(
        onPressed: () async {
          Duration? selectedtime = await showDurationPicker(
              context: context, initialTime: const Duration(minutes: 20));

          if (selectedtime == null) return;

          setState(() {
            showtime = selectedtime;
            showtimeInSeconds = selectedtime.inSeconds;
          });
        },
        child: Text("Select timer", style: TextStyle(fontSize: 20)));
  }
}

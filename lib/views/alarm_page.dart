import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cron/cron.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:medmate/alarm_helper.dart';
import 'package:medmate/constrants/theme_data.dart';
import 'package:medmate/alarm_info.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:medmate/data.dart';
import 'package:medmate/main.dart';
import 'package:medmate/views/WebSocket.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_database/firebase_database.dart';

class AlarmPage extends StatefulWidget {
  static const routeName = '/alarm';
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  DateTime? _alarmTime;
  late String userInput;
  String? _alarmTimeString;
  DateTime? selectedTime;
  AlarmHelper _alarmHelper = AlarmHelper();
  Future<List<AlarmInfo>>? _alarms;
  List<AlarmInfo>? _currentAlarms;
  TextEditingController _textEditingController = TextEditingController();
  var cabin = "1";
  DatabaseReference ref = FirebaseDatabase(
          databaseURL:
              "https://medmate-7b35b-default-rtdb.asia-southeast1.firebasedatabase.app/")
      .ref();
  List<String> _cabinnumbers = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
  ];

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _alarmTime = DateTime.now();
    _alarmHelper.initializeDatabase().then((value) {
      print('------database intialized');
      loadAlarms();
    });
    super.initState();
  }

  void loadAlarms() {
    if (mounted) setState(() {});

    _alarms = _alarmHelper.getAlarms();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Current Alarms',
            style: TextStyle(
                fontFamily: 'Avenir-Book',
                fontWeight: FontWeight.w700,
                color: CustomColors.primaryTextColor,
                fontSize: 24),
          ),
          Expanded(
            child: FutureBuilder<List<AlarmInfo>>(
              future: _alarms,
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  _currentAlarms = snapshot.data;

                  return ListView(
                    children: snapshot.data!.map<Widget>((alarm) {
                      var alarmTime = DateFormat('M/d hh:mm aa')
                          .format(alarm.alarmDateTime!);
                      var gradientColor = GradientTemplate
                          .gradientTemplate[alarm.gradientColorIndex!].colors;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 32),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColor,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: gradientColor.last.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: Offset(4, 4),
                            ),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.label,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Pill Name: " + alarm.title!,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Avenir-Book'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "At cabin number: " + alarm.cabin!,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontFamily: 'Avenir-Book'),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  alarmTime,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Avenir-Book',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.white,
                                    onPressed: () {
                                      deleteAlarm(alarm.id);
                                    }),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).followedBy([
                      if (_currentAlarms!.length < 7)
                        DottedBorder(
                          strokeWidth: 2,
                          color: CustomColors.clockOutline,
                          borderType: BorderType.RRect,
                          radius: Radius.circular(24),
                          dashPattern: [5, 4],
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: CustomColors.clockBG,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24)),
                            ),
                            child: MaterialButton(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              onPressed: () {
                                _alarmTimeString =
                                    DateFormat('HH:mm').format(DateTime.now());
                                showModalBottomSheet(
                                  useRootNavigator: true,
                                  context: context,
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Container(
                                          padding: const EdgeInsets.all(32),
                                          child: Column(
                                            children: [
                                              TextButton(
                                                onPressed: () async {
                                                  var selectedTime =
                                                      await showTimePicker(
                                                    context: context,
                                                    initialTime:
                                                        TimeOfDay.now(),
                                                  );
                                                  if (selectedTime != null) {
                                                    //final now = .DateTime.now();
                                                    final pickedDate =
                                                        await showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
                                                      firstDate: DateTime.now(),
                                                      lastDate: DateTime(2101),
                                                    );
                                                    var selectedDateTime =
                                                        DateTime(
                                                      pickedDate!.year,
                                                      pickedDate.month,
                                                      pickedDate.day,
                                                      selectedTime.hour,
                                                      selectedTime.minute,
                                                    );
                                                    _alarmTime =
                                                        selectedDateTime;
                                                    setModalState(() {
                                                      _alarmTimeString =
                                                          DateFormat('HH:mm')
                                                              .format(
                                                                  selectedDateTime);
                                                    });
                                                  }
                                                },
                                                child: Text(
                                                  _alarmTimeString ?? "",
                                                  style:
                                                      TextStyle(fontSize: 32),
                                                ),
                                              ),
                                              TextButton(
                                                child: Container(),
                                                onPressed: () async {
                                                  final pickedDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime(2101),
                                                  );
                                                  var selectedDateTime =
                                                      DateTime(
                                                          pickedDate!.year,
                                                          pickedDate.month,
                                                          pickedDate.day,
                                                          selectedTime!.hour,
                                                          selectedTime!.minute);
                                                  _alarmTime = selectedDateTime;
                                                  setModalState(() {
                                                    _alarmTimeString =
                                                        DateFormat('yyyy-M-d ')
                                                            .format(
                                                                selectedDateTime);
                                                  });
                                                },
                                              ),
                                              ListTile(
                                                title: TextField(
                                                  controller:
                                                      _textEditingController,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    hintText: 'Enter pill name',
                                                  ),
                                                ),
                                                //    _title=myController.text,
                                                trailing: Icon(
                                                    Icons.arrow_forward_ios),
                                              ),
                                              DropdownButton(
                                                iconDisabledColor: Colors.black,
                                                iconEnabledColor: Colors.black,
                                                hint: Text(
                                                  cabin,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                dropdownColor: Colors.white,
                                                icon: const Icon(
                                                    Icons.keyboard_arrow_down),
                                                items: _cabinnumbers
                                                    .map((String value1) {
                                                  return DropdownMenuItem(
                                                    value: value1,
                                                    child: Text(value1),
                                                  );
                                                }).toList(),
                                                onChanged: (String? value) {
                                                  setState(() {
                                                    cabin = value!;
                                                    /*value:
                                                    _cabin;*/
                                                    //  _cabinsnumbers.remove(value);
                                                    //  print(_cabinsnumbers);
                                                  });
                                                },
                                              ),
                                              SizedBox(width: 16, height: 96),
                                              FloatingActionButton.extended(
                                                onPressed: () {
                                                  if (_currentAlarms!.length <
                                                      7) {
                                                    onSaveAlarm(true);
                                                  }
                                                },
                                                icon: Icon(Icons.alarm),
                                                label: Text('Save'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                                // scheduleAlarm();
                              },
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/add_alarm.png',
                                    scale: 1.5,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add Pill',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Avenir-Book'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Center(
                            child: Text(
                          'Only 7 alarms allowed!',
                          style: TextStyle(color: Colors.white),
                        )),
                    ]).toList(),
                  );
                }
                return Center(
                  child: Text(
                    'Loading..',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void scheduleAlarm(
      DateTime scheduledNotificationDateTime, AlarmInfo alarmInfo,
      {required bool isRepeating}) async {
    print('start varun');
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      channelDescription: 'Channel for Alarm notification',
      icon: 'pill',
      sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
      largeIcon: DrawableResourceAndroidBitmap('pill'),
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    var dateTime = DateTime(
        scheduledNotificationDateTime.year,
        scheduledNotificationDateTime.month,
        scheduledNotificationDateTime.day,
        scheduledNotificationDateTime.hour,
        scheduledNotificationDateTime.minute);
    // DateTime dt = DateTime.now(); //Or whatever DateTime you want

    if (isRepeating) {
      print("repeating");
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Medical Pills',
        alarmInfo.title,
        tz.TZDateTime.from(dateTime, tz.local),
        platformChannelSpecifics,
        // ignore: deprecated_member_use
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        // payload: 'Payload',
      );
    } else
      print("not repeat");
  }

  // void fltimer(DateTime scheduleAlarmDateTime) {
  //   print('varundjskfk');
  //   tz.TZDateTime targetTime = tz.TZDateTime(
  //       tz.local,
  //       scheduleAlarmDateTime.year,
  //       scheduleAlarmDateTime.month,
  //       scheduleAlarmDateTime.day,
  //       scheduleAlarmDateTime.hour,
  //       scheduleAlarmDateTime.minute);
  //   tz.TZDateTime currentTime = tz.TZDateTime.now(tz.local);

  //   if (currentTime.isAfter(targetTime)) {
  //     // Navigate to the desired screen
  //     print('varun');
  //   } else {
  //     // Calculate the duration until the target time
  //     Duration durationUntilTarget = targetTime.difference(currentTime);
  //     // Schedule a timer to navigate to the desired screen when the time is reached
  //     Timer(durationUntilTarget, () {
  //       print('varun');
  //     });
  //   }
  // }

  void onSaveAlarm(bool _isRepeating) {
    DateTime? scheduleAlarmDateTime;
    print(_alarmTime);
    // if (_alarmTime!.isAfter(DateTime.now()))
    // scheduleAlarmDateTime = _alarmTime;
    // else
    // scheduleAlarmDateTime = _alarmTime!.add(Duration(days: 1));
    scheduleAlarmDateTime = _alarmTime;
    if (DateTime.now() == scheduleAlarmDateTime) {
      print('object');
    }
    var alarmInfo = AlarmInfo(
      alarmDateTime: scheduleAlarmDateTime,
      gradientColorIndex: _currentAlarms!.length,
      title: _textEditingController.text,
      cabin: cabin,
      cabinnumber: "1,2,3,4,5,6,7",
    );
    var results = readdata2().then((value) {
      var r1 = value;
      var coun = 0;
      var tempM = "";
      var tempD = "";
      var tempH = "";
      for (int i = 0; i < r1.length; i++) {
        if (r1[i].length > 2) {
          tempM = r1[i].toString().split("_")[1].split("-")[1];
          tempD = r1[i].toString().split("_")[1].split("-")[2].split("T")[0];

          tempH = r1[i]
              .toString()
              .split("_")[1]
              .split("-")[2]
              .split("T")[1]
              .split(":")[0];
        }
        if (r1[i].toString().split("_")[0] == cabin.toString()) {
          if (tempM == scheduleAlarmDateTime.toString().split("-")[1]) {
            if (tempD ==
                scheduleAlarmDateTime
                    .toString()
                    .split("-")[2]
                    .split("T")[0]
                    .split(" ")[0]) {
              if (tempH ==
                  scheduleAlarmDateTime
                      .toString()
                      .split("-")[2]
                      .split("T")[0]
                      .split(" ")[1]
                      .split(":")[0]) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Warning"),
                    content: Text(
                        "You picked the same cabin and time for a different alarm"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("OK"),
                      ),
                    ],
                  ),
                );
                print("alarm found");
                coun = 1;
              }
            }
          }
        }
      }
      if (coun != 1) {
        coun = 0;
        _alarmHelper.insertAlarm(alarmInfo);
        if (scheduleAlarmDateTime != null) {
          // scheduleAlarm(scheduleAlarmDateTime, alarmInfo,
          //     isRepeating: _isRepeating);
        }
        int hour;
        int minutes;
        hour = scheduleAlarmDateTime!.hour;
        minutes = scheduleAlarmDateTime.minute;
        FlutterAlarmClock.createAlarm(
            hour: hour, minutes: minutes, title: _textEditingController.text);
        Navigator.of(context, rootNavigator: true).pop();
        _textEditingController.clear();
        loadAlarms();
        fltimer(scheduleAlarmDateTime);
      }
    });
  }

  void deleteAlarm(int? id) {
    _alarmHelper.delete(id);
    loadAlarms();
  }

  void updateFirebaseData(DateTime scheduleAlarmDateTime) async {
    final cron = Cron();
    cron.schedule(Schedule.parse('* * * * *'), () async {
      // CollectionReference users =
      //     await FirebaseFirestore.instance.collection('client');
      // users
      //     .doc('peSChnRGwcnXaNIob2nA')
      //     .update({'alarm': false})
      //     .then((value) => print('updated'))
      //     .catchError((error) => print(error));
      await ref.onValue.listen((event) {
        final data = event.snapshot.value;
      });
      cron.close();
    });
  }

  Future<void> fltimer(DateTime scheduleAlarmDateTime) async {
    final cron = Cron();
    String dt = Schedule(
            months: scheduleAlarmDateTime.month,
            days: scheduleAlarmDateTime.day,
            hours: scheduleAlarmDateTime.hour,
            minutes: scheduleAlarmDateTime.minute)
        .toCronString();
    cron.schedule(Schedule.parse(dt), () async {
      //print('hello varun');
      // CollectionReference users =
      //     await FirebaseFirestore.instance.collection('client');
      // users
      //     .doc('peSChnRGwcnXaNIob2nA')
      //     .update({'alarm': true})
      //     .then((value) => print('varun updated'))
      //     .catchError((error) => print(error));

      // await ref
      //     .set({
      //       "testing": true,
      //     })
      //     .then((value) => print('varun updated'))
      //     .catchError((error) => print(error));
      await ref.update({
        "Alarm/opening": 1,
      });
      //updateFirebaseData(scheduleAlarmDateTime);
    });
  }

  Future<List<String>> readdata2() async {
    var dir = await getDatabasesPath();
    var path = dir + "alarm.db";
    print(path);
    var _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableAlarm ( 
          $columnId integer primary key autoincrement, 
          $columnTitle text not null,
          $columnDateTime text not null,
          $columnCabin text not null,
          $columnCabinNumber text not null,

          $columnPending integer,
          $columnColorIndex integer)
        ''');
      },
    );

    var result = await _database.query(tableAlarm);
    var lastalarm = result;
    var listdetail = ["", "", "", "", "", "", ""];
    //  await database.close();
    for (int i = 0; i < lastalarm.length; i++) {
      var ttitt = lastalarm[i]["cabin"].toString() +
          "_" +
          lastalarm[i]["alarmDateTime"].toString();
      listdetail[i] = ttitt.toString();
    }
    return listdetail;
  }
}

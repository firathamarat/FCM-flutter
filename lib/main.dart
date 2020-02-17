import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:imei_plugin/imei_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  // Values
  String _message = '-';
  String _token = '-';
  String _imei = '';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // Get Device info
  Future<void> getDeviceInfo() async {

    // Device Info
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    // Emei Info
    var imei = await ImeiPlugin.getImei();
    print('Imei: $imei');
    print('Device: ${androidInfo.androidId}'); // e.g. "Moto G (4)"
    setState(() => _imei = imei.toString());
  }

  // Firebase Register
  _register() {
    _firebaseMessaging.getToken().then((token) =>
        {setState(() => _token = token), _postRequest(token), print(token)});
  }

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
    getMessage();
  }

  void getMessage() {
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('on message $message');
      setState(() => _message = message["notification"]["title"]);
    }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      setState(() => _message = message["notification"]["title"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      setState(() => _message = message["notification"]["title"]);
    });
  }

  Future<http.Response> _postRequest(String token) async {
    var url = 'http://192.168.1.52:8080/device-token/save';

    Map data = {
      'userId': _imei, 
      'deviceToken': token
      };
    var body = json.encode(data);

    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
    print("${response.body}");

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Message: $_message"),
                OutlineButton(
                  child: Text("Register My Device"),
                  onPressed: () {
                    _register();
                  },
                ),
                Text("Imei: $_imei",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Token:", style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(left: 36.0, right: 36.0),
                  child: Text("$_token"),
                )
              ]),
        ),
      ),
    );
  }
}

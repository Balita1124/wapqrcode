import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String result = "Wap Scanning...";
  bool valid = false;
  bool showResult = false;
  // bool isEqual = false;

  void _checkWapValidity(String firstName, String lastName) async {
    await FirebaseFirestore.instance
        .collection('waps')
        .where('firstname', isEqualTo: firstName)
        // .where('lastname', isEqualTo: lastName)
        .limit(1)
        .get()
        .then((value) => {
              if (value.docs.isNotEmpty)
                {
                  setState(() {
                    // isEqual = true;
                  })
                }
            });
  }

  Map<String, dynamic> _decodeMessage(String json) {
    try {
      Map<String, dynamic> wapMap = jsonDecode(json);

      return wapMap;
    } catch (ex) {
      return null;
    }
  }

  Future _scanQR() async {
    showResult = true;
    try {
      String qrResult = (await BarcodeScanner.scan());
      Map<String, dynamic> wapMap = _decodeMessage(qrResult);
      String message = "";
      bool localValid = false;
      if (wapMap == null) {
        localValid = false;
        message = "QrCode Invalid";
      } else {
        bool isEqual = false;
        // await _checkWapValidity(wapMap['firstName'], wapMap['lastName']);
        await FirebaseFirestore.instance
            .collection('waps')
            .where('firstname', isEqualTo: wapMap['firstname'])
            .where('lastname', isEqualTo: wapMap['lastname'])
            .where('nic', isEqualTo: wapMap['nic'])
            .where('phone', isEqualTo: wapMap['phone'])
            .limit(1)
            .get()
            .then((value) => {if (value.docs.isNotEmpty) isEqual = true});

        if (isEqual) {
          message = "Firstname: " +
              wapMap['firstname'] +
              "\nLastname :  " +
              wapMap['lastname'] +
              "\nNIC :  " +
              wapMap['nic'] +
              "\nPhone :  " +
              wapMap['phone'] +
              "\n\n";
          localValid = true;
        } else {
          message = "Firstname: " +
              wapMap['firstname'] +
              "\nLastname :  " +
              wapMap['lastname'] +
              "\nNIC :  " +
              wapMap['nic'] +
              "\nPhone :  " +
              wapMap['phone'] +
              "\n\n";
          localValid = false;
        }
      }
      setState(() {
        result = message;
        valid = localValid;
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /*return Scaffold(
      appBar: AppBar(
        title: Text('Wap Scanner'),
      ),
      body: Center(
        child: Text(
          result,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanQR,
        label: Text('Scan'),
        icon: Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );*/
    return Scaffold(
      appBar: AppBar(
        title: Text('Wap Scanner'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              result,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
              textAlign: TextAlign.left,
            ),
            showResult
                ? Text(
                    valid ? "Wap Valid" : "Wap not Valid",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                : Text(''),
            showResult
                ? Icon(
                    valid ? Icons.done_sharp : Icons.cancel_sharp,
                    color: valid ? Colors.green : Colors.red,
                    size: 70,
                  )
                : Text(''),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanQR,
        label: Text('Scan'),
        icon: Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

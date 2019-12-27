import 'dart:convert';
import 'package:cekilismobil/json/jsonapi.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;



class OnlineWeb extends StatefulWidget {
  _OnlineWebState createState() => _OnlineWebState();
}

class _OnlineWebState extends State<OnlineWeb> {

  Future<Null> _qrcodelogin(qr_key) async {
    final patch = "/qrcode";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = await GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code':version_code, 'qr_key': qr_key};
    var response = await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      var result = json.decode(response.body);

      if(result['api_status'].toString() == 'false')
      {
        GlobalCode.toast(GlobalCode.lang(context, 'Failed_to_scan_code_Check_the_address_you_are_scanning'));
      }else {
        GlobalCode.toast(GlobalCode.lang(context, 'You_can_continue_from_the_web_application'));
      }
    } else {
      throw Exception(GlobalCode.lang(context, 'Connection_error'));
    }
  }

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      _qrcodelogin(qrResult);
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          GlobalCode.toast(GlobalCode.lang(context, 'Camera_permission_was_denied'));
        });
      } else {
        setState(() {
          GlobalCode.toast(GlobalCode.lang(context, 'Unknown_Error')+" $ex");
        });
      }
    } on FormatException {
      setState(() {
        GlobalCode.toast(GlobalCode.lang(context, 'You_pressed_the_back_button_before_scanning_anything'));
      });
    } catch (ex) {
      setState(() {
        GlobalCode.toast(GlobalCode.lang(context, 'Unknown_Error')+" $ex");
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    Widget _apierrorwidget = new Container(
      child: Card(
        child: Column(
          children: <Widget>[
            new ListTile(
              leading: const Icon(Icons.link, color: Colors.white70),
              title: new Text('https://lucksend.com/login'),
              subtitle: new Text('https://bit.ly/lucksend', style: TextStyle(color: Colors.white70)),
            ),
            Divider(),
            new ListTile(
              leading: const Icon(Icons.info, color: Colors.white70),
              title: new Text(GlobalCode.lang(context, 'Enter_the_Luck_Send_web_address_and_click_the_qr_code_button')),
            ),
            Divider(),
            new ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white70),
              title: new Text(GlobalCode.lang(context, 'i_am_ready_to_scan_qr_code')),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onTap: (){
                _scanQR();
              },
            ),

          ],
        ),
      ),

    );


    Widget body = new Column(
      // This makes each child fill the full width of the screen
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _apierrorwidget
      ],
    );


    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: AppBar(
        title: Text('Luck Send Web'),
        actions: <Widget>[


        ],
      ),
      body: new SingleChildScrollView(
          child:body
      ),
    );
  }
}
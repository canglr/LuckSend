import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:progress_dialog/progress_dialog.dart';


class JsonApi{
 static final url = "https://api.lucksend.com/";

  Future<Null> userCheckPost(BuildContext context,String token) async {
    if (token != null) {
      ProgressDialog pr;
      pr = new ProgressDialog(context, ProgressDialogType.Normal);
      pr.setMessage(GlobalCode.lang(context, 'Please_wait'));
      pr.show();
      final patch = "/account/check";
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      var body = {
        'token': token,
        'brand': androidInfo.brand,
        'model': androidInfo.model,
        'release': androidInfo.version.release,
        'device_key': androidInfo.androidId,
      };
      final response =
      await http.post(url + patch, body: body);

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        var result = json.decode(response.body);
        if(result['api_status'].toString() == 'false')
        {
          pr.hide();
          GlobalCode.toast(result['api_result']);
        }else {
          await GlobalCode.storagewrite('api_key', result['key']);
          await GlobalCode.storagewrite('local', result['local']);
          await GlobalCode.storagewrite('mail_address', result['mail_address']);
          await GlobalCode.storagewrite('name', result['name']);
          await GlobalCode.storagewrite('id_share', result['id_share']);
          await GlobalCode.storagewrite('profile_picture', result['profile_picture']);
        }
        pr.hide();
      } else {
        // If that response was not OK, throw an error.
        pr.hide();
        GlobalCode.toast(GlobalCode.lang(context, 'Something_went_wrong'));
      }
    }
  }


 Future<Null> accountExit(BuildContext context) async {
   final patch = "/account/exit";
   var api_key = await GlobalCode.storageread('api_key');
   var body = { 'api_key': api_key};
   final response =
   await http.post(url+patch, body: body);

   if (response.statusCode == 200) {
     // If the call to the server was successful, parse the JSON

   } else {
     // If that call was not successful, throw an error.

   }

   GlobalCode.storagedeleteall();

 }


}
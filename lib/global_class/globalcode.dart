import 'package:cekilismobil/screen/apierror.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../translations.dart';
import 'package:connectivity/connectivity.dart';


class GlobalCode
{

  static final versionCode = 'd5e0195efbe15da35c01233f6a69a387';
  static final adsAppId = 'ca-app-pub-2335291';
  static final adsId = 'ca-app-pub-2335291';
  static final bannerAdsID = 'ca-app-pub-2335291';
  static final adsTestingDevice = ['6C19E0B87BC3764E5','FF4C5823AA51307'];
  static var bannerAdsPadding = 48.0;
  static var adsTesting = false;

  static void toast(var msg)
  {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.black,
        textColor: Colors.white70,
        fontSize: 16.0
    );
  }

  static void soundplay(var patch) async
  {
    AudioCache audioCache = new AudioCache();
    await audioCache.play(patch);
  }

  static String datetimenow()
  {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    String formatted = formatter.format(now);
    String result = formatted;
    return result;
  }

  static void profileimagedownload(var userid, var profileimageurl) async
  {
    if(profileimageurl != null) {
      HttpClient client = new HttpClient();
      var _downloadData = List<int>();
      String dir = (await getApplicationDocumentsDirectory()).path;
      new Directory('$dir/images/profile').create(recursive: true);
      var fileSave = new File('$dir/images/profile/$userid.png');

      client.getUrl(Uri.parse(profileimageurl))
          .then((HttpClientRequest request) {
        return request.close();
      })
          .then((HttpClientResponse response) {
        response.listen((d) => _downloadData.addAll(d),
            onDone: () {
              fileSave.writeAsBytes(_downloadData);
            }
        );
      });
    }

  }

  static Future<String> profilegetlocalimage(var userid) async
  {
    String dir = (await getApplicationDocumentsDirectory()).path;
    print(dir);
    var image = new File('$dir/images/profile/$userid.png');

    if(image.existsSync()) {
      var profileimage = '$dir/images/profile/$userid.png';
      return profileimage;
    }else{
      var profileimage = 'assets/images/noprofile.png';
      return profileimage;
    }

  }

  static Future<String> storageread(var key) async
  {
    final storage = new FlutterSecureStorage();
    String value = await storage.read(key: key);
    return value;
  }

  static Future<Null> storagewrite(var key,var value) async
  {
    final storage = new FlutterSecureStorage();
    await storage.write(key: key, value: value);
  }

  static Future<Null> storagedeleteall() async
  {
    final storage = new FlutterSecureStorage();
    await storage.deleteAll();
  }

  static Future<Null> storagedelete(var key) async
  {
    final storage = new FlutterSecureStorage();
    await storage.delete(key: key);
  }

  static String datetimetoUTC(String date)
  {
    DateTime utc;
    utc = DateTime.parse(date).toUtc();
    date = new DateFormat('yyyy-MM-dd  HH:mm:ss').format(utc);
    return date;
  }


  static String datetimetoLOCAL(String date)
  {
    date = date.trim();
    DateTime local;
    local = DateTime.parse(date+"Z").toLocal();
    date = new DateFormat('yyyy-MM-dd HH:mm:ss').format(local);
    return date;
  }


  static void apiError(msg,context)
  {
    ApiError.msg = msg;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => ApiError(),
            settings: RouteSettings(name: 'ApiError'),
        ),
        ModalRoute.withName("/ApiError")
    );
  }


  static String lang(BuildContext context,String lang)
  {
    var language = Translations.of(context).text(lang);
    return language;
  }


  static void copyClipboard(var data)
  {
    Clipboard.setData(new ClipboardData(text: data));
  }


  static Future<bool> checkNet() async
  {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  static Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static String ConvertDate(datetime)
  {
    var date = new DateFormat("y-MM-d").format(datetime);
    return date;
  }

  static String ConvertTime(datetime)
  {
    var time = new DateFormat("HH:mm:ss").format(datetime);
    return time;
  }


  static String TagUnsupportedCharacter(tag)
  {
    tag = tag.replaceAll('#', '');
    tag = tag.replaceAll('@', '');
    tag = tag.replaceAll(',', '');
    tag = tag.replaceAll(' ', '');
    return tag;
  }


}
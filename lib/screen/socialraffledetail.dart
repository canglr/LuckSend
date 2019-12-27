import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cekilismobil/global_class/appads.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:http/http.dart' as http;
import 'package:cekilismobil/json/jsonapi.dart';
import 'package:cekilismobil/screen/onlineupdateraffle.dart';
import 'package:url_launcher/url_launcher.dart';


class SocialRaffleDetail extends StatefulWidget {
  static var id_share;
  @override
  _SocialRaffleDetailState createState() => new _SocialRaffleDetailState();
}

class _SocialRaffleDetailState extends State<SocialRaffleDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  var loading = true;
  var detailform = false;
  var visible_sponsor = false;
  var invisible_sponsor = true;
  var saved = false;
  var sponsor = false;
  var type = false;
  var id_share,author_name,author_image,display,media_description,media_image,media_url;


  Future<Null> fetchRaffle() async {
    final patch = "/socialmedia/show";
    var api_key = await GlobalCode.storageread('api_key');
    var body = { 'api_key': api_key, 'version_code':GlobalCode.versionCode, 'id_share': SocialRaffleDetail.id_share};
    final response =
    await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      var result = json.decode(response.body);

      if(result['api_status'].toString() == 'false')
      {
        GlobalCode.apiError(result['api_result'], context);
      }else{

        setState(() {
          id_share = result['id_share'];
          author_name = result['author_name'];
          author_image = result['author_image'];
          display = result['display'];
          media_description = result['media_description'];
          media_image = result['media_image'];
          media_url = result['media_url'];
          sponsor = result['sponsor'];
          type = result['type'];
          saved = result['saved'];
          if(sponsor)
            {
              visible_sponsor = true;
              invisible_sponsor = false;
            }


          loading = false;
          detailform = true;


        });

      }

    } else {
      // If that call was not successful, throw an error.
      GlobalCode.toast(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  Future<Null> fetchRaffleStatistics() async {
    final patch = "/socialmedia/statistics";
    var api_key = await GlobalCode.storageread('api_key');
    var body = { 'api_key': api_key, 'version_code':GlobalCode.versionCode, 'id_share': SocialRaffleDetail.id_share};
    final response =
    await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {


    } else {
      // If that call was not successful, throw an error.
      GlobalCode.toast(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  Future<Null> raffleSaved() async {
    final patch = "/socialmedia/saved";
    var api_key = await GlobalCode.storageread('api_key');
    var body = { 'api_key': api_key, 'version_code':GlobalCode.versionCode, 'id_share': SocialRaffleDetail.id_share};
    final response =
    await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      setState(() {
        saved = result['api_status'];
      });
    } else {
      // If that call was not successful, throw an error.
      GlobalCode.toast(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  Future<Null> warningSend(var msg) async {
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code': version_code, 'id_share': SocialRaffleDetail.id_share, 'description':msg};
    final patch = "/socialmedia/report";
    final response =
    await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var result = json.decode(response.body);
      if(result['api_status'].toString() == 'false')
      {
        GlobalCode.toast(GlobalCode.lang(context, result['api_result']));
      }else {
        GlobalCode.toast(GlobalCode.lang(context, result['api_result']));
        Navigator.of(context).pop();
        description.text = "";
      }

    } else {
      GlobalCode.toast(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  _getsocialURL(social_url) async {
    if (await canLaunch(social_url)) {
      await launch(social_url);
    } else {
      throw 'Could not launch $social_url';
    }
  }

  warningDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(GlobalCode.lang(context, 'Report')),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))
            ),
            content: new TextFormField(
              maxLines: null,
              keyboardType: TextInputType.multiline,
              maxLength: 350,
              controller: description,
              decoration: new InputDecoration(
                hintText: GlobalCode.lang(context, 'Description'),
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),

              new FlatButton(
                child: new Icon(Icons.check),
                onPressed: () {
                  warningSend(description.text);
                },
              ),

            ],

          );
        });
  }

  @override
  void initState(){
    super.initState();
    fetchRaffle();
    AppAds.init();
    AppAds.showBanner(state: this, size: AdSize.smartBanner, testDevices: GlobalCode.adsTestingDevice,testing: GlobalCode.adsTesting);
  }

  @override
  Widget build(BuildContext context) {

    Widget _loading =  new Container(
        height: 100,
        child: Center(
            child: Visibility(
              visible: loading,
              child: new CircularProgressIndicator(backgroundColor: Color.fromRGBO(29, 29, 29, 1)),
            )));




    Widget _socialraffledetailform = new Container(
        child: Visibility(
          visible: detailform,
          child: Card(
            child: Column(
              children: [

                Visibility(
                  visible: invisible_sponsor,
                  child: ListTile(
                    title: Text('$author_name',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: type ? Icon(Icons.card_giftcard, color: Colors.white70) : Icon(Icons.attach_money, color: Colors.white70),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage('$author_image'),
                    ),
                  ),
                ),

                Visibility(
                  visible: visible_sponsor,
                  child: ListTile(
                    title: Text('$author_name',
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    subtitle: Text(GlobalCode.lang(context, 'Sponsored'), style: TextStyle(color: Color.fromRGBO(187, 134, 252, 1), fontSize: 13, fontWeight: FontWeight.w500)),
                    trailing: type ? Icon(Icons.card_giftcard, color: Colors.white70) : Icon(Icons.attach_money, color: Colors.white70),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage('$author_image'),
                    ),
                  ),
                ),

                CachedNetworkImage(
                  imageUrl: '$media_image',
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Image.asset('assets/images/noimage.png'),
                ),

                Divider(),

                ListTile(
                  title: Text('$media_description', style: TextStyle(fontSize: 14)),
                ),

                ListTile(
                  title: Text('$display'),
                  leading: Icon(
                    Icons.remove_red_eye,
                    color: Colors.white70,
                  ),
                ),


              ],
            ),
          ),
        )
    );


    Widget body = new Column(
      // This makes each child fill the full width of the screen
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _socialraffledetailform,
        _loading
      ],
    );


    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              GlobalCode.lang(context, 'Product_Details'),
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              id_share ?? ' ',
              style: TextStyle(fontSize: 10.0),
            )
          ],
        ),
        actions: <Widget>[

          Visibility(
            visible: detailform,
            child: IconButton(icon: const Icon(Icons.report), onPressed: (
                ) {

              warningDialog();

            }),
          ),

          Visibility(
            visible: detailform,
            child: Visibility(
                visible: saved == true ? false:true,
                child: IconButton(icon: const Icon(Icons.bookmark_border), onPressed: (
                    ) {

                  raffleSaved();

                }),
              ),
          ),


          Visibility(
            visible: detailform,
            child: Visibility(
              visible: saved,
              child: IconButton(icon: const Icon(Icons.bookmark, color: Color.fromRGBO(187, 134, 252, 1)), onPressed: (
                  ) {

                raffleSaved();

              }),
            ),
          ),


          Visibility(
            visible: detailform,
            child: IconButton(icon: const Icon(Icons.open_in_new), onPressed: (
                ) {
              fetchRaffleStatistics();
              _getsocialURL(media_url);

            }),
          ),

        ],
      ),
      body: SingleChildScrollView(
          child: body
      ),
    );
  }
}


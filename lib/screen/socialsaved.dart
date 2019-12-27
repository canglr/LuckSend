import 'package:cached_network_image/cached_network_image.dart';
import 'package:cekilismobil/global_class/appads.dart';
import 'package:cekilismobil/screen/socialraffledetail.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cekilismobil/json/model/socialraffles.dart';
import 'package:cekilismobil/json/jsonapi.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:progress_dialog/progress_dialog.dart';



class SocialSaved extends StatefulWidget {
  _SocialSavedState createState() => _SocialSavedState();
}

class _SocialSavedState extends State<SocialSaved> {

  ScrollController _controller =
  ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
  Future<List<SocialRafflesModel>> _future;
  List<SocialRafflesModel> listOfsaved;
  List<SocialRafflesModel> listOfcached;
  int listPage=1;
  var listpagelocked=false;

  @override
  void initState(){
    super.initState();
    AppAds.init();
  }

  _SocialSavedState() {
    _controller.addListener(() {
      var isEnd = _controller.offset == _controller.position.maxScrollExtent;
      if (isEnd)
        setState(() {
          if(listpagelocked == false) {
            _future = _fetchloadRaffles(listPage);
          }
        });
    });
    _future = _fetchRaffles(listPage);
  }

  Future<List<SocialRafflesModel>> _fetchRaffles(var page) async {
    final patch = "/socialmedia/saved/list";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code':version_code, 'page': page.toString()};
    var response = await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      listOfsaved = items.map<SocialRafflesModel>((json) {
        return SocialRafflesModel.fromJson(json);
      }).toList();
      listPage++;
      return listOfsaved;

    } else {
      throw Exception(GlobalCode.lang(context, 'Connection_error'));
    }
  }

  Future<List<SocialRafflesModel>> _fetchloadRaffles(var page) async {
    ProgressDialog pr;
    pr = new ProgressDialog(context,ProgressDialogType.Normal);
    pr.setMessage(GlobalCode.lang(context, 'Please_wait'));
    pr.show();
    final patch = "/socialmedia/saved/list";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code':version_code, 'page': page.toString()};
    var response = await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      if(items.toString() == "[]"){ listpagelocked = true; }

      listOfcached = items.map<SocialRafflesModel>((json) {
        return SocialRafflesModel.fromJson(json);
      }).toList();
      listOfsaved.addAll(listOfcached);
      listOfcached.clear();
      listPage++;
      pr.hide();
      return listOfsaved;

    } else {
      throw Exception(GlobalCode.lang(context, 'Connection_error'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: AppBar(
        title: Text(GlobalCode.lang(context, 'Saved')),
      ),
      body: FutureBuilder<List<SocialRafflesModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(backgroundColor: Color.fromRGBO(29, 29, 29, 1)));

          return ListView(
            children: snapshot.data
                .map((raffle) => GestureDetector( onTap: () {

              AppAds.showScreen(state: this, testing: GlobalCode.adsTesting);

              SocialRaffleDetail.id_share = raffle.id_share;
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (BuildContext context) => new SocialRaffleDetail(),
                    settings: RouteSettings(name: 'SocialRaffleDetail'),
                  ));

            }, child: Card(
              child: Column(
                children: [

                  Visibility(
                    visible: raffle.sponsor == true ?  false : true,
                    child: ListTile(
                      title: Text(raffle.author_name,
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(raffle.id_share, style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                      trailing: raffle.type ? Icon(Icons.card_giftcard, color: Colors.white70) : Icon(Icons.attach_money, color: Colors.white70),
                    ),
                  ),

                  Visibility(
                    visible: raffle.sponsor,
                    child: ListTile(
                      title: Text(raffle.author_name,
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                      subtitle: Text(GlobalCode.lang(context, 'Sponsored'), style: TextStyle(color: Color.fromRGBO(187, 134, 252, 1), fontSize: 13, fontWeight: FontWeight.w500)),
                      trailing: raffle.type ? Icon(Icons.card_giftcard, color: Colors.white70) : Icon(Icons.attach_money, color: Colors.white70),
                    ),
                  ),


                  CachedNetworkImage(
                    imageUrl: raffle.media_image,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Image.asset('assets/images/noimage.png'),
                  ),

                  ListTile(
                    title: Text(GlobalCode.lang(context, 'More_information'),
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                    trailing: Icon(Icons.more_horiz, color: Colors.white70),
                  ),


                ],
              ),
            )),
            )
                .toList(),
          );
        },
      ),
    );
  }
}
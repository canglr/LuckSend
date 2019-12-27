import 'package:cekilismobil/json/model/reserves.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cekilismobil/json/jsonapi.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:cekilismobil/json/model/winners.dart';

class OnlineResultParticipant extends StatefulWidget {
  static var id_share;
  _OnlineResultParticipantState createState() => _OnlineResultParticipantState();
}

class _OnlineResultParticipantState extends State<OnlineResultParticipant> {

  bool show_information=false;
  bool show_tryagain = false;
  bool winners_list = true;
  bool reserves_list = true;

  String contact_information;
  String secretkey;



  Future<List<Winners>> _fetchWinners() async {
    final patch = "/winners/list";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code':version_code, 'id_share': OnlineResultParticipant.id_share};
    var response = await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      List<Winners> listOfWinners = items.map<Winners>((json) {
        return Winners.fromJson(json);
      }).toList();

      return listOfWinners;
    } else {
      throw Exception(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  Future<List<Reserves>> _fetchReserves() async {
    final patch = "/reserves/list";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code':version_code, 'id_share': OnlineResultParticipant.id_share};
    var response = await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      List<Reserves> listOfReserves = items.map<Reserves>((json) {
        return Reserves.fromJson(json);
      }).toList();


      return listOfReserves;
    } else {
      throw Exception(GlobalCode.lang(context, 'Connection_error'));
    }
  }



  Future<Null> _fetchresultcheck() async {
    final patch = "/participant/my/raffle/result";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code':version_code, 'id_share': OnlineResultParticipant.id_share};
    var response = await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      var result = json.decode(response.body);

      if(result['api_status'].toString() == 'false')
      {
        GlobalCode.toast(GlobalCode.lang(context, result['api_result']));
      }else {
        if (result['secret_key'] != null) {
          setState(() {
            contact_information = result['contact_information'];
            secretkey = result['secret_key'];
            show_information = true;
          });
        } else {
          setState(() {
            show_tryagain = true;
          });
        }
      }

    } else {
      throw Exception(GlobalCode.lang(context, 'Connection_error'));
    }
  }

  void refresh() async
  {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {

      });
    });
  }

  @override
  void initState(){
    super.initState();
    _fetchresultcheck();
  }


  @override
  Widget build(BuildContext context) {

    Widget _onlineusercontactshowform = new Container(
        child: Visibility(
        visible: show_information,
        child:Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('$contact_information'),
                  leading: Icon(
                    Icons.contacts,
                    color: Colors.white70,
                  ),
                ),


              ],
            )))
    );


    Widget _onlineuserkeyshowform = new Container(
        child: Visibility(
            visible: show_information,
        child:Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('$secretkey'),
                  leading: Icon(
                    Icons.vpn_key,
                    color: Colors.white70,
                  ),
                    trailing: Icon(Icons.content_copy, color: Colors.white70),
                  onTap: () {
                    GlobalCode.copyClipboard('$secretkey');
                    GlobalCode.toast(GlobalCode.lang(context, 'Copied'));
                  },

                ),


              ],
            )))
    );


    Widget _onlinetryagainshowform = new Container(
        child: Visibility(
            visible: show_tryagain,
            child:Card(
                child: Column(
                  children: [
                    ListTile(
                        title: Text(GlobalCode.lang(context, 'We_are_sorry')),
                        leading: Icon(
                          Icons.mood_bad,
                          color: Colors.white70,
                        ),
                    ),


                  ],
                )))
    );


    Widget _onlinewinnerstextshowform = new Container(
        child: Visibility(
            visible: winners_list,
            child:Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(GlobalCode.lang(context, 'Winners'),
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      leading: Icon(
                        Icons.star,
                        color: Colors.white70,
                      ),
                    ),


                  ],
                )))
    );

    Widget _onlinewinnersraffleform = new Container(
        height:220,
        child: Visibility(
            visible: winners_list,
        child: Card(
            child: FutureBuilder<List<Winners>>(
              future: _fetchWinners(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator(backgroundColor: Color.fromRGBO(29, 29, 29, 1)));

                return ListView(
                  children: snapshot.data
                      .map((winner) => ListTile(
                    title: Text(winner.name),
                    subtitle: Text(winner.id_share),
                    leading: CircleAvatar(
                      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
                      child: Text(winner.name[0],
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          )),
                    ),
                    onTap: () {

                    },
                  ))
                      .toList(),
                );
              },
            )))
    );


    Widget _onlinereservestextshowform = new Container(
        child: Visibility(
            visible: reserves_list,
            child:Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(GlobalCode.lang(context, 'Reserves'),
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      leading: Icon(
                        Icons.star_half,
                        color: Colors.white70,
                      ),
                    ),


                  ],
                )))
    );


    Widget _onlinereservesraffleform = new Container(
        height:220,
      child: Visibility(
          visible: reserves_list,
        child: Card(
            child: FutureBuilder<List<Reserves>>(
              future: _fetchReserves(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) return Center(child: CircularProgressIndicator(backgroundColor: Color.fromRGBO(29, 29, 29, 1)));

                if (snapshot.hasData) {
                  if (snapshot.data.length == 0) {
                    reserves_list = false;
                    refresh();
                  }
                }

                return ListView(
                  children: snapshot.data
                      .map((reserve) => ListTile(
                    title: Text(reserve.name),
                    subtitle: Text(reserve.id_share),
                    leading: CircleAvatar(
                      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
                      child: Text(reserve.name[0],
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          )),
                    ),
                    onTap: () {

                    },
                  ))
                      .toList(),
                );
              },
            )))
    );



    Widget body = new Column(
      // This makes each child fill the full width of the screen
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _onlineusercontactshowform,
        _onlineuserkeyshowform,
        _onlinetryagainshowform,
        _onlinewinnerstextshowform,
        _onlinewinnersraffleform,
        _onlinereservestextshowform,
        _onlinereservesraffleform
      ],
    );


    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: AppBar(
        title: Text(GlobalCode.lang(context, 'Raffle_Result')),
      ),
      body: new SingleChildScrollView(
          child:body
      ),
    );
  }
}
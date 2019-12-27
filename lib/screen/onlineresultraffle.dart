import 'package:cekilismobil/json/model/reserves.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cekilismobil/json/jsonapi.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:cekilismobil/json/model/winners.dart';

class OnlineResultRaffle extends StatefulWidget {
  static var id_share;
  _OnlineResultRaffleState createState() => _OnlineResultRaffleState();
}

class _OnlineResultRaffleState extends State<OnlineResultRaffle> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  var secretkey = new TextEditingController();

  var visible_search = false;
  bool winners_list = true;
  bool reserves_list = true;

  String name;
  String id_share;
  var status;


  bool _validateInputs() {
    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      return true;
    } else {
      return false;
    }
  }


  Future<List<Winners>> _fetchWinners() async {
    final patch = "/winners/list";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code':version_code, 'id_share': OnlineResultRaffle.id_share};
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
    var body = { 'api_key': api_key, 'version_code':version_code, 'id_share': OnlineResultRaffle.id_share};
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


  Future<Null> _fetchSecretkeycheck() async {
    final patch = "/raffle/secretkeycheck";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code':version_code, 'id_share': OnlineResultRaffle.id_share, 'secretkey': secretkey.text};
    var response = await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      var result = json.decode(response.body);

      if(result['api_status'].toString() == 'false')
      {
        GlobalCode.toast(GlobalCode.lang(context, result['api_result']));
      }else {
        setState(() {
          visible_search = true;

          name = result['name'];
          status = result['status'];
          id_share = result['id_share'];

          if(status)
            {
              status = GlobalCode.lang(context, 'Winners');
            }else
              {
                status = GlobalCode.lang(context, 'Reserves');
              }

        });
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
  Widget build(BuildContext context) {

    Widget _onlinecheckuserraffleform = new Container(
        child: new Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Card(
            child: Column(
              children: <Widget>[
                new ListTile(
                  leading: const Icon(Icons.vpn_key, color: Colors.white70),
                  title: new TextFormField(
                    maxLength: 30,
                    validator: (value) {
                      value = value.trim();
                      if (value.isEmpty) {
                        return GlobalCode.lang(context, 'Cannot_be_empty');
                      }
                    },
                    controller: secretkey,
                    decoration: new InputDecoration(
                      hintText: GlobalCode.lang(context, 'Secret_key'),
                    ),
                  ),
                ),

              ],
            ),
          ),
        )

    );


    Widget _onlinesecretkeyusershowform = new Container(
        child: Visibility(
            visible: visible_search,
        child:Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('$name',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('$id_share - $status'),
                  leading: Icon(
                    Icons.person,
                    color: Colors.white70,
                  ),
                  trailing: Icon(Icons.close),
                  onTap: () {

                    setState(() {
                      visible_search = false;
                    });

                  },
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
        height:180,
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
        height:180,
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
                          backgroundColor:Color.fromRGBO(18, 18, 18, 1),
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
        _onlinecheckuserraffleform,
        _onlinesecretkeyusershowform,
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
        actions: <Widget>[

          new IconButton(icon: const Icon(Icons.search), onPressed: (
              ) {

                if(_validateInputs()) {
                  _fetchSecretkeycheck();
                }

          })

        ],
      ),
      body: new SingleChildScrollView(
          child:body
      ),
    );
  }
}
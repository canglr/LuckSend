import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cekilismobil/json/model/raffles.dart';
import 'package:cekilismobil/json/jsonapi.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:cekilismobil/screen/onlinemyraffledetail.dart';
import 'package:cekilismobil/screen/onlinenewraffle.dart';

class OnlineMyRaffles extends StatefulWidget {
  _OnlineMyRafflesState createState() => _OnlineMyRafflesState();
}

class _OnlineMyRafflesState extends State<OnlineMyRaffles> {

  Future<List<Raffles>> _fetchRaffles() async {
    final patch = "/raffles/list";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code':version_code};
    var response = await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
        final items = json.decode(response.body).cast<Map<String, dynamic>>();
        List<Raffles> listOfUsers = items.map<Raffles>((json) {
        return Raffles.fromJson(json);
        }).toList();
        return listOfUsers;

    } else {
      throw Exception(GlobalCode.lang(context, 'Connection_error'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: AppBar(
        title: Text(GlobalCode.lang(context, 'My_Social_Links')),
        actions: <Widget>[

          new IconButton(icon: const Icon(Icons.add), onPressed: (
              ) {

            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) => new OnlineNewRaffle(),
                    settings: RouteSettings(name: 'OnlineNewRaffle'),
                ));

          })

        ],
      ),
      body: FutureBuilder<List<Raffles>>(
        future: _fetchRaffles(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(backgroundColor: Color.fromRGBO(29, 29, 29, 1)));

          return ListView(
            children: snapshot.data
                .map((raffle) => Card( child: ListTile(
              title: Text(raffle.title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(raffle.id_share, style: TextStyle(color: Colors.white70)),
              leading: CircleAvatar(
                backgroundColor: Color.fromRGBO(18, 18, 18, 1),
                child: Text(raffle.title[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70
                    )),
              ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onTap: () {
                OnlineMyRaffleDetail.id_share = raffle.id_share;
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new OnlineMyRaffleDetail(),
                        settings: RouteSettings(name: 'OnlineMyRaffleDetail'),
                    ));
              },
            )))
                .toList(),
          );
        },
      ),
    );
  }
}
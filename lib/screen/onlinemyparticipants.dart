import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cekilismobil/json/model/raffles.dart';
import 'package:cekilismobil/json/jsonapi.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:cekilismobil/screen/onlineparticipantraffledetail.dart';

class OnlineMyParticipants extends StatefulWidget {
  _OnlineMyParticipantsState createState() => _OnlineMyParticipantsState();
}

class _OnlineMyParticipantsState extends State<OnlineMyParticipants> {

  Future<List<Raffles>> _fetchParticipants() async {
    final patch = "/participants/list";
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
        title: Text(GlobalCode.lang(context, 'Sweepstakes_I_Participated')),
      ),
      body: FutureBuilder<List<Raffles>>(
        future: _fetchParticipants(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(backgroundColor: Color.fromRGBO(29, 29, 29, 1),));

          return ListView(
            children: snapshot.data
                .map((raffle) => Card( child: ListTile(
              title: Text(raffle.title),
              subtitle: Text(raffle.id_share, style: TextStyle(color: Colors.white70)),
              leading: CircleAvatar(
                backgroundColor: Color.fromRGBO(18, 18, 18, 1),
                child: Text(raffle.title[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold
                    )),
              ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onTap: () {
                OnlineParticipantRaffleDetail.id_share = raffle.id_share;
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new OnlineParticipantRaffleDetail(),
                        settings: RouteSettings(name: 'OnlineParticipantRaffleDetail'),
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
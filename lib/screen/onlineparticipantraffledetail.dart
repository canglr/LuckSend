import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cekilismobil/json/jsonapi.dart';
import 'package:cekilismobil/screen/onlineresultparticipant.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
class OnlineParticipantRaffleDetail extends StatefulWidget {
  static var id_share;
  @override
  _OnlineParticipantRaffleDetailState createState() => new _OnlineParticipantRaffleDetailState();
}

class _OnlineParticipantRaffleDetailState extends State<OnlineParticipantRaffleDetail> with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var loading = true;
  var detailform = false;
  var resultbtn = false;

  var id_share;
  var title;
  var description;
  var expiration;
  var winners;
  var reserves;
  var creation_date;
  var last_update;
  var raffle_join_count;

  Future<Null> fetchRaffle() async {
    final patch = "/participant/my/raffle/detail";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code':version_code , 'id_share': OnlineParticipantRaffleDetail.id_share};
    final response =
    await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      var result = json.decode(response.body);

      if(result['api_status'].toString() == 'false')
      {
        GlobalCode.apiError(result['api_result'], context);
      }else {
        setState(() {
          id_share = result['id_share'];
          title = result['title'];
          description = result['description'];
          expiration = GlobalCode.datetimetoLOCAL(result['expiration']);
          winners = result['winners'];
          reserves = result['reserves'];
          creation_date = GlobalCode.datetimetoLOCAL(result['creation_date']);
          last_update = GlobalCode.datetimetoLOCAL(result['last_update']);
          raffle_join_count = result['raffle_join_count'];

          loading = false;
          detailform = true;
          resultbtn = result['completed'];
        });
      }

    } else {
      // If that call was not successful, throw an error.
      GlobalCode.toast(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  @override
  void initState(){
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
    fetchRaffle();
  }

  @override
  Widget build(BuildContext context) {

    Widget _loading =  new Container(
      height: 100,
      child: Center(
        child: Visibility(
          visible: loading,
            child: new CircularProgressIndicator(backgroundColor: Color.fromRGBO(29, 29, 29, 1),),
        )));

    Widget _onlineparticipantsharedetailform = new Container(
        child: Visibility(
          visible: detailform,
          child: Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(GlobalCode.lang(context, 'Share_address'),
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('https://lucksend.com/share/$id_share',
                      style: TextStyle(color: Colors.white70)),
                  leading: Icon(
                    Icons.share,
                    color: Colors.white70,
                  ),
                  trailing: Icon(Icons.content_copy, color: Colors.white70),
                  onTap: () {
                    GlobalCode.copyClipboard('https://lucksend.com/share/$id_share');
                    GlobalCode.toast(GlobalCode.lang(context, 'Copied'));
                  },
                ),
                Divider(),
                ListTile(
                  title: Text(GlobalCode.lang(context, 'Share_code'),
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('$id_share',
                      style: TextStyle(color: Colors.white70)),
                  leading: Icon(
                    Icons.share,
                    color: Colors.white70,
                  ),
                  trailing: Icon(Icons.content_copy, color: Colors.white70),
                  onTap: () {
                    GlobalCode.copyClipboard('$id_share');
                    GlobalCode.toast(GlobalCode.lang(context, 'Copied'));
                  },
                ),
              ],
            ),
          ),
        )
    );

    Widget _onlineparticipantdetailform = new Container(
      child: Visibility(
        visible: detailform,
      child: Card(
        child: Column(
          children: [
            ListTile(
                title: Text('$title',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                leading: Icon(
                  Icons.card_giftcard,
                  color: Colors.white70,
                ),
            ),
            Divider(),
            ListTile(
              title: Text('$description'),
              leading: Icon(
                Icons.description,
                color: Colors.white70,
              ),
            ),
            Divider(),
            ListTile(
              title: Text('$winners',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text('$reserves',
                  style: TextStyle(color: Colors.white70)),
              leading: Icon(
                Icons.person,
                color: Colors.white70,
              ),
            ),
            Divider(),
            ListTile(
              title: Text('$raffle_join_count'),
              leading: Icon(
                Icons.supervisor_account,
                color: Colors.white70,
              ),
            ),
            Divider(),
            ListTile(
              title: Text('$creation_date'),
              leading: Icon(
                Icons.access_time,
                color: Colors.white70,
              ),
            ),
            Divider(),
            ListTile(
              title: Text('$last_update'),
              leading: Icon(
                Icons.update,
                color: Colors.white70,
              ),
            ),
            Divider(),
            ListTile(
              title: Text('$expiration'),
              leading: Icon(
                Icons.timer_off,
                color: Colors.white70,
              ),
            ),

          ],
        ),
      )),
    );

    Widget body = new Column(
      // This makes each child fill the full width of the screen
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _onlineparticipantsharedetailform,
        _onlineparticipantdetailform,
        _loading
      ],
    );

    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(GlobalCode.lang(context, 'Raffle_Details')),
        actions: <Widget>[

        Visibility(
        visible: resultbtn,
          child: IconButton(icon: const Icon(Icons.assignment), onPressed: (
              ) {

            OnlineResultParticipant.id_share = OnlineParticipantRaffleDetail.id_share;
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) => new OnlineResultParticipant(),
                    settings: RouteSettings(name: 'OnlineResultParticipant'),
                ));

          }) ,
        ),
        ],
      ),
      body: SingleChildScrollView(
        child: body,
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:http/http.dart' as http;
import 'package:cekilismobil/json/jsonapi.dart';
import 'package:cekilismobil/screen/onlineupdateraffle.dart';
import 'package:cekilismobil/screen/onlineresultraffle.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
class OnlineMyRaffleDetail extends StatefulWidget {
  static var id_share;
  @override
  _OnlineMyRaffleDetailState createState() => new _OnlineMyRaffleDetailState();
}

class _OnlineMyRaffleDetailState extends State<OnlineMyRaffleDetail> with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var visible_status = false;
  var visible_completed = false;
  var loading = true;
  var detailform = false;

  var id_share;
  var title;
  var description;
  var contact_information;
  var expiration;
  var winners;
  var reserves;
  var creation_date;
  var last_update;
  var raffle_join_count;

  List<CountrySuggestionTypeSelected> countryselected = [];

  List<TagsType> tagsselected = [];

  Future<Null> fetchRaffle() async {
    final patch = "/raffle/my/detail";
    var api_key = await GlobalCode.storageread('api_key');
    var body = { 'api_key': api_key, 'version_code':GlobalCode.versionCode, 'id_share': OnlineMyRaffleDetail.id_share};
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
        title = result['title'];
        description = result['description'];
        contact_information = result['contact_information'];
        expiration = GlobalCode.datetimetoLOCAL(result['expiration']);
        winners = result['winners'];
        reserves = result['reserves'];
        creation_date = GlobalCode.datetimetoLOCAL(result['creation_date']);
        last_update = GlobalCode.datetimetoLOCAL(result['last_update']);
        raffle_join_count = result['raffle_join_count'];

        if (result['status'] == true) {
          visible_status = false;
        } else {
          visible_status = true;
        }

        loading = false;
        detailform = true;
        visible_completed = result['completed'];

        tagsselected.clear();
        countryselected.clear();
        List tags = result['tags'];
        List countries = result['countries'];
        for (var tag in tags) {
          tagsselected.add(new TagsType(tag));
        }

        for (var country in countries) {
          countryselected.add(new CountrySuggestionTypeSelected(
              country['value'], country['name']));
        }

      });

      }

    } else {
      // If that call was not successful, throw an error.
      GlobalCode.toast(GlobalCode.lang(context, 'Connection_error'));
    }
  }

  bool tagvisiblecheck()
  {

    if(tagsselected.length != 0)
    {
      return true;
    }else{
      return false;
    }

  }


  bool countryvisiblecheck()
  {

    if(countryselected.length != 0)
    {
      return true;
    }else{
      return false;
    }

  }

  Future<Null> DeleteRaffle() async {
    final patch = "/raffle/delete";
    var api_key = await GlobalCode.storageread('api_key');
    var body = {
      'version_code':GlobalCode.versionCode,
      'api_key': api_key,
      'id_share': OnlineMyRaffleDetail.id_share
    };
    final response =
    await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      var result = json.decode(response.body);
      GlobalCode.toast(GlobalCode.lang(context, result['result']));

    } else {
      // If that call was not successful, throw an error.
      GlobalCode.toast(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  Future<Null> StartRaffle() async {
    final patch = "/raffle/start";
    var api_key = await GlobalCode.storageread('api_key');
    var body = {
      'version_code':GlobalCode.versionCode,
      'api_key': api_key,
      'id_share': OnlineMyRaffleDetail.id_share
    };
    final response =
    await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      var result = json.decode(response.body);
      GlobalCode.toast(GlobalCode.lang(context, result['result']));

    } else {
      // If that call was not successful, throw an error.
      GlobalCode.toast(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  void _showDeleteDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(GlobalCode.lang(context, 'Delete_the_raffle')),
          content: new Text(GlobalCode.lang(context, 'The_process_is_irreversible')),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))
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
                DeleteRaffle();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),

          ],
        );
      },
    );
  }


  void _showStartDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(GlobalCode.lang(context, 'Start_the_raffle')),
          content: new Text(GlobalCode.lang(context, 'The_process_is_irreversible')),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))
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
                StartRaffle();
                Navigator.of(context).pop();
              },
            ),

          ],
        );
      },
    );
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
              child: new CircularProgressIndicator(backgroundColor: Color.fromRGBO(29, 29, 29, 1)),
    )));

    Widget _onlinerafflesharedetailform = new Container(
      child: Visibility(
        visible: detailform,
        child: Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(GlobalCode.lang(context, 'Share_address'),
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('https://lucksend.com/share/$id_share', style: TextStyle(color: Colors.white70)),
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
                  subtitle: Text('$id_share', style: TextStyle(color: Colors.white70)),
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

    Widget _onlineraffledetailform = new Container(
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
                  title: Text('$contact_information'),
                  leading: Icon(
                    Icons.contacts,
                    color: Colors.white70,
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('$winners',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('$reserves', style: TextStyle(color: Colors.white70)),
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
                new Visibility(
                  visible: tagvisiblecheck(),
                  child: new ListTile(
                    leading: const Icon(Icons.text_fields, color: Colors.white70),
                    title: new ListView.builder(
                        physics: PageScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: tagsselected == null ? 0 : tagsselected.length,
                        itemBuilder: (BuildContext context, int index) {
                          return
                            new GestureDetector(
                              child: new Container(
                                child: new Center(
                                    child: new Column(
                                      // Stretch the cards in horizontal axis
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        new Text(
                                          // Read the name field value and set it in the Text widget
                                          tagsselected[index].tagsName,
                                          // set some style to text
                                          style: new TextStyle(color: Colors.white70,fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    )),
                                padding: const EdgeInsets.all(15.0),
                              ),
                            );
                        }),
                  ),
                ),
                Divider(),
                new Visibility(
                  visible: countryvisiblecheck(),
                  child: new ListTile(
                    leading: const Icon(Icons.language, color: Colors.white70),
                    title: new ListView.builder(
                        physics: PageScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: countryselected == null ? 0 : countryselected.length,
                        itemBuilder: (BuildContext context, int index) {
                          return
                            new GestureDetector(
                              child: new Container(
                                child: new Center(
                                    child: new Column(
                                      // Stretch the cards in horizontal axis
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        new Text(
                                          // Read the name field value and set it in the Text widget
                                          countryselected[index].countryName,
                                          // set some style to text
                                          style: new TextStyle(color: Colors.white70,fontWeight: FontWeight.w500),
                                        ),
                                        new Text(
                                          // Read the name field value and set it in the Text widget
                                          countryselected[index].countryCode,
                                          // set some style to text
                                          style: new TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    )),
                                padding: const EdgeInsets.all(15.0),
                              ),
                            );
                        }),
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
          ),
      )
    );


    Widget body = new Column(
      // This makes each child fill the full width of the screen
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _onlinerafflesharedetailform,
        _onlineraffledetailform,
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
            visible: visible_status,
            child: IconButton(icon: const Icon(Icons.delete), onPressed: (
                ) {
              _showDeleteDialog();
            }),
          ),

          Visibility(
            visible: visible_status,
            child: IconButton(icon: const Icon(Icons.mode_edit), onPressed: (
                ) {

              OnlineUpdateRaffle.id_share = OnlineMyRaffleDetail.id_share;
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => new OnlineUpdateRaffle(),
                      settings: RouteSettings(name: 'OnlineUpdateRaffle'),
                  ));

            }),
          ),


          Visibility(
            visible: visible_completed,
            child: IconButton(icon: const Icon(Icons.assignment), onPressed: (
                ) {

              OnlineResultRaffle.id_share = OnlineMyRaffleDetail.id_share;
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => new OnlineResultRaffle(),
                      settings: RouteSettings(name: 'OnlineResultRaffle'),
                  ));

            }),
          ),

          Visibility(
            visible: visible_status,
            child: IconButton(icon: const Icon(Icons.play_arrow), onPressed: (
                ) {

              _showStartDialog();

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

class CountrySuggestionTypeSelected {
  String countryCode, countryName;
  CountrySuggestionTypeSelected(this.countryCode, this.countryName);
}

class TagsType {
  String tagsName;
  TagsType(this.tagsName);
}
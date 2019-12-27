import 'dart:convert';
import 'package:cekilismobil/json/model/tag.dart';
import 'package:cekilismobil/screen/socialsearchlist.dart';
import 'package:http/http.dart' as http;
import 'package:cekilismobil/json/jsonapi.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:cekilismobil/database/dbhelper.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:progress_dialog/progress_dialog.dart';


class SocialSearch extends StatefulWidget {
  @override
  _SocialSearchState createState() => new _SocialSearchState();

}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
var db = new DBHelper();
bool _autoValidate = false;

var tag = new TextEditingController();


bool _validateInputs() {
  if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
    _formKey.currentState.save();
    return true;
  } else {
    return false;
  }
}

class _SocialSearchState extends State<SocialSearch> {
  List<Tag> tag_items = new List();

  @override
  void initState() {
    super.initState();
    _fetchTagSearchTop();
  }


  void _fetchTagSearch(var tag) async {
    ProgressDialog pr;
    pr = new ProgressDialog(context,ProgressDialogType.Normal);
    pr.setMessage(GlobalCode.lang(context, 'Please_wait'));
    pr.show();
    final patch = "/socialmedia/search";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code':version_code, 'tag':GlobalCode.TagUnsupportedCharacter(tag)};
    var response = await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      tag_items = items.map<Tag>((json) {
        return Tag.fromJson(json);
      }).toList();
      pr.hide();
      raffleinputclear();
      setState(() {

      });

    } else {
      throw Exception(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  void _fetchTagSearchTop() async {
    final patch = "/socialmedia/search/top";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code':version_code};
    var response = await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      tag_items = items.map<Tag>((json) {
        return Tag.fromJson(json);
      }).toList();
      setState(() {

      });

    } else {
      throw Exception(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  void raffleinputclear()
  {
    tag.text = "";
  }


  @override
  Widget build(BuildContext context) {

    Widget _localnewraffleform = new Container
      (
        child: new Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Card(
            child: Column(
              children: <Widget>[
                new ListTile(
                  leading: const Icon(Icons.input, color: Colors.white70),
                  title: new TextFormField(
                    maxLength: 60,
                    validator: (value) {
                      value = value.trim();
                      if (value.isEmpty) {
                        return GlobalCode.lang(context, 'Cannot_be_empty');
                      }
                    },
                    controller: tag,
                    decoration: new InputDecoration(
                      hintText: GlobalCode.lang(context, 'Tag'),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ));


    Widget raffleslist = new Container (
      child: ListView.builder(
          physics: PageScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: tag_items.length,
          itemBuilder: (context, position) {
            return Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.star, color: Colors.white70),
                      title: Text(
                        '${tag_items[position].tag_name}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
                      onTap: () {
                        SocialSearchList.tag_id = tag_items[position].id;
                        SocialSearchList.tag_name = tag_items[position].tag_name;
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                              builder: (
                                  BuildContext context) => new SocialSearchList(),
                              settings: RouteSettings(name: 'SocialSearchList'),
                            ));

                      },
                    ),
                  ],
                ));
          }),
    );


    Widget body = new Column(
      // This makes each child fill the full width of the screen
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _localnewraffleform,
        raffleslist
      ],
    );


    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: new AppBar(
        title: new Text(GlobalCode.lang(context, 'Search_Product')),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.search), onPressed: (
              ) {  if(_validateInputs()) {_fetchTagSearch(tag.text);}  })
        ],
      ),
      body: new SingleChildScrollView(
          child:body


      ),


    );



  }
}
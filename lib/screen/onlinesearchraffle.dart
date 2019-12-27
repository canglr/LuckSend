import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cekilismobil/json/jsonapi.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:cekilismobil/screen/onlinesearchdetail.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';


class OnlineSearchRaffle extends StatefulWidget {
  _OnlineSearchRaffleState createState() => _OnlineSearchRaffleState();
}

class _OnlineSearchRaffleState extends State<OnlineSearchRaffle> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  var inputidshare = new TextEditingController();

  var visible_search = false;


  String title;
  String id_share;
  bool found = true;


  bool _validateInputs() {
    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      return true;
    } else {
      return false;
    }
  }


  Future<Null> _fetchsearchcheck() async {
    final patch = "/raffle/search";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = await GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code':version_code, 'id_share': inputidshare.text};
    var response = await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      var result = json.decode(response.body);

      if(result['api_status'].toString() == 'false')
      {
        GlobalCode.apiError(result['api_result'], context);
      }else {
        setState(() {
          visible_search = true;

          title = result['title'];
          id_share = result['id_share'];
          found = result['found'];
        });
      }
    } else {
      throw Exception(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        inputidshare.text = qrResult;
      });
      _fetchsearchcheck();
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          GlobalCode.toast(GlobalCode.lang(context, 'Camera_permission_was_denied'));
        });
      } else {
        setState(() {
          GlobalCode.toast(GlobalCode.lang(context, 'Unknown_Error')+" $ex");
        });
      }
    } on FormatException {
      setState(() {
        GlobalCode.toast(GlobalCode.lang(context, 'You_pressed_the_back_button_before_scanning_anything'));
      });
    } catch (ex) {
      setState(() {
        GlobalCode.toast(GlobalCode.lang(context, 'Unknown_Error')+" $ex");
      });
    }
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
                  leading: const Icon(Icons.card_giftcard, color: Colors.white70),
                  title: new TextFormField(
                    maxLength: 30,
                    validator: (value) {
                      value = value.trim();
                      if (value.isEmpty) {
                        return GlobalCode.lang(context, 'Cannot_be_empty');
                      }
                    },
                    controller: inputidshare,
                    decoration: new InputDecoration(
                      hintText: GlobalCode.lang(context, 'Share_code')+' (9qjPzh...)',
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
                      title: Text('$title',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('$id_share',
                          style: TextStyle(color: Colors.white70)),
                      leading: Icon(
                        Icons.card_giftcard,
                        color: Colors.white70,
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
                      onTap: () {

                        if(found != false)
                          {

                            OnlineSearchDetail.id_share = id_share;
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (BuildContext context) => new OnlineSearchDetail(),
                                    settings: RouteSettings(name: 'OnlineSearchDetail'),
                                ));

                          }

                      },
                    ),


                  ],
                )))
    );


    Widget body = new Column(
      // This makes each child fill the full width of the screen
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _onlinecheckuserraffleform,
        _onlinesecretkeyusershowform
      ],
    );


    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: AppBar(
        title: Text(GlobalCode.lang(context, 'Raffle_Search')),
        actions: <Widget>[

          new IconButton(icon: const Icon(Icons.linked_camera), onPressed: (
              ) {
            _scanQR();

          }),

          new IconButton(icon: const Icon(Icons.search), onPressed: (
              ) {
                if(_validateInputs()) {
                  _fetchsearchcheck();
                }

          }),


        ],
      ),
      body: new SingleChildScrollView(
          child:body
      ),
    );
  }
}
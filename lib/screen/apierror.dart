import 'package:flutter/material.dart';
import 'package:cekilismobil/global_class/globalcode.dart';

import '../main.dart';


class ApiError extends StatefulWidget {
  static var msg;
  _ApiErrorState createState() => _ApiErrorState();
}

class _ApiErrorState extends State<ApiError> {


  @override
  Widget build(BuildContext context) {

    Widget _apierrorwidget = new Container(
        child: Card(
            child: Column(
              children: <Widget>[
                new ListTile(
                  leading: const Icon(Icons.mood_bad, color: Colors.white70),
                  title: new Text(GlobalCode.lang(context, ApiError.msg)),
                ),

              ],
            ),
          ),

      );


    Widget body = new Column(
      // This makes each child fill the full width of the screen
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _apierrorwidget
      ],
    );


    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: AppBar(
        actions: <Widget>[

          new IconButton(icon: const Icon(Icons.close), onPressed: (
              ) {

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => MyApp(),
                    settings: RouteSettings(name: 'MyApp'),
                ),
                ModalRoute.withName("/Main")
            );

          })

        ],
      ),
      body: new SingleChildScrollView(
          child:body
      ),
    );
  }
}
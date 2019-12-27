import 'package:flutter/material.dart';
import 'package:cekilismobil/database/model/results.dart';
import 'package:cekilismobil/database/dbhelper.dart';
import 'package:cekilismobil/global_class/globalcode.dart';

class LocalResults extends StatefulWidget {
  static var raffleid;
  @override
  _LocalResultsState createState() => new _LocalResultsState();
}

var db = new DBHelper();


class _LocalResultsState extends State<LocalResults> {
  List<Results> items = new List();
  var raffle_name;
  var count;
  var participantscount;


  void raffleget()
  {
    db.detailRaffle(LocalResults.raffleid).then((raffles) {
      setState(() {
        raffles.forEach((raffle) {
          raffle_name = raffle["name"];
        });
      });
    });
  }


  void getcount(){
    db.getResultsCount(LocalResults.raffleid).then(
            (value){
          setState(() {  this.count = value.toString();  });
        }
    );
  }


  void getparticipantscount(){
    db.getParticipantsCount(LocalResults.raffleid).then(
            (value){
          setState(() {  this.participantscount = value.toString();  });
        }
    );
  }



  @override
  void initState() {
    super.initState();

    db.getAllResults(LocalResults.raffleid).then((results) {
      setState(() {
        results.forEach((result) {
          items.add(Results.fromMap(result));
        });
      });
    });

    raffleget();
    getcount();
    getparticipantscount();

  }


  void resultlistrefresh()
  {
    db.getAllResults(LocalResults.raffleid).then((results) {
      setState(() {
        items.clear();
        results.forEach((result) {
          items.add(Results.fromMap(result));
        });
      });
    });
  }


  void _showDeleteDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(GlobalCode.lang(context, 'Delete_the_results')),
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                db.deleteResults(LocalResults.raffleid);
                db.updateDatetimeRaffle(LocalResults.raffleid, GlobalCode.datetimenow());
              },
            ),

          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    Widget _raffleinformation = new Container(
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: Text('$raffle_name',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              leading: Icon(
                Icons.card_giftcard,
                color: Colors.white70,
              ),
            ),
            Divider(),
            ListTile(
              title: Text('$participantscount'),
              leading: Icon(
                Icons.person,
                color: Colors.white70,
              ),
            ),
            Divider(),
            ListTile(
              title: Text('$count'),
              leading: Icon(
                Icons.star,
                color: Colors.white70,
              ),
            ),

          ],
        ),
      ),
    );




    Widget resultslist = new Container (
          child: ListView.builder(
              physics: PageScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, position) {
                return Card( child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.star, color: Colors.white70),
                      title: Text(
                        '${items[position].participant}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
        _raffleinformation,
        resultslist
      ],
    );


    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: new AppBar(
        title: new Text(GlobalCode.lang(context, 'Raffle_Result')),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.delete), onPressed: (
              ) {
            _showDeleteDialog();
          })
        ],
      ),
      body: new SingleChildScrollView(
          child:body


      ),


    );



  }
}
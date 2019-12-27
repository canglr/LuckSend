import 'package:flutter/material.dart';
import 'package:cekilismobil/database/model/participants.dart';
import 'package:cekilismobil/database/dbhelper.dart';
import 'package:cekilismobil/global_class/globalcode.dart';

class LocalParticipants extends StatefulWidget {
  static var raffleid;
  @override
  _LocalParticipantsState createState() => new _LocalParticipantsState();
}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
var db = new DBHelper();
bool _autoValidate = false;

var participant_name = new TextEditingController();


bool _validateInputs() {
  if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
    _formKey.currentState.save();
    return true;
  } else {
    return false;
  }
}

class _LocalParticipantsState extends State<LocalParticipants> {
  List<Participants> items = new List();
  var resultstatus;

  @override
  void initState() {
    super.initState();

    db.getAllParticipants(LocalParticipants.raffleid).then((raffles) {
      setState(() {
        raffles.forEach((raffle) {
          items.add(Participants.fromMap(raffle));
        });
      });
    });

    getresultstatus();

  }


  void participantlistrefresh()
  {
    db.getAllParticipants(LocalParticipants.raffleid).then((participants) {
      setState(() {
        items.clear();
        participants.forEach((participant) {
          items.add(Participants.fromMap(participant));
        });
      });
    });
  }

  void getresultstatus() async{
    int count = 0;
    await db.getResultsCount(LocalParticipants.raffleid).then(
            (value){
          count = value;
        }
    );
    if(count == 0)
    {
      resultstatus = true;
    }else{
      resultstatus = false;
    }
  }

  void participantinputclear()
  {
    participant_name.text = "";
  }


  Future<void> saveRaffle() async {
    if(_validateInputs()) {


      db.getParticipantNameCount(LocalParticipants.raffleid,participant_name.text).then(
              (value){

                if(value == 0)
                  {
                    db.saveParticipants(new Participants(LocalParticipants.raffleid, participant_name.text, GlobalCode.datetimenow()));
                    db.updateDatetimeRaffle(LocalParticipants.raffleid, GlobalCode.datetimenow());
                    participantlistrefresh();
                    participantinputclear();
                  }else{

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of type Dialog
                      return AlertDialog(
                        title: new Text(GlobalCode.lang(context, 'Warning')),
                        content: new Text(GlobalCode.lang(context, 'Add_the_same_name_anyway')),
                        actions: <Widget>[
                          // usually buttons at the bottom of the dialog
                          new FlatButton(
                            child: new Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                              participantinputclear();
                            },
                          ),

                          new FlatButton(
                            child: new Icon(Icons.check),
                            onPressed: () {
                              Navigator.of(context).pop();
                              db.saveParticipants(new Participants(LocalParticipants.raffleid, participant_name.text, GlobalCode.datetimenow()));
                              db.updateDatetimeRaffle(LocalParticipants.raffleid, GlobalCode.datetimenow());
                              participantlistrefresh();
                              participantinputclear();
                            },
                          ),

                        ],
                      );
                    },
                  );

                }

          }
      );

    }
  }


  void _showDeleteDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(GlobalCode.lang(context, 'Delete_the_participants_from_the_draw')),
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
                db.deleteParticipants(LocalParticipants.raffleid);
                db.updateDatetimeRaffle(LocalParticipants.raffleid, GlobalCode.datetimenow());
                participantlistrefresh();
              },
            ),

          ],
        );
      },
    );
  }

  raffleDropdownDialog(BuildContext context, var id, var name) async {
    String _value = '1';
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(name),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))
            ),
            content: DropdownButton<String>(
              items: [
                DropdownMenuItem(
                  value: "0",
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.list),
                      SizedBox(width: 10),
                      Text(
                          GlobalCode.lang(context, 'Choose')
                      ),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: "1",
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete_outline),
                      SizedBox(width: 10),
                      Text(
                          GlobalCode.lang(context, 'Delete')
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _value = value;

                  if(_value == "1")
                  {
                    if(resultstatus)
                    {
                      db.deleteParticipant(id);
                      db.updateDatetimeRaffle(LocalParticipants.raffleid, GlobalCode.datetimenow());
                      participantlistrefresh();
                      Navigator.of(context).pop();
                    }else{
                      Navigator.of(context).pop();
                      GlobalCode.toast(GlobalCode.lang(context, 'The_change_is_not_accepted'));
                    }
                  }

                });

              },
              value: _value,
              isExpanded: true,
            ),

          );
        });
  }


  @override
  Widget build(BuildContext context) {

    Widget _localnewparticipantform = new Container
      (
        child: new Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Card(
            child: Column(
              children: <Widget>[
                new ListTile(
                  leading: const Icon(Icons.person_add, color: Colors.white70),
                  title: new TextFormField(
                    maxLength: 30,
                    validator: (value) {
                      value = value.trim();
                      if (value.isEmpty) {
                        return GlobalCode.lang(context, 'Cannot_be_empty');
                      }
                    },
                    controller: participant_name,
                    decoration: new InputDecoration(
                      hintText: GlobalCode.lang(context, 'Participant_Name'),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ));




    Widget participantslist = new Container (
          child: ListView.builder(
              physics: PageScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, position) {
                return Card( child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.person, color: Colors.white70),
                      title: Text(
                        '${items[position].participant}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
                      onTap: () {
                        raffleDropdownDialog(context,items[position].id,items[position].participant);
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
        _localnewparticipantform,
        participantslist
      ],
    );


    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: new AppBar(
        title: new Text(GlobalCode.lang(context, 'Participants')),
        actions: <Widget>[

          new IconButton(icon: const Icon(Icons.delete), onPressed: (
              ) {
                      if(resultstatus)
                      {
                        _showDeleteDialog();
                      }else{
                      GlobalCode.toast(GlobalCode.lang(context, 'The_change_is_not_accepted'));
                      }

                }),

          new IconButton(icon: const Icon(Icons.save), onPressed: (
              ) {
                    if(resultstatus)
                    {
                      saveRaffle();
                    }else{
                    GlobalCode.toast(GlobalCode.lang(context, 'The_change_is_not_accepted'));
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
import 'package:cekilismobil/global_class/appads.dart';
import 'package:cekilismobil/global_class/rafflestart.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:cekilismobil/database/dbhelper.dart';
import 'package:cekilismobil/screen/localupdateraffle.dart';
import 'package:cekilismobil/screen/localparticipants.dart';
import 'package:cekilismobil/screen/localresults.dart';
import 'package:flutter/services.dart';
import 'package:cekilismobil/global_class/globalcode.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
class LocalRaffleDetail extends StatefulWidget {
  static var raffleid;
  @override
  _LocalRaffleDetailState createState() => new _LocalRaffleDetailState();
}

class _LocalRaffleDetailState extends State<LocalRaffleDetail> with RouteAware {
  var db = new DBHelper();
  TextEditingController _raffleStartCountController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var raffle_name;
  var raffle_description;
  var raffle_createdat;
  var raffle_updatedat;
  var count;
  var resultstatus;


  void raffleget()
  {
    db.detailRaffle(LocalRaffleDetail.raffleid).then((raffles) {
      setState(() {
        raffles.forEach((raffle) {
          raffle_name = raffle["name"];
          raffle_description = raffle["description"];
          raffle_createdat = raffle["createdat"];
          raffle_updatedat = raffle["updatedat"];
        });
      });
    });
  }

  void getcount(){
    db.getParticipantsCount(LocalRaffleDetail.raffleid).then(
            (value){
              setState(() {  this.count = value.toString();  });
        }
    );
  }

  void getresultstatus() async{
    int count = 0;
    await db.getResultsCount(LocalRaffleDetail.raffleid).then(
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


  _raffleStartDialog(BuildContext context) async {
    var count = int.parse(this.count)-1;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(GlobalCode.lang(context, 'Options_Raffle')),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))
            ),
            content: TextField(
              autofocus: true,
              inputFormatters: [
                WhitelistingTextInputFormatter.digitsOnly
              ],
              controller: _raffleStartCountController,
              decoration: InputDecoration(hintText: '${GlobalCode.lang(context, 'min')}: 1 - ${GlobalCode.lang(context, 'max')}: $count '),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Icon(Icons.close),
                onPressed: () {
                  _raffleStartCountController.clear();
                  Navigator.of(context).pop();
                },
              ),

              new FlatButton(
                child: new Icon(Icons.check),
                onPressed: () {
                    if(_raffleStartCountController.text.toString().length == 0)
                    {

                      GlobalCode.toast(GlobalCode.lang(context, 'Cannot_be_empty'));

                    }else if(int.parse(_raffleStartCountController.text) <= 0)
                    {

                      GlobalCode.toast(GlobalCode.lang(context, 'zero_and_cannot_be_less_than_zero'));

                    }else if(int.parse(_raffleStartCountController.text) > count)
                    {

                      GlobalCode.toast('${GlobalCode.lang(context, 'min')}: 1 - ${GlobalCode.lang(context, 'max')}: $count ');

                    }else{
                        var raffleStartCount = _raffleStartCountController.text;
                        RaffleStart rafflestart = new RaffleStart();
                        rafflestart.start(LocalRaffleDetail.raffleid, int.parse(raffleStartCount),context);
                        _raffleStartCountController.clear();
                    }
                },
              ),
            ],
          );
        });
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                db.deleteFullRaffle(LocalRaffleDetail.raffleid);
              },
            ),

          ],
        );
      },
    );
  }


  void _showRaffleResultDeleteDialog() {
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
                db.deleteResults(LocalRaffleDetail.raffleid);
                db.updateDatetimeRaffle(LocalResults.raffleid, GlobalCode.datetimenow());
                getresultstatus();
                _raffleStartDialog(context);
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
    AppAds.init();
    AppAds.showBanner(state: this, size: AdSize.smartBanner, testDevices: GlobalCode.adsTestingDevice, testing: GlobalCode.adsTesting);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
    raffleget();
    getcount();
    getresultstatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(GlobalCode.lang(context, 'Raffle_Details')),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.delete), onPressed: (
              ) {

            _showDeleteDialog();

          }),
          new IconButton(icon: const Icon(Icons.mode_edit), onPressed: (
              ) {
            AppAds.showScreen(state: this,testDevices: GlobalCode.adsTestingDevice,testing: true);

            if(resultstatus) {
            LocalUpdateRaffle.raffleid = LocalRaffleDetail.raffleid;
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (BuildContext context) => new LocalUpdateRaffle(),
                    settings: RouteSettings(name: 'LocalUpdateRaffle'),
                ));
            }else{
              GlobalCode.toast(GlobalCode.lang(context, 'The_change_is_not_accepted'));
            }

          }),
          new IconButton(icon: const Icon(Icons.assignment), onPressed: (
              ) {

              AppAds.showScreen(state: this,testDevices: GlobalCode.adsTestingDevice,testing: true);

              LocalResults.raffleid = LocalRaffleDetail.raffleid;
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (BuildContext context) => new LocalResults(),
                      settings: RouteSettings(name: 'LocalResults'),
                  ));


          }),
          new IconButton(icon: const Icon(Icons.play_arrow), onPressed: (
              ) {

            if(resultstatus) {
              _raffleStartDialog(context);
            }else{
              _showRaffleResultDeleteDialog();
            }

          })
        ],
      ),
      body: SingleChildScrollView(
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
                  title: Text('$raffle_description'),
                  leading: Icon(
                    Icons.description,
                    color: Colors.white70,
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('$raffle_createdat'),
                  leading: Icon(
                    Icons.access_time,
                    color: Colors.white70,
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('$raffle_updatedat'),
                  leading: Icon(
                    Icons.update,
                    color: Colors.white70,
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('$count'),
                  leading: Icon(
                    Icons.person_add,
                    color: Colors.white70,
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
                  onTap: (){

                    AppAds.showScreen(state: this,testDevices: GlobalCode.adsTestingDevice,testing: GlobalCode.adsTesting);

                    LocalParticipants.raffleid = LocalRaffleDetail.raffleid;
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => new LocalParticipants(),
                            settings: RouteSettings(name: 'LocalParticipants'),
                        ));

                  },
                ),
              ],
            ),
          ),
        ),
    );
  }
}
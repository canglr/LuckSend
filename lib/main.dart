import 'package:cached_network_image/cached_network_image.dart';
import 'package:cekilismobil/screen/gamedice.dart';
import 'package:cekilismobil/screen/onlineweb.dart';
import 'package:cekilismobil/screen/socialnew.dart';
import 'package:cekilismobil/screen/socialraffles.dart';
import 'package:cekilismobil/screen/socialsaved.dart';
import 'package:cekilismobil/screen/socialsearch.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import './screen/localraffles.dart';
import './screen/accountinformation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:cekilismobil/json/jsonapi.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:cekilismobil/screen/onlinemyraffles.dart';
import 'package:cekilismobil/screen/onlinemyparticipants.dart';
import 'package:cekilismobil/screen/onlinesearchraffle.dart';
import 'database/dbhelper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'global_class/appads.dart';
import 'translations.dart';
import 'package:ads/ads.dart';


final GoogleSignIn googleSignIn = GoogleSignIn();
FirebaseAnalytics analytics = FirebaseAnalytics();

void main() => runApp(MyApp());

JsonApi api = JsonApi();
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luck Send',
      theme: ThemeData(
        cursorColor: Colors.white70,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Colors.black,
        accentColor: Colors.white70,
        primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(
            color: Colors.white70,
        ),
        primaryTextTheme: TextTheme(
          title: TextStyle(
            color: Colors.white70,
          ),
        ),
        hintColor: Colors.white70,
        dialogTheme: Theme.of(context).dialogTheme.copyWith(
          backgroundColor: Color.fromRGBO(29, 29, 29, 1),
        ),
        cardTheme: Theme.of(context).cardTheme.copyWith(
          color: Color.fromRGBO(29, 29, 29, 1),
        ),
        iconTheme: Theme.of(context).iconTheme.copyWith(
          color: Colors.white70,
        ),

        canvasColor: Color.fromRGBO(29, 29, 29, 1),
        textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.white70),
        cardColor: Color.fromRGBO(29, 29, 29, 1),

      ),
      localizationsDelegates: [
        const TranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('tr', ''),
      ],
      home: MyHomePage(title: 'Luck Send'),
      builder: (context, widget) {
        return new Padding(
          child: widget,
          padding: new EdgeInsets.only(bottom: GlobalCode.bannerAdsPadding),
        );
      },
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
        MyNavigatorObserver()
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _profileImage;
  var description = new TextEditingController();
  String local_raffle_count = '0';
  String raffle_count = '-1';
  String participants_count = '-1';
  var visible_stats = false;
  var name = '';
  var mail_address = '';
  var loginCheck = false;


  void CheckLogin()
  {
    GlobalCode.storageread('api_key').then((
        dynamic result) {
      if(result != null)
      {
        setState(() {
          loginCheck = true;
        });

        GlobalCode.storageread('name').then((
            dynamic result) {
          setState(() {
            name = result;
          });
        });

        GlobalCode.storageread('mail_address').then((
            dynamic result) {
          setState(() {
            mail_address = result;
          });
        });

        GlobalCode.storageread('profile_picture').then((
            dynamic result) {
          setState(() {
            _profileImage = result;
          });
        });

        getdashboardStats();

      }else{
        setState(() {
          loginCheck = false;
        });

      }
    });


  }

   AdEventListener _eventListener = (MobileAdEvent event) {
    if (event != MobileAdEvent.loaded) {
      GlobalCode.bannerAdsPadding = 0.0;
    }
  };

  @override
  void initState() {
    super.initState();
    CheckLogin();
    getRaffleCount();
    getreleaseStatus();
    AppAds.init();
    AppAds.showBanner(state: this, size: AdSize.smartBanner, listener: _eventListener, testDevices: GlobalCode.adsTestingDevice, testing: GlobalCode.adsTesting);
    setState(() {

    });
  }



  Future<void> _handleSignIn() async {
    try {
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
      api.userCheckPost(context,googleSignInAuthentication.idToken);
      await new Future.delayed(const Duration(seconds : 3));
      CheckLogin();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    googleSignIn.disconnect();
  }

  void _showAccountExitDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(GlobalCode.lang(context, 'Exit')),
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
                api.accountExit(context);
                _handleSignOut();
                setState(() {
                  loginCheck = false;
                });
                Navigator.of(context).pop();
              },
            ),

          ],
        );
      },
    );
  }


  feedbacksDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(GlobalCode.lang(context, 'Feedback')),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))
            ),
            content: new TextFormField(
              maxLines: null,
              keyboardType: TextInputType.multiline,
              maxLength: 350,
              controller: description,
              decoration: new InputDecoration(
                hintText: GlobalCode.lang(context, 'Description'),
              ),
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
                  feedbacksSend(description.text);
                },
              ),

            ],

          );
        });
  }


  void _showReleaseUpdateDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(GlobalCode.lang(context, 'New_version_available_please_update')),
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
              child: new Icon(Icons.system_update_alt),
              onPressed: () {
                _getrateusURL();
              },
            ),

          ],
        );
      },
    );
  }


  Widget _buildBody() {
    if (loginCheck) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(name ?? '', style: TextStyle(color: Colors.white70)),
            accountEmail: Text(mail_address ?? '', style: TextStyle(color: Colors.white70)),
            currentAccountPicture: CircleAvatar(
                radius: 20,
                backgroundImage: CachedNetworkImageProvider(_profileImage ?? 'https://lucksend.com/static/app/images/noprofile.png')
            ),
            decoration: BoxDecoration(color: Colors.black),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(GlobalCode.lang(context, 'Welcome_Guest')),
            currentAccountPicture: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/noprofile.png')
            ),
            decoration: BoxDecoration(color: Colors.black),
          ),
        ],
      );
    }
  }

  Future<Null> getUser() async {
    ProgressDialog pr;
    pr = new ProgressDialog(context,ProgressDialogType.Normal);
    pr.setMessage(GlobalCode.lang(context, 'Please_wait'));
    pr.show();
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code': version_code};
    final patch = "/account/my";
    final response =
    await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var result = json.decode(response.body);
      if(result['api_status'].toString() == 'false')
      {
        pr.hide();
        GlobalCode.apiError(result['api_result'], context);
      }else {
        AccountInformation.data = json.decode(response.body);
        AccountInformation.profileImage = _profileImage;
        pr.hide();
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) => new AccountInformation(),
                settings: RouteSettings(name: 'AccountInformation'),
            ));
      }

    } else {
      pr.hide();
      GlobalCode.toast(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  Future<Null> feedbacksSend(var msg) async {
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code': version_code, 'description':msg};
    final patch = "/feedbacks";
    final response =
    await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var result = json.decode(response.body);
      if(result['api_status'].toString() == 'false')
      {
        GlobalCode.toast(GlobalCode.lang(context, result['api_result']));
      }else {
        GlobalCode.toast(GlobalCode.lang(context, result['api_result']));
        Navigator.of(context).pop();
        description.text = "";
      }

    } else {
      GlobalCode.toast(GlobalCode.lang(context, 'Connection_error'));
    }
  }

  Future<Null> getdashboardStats() async {
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = GlobalCode.versionCode;
    var body = { 'api_key': api_key, 'version_code': version_code};
    final patch = "/dashboard/stats";
    final response =
    await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var result = json.decode(response.body);
      if(result['api_status'].toString() == 'false')
      {
        GlobalCode.toast(GlobalCode.lang(context, result['api_result']));
      }else {
        setState(() {
          raffle_count = result["raffle"].toString();
          participants_count = result["participants"].toString();
          visible_stats = true;
        });
      }

    } else {
      print(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  Future<Null> getreleaseStatus() async {
    var version_code = GlobalCode.versionCode;
    var body = {'version_code': version_code};
    final patch = "/release/status";
    final response =
    await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      var result = json.decode(response.body);
      if(result['api_status'].toString() == 'false')
      {
        _showReleaseUpdateDialog();
      }

    } else {
      print(GlobalCode.lang(context, 'Connection_error'));
    }
  }


  void getRaffleCount(){
    DBHelper db = new DBHelper();
    db.getRaffleCount().then(
            (value){
          setState(() {  this.local_raffle_count = value.toString();  });
        }
    );
  }

  void dashboardStatsRefresh()
  {
    getRaffleCount();
    if(loginCheck) {
      getdashboardStats();
    }

  }

  void dashboardMenu(int itemID)
  {

    if(itemID == 1) {

      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (BuildContext context) => new LocalRaffles(),
              settings: RouteSettings(name: 'LocalRaffles'),
          ));

    }else if(itemID == 2){

      GlobalCode.checkNet().then((result) {
        if (result) {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new OnlineMyRaffles(),
                  settings: RouteSettings(name: 'OnlineMyRaffles'),
              ));
        }else {
          GlobalCode.toast(
              GlobalCode.lang(context, "Check_your_internet_connection"));
        }
      });

    }else if(itemID == 3){

      GlobalCode.checkNet().then((result) {
        if (result) {
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) => new OnlineMyParticipants(),
                  settings: RouteSettings(name: 'OnlineMyParticipants'),
              ));
        }else {
          GlobalCode.toast(
              GlobalCode.lang(context, "Check_your_internet_connection"));
        }
      });

    }else if(itemID == 4){

      GlobalCode.checkNet().then((result) {
        if (result) {
          Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (BuildContext context) => new SocialRaffles(),
                settings: RouteSettings(name: 'SocialRaffles'),
              ));
        }else {
          GlobalCode.toast(
              GlobalCode.lang(context, "Check_your_internet_connection"));
        }
      });

    }else{

    }

  }

  Widget _menuList(){
    if (loginCheck) {
      return _loginmenuList();
    }else{
      return _unloginmenuList();
    }
  }

  Widget _loginmenuList() {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        _buildBody(),

        ListTile(
          leading: Icon(
            Icons.person,
            color: Colors.white70,
          ),
          title: Text(GlobalCode.lang(context, 'My_account'), style: TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {

              GlobalCode.checkNet().then((result) {
                if (result) {
                  getUser();
                }else {
                  GlobalCode.toast(
                      GlobalCode.lang(context, "Check_your_internet_connection"));
                }
              });

          },
        ),

        ExpansionTile(
          leading: Icon(
            Icons.card_giftcard,
            color: Colors.white70,
          ),
          title: Text(GlobalCode.lang(context, 'Local_Sweepstakes'), style: TextStyle(fontWeight: FontWeight.bold)),
          children: <Widget>[
            ListTile(
              title: Text(GlobalCode.lang(context, 'My_sweepstakes')),
              leading: Icon(Icons.card_giftcard,color: Colors.white70),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer

                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new LocalRaffles(),
                        settings: RouteSettings(name: 'LocalRaffles'),
                    ));
              },
            ),

          ],
        ),

        ExpansionTile(
          leading: Icon(
            Icons.share,
            color: Colors.white70,
          ),
          title: Text(GlobalCode.lang(context, 'Online_Sweepstakes'), style: TextStyle(fontWeight: FontWeight.bold)),
          children: <Widget>[

            ListTile(
              title: Text(GlobalCode.lang(context, 'Raffle_Search')),
              leading: Icon(Icons.search,color: Colors.white70),
              onTap: () {

                GlobalCode.checkNet().then((result) {
                  if (result) {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => new OnlineSearchRaffle(),
                            settings: RouteSettings(name: 'OnlineSearchRaffle'),
                        ));
                  }else {
                    GlobalCode.toast(
                        GlobalCode.lang(context, "Check_your_internet_connection"));
                  }
                });


              },
            ),

            ListTile(
              title: Text(GlobalCode.lang(context, 'My_Social_Links')),
              leading: Icon(Icons.share,color: Colors.white70),
              onTap: () {

                GlobalCode.checkNet().then((result) {
                  if (result) {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => new OnlineMyRaffles(),
                            settings: RouteSettings(name: 'OnlineMyRaffles'),
                        ));
                  }else {
                    GlobalCode.toast(
                        GlobalCode.lang(context, "Check_your_internet_connection"));
                  }
                });

              },
            ),


            ListTile(
              title: Text(GlobalCode.lang(context, 'Sweepstakes_I_Participated')),
              leading: Icon(Icons.card_membership,color: Colors.white70),
              onTap: () {

                GlobalCode.checkNet().then((result) {
                  if (result) {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => new OnlineMyParticipants(),
                            settings: RouteSettings(name: 'OnlineMyParticipants'),
                        ));
                  }else {
                    GlobalCode.toast(
                        GlobalCode.lang(context, "Check_your_internet_connection"));
                  }
                });

              },
            ),


          ],
        ),


        ExpansionTile(
          leading: Icon(
            Icons.public,
            color: Colors.white70,
          ),
          title: Text(GlobalCode.lang(context, 'Social_Media'), style: TextStyle(fontWeight: FontWeight.bold)),
          children: <Widget>[

            ListTile(
              title: Text(GlobalCode.lang(context, 'Add_Product')),
              leading: Icon(Icons.add,color: Colors.white70),
              onTap: () {

                Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => new SocialNew(),
                      settings: RouteSettings(name: 'SocialNew'),
                    ));

              },
            ),


            ListTile(
              title: Text(GlobalCode.lang(context, 'Search_Product')),
              leading: Icon(Icons.search,color: Colors.white70),
              onTap: () {

                Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => new SocialSearch(),
                      settings: RouteSettings(name: 'SocialSearch'),
                    ));

              },
            ),


            ListTile(
              title: Text(GlobalCode.lang(context, 'Recently_added')),
              leading: Icon(Icons.restore,color: Colors.white70),
              onTap: () {

                Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => new SocialRaffles(),
                      settings: RouteSettings(name: 'SocialRaffles'),
                    ));

              },
            ),


            ListTile(
              title: Text(GlobalCode.lang(context, 'Saved')),
              leading: Icon(Icons.bookmark,color: Colors.white70),
              onTap: () {

                Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => new SocialSaved(),
                      settings: RouteSettings(name: 'SocialSaved'),
                    ));

              },
            ),


          ],
        ),


    ExpansionTile(
    leading: Icon(
      Icons.games,
      color: Colors.white70,
    ),
    title: Text(GlobalCode.lang(context, 'Games'), style: TextStyle(fontWeight: FontWeight.bold)),
    children: <Widget>[

      ListTile(
        title: Text(GlobalCode.lang(context, 'Dice')),
        leading: Icon(Icons.games,color: Colors.white70),
        onTap: () {

          Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (BuildContext context) => new GameDice(),
                settings: RouteSettings(name: 'GameDice'),
              ));

        },
      ),


    ],
    ),

        ListTile(
          leading: Icon(
            Icons.exit_to_app,
            color: Colors.white70,
          ),
          title: Text(GlobalCode.lang(context, 'Logout'), style: TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {
            _showAccountExitDialog();
          },
        ),

      ],
    );
  }


  Widget _unloginmenuList() {
    return ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        _buildBody(),

        ListTile(
          leading: Icon(
            Icons.person,
            color: Colors.white70,
          ),
          title: Text(GlobalCode.lang(context, 'Sign_in'), style: TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {

            GlobalCode.checkNet().then((result) {
              if (result) {
                _handleSignIn();
              }else {
                GlobalCode.toast(
                    GlobalCode.lang(context, "Check_your_internet_connection"));
              }
            });

          },
        ),

        ExpansionTile(
          leading: Icon(
            Icons.card_giftcard,
            color: Colors.white70,
          ),
          title: Text(GlobalCode.lang(context, 'Local_Sweepstakes'), style: TextStyle(fontWeight: FontWeight.bold)),
          children: <Widget>[
            ListTile(
              title: Text(GlobalCode.lang(context, 'My_sweepstakes')),
              leading: Icon(Icons.card_giftcard, color: Colors.white70),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) => new LocalRaffles(),
                        settings: RouteSettings(name: 'LocalRaffles'),
                    ));
              },
            ),

          ],
        ),

        ExpansionTile(
          leading: Icon(
            Icons.share,
            color: Colors.white70,
          ),
          title: Text(GlobalCode.lang(context, 'Online_Sweepstakes'), style: TextStyle(fontWeight: FontWeight.bold)),
          children: <Widget>[

            ListTile(
              title: Text(GlobalCode.lang(context, 'Raffle_Search')),
              leading: Icon(Icons.search, color: Colors.white70),
              onTap: () {

                GlobalCode.checkNet().then((result) {
                  if (result) {
                    _handleSignIn();
                  }else {
                    GlobalCode.toast(
                        GlobalCode.lang(context, "Check_your_internet_connection"));
                  }
                });

              },
            ),

            ListTile(
              title: Text(GlobalCode.lang(context, 'My_Social_Links')),
              leading: Icon(Icons.share, color: Colors.white70),
              onTap: () {

                GlobalCode.checkNet().then((result) {
                  if (result) {
                    _handleSignIn();
                  }else {
                    GlobalCode.toast(
                        GlobalCode.lang(context, "Check_your_internet_connection"));
                  }
                });

              },
            ),


            ListTile(
              title: Text(GlobalCode.lang(context, 'Sweepstakes_I_Participated')),
              leading: Icon(Icons.card_membership, color: Colors.white70),
              onTap: () {

                GlobalCode.checkNet().then((result) {
                  if (result) {
                    _handleSignIn();
                  }else {
                    GlobalCode.toast(
                        GlobalCode.lang(context, "Check_your_internet_connection"));
                  }
                });

              },
            ),


          ],
        ),


        ExpansionTile(
          leading: Icon(
            Icons.public,
            color: Colors.white70,
          ),
          title: Text(GlobalCode.lang(context, 'Social_Media'), style: TextStyle(fontWeight: FontWeight.bold)),
          children: <Widget>[

            ListTile(
              title: Text(GlobalCode.lang(context, 'Add_Product')),
              leading: Icon(Icons.add,color: Colors.white70),
              onTap: () {

                GlobalCode.checkNet().then((result) {
                  if (result) {
                    _handleSignIn();
                  }else {
                    GlobalCode.toast(
                        GlobalCode.lang(context, "Check_your_internet_connection"));
                  }
                });

              },
            ),


            ListTile(
              title: Text(GlobalCode.lang(context, 'Search_Product')),
              leading: Icon(Icons.search,color: Colors.white70),
              onTap: () {

                GlobalCode.checkNet().then((result) {
                  if (result) {
                    _handleSignIn();
                  }else {
                    GlobalCode.toast(
                        GlobalCode.lang(context, "Check_your_internet_connection"));
                  }
                });

              },
            ),


            ListTile(
              title: Text(GlobalCode.lang(context, 'Recently_added')),
              leading: Icon(Icons.restore,color: Colors.white70),
              onTap: () {

                GlobalCode.checkNet().then((result) {
                  if (result) {
                    _handleSignIn();
                  }else {
                    GlobalCode.toast(
                        GlobalCode.lang(context, "Check_your_internet_connection"));
                  }
                });

              },
            ),


            ListTile(
              title: Text(GlobalCode.lang(context, 'Saved')),
              leading: Icon(Icons.bookmark,color: Colors.white70),
              onTap: () {

                GlobalCode.checkNet().then((result) {
                  if (result) {
                    _handleSignIn();
                  }else {
                    GlobalCode.toast(
                        GlobalCode.lang(context, "Check_your_internet_connection"));
                  }
                });

              },
            ),


          ],
        ),


        ExpansionTile(
          leading: Icon(
            Icons.games,
            color: Colors.white70,
          ),
          title: Text(GlobalCode.lang(context, 'Games'), style: TextStyle(fontWeight: FontWeight.bold)),
          children: <Widget>[

            ListTile(
              title: Text(GlobalCode.lang(context, 'Dice')),
              leading: Icon(Icons.games,color: Colors.white70),
              onTap: () {

                Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => new GameDice(),
                      settings: RouteSettings(name: 'GameDice'),
                    ));

              },
            ),


          ],
        )

      ],
    );
  }

  _getprivacypolicyURL() async {
    const url = 'https://lucksend.com/PrivacyPolicy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _getrateusURL() async {
    const url = 'https://play.google.com/store/apps/details?id=net.gulernet.cekilisaraci';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color.fromRGBO(29, 29, 29, 1),
        label: Text(GlobalCode.lang(context, 'Rate_us'),style: new TextStyle(fontSize: 12.0, color: Colors.white70)),
        icon: Icon(Icons.star, color: Color.fromRGBO(187, 134, 252, 1)),
        onPressed: () {
          _getrateusURL();
        },
      ),

      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[

          new IconButton(icon: const Icon(Icons.search), onPressed: (
               ) {

              GlobalCode.checkNet().then((result) {
                if (result) {

                  if(loginCheck)
                  {
                    GlobalCode.checkNet();
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (BuildContext context) => new SocialSearch(),
                            settings: RouteSettings(name: 'SocialSearch'),
                        ));
                  }else{
                    _handleSignIn();
                  }
                }else{
                  GlobalCode.toast(GlobalCode.lang(context, "Check_your_internet_connection"));
                }

              });

          }),

          new IconButton(icon: const Icon(Icons.refresh), onPressed: (
              ) {


            GlobalCode.checkNet().then((result) {
              if (result) {
                dashboardStatsRefresh();
              }else {
                getRaffleCount();
                GlobalCode.toast(
                    GlobalCode.lang(context, "Check_your_internet_connection"));
              }
            });

          }),

          new PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "1",
                child: Text(GlobalCode.lang(context, 'Privacy_policy')),
              ),
              PopupMenuItem(
                value: "4",
                child: Text('Luck Send Web'),
              ),
              PopupMenuItem(
                value: "2",
                child: Text(GlobalCode.lang(context, 'Rate_us')),
              ),
              PopupMenuItem(
                value: "3",
                child: Text(GlobalCode.lang(context, 'Feedback')),
              ),
            ],
            onSelected: (value) {
              if(value == "1"){
                _getprivacypolicyURL();
              }else if(value == "2")
              {
                _getrateusURL();
              }else if(value == "3")
              {
                GlobalCode.checkNet().then((result) {
                  if (result) {

                    if(loginCheck)
                    {
                      feedbacksDialog();
                    }else{
                      _handleSignIn();
                    }
                  }else{
                    GlobalCode.toast(GlobalCode.lang(context, "Check_your_internet_connection"));
                  }

                });
              }else if(value == "4")
              {
                GlobalCode.checkNet().then((result) {
                  if (result) {

                    if(loginCheck)
                    {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                            builder: (BuildContext context) => new OnlineWeb(),
                            settings: RouteSettings(name: 'OnlineWeb'),
                          ));
                    }else{
                      _handleSignIn();
                    }
                  }else{
                    GlobalCode.toast(GlobalCode.lang(context, "Check_your_internet_connection"));
                  }

                });
              }
              else{

              }

            },
          ),

        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
        child: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(3.0),
          children: <Widget>[
            makeDashboardItem(1,GlobalCode.lang(context, 'Local_Sweepstakes'), local_raffle_count , Icons.card_giftcard),
            Visibility(
                visible: visible_stats,
                child:makeDashboardItem(4,GlobalCode.lang(context, 'Recently_added'), ' ' , Icons.restore)
            ),

            Visibility(
              visible: visible_stats,
              child:makeDashboardItem(2,GlobalCode.lang(context, 'My_Social_Links'), raffle_count , Icons.share)
            ),

            Visibility(
                visible: visible_stats,
                child:makeDashboardItem(3,GlobalCode.lang(context, 'My_participations'), participants_count , Icons.card_membership)
            ),

          ],
        ),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the Drawer if there isn't enough vertical
        // space to fit everything.
        child: _menuList()
      ),
    );
  }
  Card makeDashboardItem(int itemID,String title,var data , IconData icon) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 1.0,
        margin: new EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              color: Color.fromRGBO(29, 29, 29, 1),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0)
            ),
          ),
          child: new InkWell(
            onTap: () { dashboardMenu(itemID); },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                SizedBox(height: 30.0),
                Center(
                    child: Icon(
                      icon,
                      size: 50.0,
                      color: Colors.white70,
                    )),
                SizedBox(height: 10.0),
                new Center(
                  child: new Text(title,
                      style:
                      new TextStyle(fontSize: 12.0, color: Colors.white70)),
                ),
                SizedBox(height: 10.0),
                new Center(
                child: new Text(data,
                    style:
                    new TextStyle(fontSize: 16.0, color: Colors.white70)),
                )
              ],
            ),
          ),
        ));
  }
}


class MyNavigatorObserver extends NavigatorObserver {


  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) async {
    //print(route.settings.name);
  }

  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) async {
    //print(previousRoute.settings.name);
  }

  @override
  void didRemove(Route route, Route previousRoute) {

  }

  @override
  void didReplace({Route newRoute, Route oldRoute}) {

  }
}

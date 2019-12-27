import 'package:cached_network_image/cached_network_image.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:flutter/material.dart';
import 'package:cekilismobil/json/model/user.dart';

class AccountInformation extends StatefulWidget {
  static var profileImage;
  static var data;
  @override
  _AccountInformationState createState() => new _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  User user = new User.fromJson(AccountInformation.data);

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var creation_date = GlobalCode.datetimetoLOCAL(user.creation_date);
    var last_update = GlobalCode.datetimetoLOCAL(user.last_update);
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: new AppBar(
        title: new Text(GlobalCode.lang(context, 'My_account')),
      ),
      body: Container(
        child: SizedBox(
          child: Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(user.name,
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(user.id_share,
                      style: TextStyle(color: Colors.white70)),
                  leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(AccountInformation.profileImage ?? 'https://lucksend.com/static/app/images/noprofile.png')
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(user.mail_adress),
                  leading: Icon(
                    Icons.mail_outline,
                    color: Colors.white70,
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(creation_date),
                  leading: Icon(
                    Icons.access_time,
                    color: Colors.white70,
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(last_update),
                  leading: Icon(
                    Icons.update,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
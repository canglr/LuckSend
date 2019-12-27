import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cekilismobil/database/dbhelper.dart';
import 'package:cekilismobil/database/model/results.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:cekilismobil/screen/localresults.dart';
import 'package:cekilismobil/global_class/globalcode.dart';

class RaffleStart{
  var db = new DBHelper();

  Future<bool> start(var id,int count,BuildContext context) async
  {
    List<String> participantslist = new List();
    List<String> resultslist = new List();
    ProgressDialog pr;
    var rnd = new Random();

    pr = new ProgressDialog(context,ProgressDialogType.Normal);

    await db.deleteResults(id);

    pr.setMessage(GlobalCode.lang(context, 'Preparing_list'));
    pr.show();
    GlobalCode.soundplay('sound/vacuum-effect.mp3');
    await new Future.delayed(const Duration(milliseconds : 1600));

    await db.getAllParticipants(id).then((participants) {
      participants.forEach((participant) {
        participantslist.add(participant['participant']);
      });
    });


    pr.update(message: GlobalCode.lang(context, 'Shuffling'));
    participantslist.shuffle(new Random());
    GlobalCode.soundplay('sound/shuffle-effect.mp3');
    await new Future.delayed(const Duration(seconds : 2));

    int participants_count=0;
    for(int i = 0;i<count;i++)
      {
        participants_count = participantslist.length;
        int randomnumber = rnd.nextInt(participants_count);
        resultslist.add(participantslist[randomnumber]);
        participantslist.remove(participantslist[randomnumber]);
      }

    for(var result in resultslist)
    {
      await db.saveResults(new Results(id, 1, result, GlobalCode.datetimenow()));
    }
    GlobalCode.soundplay('sound/ready-effect.mp3');
    pr.update(message: GlobalCode.lang(context, 'Ready'));
    await new Future.delayed(const Duration(seconds : 1));

    GlobalCode.soundplay('sound/countdown-effect.mp3');
    pr.update(message: "3");
    await new Future.delayed(const Duration(seconds : 1));

    GlobalCode.soundplay('sound/countdown-effect.mp3');
    pr.update(message: "2");
    await new Future.delayed(const Duration(seconds : 1));

    GlobalCode.soundplay('sound/countdown-effect.mp3');
    pr.update(message: "1");
    await new Future.delayed(const Duration(seconds : 1));

    GlobalCode.soundplay('sound/countdown-effect.mp3');
    pr.update(message: "0");
    await new Future.delayed(const Duration(seconds : 1));

    pr.hide();
    db.updateDatetimeRaffle(id, GlobalCode.datetimenow());

    GlobalCode.soundplay('sound/magic-effect.mp3');

    Navigator.of(context).pop();
    LocalResults.raffleid = id;
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => new LocalResults()));
    return true;
  }

}
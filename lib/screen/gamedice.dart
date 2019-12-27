import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:shake/shake.dart';



class GameDice extends StatefulWidget {
  _GameDiceState createState() => _GameDiceState();
}

class _GameDiceState extends State<GameDice> {

  var visiblediceloading = false;
  var visiblediceresult = false;
  var visiblediceone = true;
  var sound = true;
  var count = 0;
  var dice = 0;
  var dice2 = 0;

  void dice_result_engine() async
  {
    Random random = new Random();
    var rnd_mp3 = random.nextInt(12);
    var dice_sound = [
      'sound/games/dice/dice-1.mp3',
      'sound/games/dice/dice-2.mp3',
      'sound/games/dice/dice-3.mp3',
      'sound/games/dice/dice-4.mp3',
      'sound/games/dice/dice-5.mp3',
      'sound/games/dice/dice-6.mp3',
      'sound/games/dice/dice-7.mp3',
      'sound/games/dice/dice-8.mp3',
      'sound/games/dice/dice-9.mp3',
      'sound/games/dice/dice-10.mp3',
      'sound/games/dice/dice-11.mp3',
      'sound/games/dice/dice-12.mp3',
      'sound/games/dice/dice-13.mp3'
    ];

    var dice_sound_milisecond_detail = [950, 850, 1350, 1150, 1150, 1150, 1150, 950, 1050, 1450, 850, 1250, 1050];

    Random rnd = new Random();
    int min = 1, max = 7;
    dice = min + rnd.nextInt(max - min);
    dice2 = min + rnd.nextInt(max - min);
    if(sound) {
      GlobalCode.soundplay(dice_sound[rnd_mp3]);
    }
    await new Future.delayed(Duration(milliseconds : dice_sound_milisecond_detail[rnd_mp3]));
    setState(() {
      visiblediceloading = false;
      visiblediceresult = true;
      count++;
    });
  }

  void dice_start_engine()
  {
    setState(() {
      visiblediceresult = false;
      visiblediceloading = true;
      dice_result_engine();
    });
  }

  @override
  void initState() {
    super.initState();
    ShakeDetector detector = ShakeDetector.autoStart(onPhoneShake: () {
      if(visiblediceloading != true) {
        dice_start_engine();
      }
    });

  }

  @override
  Widget build(BuildContext context) {


    Widget _dicenumber = new Container(
      child: Card(
        child: Column(
          children: <Widget>[
            new ListTile(
              leading: const Icon(Icons.loop, color: Colors.white70),
              title: new Text('$count'),
            ),

          ],
        ),
      ),

    );



    Widget _diceloading = new Container(
      child: Visibility(
        visible: visiblediceloading,
        child: GestureDetector(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(40),
                child: new Image.asset(
                  'assets/images/games/dice/diceloading.gif',
                  width: 64,
                  height: 64,
                ),
              ),

              Visibility(
                visible: visiblediceone,
                child: new Padding(
                  padding: const EdgeInsets.all(40),
                  child: new Image.asset(
                    'assets/images/games/dice/diceloading2.gif',
                    width: 64,
                    height: 64,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );


    Widget _diceresult = new Container(
      child: Visibility(
        visible: visiblediceresult,
        child: GestureDetector(
          onTap: () { dice_start_engine(); },
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(40),
              child: new Image.asset(
                    'assets/images/games/dice/dice-$dice.png',
                    width: 64,
                    height: 64,
                  ),
            ),
            Visibility(
              visible: visiblediceone,
              child: new Padding(
                padding: const EdgeInsets.all(40),
                child: new Image.asset(
                  'assets/images/games/dice/dice-$dice2.png',
                  width: 64,
                  height: 64,
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );


    Widget body = new Column(
      // This makes each child fill the full width of the screen
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _dicenumber,
        _diceloading,
        _diceresult
      ],
    );


    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: AppBar(
        title: new Text(GlobalCode.lang(context, 'Dice')),
        actions: <Widget>[

          new IconButton(icon: const Icon(Icons.filter_1), onPressed: (
              ) {

            if(visiblediceloading != true)
            {
              if(visiblediceone)
              {
                visiblediceone = false;
                GlobalCode.toast(GlobalCode.lang(context, 'Single'));
              }else{
                visiblediceone = true;
                GlobalCode.toast(GlobalCode.lang(context, 'Double'));
              }
            }

          }),

          new IconButton(icon: const Icon(Icons.volume_mute), onPressed: (
              ) {

            if(visiblediceloading != true)
            {
              if(sound)
              {
                sound = false;
                GlobalCode.toast(GlobalCode.lang(context, 'Sound_off'));
              }else{
                sound = true;
                GlobalCode.toast(GlobalCode.lang(context, 'Sound_on'));
              }
            }

          }),

          new IconButton(icon: const Icon(Icons.play_arrow), onPressed: (
              ) {


                  if(visiblediceloading != true)
                  {
                    dice_start_engine();
                  }

          }),


        ],
      ),
      body: new SingleChildScrollView(
          child: body
      ),
    );
  }
}
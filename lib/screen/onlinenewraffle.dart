import 'package:flutter/material.dart';
import 'package:cekilismobil/database/dbhelper.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cekilismobil/json/jsonapi.dart';
import 'dart:convert';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:progress_dialog/progress_dialog.dart';


class OnlineNewRaffle extends StatefulWidget {
  @override
  _OnlineNewRaffleState createState() => new _OnlineNewRaffleState();
}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
var db = new DBHelper();
bool _autoValidate = false;

var title = new TextEditingController();
var description = new TextEditingController();
var contact_information = new TextEditingController();
var winner_number = new TextEditingController();
var reserves_number = new TextEditingController();
var tags = new TextEditingController();
var today;
var date_expiration;
var time_expiration;


GlobalKey key =
new GlobalKey<AutoCompleteTextFieldState<CountrySuggestionType>>();

AutoCompleteTextField<CountrySuggestionType> textField;

CountrySuggestionType selected;

List<CountrySuggestionType> suggestions = [];

List<CountrySuggestionTypeSelected> countryselected = [];

List<TagsType> tagsselected = [];

List<String> savetag = [];

List<String> savecountry = [];


bool _validateInputs() {
  if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
    _formKey.currentState.save();
    return true;
  } else {
    return false;
  }
}

class _OnlineNewRaffleState extends State<OnlineNewRaffle> {
  
  @override
  void initState() {
    super.initState();
    raffleclear();
    getCountry();
  }


  Future<Null> SaveRaffle() async {
    ProgressDialog pr;
    try{
      pr = new ProgressDialog(context,ProgressDialogType.Normal);
      pr.setMessage(GlobalCode.lang(context, 'Please_wait'));
      pr.show();

      savecountry.clear();
      for(var country in countryselected)
      {
        savecountry.add(country.countryCode);
      }

      savetag.clear();
      for(var tag in tagsselected)
      {
        savetag.add(tag.tagsName);
      }

      final patch = "/raffle/create";
      var api_key = await GlobalCode.storageread('api_key');
      var version_code = await GlobalCode.versionCode;

      var body = {
        'api_key': api_key,
        'version_code': version_code,
        'title': title.text,
        'description': description.text,
        'contact_information': contact_information.text,
        'winners': winner_number.text,
        'reserves': reserves_number.text,
        'tags': savetag.toString(),
        'countries': savecountry.toString(),
        'expiration': GlobalCode.datetimetoUTC('$date_expiration $time_expiration')
      };
      final response =
      await http.post(JsonApi.url+patch, body: body);

      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        var result = json.decode(response.body);
        GlobalCode.toast(GlobalCode.lang(context, result['result']));
        if(result['status'].toString() == 'true')
        {
          setState(() {
            pr.hide();
          });
          raffleclear();
          Navigator.pop(context);
        }

        if(result['api_status'].toString() == 'false')
        {
          setState(() {
            pr.hide();
          });
          GlobalCode.toast(GlobalCode.lang(context, result['api_result']));
        }

        setState(() {
          pr.hide();
        });

      } else {
        // If that call was not successful, throw an error.
        setState(() {
          pr.hide();
        });
        GlobalCode.toast(GlobalCode.lang(context, 'Connection_error'));
      }

    }catch (error){
        setState(() {
          pr.hide();
        });
        GlobalCode.toast(GlobalCode.lang(context, 'Cannot_be_empty'));
    }
  }


   Future<Null> getCountry() async {
    final patch = "/raffle/countries/list";
    var api_key = await GlobalCode.storageread('api_key');
    var version_code = await GlobalCode.versionCode;
    var body = {
      'api_key': api_key,
      'version_code': version_code
    };
    final response =
    await http.post(JsonApi.url+patch, body: body);

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      var result = json.decode(response.body);
        suggestions.clear();
        for(var country in result) {
          suggestions.add(new CountrySuggestionType(country["value"], country["name"]));
        }

    } else {
      // If that call was not successful, throw an error.
      GlobalCode.toast(GlobalCode.lang(context, 'Connection_error'));
    }
  }

  void countryselectedadd(countryCode,countryName)
  {
    if(countryselected.length < 10) {
      var list_search;
      for (var country in countryselected) {
        if (country.countryCode == countryCode) {
          list_search = true;
        } else {
          list_search = false;
        }
      }

      if (list_search != true) {
        countryselected.add(
            new CountrySuggestionTypeSelected(countryCode, countryName));
        setState(() {

        });
      } else {
        GlobalCode.toast(GlobalCode.lang(context, 'Country_already_selected'));
      }
    }else{
      GlobalCode.toast(GlobalCode.lang(context, 'Up_to_ten_countries_can_be_selected'));
    }
  }

  countryselecteddelete(countryCode,countryName)
  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text('${countryName} - ${countryCode}'),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))
          ),
          content: new Text(GlobalCode.lang(context, 'Remove_it_from_the_list')),
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
                countryselected.removeWhere((item) => item.countryCode == countryCode);
                setState(() {

                });

              },
            ),

          ],
        );
      },
    );

  }

  tagsadd()
  {
      var tag = GlobalCode.TagUnsupportedCharacter(tags.text.trim());
      if(tag != "") {
        if(tagsselected.length < 4) {
          var list_search;
          for (var tags in tagsselected) {
            if (tags.tagsName == tag) {
              list_search = true;
            } else {
              list_search = false;
            }
          }

          if (list_search != true) {
            tagsselected.add(new TagsType(tag));
            tags.text = "";
            setState(() {

            });
          } else {
            GlobalCode.toast(GlobalCode.lang(context, 'Tag_already_available'));
          }
        }else{
          GlobalCode.toast(GlobalCode.lang(context, 'Up_to_four_tags_can_be_added'));
        }
      }else{
          GlobalCode.toast(GlobalCode.lang(context, 'Cannot_be_empty'));
      }
  }


  tagsdelete(tagsName)
  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(tagsName),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))
          ),
          content: new Text(GlobalCode.lang(context, 'Remove_it_from_the_list')),
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
                tagsselected.removeWhere((item) => item.tagsName == tagsName);
                setState(() {

                });

              },
            ),

          ],
        );
      },
    );

  }


  void raffleclear()
  {
    today = new DateTime.now();
    today = today.add(new Duration(days: 30));
    title.text = "";
    description.text = "";
    contact_information.text = "";
    winner_number.text = "";
    reserves_number.text = "";
    tags.text = "";
    tagsselected.clear();
    countryselected.clear();
    date_expiration = GlobalCode.ConvertDate(today);
    time_expiration = GlobalCode.ConvertTime(DateTime.now());
  }


  bool tagvisiblecheck()
  {

    if(tagsselected.length != 0)
      {
          return true;
      }else{
          return false;
    }

  }


  bool countryvisiblecheck()
  {

    if(countryselected.length != 0)
    {
      return true;
    }else{
      return false;
    }

  }


  @override
  Widget build(BuildContext context) {

  Widget _onlinenewraffleform = new Container
      (
        child: new Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Card(
            child: Column(
              children: <Widget>[
                new ListTile(
                  leading: const Icon(Icons.card_giftcard, color: Colors.white70),
                  title: new TextFormField(
                    maxLength: 60,
                    validator: (value) {
                      value = value.trim();
                      if (value.isEmpty) {
                        return GlobalCode.lang(context, 'Cannot_be_empty');
                      }
                    },
                    controller: title,
                    decoration: new InputDecoration(
                      hintText: GlobalCode.lang(context, 'Raffle_Name'),
                    ),
                  ),
                ),


                new ListTile(
                  leading: const Icon(Icons.description, color: Colors.white70),
                  title: new TextFormField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    maxLength: 350,
                    validator: (value) {
                      value = value.trim();
                      if (value.isEmpty) {
                        return GlobalCode.lang(context, 'Cannot_be_empty');
                      }
                    },
                    controller: description,
                    decoration: new InputDecoration(
                      hintText: GlobalCode.lang(context, 'Description'),
                    ),
                  ),
                ),



                new ListTile(
                  leading: const Icon(Icons.contacts, color: Colors.white70),
                  title: new TextFormField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    maxLength: 350,
                    validator: (value) {
                      value = value.trim();
                      if (value.isEmpty) {
                        return GlobalCode.lang(context, 'Cannot_be_empty');
                      }
                    },
                    controller: contact_information,
                    decoration: new InputDecoration(
                      hintText: GlobalCode.lang(context, 'Contact_information'),
                    ),
                  ),
                ),



                new ListTile(
                  leading: const Icon(Icons.person, color: Colors.white70),
                  title: new TextFormField(
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    validator: (value) {
                      value = value.trim();
                      if (value.isEmpty) {
                        return GlobalCode.lang(context, 'Cannot_be_empty');
                      }
                    },
                    controller: winner_number,
                    decoration: new InputDecoration(
                      hintText: GlobalCode.lang(context, 'Number_of_people_to_win'),
                    ),
                  ),
                ),


                new ListTile(
                  leading: const Icon(Icons.person, color: Colors.white70),
                  title: new TextFormField(
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    validator: (value) {
                      value = value.trim();
                      if (value.isEmpty) {
                        return GlobalCode.lang(context, 'Cannot_be_empty');
                      }
                    },
                    controller: reserves_number,
                    decoration: new InputDecoration(
                      hintText: GlobalCode.lang(context, 'Number_of_reserves_contacts'),
                    ),
                  ),
                ),



                new ListTile(
                  leading: const Icon(Icons.text_fields, color: Colors.white70),
                  title: new Stack(
                    alignment: const Alignment(1.0, 1.0),
                    children: <Widget>[
                        new TextFormField(
                          controller: tags,
                          decoration: new InputDecoration(
                          hintText: GlobalCode.lang(context, 'Tag'),
                          ),
                        ),

                      new FlatButton(
                        onPressed: tagsadd,
                        child: const Icon(Icons.add, color: Colors.white70),
                      ),

                    ],
                  ),
                ),

                new Visibility(
                    visible: tagvisiblecheck(),
                    child: new ListTile(
                      leading: const Icon(Icons.text_fields, color: Colors.white70),
                      title: new ListView.builder(
                          physics: PageScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: tagsselected == null ? 0 : tagsselected.length,
                          itemBuilder: (BuildContext context, int index) {
                            return
                              new GestureDetector(
                                onTap: () => tagsdelete(tagsselected[index].tagsName),
                                child: new Container(
                                  child: new Center(
                                      child: new Column(
                                        // Stretch the cards in horizontal axis
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          new Text(
                                            // Read the name field value and set it in the Text widget
                                            tagsselected[index].tagsName,
                                            // set some style to text
                                            style: new TextStyle(color: Colors.white70),
                                          ),
                                        ],
                                      )),
                                  padding: const EdgeInsets.all(15.0),
                                ),
                              );
                          }),
                    ),
                ),

                new ListTile(
                  leading: const Icon(Icons.language, color: Colors.white70),
                  title:new AutoCompleteTextField<CountrySuggestionType>(
                    decoration: new InputDecoration(
                        hintText: GlobalCode.lang(context, 'Country'), suffixIcon: new Icon(Icons.search, color: Colors.white70)),
                    itemSubmitted: (item) => setState(() => countryselectedadd(item.countryCode,item.countryName)),
                    suggestions: suggestions,
                    key: key,
                    itemBuilder: (context, suggestion) => new Padding(
                        child: new ListTile(
                            title: new Text(suggestion.countryName),
                            trailing: new Text("${suggestion.countryCode}")),
                        padding: EdgeInsets.all(8.0)),
                    itemSorter:(a, b) => a.countryName == b.countryName ? 0 : a.countryName == b.countryName ? -1 : 1,
                    itemFilter: (suggestion, input) =>
                        suggestion.countryName.toLowerCase().startsWith(input.toLowerCase()),
                  ),
                ),

                new Visibility(
                    visible: countryvisiblecheck(),
                    child: new ListTile(
                      leading: const Icon(Icons.language, color: Colors.white70),
                      title: new ListView.builder(
                          physics: PageScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: countryselected == null ? 0 : countryselected.length,
                          itemBuilder: (BuildContext context, int index) {
                            return
                              new GestureDetector(
                                onTap: () => countryselecteddelete(countryselected[index].countryCode,countryselected[index].countryName),
                                child: new Container(
                                  child: new Center(
                                      child: new Column(
                                        // Stretch the cards in horizontal axis
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          new Text(
                                            // Read the name field value and set it in the Text widget
                                            countryselected[index].countryName,
                                            // set some style to text
                                            style: new TextStyle(color: Colors.white70),
                                          ),
                                          new Text(
                                            // Read the name field value and set it in the Text widget
                                            countryselected[index].countryCode,
                                            // set some style to text
                                            style: new TextStyle(color: Colors.white70),
                                          ),
                                        ],
                                      )),
                                  padding: const EdgeInsets.all(15.0),
                                ),
                              );
                          }),
                    ),
                ),

                new ListTile(
                  leading: const Icon(Icons.timer_off, color: Colors.white70),
                  title: new Text(GlobalCode.lang(context, 'End_date'),
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: new Text(date_expiration, style: TextStyle(color: Colors.white70)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
                  onTap: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(2019, 9, 15),
                        maxTime: DateTime(2021, 8, 25),
                        onConfirm: (date) {
                          setState(() {
                            date_expiration = GlobalCode.ConvertDate(date);
                          });
                        }, currentTime: today, locale: GlobalCode.lang(context, 'locale') == 'en' ? LocaleType.en : LocaleType.tr);
                  },
                ),

                new ListTile(
                  leading: const Icon(Icons.timer_off, color: Colors.white70),
                  title: new Text(GlobalCode.lang(context, 'End_time'),
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: new Text(time_expiration, style: TextStyle(color: Colors.white70)),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
                  onTap: () {
                    DatePicker.showTimePicker(context,
                        showTitleActions: true,
                        onConfirm: (date) {
                          setState(() {
                            time_expiration = GlobalCode.ConvertTime(date);
                          });
                        }, currentTime: today, locale: GlobalCode.lang(context, 'locale') == 'en' ? LocaleType.en : LocaleType.tr);
                  },
                ),

              ],
            ),
          ),
        ));


    Widget body = new Column(
      // This makes each child fill the full width of the screen
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _onlinenewraffleform
      ],
    );


    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: new AppBar(
        title: new Text(GlobalCode.lang(context, 'Create_Raffle')),
        actions: <Widget>[

          new IconButton(icon: const Icon(Icons.save), onPressed: (
              ) {
            if(_validateInputs())
              {
                SaveRaffle();
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

class CountrySuggestionType {
  String countryCode, countryName;
  CountrySuggestionType(this.countryCode, this.countryName);
}

class CountrySuggestionTypeSelected {
  String countryCode, countryName;
  CountrySuggestionTypeSelected(this.countryCode, this.countryName);
}

class TagsType {
  String tagsName;
  TagsType(this.tagsName);
}

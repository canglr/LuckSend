import 'dart:convert';
import 'package:cekilismobil/json/jsonapi.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cekilismobil/database/dbhelper.dart';
import 'package:cekilismobil/global_class/globalcode.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:progress_dialog/progress_dialog.dart';


class SocialNew extends StatefulWidget {
  @override
  _SocialNewState createState() => new _SocialNewState();

}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

GlobalKey key =
new GlobalKey<AutoCompleteTextFieldState<CountrySuggestionType>>();

AutoCompleteTextField<CountrySuggestionType> textField;

CountrySuggestionType selected;

List<CountrySuggestionType> suggestions = [];

List<CountrySuggestionTypeSelected> countryselected = [];

List<TagsType> tagsselected = [];

List<String> savetag = [];

List<String> savecountry = [];

var db = new DBHelper();
bool _autoValidate = false;

var raffle_link = new TextEditingController();
var tags = new TextEditingController();
var dropdown_value;

bool _validateInputs() {
  if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
    _formKey.currentState.save();
    return true;
  } else {
    return false;
  }
}

class _SocialNewState extends State<SocialNew> {


  @override
  void initState() {
    super.initState();
    getCountry();
  }

  Future<Null> SaveRaffle() async {
    print(dropdown_value.toString());
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

      final patch = "/socialmedia/create";
      var api_key = await GlobalCode.storageread('api_key');
      var version_code = await GlobalCode.versionCode;

      var body = {
        'api_key': api_key,
        'version_code': version_code,
        'url': raffle_link.text,
        'type': dropdown_value.toString(),
        'tags': savetag.toString(),
        'countries': savecountry.toString(),

      };
      final response =
      await http.post(JsonApi.url+patch, body: body);

      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        var result = json.decode(response.body);

        if(result['api_status'].toString() == 'true')
        {
          GlobalCode.toast(GlobalCode.lang(context, result['api_result']));
          setState(() {
            pr.hide();
          });
          raffleinputclear();
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

  void raffleinputclear()
  {
    raffle_link.text = "";
    tags.text = "";
    tagsselected.clear();
    countryselected.clear();
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


    Widget _socialserviceform = new Container
      (
        child: Card(
            child: Column(
              children: <Widget>[
                new ListTile(
                  leading: const Icon(Icons.done_all, color: Colors.white70),
                  title: Text('Instagram'),
                  subtitle: Text('https://www.instagram.com/p/xxx.../', style: TextStyle(color: Colors.white70)),
                ),

                new ListTile(
                  leading: const Icon(Icons.verified_user, color: Colors.white70),
                  title: Text(GlobalCode.lang(context, 'Approval_process')),
                  subtitle: Text(GlobalCode.lang(context, 'After_sending_the_product_wait_for_confirmation'), style: TextStyle(color: Colors.white70)),
                ),

                new ListTile(
                  leading: const Icon(Icons.bookmark, color: Colors.white70),
                  subtitle: Text(GlobalCode.lang(context, 'After_the_operation_is_complete_the_saved_will_also_appear'), style: TextStyle(color: Colors.white70)),
                ),

              ],
            ),
          ),
        );


    Widget _socialnewform = new Container
      (
        child: new Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Card(
            child: Column(
              children: <Widget>[
                new ListTile(
                  leading: const Icon(Icons.insert_link, color: Colors.white70),
                  title: new TextFormField(
                    maxLength: 80,
                    validator: (value) {
                      value = value.trim();
                      if (value.isEmpty) {
                        return GlobalCode.lang(context, 'Cannot_be_empty');
                      }
                    },
                    controller: raffle_link,
                    decoration: new InputDecoration(
                      hintText: 'Url',
                    ),
                  ),
                ),


                new ListTile(
                  leading: const Icon(Icons.local_offer, color: Colors.white70),
                  title: new DropdownButton<String>(
                    items: [
                      DropdownMenuItem<String>(
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.attach_money),
                            Text(GlobalCode.lang(context, 'Product_sale')),
                          ],
                        ),
                        value: 'False',
                      ),
                      DropdownMenuItem<String>(
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.card_giftcard),
                            Text(" "+GlobalCode.lang(context, 'Product_raffle')),
                          ],
                        ),
                        value: 'True',
                      ),
                    ],
                    isExpanded: true,
                    onChanged: (String value) {
                      setState(() {
                        dropdown_value = value;
                      });
                    },
                    hint: Text(GlobalCode.lang(context, 'Choose')),
                    value: dropdown_value,
                    underline: Container(
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.black45))
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                    iconEnabledColor: Colors.white70,
                    //        iconDisabledColor: Colors.grey,

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

              ],
            ),
          ),
        ));


    Widget body = new Column(
      // This makes each child fill the full width of the screen
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _socialserviceform,
        _socialnewform
      ],
    );


    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 1),
      appBar: new AppBar(
        title: new Text(GlobalCode.lang(context, 'Add_Product')),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.save), onPressed: (
              ) { if(_validateInputs()) { SaveRaffle(); } })
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

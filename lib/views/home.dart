import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mdi/mdi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vortaron/query.dart';
import 'package:vortaron/views/definition.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  String language = "";
  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((instance) => setState(() => language = instance.getString("wordLanguage") ?? (language != "" ? language : "en")));
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Mdi.bookAlphabet),
        title: Text("Vortaron"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: tr("homeScreen.wordBox") //Defini la vorton
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        final _x = lookupWord(controller.text, language, "English");
                        SpinningScreen.showIn(context, until: _x);
                        _x.then((definition) => definition != null ? Navigator.push(
                          context, MaterialPageRoute(builder: (context) => DefinitionScreen(definition: definition))
                        ) : showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("errors.generic").tr(),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text("buttons.ok").tr())
                            ]
                          )
                        )).onError((error, stackTrace) => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              error.toString().contains("not a word") ? "errors.notAWord" 
                              : error.toString().contains("not found") ? "errors.notFound" 
                              : "errors.generic")
                              .tr(namedArgs: {"word": controller.text, "wordLang": language, "appLang": "English"}),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text("buttons.ok").tr())
                            ]
                          )
                        ));
                      }, 
                      child: Text("homeScreen.defineAction").tr()
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField(
                items: [
                  DropdownMenuItem(child: Text("languages.en").tr(), value: "en"),
                  DropdownMenuItem(child: Text("languages.eo").tr(), value: "eo"),
                  DropdownMenuItem(child: Text("languages.la").tr(), value: "la"),
                ],
                onChanged: (newValue) {
                  setState(() => language = newValue.toString());
                  (() async {
                    var sp = await SharedPreferences.getInstance();
                    sp.setString("wordLanguage", language);
                  })();
                },
                value: language,
                decoration: InputDecoration(
                  labelText: tr("homeScreen.wordLanguage") //Defini la vorton
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}

class SpinningScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.black54,
      child: Center(
        child: CircularProgressIndicator(value: null),
      ),
    );
  }

  static showIn(BuildContext context, {required Future until, /* required Widget toScreen */}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SpinningScreen()));
    until.whenComplete(() {
      Navigator.pop(context);
      //Navigator.push(context, MaterialPageRoute(builder: (context) => toScreen));
    });
  }
}
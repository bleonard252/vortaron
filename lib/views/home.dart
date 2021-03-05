import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mdi/mdi.dart';
import 'package:vortaron/query.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Mdi.bookAlphabet),
        title: Text("Vortaro"),
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
                        final _x = lookupWord(controller.text, "Esperanto", "English");
                        SpinningScreen.showIn(context, until: _x);
                        _x.then((__) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                              Container(color: Colors.blue)
                          )
                        )).onError((error, stackTrace) => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              error.toString().contains("not a word") ? "errors.notAWord" 
                              : "errors.generic")
                              .tr(namedArgs: {"word": controller.text, "wordLang": "Esperanto", "appLang": "English"}),
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
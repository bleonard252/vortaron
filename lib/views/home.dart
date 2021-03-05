import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mdi/mdi.dart';

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
                      onPressed: () => null, 
                      child: Text("homeScreen.translateAction").tr()
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

  static showIn(BuildContext context, {required Future until, required Widget toScreen}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SpinningScreen()));
    until.then((value) {
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => toScreen));
    });
  }
}
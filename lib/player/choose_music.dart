import 'package:flutter/material.dart';
class ChooseMusicScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选歌'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: Text("匆匆那年"),
                onTap: () => {
                  Navigator.pop(context, '匆匆那年')
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
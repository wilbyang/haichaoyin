import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:haichaoyin/player/choose_music.dart';
import 'package:haichaoyin/player/home_screen.dart';
import 'package:haichaoyin/player/music_bloc.dart';
import 'package:haichaoyin/player/music_data.dart';
void main() => runApp(MusicApp());

class MusicApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Provider(
          child: HomeScreen(),
        )
    );
  }
}

class SomeChildWidget extends StatelessWidget {
  const SomeChildWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context);
    return Column(
      children: <Widget>[

        StreamBuilder<List<Music>>(
          stream: bloc.musics,
          builder: (context, snapshot) {
            if (snapshot.data == null)
              return Text("no data...");
            else {
              return MusicList3(musics: snapshot.data);
            }
          },
        ),
        Row(
          children: <Widget>[
            IconButton(icon: Icon(Icons.subdirectory_arrow_left),onPressed: () {
              bloc.changeFact("artist:王菲");
            },),
            IconButton(icon: Icon(Icons.subdirectory_arrow_right),onPressed: () {
              bloc.changeFact("artist:许巍");
            },),
          ],
        )
      ],
    );
  }
}

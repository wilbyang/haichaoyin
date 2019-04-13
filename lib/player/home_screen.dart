import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:haichaoyin/player/choose_music.dart';
import 'package:haichaoyin/player/music_data.dart';
import 'package:haichaoyin/player/player.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  HomeScreen({Key key, this.title}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();;
  }

}
class _HomeScreenState extends State<HomeScreen> {
  Music chosenMusic;
  String chosenFacetName;
  String chosenFacetValue;
  Widget _buildDrawer(BuildContext context) {

    return FutureBuilder<Map<String, List<String>>>(
        future: MusicsDatabaseRepository.get.getMusicFacet(),
        builder: (context, snapshot) {
          if (snapshot.data == null) return Center(child: CircularProgressIndicator());
          final artistTiles = snapshot.data["artist"].map((facetItem) {
            return InkWell(
              child: CircleAvatar(child: Text(facetItem),),
              onTap: () => setState((){

                chosenFacetValue = facetItem;
                chosenFacetName = "artist";
              }),
            );
          });

          final artistTilesWidget = Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Wrap(
              children: <Widget>[]..addAll(artistTiles),
              spacing: 12.0,
              alignment: WrapAlignment.start,
            ),
          );


          final genreTiles = snapshot.data["genre"].map((facetItem) {

            return InkWell(
              child: Chip(label: Text(facetItem)),
              onTap: () => setState((){

                chosenFacetValue = facetItem;
                chosenFacetName = "genre";
              }),
            );
          });

          final genreTilesWidget = Container(
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            child: Wrap(
              children: <Widget>[]..addAll(genreTiles),
              spacing: 8.0,
              alignment: WrapAlignment.start,
            ),
          );

          return Drawer(
            child: ListView(
                dragStartBehavior: DragStartBehavior.down,
                children: <Widget>[
                  DrawerHeader(child: Center(child: Text('乐库'))),

                ]..add(artistTilesWidget)
                  ..add(Divider())
                  ..add(genreTilesWidget)
            ),
          );
        }
    );
  }
  Future<void> _createMusic() async {
    await MusicsDatabaseRepository.get.insert(
        Music(title: "匆匆那年",
            uri: "https://sample-videos.com/audio/mp3/crowd-cheering.mp3",
            genre: "嘈杂",
            artist: "王菲",
            album: "菲比寻常"
        ));

    await MusicsDatabaseRepository.get.insert(
        Music(title: "故乡",
            uri: "https://sample-videos.com/audio/mp3/wave.mp3",
            genre: "自由抒情",
            artist: "许巍",
            album: "蓝莲花"
        ));

  }

  void chooseMusic(Music music) {
    setState(() {
      chosenMusic = music;
    });
  }
  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;

    final children = <Widget>[
      Image.network(
          "https://images.unsplash.com/photo-1471115853179-bb1d604434e0?dpr=1&auto=format&fit=crop&w=767&h=583&q=80&cs=tinysrgb&crop=",
          width: 600,
          height: 240,
          fit: BoxFit.cover),
    ];

    Widget w = Text("还没选择乐曲");
    if (chosenFacetName != null && chosenFacetName.isNotEmpty &&
        chosenFacetValue != null && chosenFacetValue.isNotEmpty) {
      w = MusicList(facetName: chosenFacetName, facetValue: chosenFacetValue, onTapItem: chooseMusic);
    }
    if (chosenMusic != null) {
      w = MyAudioPlayer(music: chosenMusic);
    }
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Container(
                padding: EdgeInsets.only(right: 12.0),
                child: IconButton(icon: Icon(Icons.add, color: Colors.white,), onPressed: null)
            )
          ],
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          centerTitle: true,
        ),
        drawer: _buildDrawer(context),
        body: Container(

            child: w
        )
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}
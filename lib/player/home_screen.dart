import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:haichaoyin/player/music_list.dart';
import 'package:haichaoyin/player/music_bloc.dart';
import 'package:haichaoyin/player/music_data.dart';
import 'package:haichaoyin/player/player.dart';
import 'package:haichaoyin/player/player2.dart';
import 'package:haichaoyin/trial/lifecycle.dart';
//import 'package:haichaoyin/trial/lifecycle.dart';
import 'package:qrcode_reader/qrcode_reader.dart';

class HomeScreen extends StatelessWidget {
  Future<void> _createMusic() async {
    await MusicsDatabaseRepository.get.insert(Music(
      title: "棋子",
      uri: "https://sample-videos.com/audio/mp3/crowd-cheering.mp3",
      genre: "嘈杂",
      artist: "王菲",
      album: "旋转木马",
    ));

    await MusicsDatabaseRepository.get.insert(Music(
      title: "故乡",
      uri: "https://sample-videos.com/audio/mp3/wave.mp3",
      genre: "自由抒情",
      artist: "许巍",
      album: "蓝莲花",
    ));
  }

  Widget _buildDrawer(BuildContext context) {
    final bloc = Provider.of(context);
    return FutureBuilder<Map<String, List<String>>>(
      future: MusicsDatabaseRepository.get.getMusicFacet(),
      builder: (context, snapshot) {
        if (snapshot.data == null)
          return Center(child: CircularProgressIndicator());
        final artistTiles = snapshot.data["artist"].map((facetItem) {
          return RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            textColor: Colors.white,
            color: Colors.pink,
            splashColor: Colors.redAccent,
            child: Text(facetItem),
            onPressed: () {
              bloc.nextFact('artist:$facetItem');
              Navigator.of(context).pop();
            },
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
          return RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            textColor: Colors.white,
            color: Colors.pink,
            splashColor: Colors.redAccent,
            child: Text(facetItem),
            onPressed: () {
              bloc.nextFact('genre:$facetItem');
              Navigator.of(context).pop();
            },
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
            ]
              ..add(artistTilesWidget)
              ..add(Divider())
              ..add(genreTilesWidget),
          ),
        );
      },
    );
  }
  Music parseJson(String jsonTxt) {
    final parsed = json.decode(jsonTxt);

    return Music.fromMap(parsed);
  }
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context);
    Color color = Theme.of(context).primaryColor;

    Widget poster = Image.network(
      "https://images.unsplash.com/photo-1471115853179-bb1d604434e0?dpr=1&auto=format&fit=crop&w=767&h=583&q=80&cs=tinysrgb&crop=",
      width: 600,
      height: 240,
      fit: BoxFit.cover,
    );

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () async {
                final result = await QRCodeReader().scan();
                final music = parseJson(result);
                bloc.nextFlash("下载中");
                final localPath = await Music.downloadMusic(music);
                music.local_uri = localPath;
                MusicsDatabaseRepository.get.insert(music).then((music) {
                  bloc.nextFlash("下载完成");

                });
              },
            ),
          )
        ],
        title: Text(""),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          StreamBuilder<List<Music>>(
            stream: bloc.musics,
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: Text("客官还没有选中曲子"),);
              else {
                return MusicList3(
                  musics: snapshot.data,
                  onTapItem: bloc.nextMusic,
                );
              }
            },
          ),
          StreamBuilder<Music>(
            stream: bloc.chosenMusic,
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Container(
                  width: 0.0,
                  height: 0.0,
                );
              else {
                return MyAudioPlayerWithBloc();
//                return MyAudioPlayer2(music: snapshot.data.title);
              }
            },
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

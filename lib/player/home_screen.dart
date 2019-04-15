import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:haichaoyin/player/choose_music.dart';
import 'package:haichaoyin/player/music_bloc.dart';
import 'package:haichaoyin/player/music_data.dart';
import 'package:haichaoyin/player/player.dart';


class HomeScreen extends StatelessWidget{

  Future<void> _createMusic() async {
    await MusicsDatabaseRepository.get.insert(Music(
        title: "匆匆那年",
        uri: "https://sample-videos.com/audio/mp3/crowd-cheering.mp3",
        genre: "嘈杂",
        artist: "王菲",
        album: "菲比寻常"));

    await MusicsDatabaseRepository.get.insert(Music(
        title: "故乡",
        uri: "https://sample-videos.com/audio/mp3/wave.mp3",
        genre: "自由抒情",
        artist: "许巍",
        album: "蓝莲花"));
  }

  Widget _buildDrawer(BuildContext context) {
    final bloc = Provider.of(context);
    return FutureBuilder<Map<String, List<String>>>(
      future: MusicsDatabaseRepository.get.getMusicFacet(),
      builder: (context, snapshot) {
        if (snapshot.data == null)
          return Center(child: CircularProgressIndicator());
        final artistTiles = snapshot.data["artist"].map((facetItem) {
          return InkWell(
            child: CircleAvatar(
              child: Text(facetItem),
            ),
            onTap: () => bloc.changeFact('artist:$facetItem'),
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
            onTap: () => bloc.changeFact('genre:$facetItem'),
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

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context);
    Color color = Theme.of(context).primaryColor;

    final children = <Widget>[
      Image.network(
        "https://images.unsplash.com/photo-1471115853179-bb1d604434e0?dpr=1&auto=format&fit=crop&w=767&h=583&q=80&cs=tinysrgb&crop=",
        width: 600,
        height: 240,
        fit: BoxFit.cover,
      ),
    ];



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
              onPressed: null,
            ),
          )
        ],
        title: Text(""),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: ListView(
        children: <Widget>[StreamBuilder<List<Music>>(
          stream: bloc.musics,
          builder: (context, snapshot) {
            if (snapshot.data == null) return Text("客官还没有选中曲子");
            else {
              return MusicList3(musics: snapshot.data, onTapItem: bloc.chooseMusic,);
            }
          },
        ), StreamBuilder<Music>(
          stream: bloc.chosenMusic,
          builder: (context, snapshot) {
            if (snapshot.data == null)
              return Container(width: 0.0, height: 0.0,);
            else {
              return MyAudioPlayer(music: snapshot.data);
            }
          },
        )],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:haichaoyin/player/choose_music.dart';
import 'package:haichaoyin/player/music_data.dart';
import 'package:audioplayer/audioplayer.dart';

class PlayerPage extends StatefulWidget {
  PlayerPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PlayerState createState() => _PlayerState();
}

class ControlWidget extends StatelessWidget {
  final String label;

  final IconData icon;

  final Color color;
  final Function onTapAction;

  const ControlWidget({Key key,
    @required this.label,
    @required this.icon,
    @required this.color,
    this.onTapAction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onTapAction,
          child: Icon(icon, color: color),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

}
enum PlayerState { stopped, playing, paused }
class _PlayerState extends State<PlayerPage> {
  
  AudioPlayer audioPlayer;
  Duration duration;
  Duration position;
  PlayerState playerState;
  String localFilePath;


  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  Music chosenMusic;
  String chosenFacet;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            setState(() => duration = audioPlayer.duration);
          } else if (s == AudioPlayerState.STOPPED) {
            onComplete();
            setState(() {
              position = duration;
            });
          }
        }, onError: (msg) {
          setState(() {
            playerState = PlayerState.stopped;
            duration = new Duration(seconds: 0);
            position = new Duration(seconds: 0);
          });
        });
  }
  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  Future<void> play(String uri) async {
//    var audio = AudioPlayer();
    await audioPlayer.play(uri);
    setState(() => playerState = PlayerState.playing);
  }

  Future<void> pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future<void> stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = new Duration();
    });
  }


  @override
  void dispose() {
    audioPlayer.stop();
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer = null;
    super.dispose();
  }
  Widget _buildDrawer(BuildContext context) {

    return FutureBuilder<Map<String, List<String>>>(
      future: MusicsDatabaseRepository.get.getMusicFacet(),
      builder: (context, snapshot) {
        if (snapshot.data == null) return Center(child: CircularProgressIndicator());
        final artistTiles = snapshot.data["artist"].map((facetItem) {
          return InkWell(
            child: CircleAvatar(child: Text(facetItem),),
            onTap: () => setState((){

              chosenFacet = facetItem;
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

              chosenFacet = facetItem;
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
  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
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
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
        child:ListView(
        children: <Widget>[
          Image.network(
            "https://images.unsplash.com/photo-1471115853179-bb1d604434e0?dpr=1&auto=format&fit=crop&w=767&h=583&q=80&cs=tinysrgb&crop=",
            width: 600,
            height: 240,
            fit: BoxFit.cover),
        ]..addAll(chosenMusic == null? []:[

          PriSecTextWidget(music: chosenMusic),

          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ControlWidget(color: color, icon: Icons.skip_previous, label:'上一曲'),
                ControlWidget(color: color, icon: Icons.play_arrow, label:'播放',
                    onTapAction: () => play(chosenMusic.uri)
                ),
                ControlWidget(color: color, icon: Icons.skip_next, label:'下一曲')
              ],
            ),
          ),
        ]),
      )),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  _navigateAndChooseMusic(BuildContext context) async {
    // Navigator.push returns a Future that will complete after we call
    // Navigator.pop on the Selection Screen!
    final result = await Navigator.push(
      context,
      MaterialPageRoute(

        builder: (context) => ChooseMusicScreen()
      ),
    );
    if (result == null) return;
    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result!
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("$result")));
  }

  

}


class PriSecTextWidget extends StatelessWidget {
  final Music music;
  const PriSecTextWidget({
    Key key, @required this.music
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${music.title}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${music.genre}',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          /*3*/
          Chip(label: Text(music.album, style: TextStyle(color: Colors.white),), backgroundColor: Colors.redAccent.shade100,),
        ],
      ),
    );
  }
}

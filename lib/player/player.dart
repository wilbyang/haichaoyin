
import 'dart:async';

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
    print(uri);
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

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: FutureBuilder(
            future: MusicsDatabaseRepository.get.getMusic(2),
            builder: (context, snapshot) {
            if(!snapshot.hasData) return CircularProgressIndicator();
            return ListView(
              children: <Widget>[
                Image.network(
                    "https://images.unsplash.com/photo-1471115853179-bb1d604434e0?dpr=1&auto=format&fit=crop&w=767&h=583&q=80&cs=tinysrgb&crop=",
                    width: 600,
                    height: 240,
                    fit: BoxFit.cover),

                PriSecTextWidget(music: snapshot.data),

                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ControlWidget(color: color, icon: Icons.skip_previous, label:'上一曲'),
                      ControlWidget(color: color, icon: Icons.play_arrow, label:'播放', onTapAction:() => play("https://sample-videos.com/audio/mp3/crowd-cheering.mp3")),
                      ControlWidget(color: color, icon: Icons.skip_next, label:'下一曲')
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    '${snapshot.data.album}',
                    softWrap: true,
                  ),
                )
              ],
            );
          })),
      floatingActionButton: Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          onPressed: () => {
            _navigateAndChooseMusic(context)
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        );
      }), // This trailing comma makes auto-formatting nicer for build methods.
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
          Icon(
            Icons.star,
            color: Colors.red[500],
          ),
          Text('41'),
        ],
      ),
    );
  }
}

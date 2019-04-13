
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:haichaoyin/player/music_data.dart';
import 'package:audioplayer/audioplayer.dart';
class MyAudioPlayer extends StatefulWidget {
  final Music music;
  MyAudioPlayer({Key key, this.music}) : super(key: key);


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
class _PlayerState extends State<MyAudioPlayer> {
  
  AudioPlayer audioPlayer;
  Duration duration;
  Duration position;
  PlayerState playerState;
  String localFilePath;
  String uri;


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

  Future<void> play() async {
//    var audio = AudioPlayer();
    await audioPlayer.play(widget.music.uri);
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
    final music = widget.music;
    final color = Colors.blueAccent;
    var children = [

      PriSecTextWidget(music: music),

      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ControlWidget(color: color, icon: Icons.skip_previous, label:'上一曲'),
            ControlWidget(color: color, icon: Icons.play_arrow, label:'播放',
                onTapAction: () => play()
            ),
            ControlWidget(color: color, icon: Icons.skip_next, label:'下一曲')
          ],
        ),
      ),
    ];
    return Column(
      children: <Widget>[]..addAll(children)
    );
  }

  /*_navigateAndChooseMusic(BuildContext context) async {
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
  ..addAll(chosenMusic == null? []:[

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
        ])
*/

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

import 'dart:async';

import 'package:flutter/foundation.dart';
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

  const ControlWidget(
      {Key key,
      @required this.label,
      @required this.icon,
      @required this.color,
      this.onTapAction})
      : super(key: key);

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
  get isStopped => playerState == PlayerState.stopped;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;
  Future<void> operation;


  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    playerState = PlayerState.stopped;
    position = Duration(seconds: 1);
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));

    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
//        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  Future<void> play() async {
//    var audio = AudioPlayer();
    await audioPlayer.play(widget.music.local_uri, isLocal: true);
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
      position = Duration();
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
    return Column(children: <Widget>[
      PriSecTextWidget(music: music),
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ControlWidget(
                color: color, icon: Icons.skip_previous, label: '上一曲'),
            isPlaying
                ? ControlWidget(
                    color: color,
                    icon: Icons.pause,
                    label: '暂停',
                    onTapAction: () => pause())
                : ControlWidget(
                    color: color,
                    icon: Icons.play_arrow,
                    label: '播放',
                    onTapAction: () => play()),
            ControlWidget(color: color, icon: Icons.skip_next, label: '下一曲'),
          ],
        ),
      ),
      isStopped? Container(width: 0.0, height: 0.0,) : LinearProgressIndicator(
        value: position.inMilliseconds / audioPlayer.duration.inMilliseconds + 1,
      ),
    ]);
  }

  @override
  void didUpdateWidget(MyAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final music = widget.music;
    if (oldWidget.music != music) {
      audioPlayer.stop().then((void _) {
        setState(() {
          playerState = PlayerState.stopped;
          position = Duration();
        });
        if (music.local_uri != null && music.local_uri.isNotEmpty) {
          audioPlayer.play(music.local_uri, isLocal: true);
          setState(() => playerState = PlayerState.playing);
        } else {
          audioPlayer.play(music.uri);
          compute(Music.downloadMusic, music).then((Future<String> futurePath) {
            futurePath.then((String path) {
              music.cached = true;
              music.local_uri = path;
              MusicsDatabaseRepository.get.update(music);
            });
          });
        }
      });
    }
  }
}

class PriSecTextWidget extends StatelessWidget {
  final Music music;
  const PriSecTextWidget({Key key, @required this.music}) : super(key: key);

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
          Chip(
            label: Text(
              music.album,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent.shade100,
          ),
        ],
      ),
    );
  }
}

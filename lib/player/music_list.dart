import 'dart:math';

import 'package:flutter/material.dart';
import 'package:haichaoyin/player/music_data.dart';
import 'package:haichaoyin/trial/head_stream.dart';

const List<Color> colors = [
  Colors.brown,
  Colors.green,
  Colors.yellow,
  Colors.blueAccent,
  Colors.redAccent
];

class MusicList3 extends StatelessWidget {
  const MusicList3(
      {Key key,
      this.onTapItem,
      this.onDoubleTap,
      this.onLongPressed,
      this.musics})
      : super(key: key);

  final MusicRowActionCallback onTapItem;
  final MusicRowActionCallback onDoubleTap;
  final MusicRowActionCallback onLongPressed;
  final List<Music> musics;

//  final Future<List<Music>> loadMusicByFacet;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      child: ListView.builder(
        shrinkWrap: true,
        key: const ValueKey<String>('music-list'),
        itemCount: musics.length,
        itemBuilder: (BuildContext context, int index) {
          final random = Random();
          var i = random.nextInt(5);
          return MusicRow(
            avatarBgColor: colors[i],
            music: musics[index],
            onTap: onTapItem,
            onDoubleTap: onDoubleTap,
            onLongPressed: onLongPressed,
          );
        },
      ),
    );
  }
}

typedef MusicRowActionCallback = void Function(Music music);

class MusicRow extends StatelessWidget {
  MusicRow(
      {this.music,
      this.onTap,
      this.onDoubleTap,
      this.onLongPressed,
      this.avatarBgColor})
      : super(key: ObjectKey(music));

  final Music music;
  final Color avatarBgColor;
  final MusicRowActionCallback onTap;
  final MusicRowActionCallback onDoubleTap;
  final MusicRowActionCallback onLongPressed;

  GestureTapCallback _getHandler(MusicRowActionCallback callback) {
    return callback == null ? null : () => callback(music);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _getHandler(onTap),
      onDoubleTap: _getHandler(onDoubleTap),
      onLongPress: _getHandler(onLongPressed),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Center(
                child: CircleAvatar(
                  backgroundColor: avatarBgColor,
                  child: Text(
                    music.artist ?? '',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    music.title,
                    style: TextStyle(fontSize: 16.0, letterSpacing: 1.2),
                  ),
                  Text(music.album),
                  Text(music.local_uri ?? ""),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

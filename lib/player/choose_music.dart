import 'dart:math';

import 'package:flutter/material.dart';
import 'package:haichaoyin/player/music_data.dart';

const List<Color> colors = [
  Colors.brown,
  Colors.green,
  Colors.yellow,
  Colors.blueAccent,
  Colors.redAccent
];

class MusicList2 extends StatefulWidget {
  final MusicRowActionCallback onTapItem;
  final MusicRowActionCallback onDoubleTap;
  final MusicRowActionCallback onLongPressed;
  final String facetName;
  final String facetValue;
  const MusicList2(
      {Key key,
        this.onTapItem,
        this.onDoubleTap,
        this.onLongPressed,
//      this.loadMusicByFacet,
        this.facetName,
        this.facetValue}) : super(key: key);
  @override
  State<StatefulWidget> createState() {

    return _MusicList2State();
  }


}

class _MusicList2State extends State<MusicList2> {
  Future<List<Music>> loadMusicByFacet;
  @override
  Widget build(BuildContext context) {

    return FutureBuilder<List<Music>>(
      future:
        loadMusicByFacet,
      builder: (context, snapshot) {
        if (snapshot.data == null)
          return Center(child: CircularProgressIndicator(),);
        return ListView.builder(
          shrinkWrap: true,
          key: const ValueKey<String>('music-list'),
          itemCount: snapshot.data.length,
          itemBuilder: (BuildContext context, int index) {
            final random = Random();
            var i = random.nextInt(5);
            return MusicRow(
              avatarBgColor: colors[i],
              music: snapshot.data[index],
              onTap: widget.onTapItem,
              onDoubleTap: widget.onDoubleTap,
              onLongPressed: widget.onLongPressed,
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadMusicByFacet = MusicsDatabaseRepository.get.getMusicsByFacet(widget.facetName, widget.facetValue);
  }
  @override
  void didUpdateWidget(MusicList2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.facetValue != widget.facetValue || oldWidget.facetName != widget.facetName) {
      loadMusicByFacet = MusicsDatabaseRepository.get.getMusicsByFacet(widget.facetName, widget.facetValue);
    }
  }
}
class MusicList extends StatelessWidget {
  const MusicList(
      {Key key,
      this.onTapItem,
      this.onDoubleTap,
      this.onLongPressed,
//      this.loadMusicByFacet,
      this.facetName,
      this.facetValue}) : super(key: key);

  final MusicRowActionCallback onTapItem;
  final MusicRowActionCallback onDoubleTap;
  final MusicRowActionCallback onLongPressed;
  final String facetName;
  final String facetValue;
//  final Future<List<Music>> loadMusicByFacet;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Music>>(
      future:
        MusicsDatabaseRepository.get.getMusicsByFacet(facetName, facetValue),
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.data == null)
          return Center(child: CircularProgressIndicator(),);
        return ListView.builder(
          shrinkWrap: true,
          key: const ValueKey<String>('music-list'),
          itemCount: snapshot.data.length,
          itemBuilder: (BuildContext context, int index) {
            final random = Random();
            var i = random.nextInt(5);
            return MusicRow(
              avatarBgColor: colors[i],
              music: snapshot.data[index],
              onTap: onTapItem,
              onDoubleTap: onDoubleTap,
              onLongPressed: onLongPressed,
            );
          },
        );
      },
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
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 40.0),
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
            CircleAvatar(
              backgroundColor: avatarBgColor,
              child: Text(
                music.artist ?? '',
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  music.title,
                  style: TextStyle(fontSize: 16.0, letterSpacing: 1.2),
                ),
                Text(music.album),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

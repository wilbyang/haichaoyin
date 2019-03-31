import 'package:flutter/material.dart';
import 'package:haichaoyin/player/music_data.dart';
import 'dart:math' as math;

class ChooseMusicScreen extends StatefulWidget {
  @override
  createState() => MusicState();
}

class MusicState extends State<ChooseMusicScreen> {
  List<Music> items = List();

  @override
  void initState() {
    super.initState();
    var repository = MusicsDatabaseRepository.get;
//    var insert = repository.insert(Music("匆匆那年", artist: "王菲", genre: "怀旧伤感", album: "菲比寻常"));
    repository.getMusics().then((musics) {
      setState(() {
        items = musics;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("选音乐"),
      ),
      body: Container(
        child: MusicList(
          musics: items,
          onLongPressed: (Music music) {},
          onTapItem: (Music music) {

          },
          onDoubleTap: (Music music) {},
        ),
      ),
    );

  }
}

class MusicList extends StatelessWidget {
  const MusicList(
      {Key key, this.musics, this.onTapItem, this.onDoubleTap, this.onLongPressed})
      : super(key: key);

  final List<Music> musics;
  final MusicRowActionCallback onTapItem;
  final MusicRowActionCallback onDoubleTap;
  final MusicRowActionCallback onLongPressed;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const ValueKey<String>('music-list'),
      itemExtent: MusicRow.kHeight,
      itemCount: musics.length,
      itemBuilder: (BuildContext context, int index) {
        return MusicRow(
            music: musics[index],
            onTap: onTapItem,
            onDoubleTap: onDoubleTap,
            onLongPressed: onLongPressed);
      },
    );
  }
}

typedef MusicRowActionCallback = void Function(Music music);

class MusicRow extends StatelessWidget {
  MusicRow({this.music, this.onTap, this.onDoubleTap, this.onLongPressed})
      : super(key: ObjectKey(music));

  final Music music;
  final MusicRowActionCallback onTap;
  final MusicRowActionCallback onDoubleTap;
  final MusicRowActionCallback onLongPressed;

  static const double kHeight = 79.0;

  GestureTapCallback _getHandler(MusicRowActionCallback callback) {
    return callback == null ? null : () => callback(music);
  }

  @override
  Widget build(BuildContext context) {
    final String title = '\$${music.title}';
    String artist = '${music.artist}';
    return InkWell(
        onTap: _getHandler(onTap),
        onDoubleTap: _getHandler(onDoubleTap),
        onLongPress: _getHandler(onLongPressed),
        child: Container(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 20.0),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor)
                )
            ),
            child: Row(
                children: <Widget>[
                  Text(music.artist ?? ''),
                  Text(title, textAlign: TextAlign.right),
                  Text(artist, textAlign: TextAlign.right),
                ]
            )
        ));
  }
}


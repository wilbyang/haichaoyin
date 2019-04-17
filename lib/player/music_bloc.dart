
import 'dart:async';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:haichaoyin/player/music_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

enum MusicControlOperation { stop, play, pause, next, previous }
typedef void OnError(Exception exception);
class Bloc {
  Bloc() {

    facet.distinct().listen((facet) async {
      final musics = await MusicsDatabaseRepository.get.getMusicsByFacet(facet);
      _musics.sink.add(musics);
    });

    chosenMusic.distinct().listen((music) async {
      if (music.local_uri == null || music.local_uri.isEmpty) {
        nextFlash("缓冲中");
        music.local_uri = await Music.downloadMusic(music);
        music.cached = true;
        await MusicsDatabaseRepository.get.update(music);
        nextFlash("缓存到本地");
      }
      await audioPlayer.stop();
      audioPlayer.play(music.local_uri, isLocal: true);
    });

    operations.listen((op) {
      switch(op) {

        case MusicControlOperation.stop:
          audioPlayer.stop();
          break;
        case MusicControlOperation.play:
          audioPlayer.play(_chosenMusic.value.local_uri, isLocal: true);
          break;
        case MusicControlOperation.pause:
          audioPlayer.pause();
          break;
        case MusicControlOperation.next:

          break;
        case MusicControlOperation.previous:
          break;
      }
    });


    flash.listen((flash) {
      print(flash);
    });
  }
  AudioPlayer audioPlayer = AudioPlayer();
  Stream<double> get playerPosition => audioPlayer.onAudioPositionChanged.map(
          (d) => d.inMilliseconds / audioPlayer.duration.inMilliseconds
  );

  Stream<AudioPlayerState> get playerSate => audioPlayer.onPlayerStateChanged;


  BehaviorSubject<String> _facet = BehaviorSubject.seeded("");
  Stream<String> get facet => _facet.stream;
  Function(String) get nextFact => _facet.sink.add;

  BehaviorSubject<String> _flash = BehaviorSubject.seeded("");
  Stream<String> get flash => _flash.stream;
  Function(String) get nextFlash => _flash.sink.add;


  BehaviorSubject<MusicControlOperation> _operations = BehaviorSubject.seeded(MusicControlOperation.stop);
  Stream<MusicControlOperation> get operations => _operations.stream;
  Function(MusicControlOperation) get act  => _operations.sink.add;

  BehaviorSubject<List<Music>> _musics = BehaviorSubject.seeded([]);
  Stream<List<Music>> get musics => _musics.stream;

  BehaviorSubject<Music> _chosenMusic = BehaviorSubject();
  Stream<Music> get chosenMusic => _chosenMusic.stream;
  Function(Music) get nextMusic => _chosenMusic.sink.add;

//  Function(List<Music>) get changeMusics    => _musics.sink.add;
  void dispose() {
    _chosenMusic.close();
    _facet.close();
    _musics.close();
  }

}

class Provider extends InheritedWidget {

  final bloc = Bloc();

  Provider({Key key, Widget child})
      : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static Bloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(Provider) as Provider).bloc;
  }

}

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:haichaoyin/player/music_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart';


typedef void OnError(Exception exception);
class Bloc {
  Bloc() {
    facet.distinct().listen((facet) async {
      final musics = await MusicsDatabaseRepository.get.getMusicsByFacet(facet);
      _musics.sink.add(musics);
    });
  }



  BehaviorSubject<String> _facet = BehaviorSubject.seeded("");
  Stream<String> get facet => _facet.stream;
  Function(String) get changeFact => _facet.sink.add;

  BehaviorSubject<String> _flash = BehaviorSubject.seeded("");
  Stream<String> get flash => _flash.stream;
  Function(String) get changeFlash => _flash.sink.add;

  BehaviorSubject<List<Music>> _musics = BehaviorSubject.seeded([]);
  Stream<List<Music>> get musics => _musics.stream;

  BehaviorSubject<Music> _chosenMusic = BehaviorSubject();
  Stream<Music> get chosenMusic => _chosenMusic.stream;
  Function(Music) get chooseMusic => _chosenMusic.sink.add;

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
import 'dart:math';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:haichaoyin/player/music_list.dart';
import 'package:haichaoyin/player/music_data.dart';
import 'package:rxdart/rxdart.dart';
class MyStream extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Provider(
          child: Scaffold(
            appBar: AppBar(title: Text("Stream test"),
            ),
            body: Center(
              child: new SomeChildWidget(),
            ),
            floatingActionButton: Builder(builder: (context) {
              final bloc = Provider.of(context);
              return FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () => bloc.changeGreeting("${Random(18).nextInt(12)}"),
              );
            },)
          ),
        )
    );
  }
}

class SomeChildWidget extends StatelessWidget {
  const SomeChildWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context);
    return Column(
      children: <Widget>[
        StreamBuilder<String>(
          stream: bloc.greeting,
          builder: (context, snapshot) {
            if (snapshot.data == null)
              return CircularProgressIndicator();
            else {
              return Text(snapshot.data);
            }
          },
        ),
        StreamBuilder<List<Music>>(
          stream: bloc.musics,
          builder: (context, snapshot) {
            if (snapshot.data == null)
              return Text("no data...");
            else {
              return MusicList3(musics: snapshot.data);
            }
          },
        ),
        Row(
          children: <Widget>[
            IconButton(icon: Icon(Icons.subdirectory_arrow_left),onPressed: () {
              bloc._facetValue.sink.add("王菲");
            },),
            IconButton(icon: Icon(Icons.subdirectory_arrow_right),onPressed: () {
              bloc._facetValue.sink.add("许巍");
            },),
          ],
        )
      ],
    );
  }
}


class Bloc {
  Bloc() {
    Observable.combineLatest2(_facetKey.stream, _facetValue.stream, (key, value) {
      return Tuple2<String, String>(key, value);
    }).distinct().listen((tuple) async {
//      final musics = await MusicsDatabaseRepository.get.getMusicsByFacet(tuple.item1, tuple.item2);
      _musics.sink.add(null);
    });
    //_greeting.stream.flatMap((s) =>)

  }
  BehaviorSubject<String> _greeting = BehaviorSubject.seeded("你好");//TODO: do not know why there is a warning
  Stream<String> get greeting => _greeting.stream;
  Function(String) get changeGreeting    => _greeting.sink.add;

  BehaviorSubject<String> _facetKey = BehaviorSubject.seeded("artist");
  BehaviorSubject<String> _facetValue = BehaviorSubject.seeded("");

  BehaviorSubject<List<Music>> _musics = BehaviorSubject.seeded([]);
  Stream<List<Music>> get musics => _musics.stream;


//  Function(List<Music>) get changeMusics    => _musics.sink.add;
  void dispose() {
    _greeting.close();
    _facetKey.close();
    _facetValue.close();
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
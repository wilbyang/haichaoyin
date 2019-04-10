import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:haichaoyin/player/choose_music.dart';
import 'package:http/http.dart' as http;

class PlayerPage extends StatefulWidget {
  PlayerPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _PlayerState createState() => _PlayerState();
}

class Music {
  final int userId;
  final int id;
  final String name;
  final String description;

  Music({this.userId, this.id, this.name, this.description});

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      userId: json['userId'],
      id: json['id'],
      name: json['title'],
      description: json['body'],
    );
  }
}

class _PlayerState extends State<PlayerPage> {
  int _selectedIndex = 1;
  Future<Music> _fetchMusic;

  @override
  void initState() {
    _fetchMusic = fetchMusic('https://jsonplaceholder.typicode.com/posts/1');
  }

  void _refreshMusic({String url = 'https://jsonplaceholder.typicode.com/posts/2'}) {
    setState(() {
      _fetchMusic = fetchMusic(url);
    });
  }
  Future<Music> fetchMusic(String url) async {
    final response =
        await http.get(url);

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return Music.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  Column _buildButtonColumn(Color color, IconData icon, String label) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: _refreshMusic,
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
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;

    Widget buttonSection = Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButtonColumn(color, Icons.skip_previous, '上一曲'),
            _buildButtonColumn(color, Icons.play_arrow, '播放'),
            _buildButtonColumn(color, Icons.skip_next, '下一曲'),
          ],
        ),
      );

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('我的医生')),
          BottomNavigationBarItem(icon: Icon(Icons.business), title: Text('iCare')),
          BottomNavigationBarItem(icon: Icon(Icons.school), title: Text('严选')),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('我')),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.black38,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),

      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: FutureBuilder(
              future: _fetchMusic,
              builder: (context, snapshot) {
                if(!snapshot.hasData) return CircularProgressIndicator();
            return ListView(
              children: <Widget>[
                Image.network(
                    "https://images.unsplash.com/photo-1471115853179-bb1d604434e0?dpr=1&auto=format&fit=crop&w=767&h=583&q=80&cs=tinysrgb&crop=",
                    width: 600,
                    height: 240,
                    fit: BoxFit.cover),
                _buildTitleSection(snapshot.data),
                buttonSection,
                _buildDescSection(snapshot.data),
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

  Widget _buildDescSection(Music music) {
    String description = music.description;
    Widget textSection = Container(
      padding: const EdgeInsets.all(32),
      child: Text(
        '$description',
        softWrap: true,
      ),
    );
    return textSection;
  }

  Widget _buildTitleSection(Music music) {
    String name = music.name;
    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
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
                    '$name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Kandersteg, Switzerland',
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
    return titleSection;
  }
}

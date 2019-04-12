
import 'package:flutter/material.dart';
import 'package:haichaoyin/player/choose_music.dart';
import 'package:haichaoyin/player/music_data.dart';

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

  const ControlWidget({Key key, @required this.label, @required this.icon, @required this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: null,
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
class _PlayerState extends State<PlayerPage> {
  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;

    Widget buttonSection = Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ControlWidget(color: color, icon: Icons.skip_previous, label:'上一曲'),
            ControlWidget(color: color, icon: Icons.play_arrow, label:'播放'),
            ControlWidget(color: color, icon: Icons.skip_next, label:'下一曲')
          ],
        ),
      );

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
              future: MusicsDatabaseRepository.get.insert(Music(title: "匆匆那年", uri: "", artist: "王菲", genre: "伤感真情", album: "菲比寻常")),
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
    return Container(
      padding: EdgeInsets.all(32),
      child: Text(
        '${music.album}',
        softWrap: true,
      ),
    );
  }

  Widget _buildTitleSection(Music music) {
    String name = music.title;
    Widget titleSection = Container(
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

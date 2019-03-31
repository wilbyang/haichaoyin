import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
abstract class Dao<T> {
  //queries
  String get createTableQuery;
  //abstract mapping methods
  T fromMap(Map<String, dynamic> query);
  List<T> fromList(List<Map<String,dynamic>> query);
  Map<String, dynamic> toMap(T object);
}
class DatabaseProvider {
  static final _instance = DatabaseProvider._internal();
  static final DatabaseProvider get = _instance;

  bool isInitialized = false;
  Database _db;

  DatabaseProvider._internal();

  Future<Database> db() async {
    if (!isInitialized) await _init();
    return _db;
  }

  Future _init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'music_app.db');
    _db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(MusicDao().createTableQuery);
        });
  }
}
class Music {
  int id;
  String title;
  String artist;
  String genre;
  String album;
  Music(this.title, {this.artist, this.genre, this.album});
}

class MusicDao implements Dao<Music> {
  final tableName = 'musics';
  final _columnId = 'id';
  final _columnTitle = 'title';
  final _columnArtist = 'artist';
  final _columnGenre = 'genre';
  final _columnAlbum = 'album';

  @override
  String get createTableQuery =>
      "CREATE TABLE $tableName($_columnId INTEGER PRIMARY KEY,"
          " $_columnTitle TEXT,"
          " $_columnArtist TEXT,"
          " $_columnAlbum TEXT,"
          " $_columnGenre TEXT)";
  @override
  Music fromMap(Map<String, dynamic> query) {
    Music music = Music(query[_columnTitle]);
    music.id = query[_columnId];
    music.artist = query[_columnArtist];
    music.album = query[_columnAlbum];
    music.genre = query[_columnGenre];
    return music;
  }
  @override
  Map<String, dynamic> toMap(Music object) {
    return <String, dynamic>{
      _columnTitle: object.title,
      _columnArtist: object.artist,
      _columnAlbum: object.album,
      _columnGenre: object.genre
    };
  }
  @override
  List<Music> fromList(List<Map<String,dynamic>> query) {
    List<Music> musics = List<Music>();
    for (Map map in query) {
      musics.add(fromMap(map));
    }
    return musics;
  }
}

class MusicsDatabaseRepository implements MusicsRepository {
  static final _instance = MusicsDatabaseRepository._internal();
  static MusicsDatabaseRepository get = _instance;

  MusicsDatabaseRepository._internal();
  final dao = MusicDao();
  @override
  DatabaseProvider databaseProvider = DatabaseProvider.get;
  @override
  Future<Music> insert(Music music) async {

    final db = await databaseProvider.db();
    music.id = await db.insert(dao.tableName, dao.toMap(music));
    return music;
  }
  @override
  Future<Music> delete(Music music) async {
    final db = await databaseProvider.db();
    await db.delete(dao.tableName,
        where: dao._columnId + " = ?", whereArgs: [music.id]);
    return music;
  }
  @override
  Future<Music> update(Music music) async {
    final db = await databaseProvider.db();
    await db.update(dao.tableName, dao.toMap(music),
        where: dao._columnId + " = ?", whereArgs: [music.id]);
    return music;
  }
  @override
  Future<List<Music>> getMusics() async {
    final db = await databaseProvider.db();
    List<Map> maps = await db.query(dao.tableName);
    return dao.fromList(maps);
  }
}
abstract class MusicsRepository {
  DatabaseProvider databaseProvider;

  Future<Music> insert(Music music);
  Future<Music> update(Music music);
  Future<Music> delete(Music music);
  Future<List<Music>> getMusics();
}

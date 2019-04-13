import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
abstract class Dao<T> {
  //queries
  String get createTableQuery;
  //abstract mapping methods
  T fromMap(Map<String, dynamic> query);
  List<T> fromResultSet(List<Map<String, dynamic>> query);
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
    _db = await openDatabase(path, version: 2,
      onCreate: (Database db, int version) {
        return db.execute(MusicDao.get.createTableQuery);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion)  {
        if (newVersion == 2) {
          return db.execute("ALTER TABLE ${MusicDao.get.tableName} ADD COLUMN uri TEXT ");
        }
      }
    );
  }
}
class Music {
  int id;
  String title;
  String artist;
  String genre;
  String album;
  String uri;
  Music({@required this.title, @required this.uri, this.artist, this.genre, this.album});
}

class MusicDao implements Dao<Music> {
  final tableName = 'musics';
  final _columnId = 'id';
  final _columnTitle = 'title';
  final _columnArtist = 'artist';
  final _columnGenre = 'genre';
  final _columnAlbum = 'album';
  final _columnURI = 'uri';
  MusicDao._internal();
  static final _instance = MusicDao._internal();
  static final MusicDao get = _instance;
  @override
  String get createTableQuery =>
      "CREATE TABLE $tableName($_columnId INTEGER PRIMARY KEY,"
          " $_columnTitle TEXT,"
          " $_columnArtist TEXT,"
          " $_columnAlbum TEXT,"
          " $_columnGenre TEXT,"
          " $_columnURI TEXT)";
  @override
  Music fromMap(Map<String, dynamic> query) {
    Music music = Music(title: query[_columnTitle], uri: query[_columnURI]);
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
      _columnGenre: object.genre,
      _columnURI: object.uri
    };
  }
  @override
  List<Music> fromResultSet(List<Map<String, dynamic>> query) {
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
  final dao = MusicDao.get;
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
    return dao.fromResultSet(maps);
  }

  @override
  Future<Music> getMusic(int id) async {
    final db = await databaseProvider.db();
    List<Map> resultSet = await db.query(dao.tableName, where: dao._columnId + " = ?", whereArgs: [id]);
    return dao.fromResultSet(resultSet).first;
  }

  @override
  Future<List<String>> getMusicArtistFacet() async {
    final db = await databaseProvider.db();
    List<String> artistFacet = List<String>();
    List<Map<String, dynamic>> maps = await db.rawQuery("SELECT DISTINCT artist FROM musics");
    return maps.map((map) => map["artist"] as String).toList();
  }

  @override
  Future<Map<String, List<String>>> getMusicFacet() async {
    Map<String, List<String>> ret = Map<String, List<String>>();
    ret["artist"] = await getMusicArtistFacet();
    ret["genre"] = await getMusicGenreFacet();
    return ret;
  }
  @override
  Future<List<String>> getMusicGenreFacet() async {
    final db = await databaseProvider.db();
    List<String> artistFacet = List<String>();
    List<Map<String, dynamic>> maps = await db.rawQuery("SELECT DISTINCT genre FROM musics");
    return maps.map((map) => map["genre"] as String).toList();
  }
}
abstract class MusicsRepository {
  DatabaseProvider databaseProvider;

  Future<Music> insert(Music music);
  Future<Music> update(Music music);
  Future<Music> delete(Music music);
  Future<List<Music>> getMusics();
  Future<Music> getMusic(int id);

  Future<List<String>> getMusicArtistFacet();
  Future<List<String>> getMusicGenreFacet();
  Future<Map<String, List<String>>> getMusicFacet();

}

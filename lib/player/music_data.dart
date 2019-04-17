import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const _tableName = 'musics';
const _columnId = 'id';
const _columnTitle = 'title';
const _columnArtist = 'artist';
const _columnGenre = 'genre';
const _columnAlbum = 'album';
const _columnURI = 'uri';
const _columnLocalURI = 'local_uri';
const _columnCached = 'cached';

const createTableQuery =
    "CREATE TABLE $_tableName($_columnId INTEGER PRIMARY KEY,"
    " $_columnTitle TEXT,"
    " $_columnArtist TEXT,"
    " $_columnAlbum TEXT,"
    " $_columnGenre TEXT,"
    " $_columnURI TEXT)";

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
    final databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'music_app.db');
    _db = await openDatabase(path, version: 4,
        onCreate: (Database db, int version) {
      return db.execute(createTableQuery);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) {
      if (newVersion == 2) {
        return db
            .execute("ALTER TABLE $_tableName ADD COLUMN $_columnURI TEXT ");
      }
      if (newVersion == 3) {
        return db.execute(
            "ALTER TABLE $_tableName ADD COLUMN $_columnLocalURI TEXT ");
      }
      if (newVersion == 4) {
        return db.execute(
            "ALTER TABLE $_tableName ADD COLUMN $_columnCached INTEGER ");
      }
    });
  }
}

class Music {
  int id;
  String title;
  String artist;
  String genre;
  String album;
  String uri;
  String local_uri;
  bool cached;
  Music({
    @required this.title,
    @required this.uri,
    this.artist,
    this.genre,
    this.album,
    this.local_uri,
    this.cached,
  });

  factory Music.fromMap(Map<String, dynamic> map) {
    Music music = Music(title: map[_columnTitle], uri: map[_columnURI]);
    music.id = map[_columnId] as int ?? 0;
    music.artist = map[_columnArtist] as String;
    music.album = map[_columnAlbum] as String;
    music.genre = map[_columnGenre] as String;
    music.local_uri = map[_columnLocalURI] as String;
    music.cached = map[_columnCached] as int == 1 ? true : false;
    return music;
  }

  @override
  String toString() {
    return "$title, $artist";
  }

  static Map<String, dynamic> toMap(Music object) {
    return <String, dynamic>{
      _columnTitle: object.title,
      _columnArtist: object.artist,
      _columnAlbum: object.album,
      _columnGenre: object.genre,
      _columnURI: object.uri,
      _columnLocalURI: object.local_uri,
      _columnCached: object.cached ? 1 : 0,
    };
  }

  static List<Music> fromResultSet(List<Map<String, dynamic>> resultSet) {
    return List.generate(resultSet.length, (i) {
      return Music.fromMap(resultSet[i]);
    });
  }

  static Future<String> downloadMusic(Music music) {
    return HttpClient()
        .getUrl(Uri.parse(music.uri))
        .then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${music.title}.mp3');
      await response.pipe(file.openWrite());
      return file.path;
    });
  }
}

class MusicsDatabaseRepository implements MusicsRepository {
  static final _instance = MusicsDatabaseRepository._internal();
  static MusicsDatabaseRepository get = _instance;

  MusicsDatabaseRepository._internal();
  @override
  DatabaseProvider databaseProvider = DatabaseProvider.get;
  @override
  Future<Music> insert(Music music) async {
    final db = await databaseProvider.db();
    music.id = await db.insert(_tableName, Music.toMap(music));
    return music;
  }

  @override
  Future<Music> delete(Music music) async {
    final db = await databaseProvider.db();
    await db
        .delete(_tableName, where: _columnId + " = ?", whereArgs: [music.id]);
    return music;
  }

  @override
  Future<Music> update(Music music) async {
    final db = await databaseProvider.db();
    await db.update(_tableName, Music.toMap(music),
        where: _columnId + " = ?", whereArgs: [music.id]);
    return music;
  }

  @override
  Future<List<Music>> getMusicsByFacet(String facet) async {
    if (facet == null || facet.isEmpty) {
      return Future.value(null);
    }
    final split = facet.split(":");
    final facetName = split.first;
    final facetValue = split[1];
    final db = await databaseProvider.db();
    List<Map> resultSet = await db
        .query(_tableName, where: facetName + " = ?", whereArgs: [facetValue]);
    return Music.fromResultSet(resultSet);
  }

  @override
  Future<List<Music>> getMusics() async {
    final db = await databaseProvider.db();
    List<Map> maps = await db.query(_tableName);
    return Music.fromResultSet(maps);
  }

  @override
  Future<Music> getMusic(int id) async {
    final db = await databaseProvider.db();
    List<Map> resultSet =
        await db.query(_tableName, where: _columnId + " = ?", whereArgs: [id]);
    return Music.fromResultSet(resultSet).first;
  }

  @override
  Future<List<String>> getMusicArtistFacet() async {
    final db = await databaseProvider.db();
    List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT DISTINCT artist FROM musics");
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
    List<Map<String, dynamic>> maps =
        await db.rawQuery("SELECT DISTINCT genre FROM musics");
    return maps.map((map) => map["genre"] as String).toList();
  }
}

abstract class MusicsRepository {
  DatabaseProvider databaseProvider;

  Future<Music> insert(Music music);
  Future<Music> update(Music music);
  Future<Music> delete(Music music);
  Future<List<Music>> getMusics();
  Future<List<Music>> getMusicsByFacet(String facet);
  Future<Music> getMusic(int id);

  Future<List<String>> getMusicArtistFacet();
  Future<List<String>> getMusicGenreFacet();
  Future<Map<String, List<String>>> getMusicFacet();
}

import 'package:path/path.dart';
import 'package:notekeeper/model/note.dart';
import 'package:sqflite/sqflite.dart';

class NoteHelper {
  static NoteHelper _noteHelper; //* Singleton Database Helper
  static Database _database; //* Singleton Database

  String dbName = "note.db";
  String noteTable = "note_table";
  String colID = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colDate = "date";
  String colPriority = "priority";

  NoteHelper._createInstance(); //? NamedConstructor to create instance of noteHelper

  factory NoteHelper() {
    if (_noteHelper == null) {
      _noteHelper =
          NoteHelper._createInstance(); //! this only execute only once
    }
    return _noteHelper;
  }

  //* create database andd open
  Future<Database> initailizeDatabase() async {
    String directoryPath = await getDatabasesPath();
    String path = join(directoryPath, dbName);
    var notesDatabase = openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $noteTable (
            $colID INTEGER PRIMARY KEY,
            $colTitle TEXT,
            $colDescription TEXT,
            $colDate TEXT,
            $colPriority INTEGER
          )
        ''');
      },
    );
    return notesDatabase;
  }

  //? if database is not created then this function will create and return it
  Future<Database> get database async {
    if (_database == null) {
      _database = await initailizeDatabase();
    }
    return _database;
  }

  //* getNotes from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    /* var result =
        await db.query('SELECT * FROM $noteTable ORDER BY $colPriority ASC'); */
    var result = await db.query(noteTable, orderBy: "$colPriority ASC");
    return result;
  }

  //* Insert notes into database
  Future<int> insertIntoDatabase(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  //* update notes into database
  Future<int> updateNotes(Note note) async {
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colID = ?', whereArgs: [note.id]);
    return result;
  }

  //* Delete note
  Future<int> deleteNote(int nodeid) async {
    Database db = await this.database;
    var result =
        await db.delete(noteTable, where: '$colID = ?', whereArgs: [nodeid]);
    return result;
  }

  //* Get Number of notes in database
  Future<int> getNoteCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //* GetNoteList from database and return as List<Note> to note_list.dart page
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList(); //* get MapList from database
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();

    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}

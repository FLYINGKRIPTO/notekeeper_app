import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:notekeeper_app/models/note.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;  //Singleton DatabaseHelper --> this means that
  //this instance will be initialized only once throughout the lifecycle of the application

  static  Database _database;

  String noteTable = 'noteTable';
  String colId= 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';


  //When you use factory keyword with constructor that means that
  //the constructor will allow you to return some value

  DatabaseHelper._createInstance(); //Named constructor to create instance of DatabaseHelper


  factory DatabaseHelper(){

    if(_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }
  //initialize database
 Future<Database>  initializeDatabase() async {
    //get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    var notesDatabase = await openDatabase(path, version: 1,onCreate: _createDb);
    return notesDatabase;
  }


   //create database
  void _createDb(Database db,int newVersion) async {
    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,'
        '$colTitle TEXT,'
        '$colDescription TEXT,'
        '$colPriority INTEGER,'
        '$colDate TEXT)');
  }

  //getter for our database
  Future<Database> get database async {

    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;

  }


  //Fetch Operation : get all note object to database
  Future<List<Map<String,dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    //var result  = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC' );
    return result;
  }

  //Insert Operation
  Future<int> insertNote(Note note) async {
    Database db  = await this.database;
    var result =await db.insert(noteTable, note.toMap());
    return result;
  }

  //update operation
  Future<int> updateNote(Note note) async  {
    var db =  await this.database;
    var result =await db.update(noteTable, note.toMap(),where: '$colId = ?', whereArgs: [note.id] );
    return result;
  }

  //Delete Operation
  Future<int> deleteNode(int id) async {
    var db = await this.database;
    int result  = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  //Get the number of objects in the Database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String,dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }
}
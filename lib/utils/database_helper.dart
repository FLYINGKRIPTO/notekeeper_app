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
}
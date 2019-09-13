import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper_app/screens/note_detail.dart';
import 'dart:async';
import 'package:notekeeper_app/models/note.dart';
import 'package:notekeeper_app/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';


class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;
  NoteDetail(this.note,this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note,this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  static var _priorities = ['high', 'low'];
  var _currentItemSelected = '';
  Note note;
  String appBarTitle;

  //Database Helper
  DatabaseHelper helper = DatabaseHelper();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note,this.appBarTitle);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentItemSelected = _priorities[0];
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;
    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }),
          ),
          body: Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: ListView(
                children: <Widget>[
                  //First Element

                  ListTile(
                    title: DropdownButton(
                      items: _priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),
                      style: textStyle,
                      value: getPriorityAsString(note.priority),
                      onChanged: (String valueSelectedByUser) {

                         _onDropDownItemSelected(valueSelectedByUser);
                          debugPrint('user selected $valueSelectedByUser');
                          updatePriorityAsInt(valueSelectedByUser);

                      },
                    ),
                  ),

                  //Second Element
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextField(
                      controller: titleController,
                      style: textStyle,
                      onChanged: (value) {
                        debugPrint('You changed it to $value');
                        updateTitle();
                      },
                      decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          )),
                    ),
                  ),

                  //Third Element
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextField(
                      controller: descriptionController,
                      style: textStyle,
                      onChanged: (value) {
                        debugPrint('You changed it to $value');
                        updateDescription();

                      },
                      decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          )),
                    ),
                  ),

                  //Fourth Element
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Save',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              debugPrint('Save button Clicked');
                              if(titleController.text.isEmpty){
                                _showAlertDialog('ERROR', 'Title field cannot be empty');
                              }
                              else{
                              _save();}
                            },
                          ),
                        ),
                        Container(
                          width: 6.9,
                        ),
                        Expanded(
                          child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Delete',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              debugPrint('Delete button Clicked');
                              //Delete function gets called once the delete button is pressed
                              _delete();
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context,true);

  }

  //Convert the String priority into integer before saving to the database
  void updatePriorityAsInt(String value){
    switch(value) {
      case 'High':
        note.priority =1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //Convert the integer priority to String prioroy and display it ti user in Dropdown
  String getPriorityAsString(int value){
    String priority;
    switch(value) {
      case 1:
        priority = _priorities[0];// 'High'
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }
  //update the title of the project
void updateTitle(){
    note.title = titleController.text;
}

 //update description
void updateDescription(){
    note.description  = descriptionController.text;
}

//Function to save the data to the database

void _delete() async {

    moveToLastScreen();
    //CASE 1 : if user is trying to delete a new note i.e he Has come to
    //the detail page by pressing the FAB of NoteList Page
    if(note.id == null){
          _showAlertDialog('Status ', 'No Note was deleted');
          return;
    }

    //CASE 2 : if user is trying to delete a note which already has a valid ID
    int result =  await helper.deleteNode(note.id);
    if(result != 0){
      _showAlertDialog('Status', 'Note deleted successfully');
    }
    else {
      _showAlertDialog('Status', 'Error occured whilr deleting the Note');
    }


}
void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());

    int result ;
    if(note.id != null){  //update operation
      result = await helper.updateNote(note);
    }
    else{  //insert operation
      result = await helper.insertNote(note);
    }

    if(result != 0){
      //success
      _showAlertDialog('status','Note saved successfully');
    }
    else{
      // failure
      _showAlertDialog('status','Problem in saving note');
    }


}

void _showAlertDialog(String title,String message){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    
    showDialog(context: context,
      builder: (_) =>alertDialog
    );
}

  void _onDropDownItemSelected(String newValueSelectedByUser) {

    setState(() {
      this._currentItemSelected = newValueSelectedByUser;
    });
  }
}

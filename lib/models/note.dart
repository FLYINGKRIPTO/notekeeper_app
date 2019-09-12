class Note{
  int _id;
  String _title,_description,_date;
  int _priority;

  //Made Description field optional
  Note(this._title,this._date,this._priority,[this._description]);
  Note.withId(this._title,this._date,this._priority,[this._description]);

  int get id => _id;
  String get title => _title;
  String get description => _description;
  String get date => _date;
  int get priority => _priority;

  set title(String newTitle){
     if(newTitle.length <= 255){
       this._title = newTitle;
     }
  }

  set description(String newDesc){
    if(newDesc.length <= 255){
      this._description = newDesc;
    }
  }

  set priority(int newPriority){
    if(newPriority >=1 && newPriority <=2){
      this._priority = newPriority;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  //Convert the NOTE object into a MAP Object
  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();

    if(id != null) {
      map['id'] = _id;
    }

    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = priority;
    map['date']= _date;

    return map;
  }

  //Extract a Note object from MAP object

  Note.fromMapObject(Map<String,dynamic> map){
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this.priority = map['priority'];
    this._date = map['date'];

  }


}
//* Model class is used for to create database table..it has all the attributes as database has.
//* this contains all getter and setter for all attribute except id as id are set by database.
//* aslo this class has toMap() and fromMap() function to convert class to map as,
// *sqlite only deals with map objects.

class Note {
  int _id;
  String _title;
  String _description;
  String _date;
  int _priority;

  Note(this._title, this._date, this._priority, this._description);
  Note.withID(
      this._id, this._title, this._date, this._priority, this._description);

  //* getter for attributes
  int get id => _id;
  String get title => _title;
  String get description => _description;

  String get date => _date;
  int get priority => _priority;

  //* setter for attributes except for _id as _id are created by database

  set title(String newtitle) {
    if (newtitle.length <= 255) {
      this._title = newtitle;
    }
  }

  set description(String newDesc) {
    if (newDesc.length <= 255) {
      this._description = newDesc;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2) {
      this._priority = newPriority;
    }
  }

  //* converting note object to Map object

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map['id'] = _id;
    map['title'] = _title;
    map['description'] = _description;
    map['date'] = _date;
    map['priority'] = _priority;
    return map;
  }

  Note.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._priority = map['priority'];
    this._date = map['date'];
  }
}

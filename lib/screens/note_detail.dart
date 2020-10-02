import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/model/note.dart';
import 'package:notekeeper/utils/notehelper.dart';

class NoteDetail extends StatefulWidget {
  NoteDetail(this.note, this.titlebartext, {Key key}) : super(key: key);
  final String titlebartext;
  final Note note;
  @override
  _NoteDetailState createState() => _NoteDetailState(this.note, titlebartext);
}

class _NoteDetailState extends State<NoteDetail> {
  final _formKey = GlobalKey<FormState>();
  NoteHelper noteHelper = NoteHelper();
  String titlebartext;
  Note note;
  _NoteDetailState(this.note, this.titlebartext);
  var _priorities = ["High", "Low"];
  var _currentPriority = "Low";
  TextEditingController titletextEditingController = TextEditingController();
  TextEditingController desctextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titletextEditingController.text = note.title;
    desctextEditingController.text = note.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(titlebartext),
        leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Navigator.pop(context, true);
            }),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: [
              myDropDown(),
              Padding(
                padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter Title';
                    }
                  },
                  controller: titletextEditingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    labelText: "Title",
                    hintText: "Enter Note title",
                  ),
                  onChanged: (value) {
                    _formKey.currentState.validate();
                    note.title = titletextEditingController.text;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 15.0),
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter Title';
                    }
                  },
                  controller: desctextEditingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    labelText: "Description",
                    hintText: "Enter Note Description",
                  ),
                  onChanged: (value) {
                    _formKey.currentState.validate();
                    note.description = desctextEditingController.text;
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      onPressed: () {
                        if (_formKey.currentState.validate()) _save();
                      },
                      child: Text(
                        "Save",
                        textScaleFactor: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      onPressed: _delete,
                      child: Text(
                        "Delete",
                        textScaleFactor: 1.5,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  myDropDown() {
    return ListTile(
      title: DropdownButton(
        items: _priorities.map((String dropDownStringItem) {
          return DropdownMenuItem<String>(
            value: dropDownStringItem,
            child: Text(dropDownStringItem),
          );
        }).toList(),
        value: getPriorityAsString(note.priority),
        onChanged: (valueSelectedByUser) {
          setState(() {
            _currentPriority = valueSelectedByUser;
            updatePriorityAsInt(valueSelectedByUser);
          });
        },
      ),
    );
  }

  //* Convert String priority to int before saving to database

  void updatePriorityAsInt(String priority) {
    switch (priority) {
      case "High":
        note.priority = 1;
        break;
      case "Low":
        note.priority = 2;
        break;
      default:
        note.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int priority) {
    String priorityString;
    switch (priority) {
      case 1:
        priorityString = _priorities[0];
        break;
      case 2:
        priorityString = _priorities[1];
        break;
      default:
        priorityString = _priorities[1];
    }
    return priorityString;
  }

  void _save() async {
    Navigator.pop(context, true);
    int result;
    note.date = DateFormat.yMMMd().format(DateTime.now());
    //print(note.toMap());
    if (note.id == null) {
      //* Insert Operation
      result = await noteHelper.insertIntoDatabase(note);
    } else {
      //* Update operation
      result = await noteHelper.updateNotes(note);
    }

    if (result != 0) {
      //* Success
      _alertDailog('Status', "Note Saved");
    } else {
      _alertDailog("Status", "Error...Not Saved");
    }
  }

  void _delete() async {
    //* case 1 : user is trying to delete note which is not exist in database
    //* He come to page by pressing FAB button and trying to delete
    Navigator.pop(context, true);
    if (note.id == null) {
      _alertDailog('Error', "Note not deleted");
      return;
    }

    //* case 2 note has valid id and try to delete
    int result = await noteHelper.deleteNote(note.id);

    if (result != 0) {
      _alertDailog('Success', "Note Deleted");
    } else {
      _alertDailog("Error", "Unable to delete note");
    }
  }

  void _alertDailog(String title, String msg) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(msg),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  bool validation(TextEditingController t1, TextEditingController t2) {
    bool result;
    result = t1.text == "" ? false : true;
    result = t2.text == "" ? false : true;

    return result;
  }
}

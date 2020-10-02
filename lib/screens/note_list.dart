import 'package:flutter/material.dart';
import 'package:notekeeper/model/note.dart';
import 'package:notekeeper/screens/note_detail.dart';
import 'package:notekeeper/utils/notehelper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  NoteList({Key key}) : super(key: key);

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  NoteHelper noteHelper = NoteHelper();
  int _noteCount = 0;
  List<Note> noteList;
  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateNoteListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 2, ''), "Add Note");
        },
        child: Icon(Icons.add),
      ),
      body: myListView(),
    );
  }

  ListView myListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: _noteCount,
      itemBuilder: (context, index) {
        return Card(
          elevation: 8.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[index].priority),
              child: getPriorityIcon(this.noteList[index].priority),
            ),
            title: Text(this.noteList[index].title, style: titleStyle),
            subtitle:
                Text(this.noteList[index].description, style: titleStyle), //
            trailing: GestureDetector(
              child: Icon(Icons.delete, color: Colors.grey),
              onTap: () {
                deleteNote(context, noteList[index]);
              },
            ),
            onTap: () {
              navigateToDetail(noteList[index], "Edit Note");
            },
          ),
        );
      },
    );
  }

  //* Navigate to note_detail.dart for editing note
  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetail(note, title)),
    );
    print("Operation on second sreen is successful...");
    if (result == true) {
      updateNoteListView();
    }
  }

  //* delete Note
  void deleteNote(BuildContext context, Note note) async {
    int result = await noteHelper.deleteNote(note.id);
    if (result != 0) {
      _snackBar(context, 'Note Deleted Succescfully...');
      updateNoteListView();
    }
  }

  //* UpdateNoteListView as note Added or deleted from list
  void updateNoteListView() {
    Future<Database> db = noteHelper.database;
    db.then((database) {
      Future<List<Note>> futureListNote = noteHelper.getNoteList();
      futureListNote.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this._noteCount = noteList.length;
        });
      });
    });
  }

  //* Show Snackbar
  void _snackBar(BuildContext context, String msg) {
    SnackBar snackBar = SnackBar(
      content: Text(msg),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  //* Retrun the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
        break;
    }
  }

  //* Retrun the priority Icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
        break;
    }
  }
}

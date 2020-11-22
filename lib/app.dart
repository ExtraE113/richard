import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:richard/services/auth.dart';

class CupertinoTodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoTodoHomePage(),
    );
  }
}

class CupertinoTodoHomePage extends StatefulWidget {
  @override
  _CupertinoTodoHomePageState createState() => _CupertinoTodoHomePageState();
}

class _CupertinoTodoHomePageState extends State<CupertinoTodoHomePage> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  CollectionReference _users;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Thing A Day"),
        trailing: GestureDetector(
          child: Icon(CupertinoIcons.plus),
          onTap: () async {
            final result = await Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => AddTask(),
                fullscreenDialog: true,
              ),
            );
            if (result != null) {
              await _initialization;
              _users = FirebaseFirestore.instance.collection('users');
              print("here");
              _users
                  .doc(await AuthService().getUID())
                  .set({'full_text' + (DateTime.now().millisecondsSinceEpoch).toString(): result},
                      SetOptions(merge: true))
                  .then((value) => print("Added"))
                  .catchError((error) => print("Error: $error"));
            }
          },
        ),
      ),
      child: Center(
        child: FutureBuilder(
          future: _initialization,
          builder: (BuildContext context, prim) {
            _users = FirebaseFirestore.instance.collection('users');
            if (prim.hasError) {
              return Text("Something went wrong. That's all we know.");
            }
            if (prim.connectionState == ConnectionState.done) {
              return FutureBuilder(
                future: AuthService().getUID(),
                builder: (BuildContext _, uidSnapshot) {
                  return uidSnapshot.hasData
                      ? StreamBuilder(
                          stream: _users.doc(uidSnapshot.data).snapshots(),
                          builder: (BuildContext _, docSnapshot) {
                            return docSnapshot.hasData
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          docSnapshot.data.data().values.length > 0
                                              ? docSnapshot.data
                                                  .data()
                                                  .values
                                                  .elementAt(_index)
                                                  .toString()
                                              : "Add a task",
                                          style: CupertinoTheme.of(context)
                                              .textTheme
                                              .textStyle
                                              .copyWith(fontSize: 32)),
                                      Padding(padding: EdgeInsets.all(16.0)),
                                      CupertinoButton(
                                        child: docSnapshot.data.data().values.length > 0
                                            ? Text("Done!")
                                            : Icon(CupertinoIcons.add),
                                        onPressed: () async {
                                          if (docSnapshot.data.data().values.length > 0) {
                                            var keyName = docSnapshot.data
                                                .data()
                                                .keys
                                                .elementAt(_index)
                                                .toString();
                                            _users
                                                .doc(uidSnapshot.data)
                                                .update({keyName: FieldValue.delete()});
                                            int len = docSnapshot.data.data().values.length;
                                            if (_index > len - 1) {
                                              setState(() {
                                                _index = 0;
                                              });
                                            }
                                          } else {
                                            final result = await Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (context) => AddTask(),
                                                fullscreenDialog: true,
                                              ),
                                            );
                                            if (result != null) {
                                              await _initialization;
                                              _users =
                                                  FirebaseFirestore.instance.collection('users');
                                              print("here");
                                              _users
                                                  .doc(await AuthService().getUID())
                                                  .set({
                                                    'full_text' +
                                                        (DateTime.now().millisecondsSinceEpoch)
                                                            .toString(): result
                                                  }, SetOptions(merge: true))
                                                  .then((value) => print("Added"))
                                                  .catchError((error) => print("Error: $error"));
                                            }
                                          }
                                        },
                                        color: CupertinoColors.activeBlue,
                                      ),
                                      AbsorbPointer(
                                        absorbing: !(docSnapshot.data.data().values.length > 0),
                                        child: Opacity(
                                          opacity: docSnapshot.data.data().values.length > 0 ? 1 : 0,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              CupertinoButton(
                                                child: Text("Later"),
                                                onPressed: () {
                                                  setState(() {
                                                    int len = docSnapshot.data.data().values.length;
                                                    _index++;
                                                    _index = _index % len;
                                                    print(_index);
                                                  });
                                                },
                                                padding: EdgeInsets.all(0),
                                              ),
                                              Padding(padding: EdgeInsets.all(8.0)),
                                              CupertinoButton(
                                                child: Text(
                                                  "Delete",
                                                  style: CupertinoTheme.of(context)
                                                      .textTheme
                                                      .textStyle
                                                      .copyWith(color: CupertinoColors.destructiveRed),
                                                ),
                                                onPressed: () {
                                                  var keyName = docSnapshot.data
                                                      .data()
                                                      .keys
                                                      .elementAt(_index)
                                                      .toString();
                                                  _users
                                                      .doc(uidSnapshot.data)
                                                      .update({keyName: FieldValue.delete()});
                                                  int len = docSnapshot.data.data().values.length;
                                                  if (_index > len - 1) {
                                                    setState(() {
                                                      _index = 0;
                                                    });
                                                  }
                                                },
                                                padding: EdgeInsets.all(0),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : CupertinoActivityIndicator();
                          },
                        )
                      : CupertinoActivityIndicator();
                },
              );
            }
            return CupertinoActivityIndicator();
          },
        ),
      ),
    );
  }
}

class AddTask extends StatefulWidget {
  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text("Add a thing"),
        trailing: CupertinoButton(
          padding: EdgeInsets.all(0),
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text("What're you going to do?",
                  style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 42)),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: CupertinoTextField(
                controller: _textController,
                placeholder: "Call mom",
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 32),
                onSubmitted: (_) {
                  Navigator.of(context).pop(_textController.text);
                },
              ),
            ),
            Padding(padding: EdgeInsets.all(16)),
            Center(
              child: CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop(_textController.text);
                },
                child: Text("I'm done"),
                color: CupertinoColors.activeBlue,
              ),
            )
          ],
        ),
      ),
    );
  }
}

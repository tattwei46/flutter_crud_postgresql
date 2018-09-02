import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() => runApp(new MyApp());

class Hero {
  Hero({this.id, this.name});
  final int id;
  String name;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

enum HttpRequestStatus {
  NOT_DONE,
  DONE,
  ERROR
}

class DialogUpdateHero extends StatefulWidget {
  final int id;
  final String name;
  DialogUpdateHero({this.id, this.name});

  @override
  _DialogUpdateHeroState createState() => new _DialogUpdateHeroState();
}

class _DialogUpdateHeroState extends State<DialogUpdateHero> {
  bool _canSave = false;
  String updatedName;
  TextEditingController _controller;

  void _setCanSave(bool save) {
    if (save != _canSave)
      setState(() => _canSave = save);
  }

  @override
    void initState() {
      super.initState();
      _controller = new TextEditingController(text: widget.name);

    }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return new Scaffold(
      appBar: new AppBar(
          title: const Text('Update Hero'),
          backgroundColor: Colors.blue,
          actions: <Widget> [
            new FlatButton(
                child: new Text('Save', style: theme.textTheme.body1.copyWith(color: _canSave ? Colors.white : new Color.fromRGBO(255, 255, 255, 0.5))),
                onPressed: _canSave ? () { Navigator.of(context).pop(updatedName); } : null
            )
          ]
      ),
      body: new Form(
        child: new ListView(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          children: <Widget>[
            new TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Tap to enter Hero name",
              ),
              onChanged: (String value) {
                updatedName = value;
                _setCanSave(value.isNotEmpty);
              },
            ),    
          ],
        ),
      ),
    );
  }
}


class DialogAddHero extends StatefulWidget {
  @override
  _DialogAddHeroState createState() => new _DialogAddHeroState();
}

class _DialogAddHeroState extends State<DialogAddHero> {
  bool _canSave = false;
  String name;

  void _setCanSave(bool save) {
    if (save != _canSave)
      setState(() => _canSave = save);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return new Scaffold(
      appBar: new AppBar(
          title: const Text('Add New Hero'),
          backgroundColor: Colors.blue,
          actions: <Widget> [
            new FlatButton(
                child: new Text('ADD', style: theme.textTheme.body1.copyWith(color: _canSave ? Colors.white : new Color.fromRGBO(255, 255, 255, 0.5))),
                onPressed: _canSave ? () { Navigator.of(context).pop(name); } : null
            )
          ]
      ),
      body: new Form(
        child: new ListView(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
          children: <Widget>[
            new TextField(
              decoration: const InputDecoration(
                labelText: "Tap to enter Hero name",
              ),
              onChanged: (String value) {
                name = value;
                _setCanSave(value.isNotEmpty);
              },
            ),    
          ],
        ),
      ),
    );
  }
}


class _MyHomePageState extends State<MyHomePage> {
  static const _heroesUrl = 'http://localhost:8888/heroes';
  static final _headers = {'Content-Type': 'application/json'};

  var newHero = new Hero(id: 18, name: "dragonman");

  HttpRequestStatus httpRequestStatus = HttpRequestStatus.NOT_DONE;

  Future<List<Hero>> readHeroes() async {
    final response = await http.get(_heroesUrl);
    print(response.body);
    List responseJson = json.decode(response.body.toString());
    List<Hero> userList = createHeroesList(responseJson);
    return userList;
  }

  List<Hero> createHeroesList(List data) {
    List<Hero> list = new List();

    for (int i = 0; i < data.length; i++) {
      String name = data[i]["name"];
      int id = data[i]["id"];
      Hero hero = new Hero(name: name, id: id);
      list.add(hero);
    }

    return list;
  }

  Future createHero(String name) async {
    httpRequestStatus = HttpRequestStatus.NOT_DONE;
    final response = await http.post(_heroesUrl,
        headers: _headers, body: json.encode({'name': name}));
    if (response.statusCode == 200) {
      print(response.body.toString());
      httpRequestStatus = HttpRequestStatus.DONE;
    } else {
      httpRequestStatus = HttpRequestStatus.ERROR;
    }

    return httpRequestStatus;
  }

  Future deleteHero(int id) async {
    httpRequestStatus = HttpRequestStatus.NOT_DONE;
    final url = '$_heroesUrl/$id';
    final response = await http.delete(url, headers: _headers);
    if (response.statusCode == 200) {
      print(response.body.toString());
      httpRequestStatus = HttpRequestStatus.DONE;
    } else {
      //throw Exception('Failed to delete data');
      httpRequestStatus = HttpRequestStatus.ERROR;
    }

    return httpRequestStatus;
  }

  Future updateHero(int id, String name) async {
    httpRequestStatus = HttpRequestStatus.NOT_DONE;
    final url = '$_heroesUrl/$id';
    final response = await http.put(url,
        headers: _headers, body: json.encode({'id': id, 'name': name}));
    if (response.statusCode == 200) {
      print(response.body.toString());
      httpRequestStatus = HttpRequestStatus.DONE;
    } else {
      httpRequestStatus = HttpRequestStatus.ERROR;
    }
  }

  Future _openDialogAddHero() async {
    String name = await Navigator.of(context).push(
      new MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return new DialogAddHero();
        },
        fullscreenDialog: true));

    return name;
  }

  Future _openDialogUpdateHero(int id, String oldName) async {
    print(oldName);
    String name = await Navigator.of(context).push(
      new MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return new DialogUpdateHero(id: id, name: oldName,);
        },
        fullscreenDialog: true));

    return name;
  }

  void _addHeroService() async {
    String name = await _openDialogAddHero();
    HttpRequestStatus httpRequestStatus = await createHero(name);
    if (httpRequestStatus == HttpRequestStatus.DONE) {
      setState(() {
        
      });
    }
  }

  Future _updateHeroService(int id, String name) async {
    String updatedName = await _openDialogUpdateHero(id, name);
    HttpRequestStatus httpRequestStatus = await updateHero(id, updatedName);
    if (httpRequestStatus == HttpRequestStatus.DONE) {
      print(httpRequestStatus.toString());
      setState(() {
        
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter CRUD Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter CRUD Demo'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _addHeroService,
              tooltip: 'Add New Hero',
            )
          ],
        ),
        body: new Container(
          child: new FutureBuilder<List<Hero>>(
            future: readHeroes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return new ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      var item = snapshot.data[index];

                      return Dismissible(
                        key: Key(item.id.toString()),
                        onDismissed: (direction) async {
                          httpRequestStatus = await deleteHero(item.id);
                          if (httpRequestStatus == HttpRequestStatus.DONE) {
                            setState(() {
                              snapshot.data.removeAt(index);  
                            });
                          }
                          // Then show a snackbar!
                          // Scaffold.of(context).showSnackBar(
                          //     SnackBar(content: Text("${item.name}} dismissed")));
                        },
                        // Show a red background as the item is swiped away
                        background: Container(color: Colors.red),
                        child: ListTile(
                          title: Text('${item.name}'),
                          onTap: () => _updateHeroService(item.id, item.name)
                      ));
                    });
              } else if (snapshot.hasError) {
                return new Text("${snapshot.error}");
              }

              // By default, show a loading spinner
              return new CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}

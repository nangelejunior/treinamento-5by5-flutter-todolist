import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/models/item.model.dart';

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskCtrl = TextEditingController();

  void add() {
    setState(() {
      widget.items.add(new Item(
        title: newTaskCtrl.value.text,
        done: false,
      ));
      newTaskCtrl.clear();
      save();
    });
  }

  void remove(index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString("data", jsonEncode(widget.items));
  }

  Future loadData() async {
    var pres = await SharedPreferences.getInstance();
    var data = pres.getString("data");
    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();

      setState(() {
        widget.items = result;
      });
    }
  }

  _HomePageState() {
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskCtrl,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: "Nova Tarefa",
            labelStyle: TextStyle(
              color: Colors.white,
            ),
          ),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return Dismissible(
            key: Key(widget.items[index].title),
            child: CheckboxListTile(
              title: Text(widget.items[index].title),
              value: widget.items[index].done,
              onChanged: (bool value) {
                setState(() {
                  widget.items[index].done = value;
                  save();
                });
              },
            ),
            onDismissed: (direction) {
              remove(index);
            },
            background: Container(
              color: Colors.red,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}

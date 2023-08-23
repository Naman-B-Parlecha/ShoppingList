import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoppinglist_app/data/categories.dart';
import 'package:shoppinglist_app/models/grocery_item.dart';
import 'package:shoppinglist_app/widgets/newitem.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() {
    return _GroceryListState();
  }
}

class _GroceryListState extends State<GroceryList> {
  var isloading = true;
  String? error;
  List<GroceryItem> grocerylist = [];
  void loaditems() async {
    final url = Uri.https(
        'naman-db189-default-rtdb.firebaseio.com', 'shoppinglist.json');

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          error = "No able to fetch data at the moment,Kindly try again later";
        });
      }
      if (response.body == 'null') {
        setState(() {
          isloading = false;
        });
        return;
      }
      Map<String, dynamic> loadeditems = json.decode(response.body);
      List<GroceryItem> newitemloaded = [];
      for (final items in loadeditems.entries) {
        final category = categories.entries
            .firstWhere(
                (catval) => catval.value.title == items.value['category'])
            .value;
        newitemloaded.add(GroceryItem(
            id: items.key,
            name: items.value['name'],
            quantity: items.value['quantity'],
            category: category));
      }
      setState(() {
        isloading = true;
        grocerylist = newitemloaded;
      });
    } catch (err) {
      setState(() {
        error = "Something went wrong......";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loaditems();
  }

  void additem() async {
    final newitem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );
    if (newitem == null) {
      return;
    }
    setState(() {
      grocerylist.add(newitem);
    });
    // loaditems();
  }

  void removeitem(GroceryItem item) async {
    final indexing = grocerylist.indexOf(item);
    setState(() {
      grocerylist.remove(item);
    });
    final url = Uri.https('naman-db189-default-rtdb.firebaseio.com',
        'shoppinglist/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        grocerylist.insert(indexing, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content =
        const Center(child: Text('No item available kindly enter a new item'));
    if (isloading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (grocerylist.isNotEmpty) {
      content = ListView.builder(
        itemCount: grocerylist.length,
        itemBuilder: (context, index) => Dismissible(
          onDismissed: (direction) {
            removeitem(grocerylist[index]);
          },
          key: ValueKey(grocerylist[index].id),
          child: ListTile(
            title: Text(grocerylist[index].name),
            leading: Container(
              height: 24,
              width: 24,
              color: grocerylist[index].category.color,
            ),
            trailing: Text(grocerylist[index].quantity.toString()),
          ),
        ),
      );
    }
    if (error != null) {
      content = Center(child: Text(error!));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groceries"),
        actions: [
          IconButton(
            onPressed: additem,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoppinglist_app/data/categories.dart';
import 'package:shoppinglist_app/models/category.dart';
import 'package:shoppinglist_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  var issending = false;
  final _formKey = GlobalKey<FormState>();
  var entername = "";
  var enterquantity = 1;
  var entercategory = categories[Categories.vegetables]!;

  void submitform() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        issending = true;
      });
      _formKey.currentState!.save();
      final url = Uri.https(
          'naman-db189-default-rtdb.firebaseio.com', 'shoppinglist.json');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'name': entername,
            'quantity': enterquantity,
            'category': entercategory.title
          },
        ),
      );
      final resdata = json.decode(response.body);
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(GroceryItem(
          id: resdata['name'],
          name: entername,
          quantity: enterquantity,
          category: entercategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add a new item")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text("Grocery")),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return "Enter a valid input";
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    entername = newValue!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: '1',
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(label: Text("Quantity")),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return "Enter a valid input, greater than 0";
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          enterquantity = int.parse(newValue!);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: entercategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 16,
                                      width: 16,
                                      color: category.value.color,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(category.value.title)
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          setState(() {
                            entercategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: issending
                            ? null
                            : () {
                                _formKey.currentState!.reset();
                              },
                        child: Text("Reset")),
                    ElevatedButton(
                      onPressed: issending ? null : submitform,
                      child: issending
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ))
                          : Text("Submit"),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}

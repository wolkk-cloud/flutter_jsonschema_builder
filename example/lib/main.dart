import 'dart:convert';
import 'dart:developer';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/flutter_jsonschema_builder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final json = '''
 {
  "title": "Texto",
  "type": "object",
  "properties": {
    
    "files": {
      "type": "array",
      "title": "Multiple files",
      "items": {
        "type": "string",
        "format": "data-url"
      }
    },
    "select": {
      "title" : "Select your Cola",
      "type": "string",
      "description": "This is the select-description",
      "enum" : [0,1,2,3,4],
      "enumNames" : ["Vale 0","Vale 1","Vale 2","Vale 3","Vale 4"],
      "default" : 3
    },
    "profession" :  {
      "type":"string",
      "default" : "investor",
      "oneOf":[
          {
            "enum":[
                "trader"
            ],
            "type":"string",
            "title":"Trader"
          },
          {
            "enum":[
                "investor"
            ],
            "type":"string",
            "title":"Inversionista"
          },      
          {
            "enum":[
                "manager_officier"
            ],
            "type":"string",
            "title":"Gerente / Director(a)"
          }
      ],
      "title":"Ocupación o profesión"
    },
    "isGood" :  {
      "type":"boolean",
      "description": "This is the select-description",
      "format" : "date",
      "title":"good o profesión"
    }

  }
}


  ''';

  final jsonSchema = '''
  {
    "type": "object",
    "description": "Geo fruits surway",
    "properties": {
      "question": {
        "type": "string",
        "description": "Do you like apples?",
        "enum": ["Yes, coz I'm Tom Cook", "Yes", "No"]
      },
      "when": {
        "type": "string",
        "format": "date-time",
        "description": "When did realise that like/dislike apples?"
      },
      "amount": {
        "type": "number",
        "minimum": 0,
        "description": "How many apples do you eat per day?",
        "default": "0"
      },
      "will": {
        "type": "boolean",
        "description":
            "Are you willing to eat only apples till the end of your life?"
      }
    },
    "required": ["question", "when"]
  } ''';
  final Map<String, dynamic> jsonSchema1 = {
    "type": "object",
    "description": "Geo fruits surway",
    "properties": {
      "question": {
        "type": "string",
        "description": "Do you like apples?",
        "enum": ["Yes, coz I'm Tom Cook", "Yes", "No"]
      },
      "when": {
        "type": "string",
        "format": "date-time",
        "description": "When did realise that like/dislike apples?"
      },
      "amount": {
        "type": "number",
        "minimum": 0,
        "description": "How many apples do you eat per day?",
        "default": 0
      },
      "will": {
        "type": "boolean",
        "description":
            "Are you willing to eat only apples till the end of your life?"
      }
    },
    "required": ["question", "when"]
  };

  final uiSchema = '''

{
 "question": {
						"ui:widget": "radio"
					}
}

        ''';

  Map<String, dynamic> updateIntegerValuesToString(Map<String, dynamic> json) {
    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        updateIntegerValuesToString(value);
      } else if (value is int) {
        json[key] = value.toString();
      }
    });
    return json;
  }

  Future<List<XFile>?> defaultCustomFileHandler() async {
    await Future.delayed(const Duration(seconds: 3));

    final file1 = XFile(
        'https://cdn.mos.cms.futurecdn.net/LEkEkAKZQjXZkzadbHHsVj-970-80.jpg');
    final file2 = XFile(
        'https://cdn.mos.cms.futurecdn.net/LEkEkAKZQjXZkzadbHHsVj-970-80.jpg');
    final file3 = XFile(
        'https://cdn.mos.cms.futurecdn.net/LEkEkAKZQjXZkzadbHHsVj-970-80.jpg');

    return [file1, file2, file3];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Material(
              child: JsonForm(
                jsonSchema:
                    jsonEncode(updateIntegerValuesToString(jsonSchema1)),
                uiSchema: uiSchema,
                showHeader: false,
                onFormDataSaved: (data) {
                  inspect(data);
                },
                fileHandler: () => {
                  'files': defaultCustomFileHandler,
                  'file': () async {
                    return [
                      XFile(
                          'https://cdn.mos.cms.futurecdn.net/LEkEkAKZQjXZkzadbHHsVj-970-80.jpg')
                    ];
                  },
                  '*': defaultCustomFileHandler
                },
                customPickerHandler: () => {
                  '*': (data) async {
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return Scaffold(
                            body: Container(
                              margin: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Text('My Custom Picker'),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: data.keys.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(data.values
                                            .toList()[index]
                                            .toString()),
                                        onTap: () => Navigator.pop(
                                            context, data.keys.toList()[index]),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  }
                },
                jsonFormSchemaUiConfig: JsonFormSchemaUiConfig(
                  title: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                  fieldTitle: const TextStyle(color: Colors.pink, fontSize: 12),
                  submitButtonBuilder: (onSubmit) => TextButton.icon(
                    onPressed: onSubmit,
                    icon: const Icon(Icons.heart_broken),
                    label: const Text('Enviar'),
                  ),
                  addItemBuilder: (onPressed, key) => TextButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.plus_one),
                    label: const Text('Add Item'),
                  ),
                  addFileButtonBuilder: (onPressed, key) {
                    if (['file', 'file3'].contains(key)) {
                      return OutlinedButton(
                        onPressed: onPressed,
                        child: Text('+ Agregar archivo $key'),
                        style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(
                                const Size(double.infinity, 40)),
                            backgroundColor: MaterialStateProperty.all(
                              const Color(0xffcee5ff),
                            ),
                            side: MaterialStateProperty.all(
                                const BorderSide(color: Color(0xffafd5ff))),
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(color: Color(0xff057afb)))),
                      );
                    }

                    return null;
                  },
                ),
                customValidatorHandler: () => {
                  'files': (value) {
                    return null;
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

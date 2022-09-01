// ignore_for_file: avoid_print

import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_form/src/builder/array_schema_builder.dart';
import 'package:flutter_jsonschema_form/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_form/src/builder/object_schema_builder.dart';
import 'package:flutter_jsonschema_form/src/builder/property_schema_builder.dart';
import 'package:flutter_jsonschema_form/src/models/json_form_schema_style.dart';
import 'dart:convert';

import '../models/models.dart';

// ignore: prefer_generic_function_type_aliases
typedef Map<String, Future<List<File>?> Function()?> CustomFileHandler();
typedef Map<String, Future<dynamic> Function(Map data)> CustomPickerHandler();

typedef Map<String, String? Function(dynamic)?> CustomValidatorHandler();

class JsonForm extends StatefulWidget {
  const JsonForm({
    Key? key,
    required this.jsonSchema,
    this.uiSchema,
    required this.onFormDataSaved,
    this.onChanged,
    this.customFileHandler,
    this.jsonFormSchemaUiConfig,
    this.customPickerHandler,
    this.customValidatorHandler,
  }) : super(key: key);

  final String jsonSchema;
  final void Function(dynamic) onFormDataSaved;
  final void Function(dynamic data)? onChanged;

  final String? uiSchema;
  final CustomFileHandler? customFileHandler;

  final JsonFormSchemaUiConfig? jsonFormSchemaUiConfig;

  final CustomPickerHandler? customPickerHandler;

  final CustomValidatorHandler? customValidatorHandler;
  @override
  _JsonFormState createState() => _JsonFormState();
}

class _JsonFormState extends State<JsonForm> {
  late SchemaObject mainSchema;

  final _formKey = GlobalKey<FormState>();

  _JsonFormState();

  @override
  void initState() {
    mainSchema = (Schema.fromJson(json.decode(widget.jsonSchema),
        id: kGenesisIdKey) as SchemaObject)
      ..setUiSchema(
          widget.uiSchema != null ? json.decode(widget.uiSchema!) : null);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetBuilderInherited(
      mainSchema: mainSchema,
      onChanged: widget.onChanged,
      customFileHandler: widget.customFileHandler,
      customPickerHandler: widget.customPickerHandler,
      customValidatorHandler: widget.customValidatorHandler,
      child: Builder(builder: (context) {
        final widgetBuilderInherited = WidgetBuilderInherited.of(context);

        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  if (!kReleaseMode)
                    TextButton(
                      onPressed: () {
                        inspect(mainSchema);
                      },
                      child: const Text('INSPECT'),
                    ),
                  _buildHeaderTitle(context),
                  FormFromSchemaBuilder(
                    mainSchema: mainSchema,
                    schema: mainSchema,
                  ),
                  const SizedBox(height: 20),
                  widgetBuilderInherited.uiConfig.submitButtonBuilder == null
                      ? ElevatedButton(
                          onPressed: () => onSubmit(widgetBuilderInherited),
                          child: const Text('Enviar'),
                        )
                      : widgetBuilderInherited.uiConfig.submitButtonBuilder!(
                          () => onSubmit(widgetBuilderInherited)),
                ],
              ),
            ),
          ),
        );
      }),
    )..setJsonFormSchemaStyle(context, widget.jsonFormSchemaUiConfig);
  }

  Widget _buildHeaderTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: Text(
            mainSchema.title,
            style: WidgetBuilderInherited.of(context).uiConfig.title,
            textAlign: WidgetBuilderInherited.of(context).uiConfig.titleAlign,
          ),
        ),
        const Divider(),
        if (mainSchema.description != null)
          SizedBox(
            width: double.infinity,
            child: Text(
              mainSchema.description!,
              style: WidgetBuilderInherited.of(context).uiConfig.description,
              textAlign: WidgetBuilderInherited.of(context).uiConfig.titleAlign,
            ),
          ),
      ],
    );
  }

  //  Form methods
  void onSubmit(WidgetBuilderInherited widgetBuilderInherited) {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      print(widgetBuilderInherited.data);

      widget.onFormDataSaved(widgetBuilderInherited.data);
    }
  }
}

class FormFromSchemaBuilder extends StatelessWidget {
  const FormFromSchemaBuilder({
    Key? key,
    required this.mainSchema,
    required this.schema,
    this.schemaObject,
  }) : super(key: key);
  final Schema mainSchema;
  final Schema schema;
  final SchemaObject? schemaObject;

  @override
  Widget build(BuildContext context) {
    if (schema is SchemaProperty) {
      return PropertySchemaBuilder(
        mainSchema: mainSchema,
        schemaProperty: schema as SchemaProperty,
      );
    }
    if (schema is SchemaArray) {
      return ArraySchemaBuilder(
        mainSchema: mainSchema,
        schemaArray: schema as SchemaArray,
      );
    }

    if (schema is SchemaObject) {
      return ObjectSchemaBuilder(
        mainSchema: mainSchema,
        schemaObject: schema as SchemaObject,
      );
    }

    return const SizedBox.shrink();
  }
}

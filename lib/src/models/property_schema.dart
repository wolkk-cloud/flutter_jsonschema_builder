import 'package:flutter_jsonschema_form/src/models/one_of_model.dart';

import '../models/models.dart';

enum PropertyFormat { general, password, date, datetime, email, dataurl, uri }

PropertyFormat propertyFormatFromString(String? value) {
  switch (value) {
    case 'password':
      return PropertyFormat.password;
    case 'date':
      return PropertyFormat.date;
    case 'datetime':
      return PropertyFormat.datetime;
    case 'email':
      return PropertyFormat.email;
    case 'data-url':
      return PropertyFormat.dataurl;
    case 'uri':
      return PropertyFormat.uri;
    default:
      return PropertyFormat.general;
  }
}

class SchemaProperty extends Schema {
  SchemaProperty(
      {required String id,
      required SchemaType type,
      String? title,
      String? description,
      this.defaultValue,
      this.enumm,
      this.enumNames,
      this.required = false,
      this.format = PropertyFormat.general,
      this.minLength,
      this.maxLength,
      this.pattern,
      this.oneOf})
      : super(
          id: id,
          title: title ?? 'no-title',
          type: type,
          description: description,
        );

  factory SchemaProperty.fromJson(
    String id,
    Map<String, dynamic> json, {
    Schema? parent,
  }) {
    final property = SchemaProperty(
        id: id,
        title: json['title'],
        type: schemaTypeFromString(json['type']),
        format: propertyFormatFromString(json['format']),
        defaultValue: json['default'],
        description: json['description'],
        // enums
        enumm: json['enum'],
        enumNames: json['enumNames'],
        minLength: json['minLength'],
        maxLength: json['maxLength'],
        pattern: json['pattern'],
        oneOf: json['oneOf'],
        );
    property.parentIdKey = parent?.idKey;

    return property;
  }

  @override
  SchemaProperty copyWith({
    required String id,
    String? parentIdKey,
  }) {
    var newSchema = SchemaProperty(
        id: id,
        title: title,
        type: type,
        description: description,
        format: format,
        defaultValue: defaultValue,
        enumNames: enumNames,
        enumm: enumm,
        required: required,
        oneOf: oneOf)
      ..autoFocus = autoFocus
      ..emptyValue = emptyValue
      ..help = help
      ..maxLength = maxLength
      ..minLength = minLength
      ..widget = widget
      ..parentIdKey = parentIdKey ?? this.parentIdKey
      ..required = required;

    return newSchema;
  }

  PropertyFormat format;

  /// it means enum
  List? enumm;

  /// displayed as text if is not empty
  List? enumNames;

  dynamic defaultValue;

  // propiedades que se llenan con el json
  bool required;
  bool? autoFocus;
  int? minLength, maxLength;
  String? pattern;
  dynamic dependents;

  /// indica si sus dependentes han sido activados por XDependencies
  bool  isDependentsActive = false;
  String? dependentsAddedBy;

  // not suported yet
  String? widget, emptyValue, help = '';
  List<dynamic>? oneOf;
}

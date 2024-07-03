import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/fields/fields.dart';
import 'package:flutter_jsonschema_builder/src/fields/shared.dart';
import '../models/models.dart';
import '../utils/input_validation_json_schema.dart';

class RadioButtonJFormField extends PropertyFieldWidget<dynamic> {
  const RadioButtonJFormField({
    Key? key,
    required SchemaProperty property,
    required final ValueSetter<dynamic> onSaved,
    ValueChanged<dynamic>? onChanged,
    final String? Function(dynamic)? customValidator,
  }) : super(
          key: key,
          property: property,
          onSaved: onSaved,
          onChanged: onChanged,
          customValidator: customValidator,
        );

  @override
  _RadioButtonJFormFieldState createState() => _RadioButtonJFormFieldState();
}

class _RadioButtonJFormFieldState extends State<RadioButtonJFormField> {
  bool booleanValue = false;

  dynamic groupValue;

  @override
  void initState() {
    print(widget.property.defaultValue);

    // fill enum property

    if (widget.property.enumm == null) {
      switch (widget.property.type) {
        case SchemaType.boolean:
          widget.property.enumm = [true, false];
          break;
        default:
          widget.property.enumm =
              widget.property.enumNames?.map((e) => e.toString()).toList() ??
                  [];
      }
    }

    // fill groupValue
    if (widget.property.type == SchemaType.boolean) {
      groupValue = widget.property.defaultValue;
    } else {
      groupValue = null;
    }

    widget.triggetDefaultValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.property.enumm != null, 'enum is required');
    assert(() {
      if (widget.property.enumNames != null) {
        return widget.property.enumNames!.length ==
            widget.property.enumm!.length;
      }
      return true;
    }(), '[enumNames] and [enum]  must be the same size ');

    inspect(widget.property);
    return FormField<dynamic>(
      key: Key(widget.property.idKey),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: groupValue,
      onSaved: (newValue) {
        widget.onSaved(newValue);
      },
      validator: (value) {
        if (widget.property.required && value == null) {
          return 'Required';
        }
        if (widget.customValidator != null)
          return widget.customValidator!(value);

        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${widget.property.title ?? widget.property.description} ${widget.property.required ? "*" : ""}',
                style: WidgetBuilderInherited.of(context).uiConfig.fieldTitle),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List<Widget>.generate(
                  widget.property.enumm?.length ?? 0,
                  (int i) => RadioListTile(
                        value: widget.property.enumm != null
                            ? widget.property.enumm![i]
                            : i,
                        title: Text(
                            widget.property.enumNames?[i] ??
                                widget.property.enumm?[i],
                            style: widget.property.readOnly
                                ? const TextStyle(color: Colors.grey)
                                : WidgetBuilderInherited.of(context)
                                    .uiConfig
                                    .label),
                        groupValue: groupValue,
                        onChanged: widget.property.readOnly
                            ? null
                            : (dynamic value) {
                                print(value);
                                groupValue = value;
                                if (value != null) {
                                  field.didChange(groupValue);
                                  if (widget.onChanged != null) {
                                    widget.onChanged!(groupValue!);
                                  }
                                }
                              },
                      )),
            ),
            if (field.hasError) CustomErrorText(text: field.errorText!),
          ],
        );
      },
    );
  }
}

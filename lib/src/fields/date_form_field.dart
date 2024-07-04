import 'package:flutter/material.dart';
import 'package:flutter_jsonschema_builder/src/builder/logic/widget_builder_logic.dart';
import 'package:flutter_jsonschema_builder/src/fields/fields.dart';
import 'package:intl/intl.dart';
import 'package:extended_masked_text/extended_masked_text.dart';

import '../models/models.dart';
import '..//utils/date_text_input_json_formatter.dart';

class DateJFormField extends PropertyFieldWidget<DateTime> {
  const DateJFormField({
    Key? key,
    required SchemaProperty property,
    required final ValueSetter<DateTime?> onSaved,
    ValueChanged<DateTime?>? onChanged,
    final String? Function(dynamic)? customValidator,
  }) : super(
          key: key,
          property: property,
          onSaved: onSaved,
          onChanged: onChanged,
          customValidator: customValidator,
        );

  @override
  _DateJFormFieldState createState() => _DateJFormFieldState();
}

class _DateJFormFieldState extends State<DateJFormField> {
  final txtDateCtrl = MaskedTextController(mask: '0000-00-00');
  final formatter = DateFormat(dateFormatString);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.property.defaultValue != null &&
          DateTime.tryParse(widget.property.defaultValue) != null)
        txtDateCtrl.updateText(widget.property.defaultValue);
    });

    widget.triggetDefaultValue();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.property.title ?? widget.property.description} ${widget.property.required ? "*" : ""}',
          style: WidgetBuilderInherited.of(context).uiConfig.fieldTitle,
        ),
        const SizedBox(height: 20),
        TextFormField(
          key: Key(widget.property.idKey),
          controller: txtDateCtrl,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (widget.property.required && (value == null || value.isEmpty)) {
              return WidgetBuilderInherited.of(context)
                  .localizationLabelConfig
                  .requiredLabel;
            }
            if (widget.customValidator != null)
              return widget.customValidator!(value);
            return null;
          },
          // inputFormatters: [DateTextInputJsonFormatter()],
          readOnly: widget.property.readOnly,
          style: widget.property.readOnly
              ? const TextStyle(color: Colors.grey)
              : WidgetBuilderInherited.of(context).uiConfig.label,

          onSaved: (value) {
            if (value != null) widget.onSaved(formatter.parse(value));
          },
          onChanged: (value) {
            try {
              if (widget.onChanged != null && DateTime.tryParse(value) != null)
                widget.onChanged!(formatter.parse(value));
            } catch (e) {
              return;
            }
          },
          decoration: WidgetBuilderInherited.of(context)
                  .uiConfig
                  .textfieldDecoration
                  ?.copyWith(
                    suffixIcon: _suffixIcon,
                    helperText: _helperText,
                    hintText: _hintText,
                  ) ??
              InputDecoration(
                hintText: _hintText,
                helperText: _helperText,
                suffixIcon: _suffixIcon,
                errorStyle: WidgetBuilderInherited.of(context).uiConfig.error,
              ),
        ),
      ],
    );
  }

  String? get _hintText => widget.property.title ?? widget.property.description;

  String? get _helperText =>
      widget.property.help != null && widget.property.help!.isNotEmpty
          ? widget.property.help
          : null;

  Widget get _suffixIcon => IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: _openCalendar,
      );

  void _openCalendar() async {
    late DateTime tempDate;
    try {
      tempDate = formatter.parse(txtDateCtrl.text);
    } catch (e) {
      tempDate = DateTime.now();
    }

    final date = await showDatePicker(
      context: context,
      initialDate: tempDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2099),
    );

    if (date != null) txtDateCtrl.text = formatter.format(date);

    widget.onSaved(date);
  }
}

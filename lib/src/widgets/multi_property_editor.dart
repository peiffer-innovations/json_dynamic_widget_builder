import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:json_dynamic_widget/json_dynamic_widget_schemas.dart';
import 'package:json_dynamic_widget_builder/src/bloc/schema_bloc.dart';
import 'package:json_dynamic_widget_builder/src/widgets/supported_widgets_list.dart';
import 'package:json_schema2/json_schema2.dart';
import 'package:provider/provider.dart';

class MultiPropertyEditor extends StatefulWidget {
  MultiPropertyEditor({
    required this.id,
    Key? key,
    required this.schema,
    required this.values,
  })  : assert(id.isNotEmpty == true),
        super(key: key);

  final String id;
  final JsonSchema schema;
  final dynamic values;

  @override
  _MultiPropertyEditorState createState() => _MultiPropertyEditorState();
}

class _MultiPropertyEditorState extends State<MultiPropertyEditor> {
  final FocusNode _focusNode = FocusNode();
  List<Widget>? _properties;
  late SchemaBloc _schemaBloc;
  dynamic _values;

  @override
  void initState() {
    super.initState();

    _schemaBloc = context.read<SchemaBloc>();
    _schemaBloc.current = widget.schema;

    _values = widget.values;

    final schema = widget.schema;

    var props = _getAllProperties(schema);

    final properties = <Widget>[];
    props = SplayTreeMap.from(props);
    props.forEach((key, value) {
      if (value.ref != null) {
        value = _schemaBloc.getSchema(value.ref.toString());
      }
      properties.add(_getFormWidget(
        key,
        value,
        parent: schema,
      ));
    });

    if (properties.isNotEmpty != true) {
      properties.add(_getFormWidget(
        widget.id,
        schema,
        parent: schema,
      ));
    }

    _properties = properties;
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  Map<String, JsonSchema> _getAllProperties(JsonSchema schema) {
    var props = schema.properties.isNotEmpty == true ? schema.properties : null;

    props ??= _getPropertiesFromList(schema.anyOf);
    props ??= _getPropertiesFromList(schema.oneOf);

    return props!;
  }

  Widget _getFormWidget(
    String key,
    JsonSchema schema, {
    JsonSchema? parent,
  }) {
    Widget result;
    final enumValues = <String>{};
    var isBool = false;
    var isNumber = false;
    JsonSchema? dynWidgetRef;
    JsonSchema? objRef;

    // var props = _getAllProperties(schema);

    final checkSchema = (JsonSchema schema) {
      if (schema.ref != null) {
        schema = _schemaBloc.getSchema(schema.ref.toString());
      }

      if (schema.id.toString() == JsonWidgetDataSchema.id) {
        dynWidgetRef = schema;
      }

      if (schema.enumValues?.isNotEmpty == true) {
        enumValues.addAll(List<String>.from(schema.enumValues!));
      }
      try {
        final type = schema.type?.toString();
        switch (type) {
          case 'boolean':
            isBool = true;
            break;
          case 'number':
            isNumber = true;
            break;
          case 'object':
            objRef = schema;
            break;
        }
      } catch (e) {
        // no-op
      }
    };

    // if (props?.isNotEmpty == true) {
    //   result = ListTile(
    //     onTap: () => Navigator.of(context).push(
    //       MaterialPageRoute(
    //         builder: (BuildContext context) => MultiPropertyEditor(
    //           id: key,
    //           onChanged: (value) {
    //             _values[key] = value;
    //             widget.onChanged(_values);
    //             setState(() {});
    //           },
    //           schema: schema,
    //           values: _values[key],
    //         ),
    //       ),
    //     ),
    //     title: Text(key),
    //     trailing: Icon(Icons.chevron_right),
    //   );
    // } else {
    checkSchema(schema);
    schema.anyOf.forEach((s) => checkSchema(s));
    schema.allOf.forEach((s) => checkSchema(s));
    schema.oneOf.forEach((s) => checkSchema(s));

    if (dynWidgetRef != null) {
      result = ListTile(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => SupportedWidgetsList(
                values: _values[key] ?? <String, dynamic>{},
              ),
            ),
          );

          _schemaBloc.current = widget.schema;
          if (mounted == true) {
            setState(() {});
          }
        },
        subtitle: _values[key] == null
            ? null
            : Text(
                _values[key].toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        title: Text(
          key,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      );
    } else if (objRef != null) {
      result = ListTile(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => MultiPropertyEditor(
                id: key,
                schema: objRef!,
                values: _values[key] ?? <String, dynamic>{},
              ),
            ),
          );

          _schemaBloc.current = widget.schema;
          if (mounted == true) {
            setState(() {});
          }
        },
        subtitle: _values[key] == null
            ? null
            : Text(
                _values[key].toString(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        title: Text(
          key,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      );
    } else if (isBool == true) {
      result = DropdownButtonFormField(
        decoration: InputDecoration(labelText: key),
        items: [
          const DropdownMenuItem(value: 'null', child: Text('')),
          const DropdownMenuItem(value: true, child: Text('true')),
          const DropdownMenuItem(value: false, child: Text('false')),
        ],
        onChanged: (dynamic value) {
          _values[key] = value == 'null' ? null : value;
        },
        onSaved: (dynamic value) {
          _values[key] = value == 'null' ? null : value;
        },
        value:
            _values[key] == null ? 'null' : JsonClass.parseBool(_values[key]),
      );
    } else if (enumValues.isNotEmpty == true) {
      result = DropdownButtonFormField(
        autovalidateMode: AutovalidateMode.always,
        decoration: InputDecoration(labelText: key),
        items: [
          const DropdownMenuItem(value: 'null', child: Text('')),
          ...[
            for (var e in enumValues)
              DropdownMenuItem(value: e, child: Text(e)),
          ],
        ],
        onChanged: (dynamic value) {
          _values[key] = value == 'null' ? null : value;
        },
        onSaved: (dynamic value) {
          _values[key] = value == 'null' ? null : value;
        },
        value: _values[key] ?? 'null',
        validator: (dynamic value) {
          String? error;

          if ('null' == value) {
            value = null;
          }

          if (parent?.requiredProperties?.contains(key) == true &&
              value is String &&
              value.isNotEmpty != true) {
            error = '$key is a required field';
          }

          return error;
        },
      );
    } else {
      result = TextFormField(
        autovalidateMode: AutovalidateMode.always,
        decoration: InputDecoration(labelText: key),
        initialValue: (isNumber == true
                ? JsonClass.parseDouble(_values[key])
                : _values[key])
            ?.toString(),
        onChanged: (value) {
          _values[key] = value.isNotEmpty == true ? value : null;
        },
        onSaved: (value) {
          _values[key] = value?.isNotEmpty == true ? value : null;
        },
        validator: (String? value) {
          String? error;

          if (value?.isNotEmpty == true && isNumber == true) {
            error = double.tryParse(value!) == null
                ? 'Value is not a valid number'
                : null;
          }

          if (parent?.requiredProperties?.contains(key) == true &&
              value?.isNotEmpty != true) {
            error = '$key is a required field';
          }

          return error;
        },
      );
    }

    return result;
  }

  Map<String, JsonSchema>? _getPropertiesFromList(List<JsonSchema> schemas) {
    Map<String, JsonSchema>? props;

    if (schemas.isNotEmpty == true) {
      props = <String, JsonSchema>{};

      for (var schema in schemas) {
        if (schema.properties.isNotEmpty == true) {
          props.addAll(schema.properties);
        }
      }
    }

    return props;
  }

  // Text _getValue(String key) {
  //   var data = _widgetTreeBloc.current;
  //   Text result;

  //   if (data != null && data.args != null) {
  //     var value = data.args[key];

  //     if (value != null) {
  //       result = Text(
  //         value.toString(),
  //         style: TextStyle(
  //           fontFamily: 'Courier New',
  //           fontFamilyFallback: ['monospace', 'Courier'],
  //         ),
  //       );
  //     }
  //   }

  //   return result;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.id)),
      body: _properties?.isNotEmpty != true
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('UNKNOWN SCHEMA'),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _properties![index],
                    ),
                    itemCount: _properties!.length,
                    padding: const EdgeInsets.all(16.0),
                  ),
                ),
              ],
            ),
    );
  }
}

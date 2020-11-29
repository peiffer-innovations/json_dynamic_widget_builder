import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:json_dynamic_widget_builder/src/bloc/schema_bloc.dart';
import 'package:json_schema/json_schema.dart';
import 'package:provider/provider.dart';

class MultiPropertyEditor extends StatefulWidget {
  MultiPropertyEditor({
    @required this.id,
    Key key,
    @required this.schema,
    @required this.values,
  })  : assert(id?.isNotEmpty == true),
        assert(schema != null),
        super(key: key);

  final String id;
  final JsonSchema schema;
  final dynamic values;

  @override
  _MultiPropertyEditorState createState() => _MultiPropertyEditorState();
}

class _MultiPropertyEditorState extends State<MultiPropertyEditor> {
  final FocusNode _focusNode = FocusNode();
  List<Widget> _properties;
  SchemaBloc _schemaBloc;
  dynamic _values;

  @override
  void initState() {
    super.initState();

    _schemaBloc = context.read<SchemaBloc>();
    _schemaBloc.current = widget.schema;

    _values = widget.values;

    var schema = widget.schema;

    var props = _getAllProperties(schema);

    var properties = <Widget>[];
    props = SplayTreeMap.from(props);
    props.forEach((key, value) {
      if (value.ref != null) {
        value = _schemaBloc.getSchema(value.ref.toString());
      }
      properties.add(_getFormWidget(key, value));
    });

    if (properties?.isNotEmpty != true) {
      properties.add(_getFormWidget(widget.id, schema));
    }

    _properties = properties;
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  Map<String, JsonSchema> _getAllProperties(JsonSchema schema) {
    var props =
        schema.properties?.isNotEmpty == true ? schema.properties : null;

    props ??= _getPropertiesFromList(schema.anyOf);
    props ??= _getPropertiesFromList(schema.oneOf);

    return props;
  }

  Widget _getFormWidget(String key, JsonSchema schema) {
    Widget result;
    var enumValues = <String>{};
    var isBool = false;
    var isNumber = false;
    JsonSchema objRef;

    // var props = _getAllProperties(schema);

    var checkSchema = (JsonSchema schema) {
      if (schema.ref != null) {
        schema = _schemaBloc.getSchema(schema.ref.toString());
      }
      if (schema.enumValues?.isNotEmpty == true) {
        enumValues.addAll(List<String>.from(schema.enumValues));
      }
      try {
        var type = schema.type?.toString();
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
    schema.anyOf?.forEach((s) => checkSchema(s));
    schema.allOf?.forEach((s) => checkSchema(s));
    schema.oneOf?.forEach((s) => checkSchema(s));

    if (objRef != null) {
      result = ListTile(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => MultiPropertyEditor(
                id: key,
                schema: objRef,
                values: _values[key] ?? <String, dynamic>{},
              ),
            ),
          );

          _schemaBloc.current = widget.schema;
          if (mounted == true) {
            setState(() {});
          }
        },
        title: Text(key),
        trailing: Icon(Icons.chevron_right),
      );
    } else if (isBool == true) {
      result = DropdownButtonFormField(
        decoration: InputDecoration(labelText: key),
        items: [
          DropdownMenuItem(value: 'null', child: Text('')),
          DropdownMenuItem(value: true, child: Text('true')),
          DropdownMenuItem(value: false, child: Text('false')),
        ],
        onChanged: (value) {
          _values[key] = value == 'null' ? null : value;
        },
        onSaved: (value) {
          _values[key] = value == 'null' ? null : value;
        },
        value:
            _values[key] == null ? 'null' : JsonClass.parseBool(_values[key]),
      );
    } else if (enumValues?.isNotEmpty == true) {
      result = DropdownButtonFormField(
        decoration: InputDecoration(labelText: key),
        items: [
          DropdownMenuItem(value: 'null', child: Text('')),
          ...[
            for (var e in enumValues)
              DropdownMenuItem(value: e, child: Text(e)),
          ],
        ],
        onChanged: (value) {
          _values[key] = value == 'null' ? null : value;
        },
        onSaved: (value) {
          _values[key] = value == 'null' ? null : value;
        },
        value: _values[key] ?? 'null',
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
          _values[key] = value;
        },
        onSaved: (value) {
          _values[key] = value == 'null' ? null : value;
        },
        validator: (String value) {
          String error;

          if (value?.isNotEmpty == true && isNumber == true) {
            error = double.tryParse(value) == null
                ? 'Value is not a valid number'
                : null;
          }

          return error;
        },
      );
    }

    return result;
  }

  Map<String, JsonSchema> _getPropertiesFromList(List<JsonSchema> schemas) {
    Map<String, JsonSchema> props;

    if (schemas?.isNotEmpty == true) {
      props = <String, JsonSchema>{};

      for (var schema in schemas) {
        if (schema.properties?.isNotEmpty == true) {
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
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('UNKNOWN SCHEMA'),
              ),
            )
          : Form(
              autovalidateMode: AutovalidateMode.always,
              child: Builder(
                builder: (BuildContext context) => Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) =>
                            Padding(
                          padding: EdgeInsets.only(bottom: 16.0),
                          child: _properties[index],
                        ),
                        itemCount: _properties.length,
                        padding: EdgeInsets.all(16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_dynamic_widget/json_dynamic_widget_schemas.dart';
import 'package:json_dynamic_widget_builder/src/bloc/widget_tree_bloc.dart';
import 'package:json_schema/json_schema.dart';
import 'package:json_theme/json_theme_schemas.dart';
import 'package:provider/provider.dart';

class WidgetPropertiesEditor extends StatefulWidget {
  WidgetPropertiesEditor({
    Key key,
    @required this.data,
  })  : assert(data != null),
        super(key: key);

  final JsonWidgetData data;

  @override
  _WidgetPropertiesEditorState createState() => _WidgetPropertiesEditorState();
}

class _WidgetPropertiesEditorState extends State<WidgetPropertiesEditor> {
  List<Widget> _properties;
  WidgetTreeBloc _widgetTreeBloc;

  @override
  void initState() {
    super.initState();

    _widgetTreeBloc = context.read<WidgetTreeBloc>();

    var schemaData = JsonDynamicWidgetSchemas.lookup(widget.data.type);
    if (schemaData != null) {
      var schema = _widgetTreeBloc.getSchema(schemaData[r'$id']);

      var props =
          schema.properties?.isNotEmpty == true ? schema.properties : null;
      if (props?.isNotEmpty == true) {
        props[r'$self'] = JsonSchema.createSchema({'type': 'string'});
      }
      props ??= _getPropertiesFromList(schema.anyOf);
      props ??= _getPropertiesFromList(schema.oneOf);

      var properties = <Widget>[];
      props = SplayTreeMap.from(props);
      props.forEach((key, value) {
        properties.add(
          ListTile(
            title: Text(key),
          ),
        );
      });

      _properties = properties;
    }
  }

  Map<String, JsonSchema> _getPropertiesFromList(List<JsonSchema> schemas) {
    Map<String, JsonSchema> props;

    if (schemas?.isNotEmpty == true) {
      props = <String, JsonSchema>{};

      for (var schema in schemas) {
        if (schema.properties?.isNotEmpty == true) {
          props.addAll(schema.properties);
        } else {
          props[r'$self'] = JsonSchema.createSchema({'type': 'string'});
        }
      }
    }

    return props;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Properties')),
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
                      child: ListView.separated(
                        itemBuilder: (BuildContext context, int index) =>
                            _properties[index],
                        itemCount: _properties.length,
                        separatorBuilder: (_, __) => Divider(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_dynamic_widget/json_dynamic_widget_schemas.dart';
import 'package:json_dynamic_widget_builder/src/bloc/schema_bloc.dart';
import 'package:json_dynamic_widget_builder/src/bloc/widget_tree_bloc.dart';
import 'package:json_dynamic_widget_builder/src/widgets/multi_property_editor.dart';
import 'package:json_schema/json_schema.dart';
import 'package:logging/logging.dart';
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
  static final Logger _logger = Logger('_WidgetPropertiesEditorState');

  JsonWidgetData _data;
  JsonSchema _schema;
  SchemaBloc _schemaBloc;
  dynamic _values;
  WidgetTreeBloc _widgetTreeBloc;

  @override
  void initState() {
    super.initState();

    _widgetTreeBloc = context.read<WidgetTreeBloc>();

    _data = widget.data;
    _schemaBloc = context.read<SchemaBloc>();
    _values = json.decode(json.encode(widget.data.args));

    var schemaData = JsonDynamicWidgetSchemas.lookup(widget.data.type);
    if (schemaData != null) {
      _schema = _schemaBloc.getSchema(schemaData[r'$id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    var id = _schema.id.toString().split('/').last;
    if (id?.endsWith('.json') == true) {
      id = id.substring(0, id.length - '.json'.length);
    }

    return _schema == null
        ? Scaffold(
            appBar: AppBar(title: Text('Properties')),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('UNKNOWN SCHEMA'),
              ),
            ),
          )
        : Form(
            child: Builder(
              builder: (BuildContext context) => Column(
                children: [
                  Expanded(
                    child: WillPopScope(
                      onWillPop: () async {
                        try {
                          var data = widget.data.copyWith(args: _values);

                          var reprocessed =
                              JsonWidgetData.fromDynamic(data.toJson());
                          reprocessed.builder().build(
                                childBuilder: null,
                                context: context,
                                data: reprocessed,
                              );

                          Navigator.of(context).pop(data);
                        } catch (e) {
                          _logger.info('Error processing widget from data', e);
                        }

                        return false;
                      },
                      child: MultiPropertyEditor(
                        id: id,
                        onChanged: (values) {
                          _values = values;
                        },
                        schema: _schema,
                        values: _values,
                      ),
                    ),
                  ),
                  Divider(height: 1.0),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: RaisedButton(
                      onPressed: () {
                        try {
                          FocusScope.of(context).requestFocus(FocusNode());
                          Form.of(context).save();
                          var data = _widgetTreeBloc.replace(
                            widget.data,
                            widget.data.copyWith(
                              args: _values,
                            ),
                          );

                          data.builder().build(
                                childBuilder: null,
                                context: null,
                                data: data,
                              );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Widget Updated'),
                            ),
                          );

                          _widgetTreeBloc.widget = data;

                          var nav = Navigator.of(context);
                          while (nav.canPop()) {
                            nav.pop();
                          }
                        } catch (e, stack) {
                          _logger.info(
                            'Error attempting to create widget with current values.',
                            e,
                            stack,
                          );
                        }
                      },
                      child: Text('APPLY'),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

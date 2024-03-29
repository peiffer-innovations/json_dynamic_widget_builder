import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_dynamic_widget/json_dynamic_widget_schemas.dart';
import 'package:json_dynamic_widget_builder/src/bloc/schema_bloc.dart';
import 'package:json_dynamic_widget_builder/src/bloc/widget_tree_bloc.dart';
import 'package:json_dynamic_widget_builder/src/widgets/multi_property_editor.dart';
import 'package:json_schema2/json_schema2.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class WidgetPropertiesEditor extends StatefulWidget {
  WidgetPropertiesEditor({
    Key? key,
    required this.data,
    this.onApply,
  }) : super(key: key);

  final JsonWidgetData data;
  final Function(JsonWidgetData data)? onApply;

  @override
  _WidgetPropertiesEditorState createState() => _WidgetPropertiesEditorState();
}

class _WidgetPropertiesEditorState extends State<WidgetPropertiesEditor> {
  static final Logger _logger = Logger('_WidgetPropertiesEditorState');

  JsonWidgetData? _data;
  JsonSchema? _schema;
  late SchemaBloc _schemaBloc;
  dynamic _values;
  late WidgetTreeBloc _widgetTreeBloc;

  @override
  void initState() {
    super.initState();

    _widgetTreeBloc = context.read<WidgetTreeBloc>();

    _data = widget.data;
    _schemaBloc = context.read<SchemaBloc>();
    _values = json.decode(json.encode(widget.data.args));

    final schemaData = JsonDynamicWidgetSchemas.lookup(widget.data.type);
    if (schemaData != null) {
      _schema = _schemaBloc.getSchema(schemaData[r'$id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    var id = _schema!.id.toString().split('/').last;
    if (id.endsWith('.json') == true) {
      id = id.substring(0, id.length - '.json'.length);
    }

    return _schema == null
        ? Scaffold(
            appBar: AppBar(title: const Text('Properties')),
            body: const Center(
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
                    child: MultiPropertyEditor(
                      id: id,
                      schema: _schema!,
                      values: _values,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(),
                        Flexible(
                          child: ClipRect(
                            child: TextButton(
                              onPressed: () {
                                final nav = Navigator.of(context);
                                while (nav.canPop()) {
                                  nav.pop();
                                }
                              },
                              child: const Text(
                                'CANCEL',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Flexible(
                          child: ClipRect(
                            child: ElevatedButton(
                              onPressed: widget.onApply != null
                                  ? () {
                                      final form = Form.of(context);
                                      if (form.validate() == true) {
                                        form.save();
                                        FocusScope.of(context).requestFocus(
                                          FocusNode(),
                                        );

                                        widget.onApply!(
                                          _data!.copyWith(
                                            args: _values,
                                          ),
                                        );

                                        Navigator.of(context).pop();
                                      }
                                    }
                                  : () {
                                      try {
                                        final form = Form.of(context);
                                        if (form.validate() == true) {
                                          form.save();
                                          FocusScope.of(context).requestFocus(
                                            FocusNode(),
                                          );
                                          final newData = _data!.copyWith(
                                            args: _values,
                                          );

                                          final data = _widgetTreeBloc.replace(
                                            _data,
                                            newData,
                                          )!;

                                          data.builder().build(
                                                childBuilder: null,
                                                context: context,
                                                data: data,
                                              );

                                          _widgetTreeBloc.widget = data;

                                          // var nav = Navigator.of(context);
                                          // while (nav.canPop()) {
                                          //   nav.pop();
                                          // }

                                          _data = newData;
                                          if (mounted == true) {
                                            setState(() {});
                                          }
                                        }
                                      } catch (e) {
                                        _logger.info(
                                          'Error attempting to create widget with current values.',
                                          e,
                                        );
                                      }
                                    },
                              child: const Text(
                                'APPLY',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

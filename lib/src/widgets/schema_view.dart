import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_dynamic_widget/json_dynamic_widget_schemas.dart';
import 'package:json_dynamic_widget_builder/src/bloc/widget_tree_bloc.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class SchemaView extends StatefulWidget {
  SchemaView({
    Key key,
  }) : super(key: key);

  _SchemaViewState createState() => _SchemaViewState();
}

class _SchemaViewState extends State<SchemaView> {
  static final Logger _logger = Logger('_SchemaViewState');
  final List<StreamSubscription> _subscriptions = [];

  JsonWidgetData _current;

  @override
  void initState() {
    super.initState();

    var widgetTreeBloc = context.read<WidgetTreeBloc>();

    _subscriptions.add(widgetTreeBloc.stream.listen((event) {
      _current = widgetTreeBloc.current;
      if (mounted == true) {
        setState(() {});
      }
    }));
    _current = widgetTreeBloc.current;
    ;
  }

  @override
  void dispose() {
    _subscriptions.forEach((sub) => sub.cancel());
    _subscriptions.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var schema = JsonDynamicWidgetSchemas.lookup(_current?.type);
    List<String> lines;

    if (schema != null) {
      try {
        lines = JsonEncoder.withIndent('  ').convert(schema).split('\n');
      } catch (e) {
        _logger.info('Error locating schema for type: [${_current.type}].', e);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (lines != null) ...[
          Container(
            padding: EdgeInsets.fromLTRB(4.0, 16.0, 4.0, 16.0),
            child: Text('Schema: ${_current.type}'),
          ),
          Divider(height: 1.0),
        ],
        Expanded(
          child: lines == null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('SELECT WIDGET'),
                  ),
                )
              : ListView.builder(
                  itemCount: lines.length,
                  itemBuilder: (BuildContext context, int index) => Text(
                    lines[index],
                    style: TextStyle(
                      fontFamily: 'Courier New',
                      fontFamilyFallback: ['monospace', 'Courier'],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart';
import 'package:json_dynamic_widget_builder/src/bloc/schema_bloc.dart';
import 'package:json_schema/json_schema.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class SchemaView extends StatefulWidget {
  SchemaView({
    Key key,
  }) : super(key: key);

  @override
  _SchemaViewState createState() => _SchemaViewState();
}

class _SchemaViewState extends State<SchemaView> {
  static final Logger _logger = Logger('_SchemaViewState');
  final List<StreamSubscription> _subscriptions = [];

  JsonSchema _current;
  String _markdown;

  @override
  void initState() {
    super.initState();

    var schemaBloc = context.read<SchemaBloc>();

    _subscriptions.add(schemaBloc.stream.listen((event) {
      if (_current?.id?.toString() != schemaBloc.current?.id?.toString()) {
        _current = schemaBloc.current;
        _loadData();
      }
    }));
    _current = schemaBloc.current;

    _loadData();
  }

  @override
  void dispose() {
    _subscriptions.forEach((sub) => sub.cancel());
    _subscriptions.clear();

    super.dispose();
  }

  Future<void> _loadData() async {
    _markdown = null;
    if (mounted == true) {
      setState(() {});
    }
    if (_current != null) {
      try {
        var paths = _current.id.pathSegments;
        var lastTwo = '${paths[paths.length - 2]}/${paths[paths.length - 1]}';
        lastTwo = lastTwo.substring(0, lastTwo.length - '.json'.length);
        var mdUrl =
            'https://peiffer-innovations.github.io/flutter_json_schemas/docs/${lastTwo}.md';

        var data = await get(mdUrl);
        if (data != null) {
          _markdown = utf8.decode(data.bodyBytes);
        }
      } catch (e) {
        _markdown = 'ERROR: loading help for schema -- ${_current.id}';
        _logger.info('ERROR loading help file: ${_current.id}', e);
      }
    }

    if (mounted == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (_current != null) ...[
          Container(
            padding: EdgeInsets.fromLTRB(4.0, 16.0, 4.0, 16.0),
            child: Text('Help'),
          ),
          Divider(height: 1.0),
        ],
        Expanded(
          child: _current == null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('NOTHING SELECTED'),
                  ),
                )
              : _markdown == null
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Markdown(
                      data: _markdown,
                    ),
        ),
      ],
    );
  }
}

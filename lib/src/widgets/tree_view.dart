import 'dart:async';

import 'package:flutter/material.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_dynamic_widget/json_dynamic_widget_schemas.dart';
import 'package:json_dynamic_widget_builder/src/bloc/widget_tree_bloc.dart';
import 'package:json_dynamic_widget_builder/src/widgets/supported_widgets_list.dart';
import 'package:json_dynamic_widget_builder/src/widgets/widget_properties_editor.dart';
import 'package:json_theme/json_theme_schemas.dart';
import 'package:provider/provider.dart';

class TreeView extends StatefulWidget {
  TreeView({
    Key key,
  }) : super(key: key);

  @override
  _TreeViewState createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  final List<StreamSubscription> _subscriptions = [];

  WidgetTreeBloc _widgetTreeBloc;

  @override
  void initState() {
    super.initState();

    _widgetTreeBloc = context.read<WidgetTreeBloc>();

    _subscriptions.add(_widgetTreeBloc.stream.listen((event) {
      if (mounted == true) {
        setState(() {});
      }
    }));
  }

  @override
  void dispose() {
    _subscriptions?.forEach((sub) => sub.cancel());
    _subscriptions.clear();

    super.dispose();
  }

  List<Widget> _buildTree(JsonWidgetData data, {int depth = 0}) {
    var widgets = <Widget>[];

    var text = ''.padLeft(depth * 2);
    text += data.type;

    widgets.add(
      ListTile(
        onTap: () {
          _widgetTreeBloc.current = data;
          if (mounted == true) {
            setState(() {});
          }
        },
        selected: _widgetTreeBloc.current == data,
        title: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Courier New',
            fontFamilyFallback: ['monospace', 'Courier'],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _widgetTreeBloc.current = data;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => WidgetPropertiesEditor(
                      data: data,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => SupportedWidgetsList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

    data.children?.forEach(
      (element) => widgets.addAll(
        _buildTree(element, depth: depth + 1),
      ),
    );

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Widget Tree'),
      ),
      body: _widgetTreeBloc.widget == null
          ? Center(
              child: Text('ADD WIDGET'),
            )
          : ListView(
              children: _buildTree(_widgetTreeBloc.widget),
            ),
    );
  }
}

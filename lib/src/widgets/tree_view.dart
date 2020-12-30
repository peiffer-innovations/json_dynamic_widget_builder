import 'dart:async';

import 'package:flutter/material.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_dynamic_widget_builder/src/bloc/widget_tree_bloc.dart';
import 'package:json_dynamic_widget_builder/src/widgets/supported_widgets_list.dart';
import 'package:json_dynamic_widget_builder/src/widgets/widget_properties_editor.dart';
import 'package:provider/provider.dart';

class TreeView extends StatefulWidget {
  TreeView({
    Key key,
  }) : super(key: key);

  @override
  _TreeViewState createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView>
    with SingleTickerProviderStateMixin {
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

    var text = ''.padLeft(depth);
    text += data.type;

    widgets.add(
      ListTile(
        onLongPress: () {
          _widgetTreeBloc.current = data;
          if (mounted == true) {
            setState(() {});
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => WidgetPropertiesEditor(
                data: data,
              ),
            ),
          );
        },
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
        // trailing: Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     IconButton(
        //       icon: Icon(Icons.edit),
        //       onPressed: () {
        //         _widgetTreeBloc.current = data;
        //         Navigator.of(context).push(
        //           MaterialPageRoute(
        //             builder: (BuildContext context) => WidgetPropertiesEditor(
        //               data: data,
        //             ),
        //           ),
        //         );
        //       },
        //     ),
        //     IconButton(
        //       icon: Icon(Icons.add),
        //       onPressed: () {
        //         Navigator.of(context).push(
        //           MaterialPageRoute(
        //             builder: (BuildContext context) => SupportedWidgetsList(),
        //           ),
        //         );
        //       },
        //     ),
        //   ],
        // ),
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
    var numSupportedChildren =
        _widgetTreeBloc.current?.builder()?.numSupportedChildren ?? 0;
    var actualChildren = _widgetTreeBloc.current?.children?.length ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Widget Tree'),
      ),
      body: _widgetTreeBloc.widget == null
          ? Center(
              child: RaisedButton(
                onPressed: () async {
                  var data = await Navigator.of(context).push(
                    MaterialPageRoute<JsonWidgetData>(
                      builder: (BuildContext context) => SupportedWidgetsList(),
                    ),
                  );

                  if (data != null) {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            WidgetPropertiesEditor(
                          data: data,
                          onApply: (JsonWidgetData data) {
                            _widgetTreeBloc.widget = data;

                            if (mounted == true) {
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    );
                  }
                },
                child: Text('ADD WIDGET'),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: _buildTree(_widgetTreeBloc.widget),
                  ),
                ),
                AnimatedSize(
                  duration: Duration(milliseconds: 300),
                  vsync: this,
                  child: _widgetTreeBloc.current == null
                      ? SizedBox()
                      : Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Divider(),
                              Flexible(
                                child: ClipRect(
                                  child: ElevatedButton.icon(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Colors.redAccent,
                                      ),
                                    ),
                                    icon: Flexible(
                                      child: ClipRect(
                                        child: Icon(Icons.delete),
                                      ),
                                    ),
                                    label: Flexible(
                                      child: Text(
                                        'REMOVE WIDGET',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    onPressed: () {
                                      var parent =
                                          _widgetTreeBloc.findParentOfWidget(
                                        _widgetTreeBloc.widget,
                                        _widgetTreeBloc.current.id,
                                        _widgetTreeBloc.current.type,
                                      );

                                      if (parent == null) {
                                        _widgetTreeBloc.widget = null;
                                      } else {
                                        parent.children.remove(
                                          _widgetTreeBloc.current,
                                        );
                                      }
                                      _widgetTreeBloc.current = null;

                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Flexible(
                                child: ClipRect(
                                  child: ElevatedButton.icon(
                                    icon: Flexible(
                                      child: ClipRect(
                                        child: Icon(Icons.add_circle),
                                      ),
                                    ),
                                    label: Flexible(
                                      child: Text(
                                        'ADD CHILD',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    onPressed: numSupportedChildren == -1 ||
                                            numSupportedChildren >
                                                actualChildren
                                        ? () async {
                                            var data =
                                                await Navigator.of(context)
                                                    .push(
                                              MaterialPageRoute<JsonWidgetData>(
                                                builder:
                                                    (BuildContext context) =>
                                                        SupportedWidgetsList(),
                                              ),
                                            );

                                            if (data != null) {
                                              await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      WidgetPropertiesEditor(
                                                    data: data,
                                                    onApply:
                                                        (JsonWidgetData data) {
                                                      var newData =
                                                          _widgetTreeBloc
                                                              .addWidget(
                                                        _widgetTreeBloc.current,
                                                        data,
                                                      );

                                                      _widgetTreeBloc.widget =
                                                          newData;

                                                      if (mounted == true) {
                                                        setState(() {});
                                                      }
                                                    },
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Flexible(
                                child: ClipRect(
                                  child: ElevatedButton.icon(
                                    icon: Flexible(
                                      child: ClipRect(
                                        child: Icon(Icons.edit),
                                      ),
                                    ),
                                    label: Flexible(
                                      child: Text(
                                        'EDIT',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              WidgetPropertiesEditor(
                                            data: _widgetTreeBloc.current,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:json_dynamic_widget_builder/src/bloc/widget_tree_bloc.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class UiTab extends StatefulWidget {
  UiTab({
    this.all = true,
    this.leftAlign = true,
    this.topAlign = true,
    Key key,
  }) : super(key: key);

  final bool all;
  final bool leftAlign;
  final bool topAlign;

  @override
  _UiTabState createState() => _UiTabState();
}

class _UiTabState extends State<UiTab> {
  static final Logger _logger = Logger('Ui');
  final List<StreamSubscription> _subscriptions = [];

  Widget _built;
  WidgetTreeBloc _widgetTreeBloc;

  @override
  void initState() {
    super.initState();

    _widgetTreeBloc = context.read<WidgetTreeBloc>();

    _subscriptions.add(_widgetTreeBloc.stream.listen((event) {
      _rebuild();
    }));
    _rebuild();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);

    _rebuild();
  }

  @override
  void dispose() {
    _subscriptions?.forEach((sub) => sub.cancel());
    _subscriptions.clear();

    super.dispose();
  }

  void _rebuild() {
    try {
      var widget = this.widget.all == true
          ? _widgetTreeBloc.widget
          : _widgetTreeBloc.current;
      if (widget == null) {
        _built = null;
      } else {
        _built = widget.build(context: context);
      }
    } catch (e, stack) {
      _logger.info('Error building widget', e, stack);
    }

    if (mounted == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
          child: Container(
            alignment: widget.leftAlign == true
                ? widget.topAlign == true
                    ? Alignment.topLeft
                    : Alignment.centerLeft
                : widget.topAlign == true
                    ? Alignment.topCenter
                    : Alignment.center,
            child: _built,
          ),
        ) ??
        Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('ADD WIDGET'),
          ),
        );
  }
}

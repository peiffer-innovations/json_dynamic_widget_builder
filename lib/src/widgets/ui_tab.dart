import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:json_dynamic_widget_builder/src/bloc/widget_tree_bloc.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class UiTab extends StatefulWidget {
  UiTab({
    this.all = true,
    this.highRatio = 9,
    this.leftAlign = true,
    this.topAlign = true,
    this.wideRatio = 16,
    Key key,
  }) : super(key: key);

  final bool all;
  final int highRatio;
  final bool leftAlign;

  final bool topAlign;
  final int wideRatio;

  @override
  _UiTabState createState() => _UiTabState();
}

class _UiTabState extends State<UiTab> {
  static final Logger _logger = Logger('Ui');
  final List<StreamSubscription> _subscriptions = [];

  Widget _built;
  UniqueKey _uniqueKey = UniqueKey();
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

  Widget _neverNullWidget(BuildContext context, Widget widget) =>
      widget ??
      Container(
        constraints: BoxConstraints(
          maxHeight: 40.0,
          minWidth: 40.0,
        ),
        color: Color(0xff444444),
        child: Placeholder(),
      );

  void _rebuild() {
    try {
      var widget = this.widget.all == true
          ? _widgetTreeBloc.widget ?? _widgetTreeBloc.current
          : _widgetTreeBloc.current;
      if (widget == null) {
        _built = null;
      } else {
        _built = widget.build(
          childBuilder: _neverNullWidget,
          context: context,
        );
      }
      _uniqueKey = UniqueKey();
    } catch (e, stack) {
      _logger.info('Error building widget', e, stack);
    }

    if (mounted == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: _uniqueKey,
      builder: (context, constraints) {
        final ratio = min(
          constraints.maxWidth / widget.wideRatio,
          constraints.maxHeight / widget.highRatio,
        );
        return Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
              ),
            ),
            alignment: widget.leftAlign == true
                ? widget.topAlign == true
                    ? Alignment.topLeft
                    : Alignment.centerLeft
                : widget.topAlign == true
                    ? Alignment.topCenter
                    : Alignment.center,
            height: ratio * widget.highRatio,
            width: ratio * widget.wideRatio,
            child: _built ??
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('NOTHING SELECTED'),
                  ),
                ),
          ),
        );
      },
    );
  }
}

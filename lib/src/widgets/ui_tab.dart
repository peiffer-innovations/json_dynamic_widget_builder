import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:json_dynamic_widget_builder/src/bloc/widget_tree_bloc.dart';
import 'package:json_dynamic_widget_builder/src/models/simulated_device.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class UiTab extends StatefulWidget {
  UiTab({
    this.all = true,
    this.device,
    this.landscape = false,
    this.leftAlign = true,
    this.strictSize = true,
    this.topAlign = true,
    Key? key,
  }) : super(key: key);

  final bool all;
  final SimulatedDevice? device;
  final bool landscape;
  final bool leftAlign;
  final bool strictSize;
  final bool topAlign;

  @override
  _UiTabState createState() => _UiTabState();
}

class _UiTabState extends State<UiTab> {
  static final Logger _logger = Logger('UiTab');
  final List<StreamSubscription> _subscriptions = [];

  Widget? _built;
  UniqueKey _uniqueKey = UniqueKey();
  late WidgetTreeBloc _widgetTreeBloc;

  @override
  void initState() {
    super.initState();

    _widgetTreeBloc = context.read<WidgetTreeBloc>();

    _subscriptions.add(_widgetTreeBloc.stream!.listen((event) {
      _rebuild();
    }));
    _rebuild();
  }

  @override
  void didUpdateWidget(UiTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    _rebuild();
  }

  @override
  void dispose() {
    _subscriptions.forEach((sub) => sub.cancel());
    _subscriptions.clear();

    super.dispose();
  }

  Widget _neverNullWidget(BuildContext context, Widget? widget) =>
      widget ??
      Container(
        constraints: const BoxConstraints(
          maxHeight: 40.0,
          minWidth: 40.0,
        ),
        color: const Color(0xff444444),
        child: const Placeholder(),
      );

  void _rebuild() {
    try {
      final widget = this.widget.all == true
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
    final ratio = widget.landscape == true
        ? widget.device?.dips.flipped.aspectRatio
        : widget.device?.dips.aspectRatio;
    final size = widget.landscape == true
        ? widget.device?.dips.flipped
        : widget.device?.dips;

    return Container(
      alignment: widget.leftAlign == true
          ? widget.topAlign == true
              ? Alignment.topLeft
              : Alignment.centerLeft
          : widget.topAlign == true
              ? Alignment.topCenter
              : Alignment.center,
      key: _uniqueKey,
      child: Container(
        constraints: size == null
            ? null
            : BoxConstraints(
                minHeight: size.height,
                minWidth: size.width,
              ),
        decoration: ratio == null
            ? null
            : BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                ),
              ),
        child: LayoutBuilder(
          builder: (BuildContext context, constraints) {
            Widget result = Container(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight,
                maxWidth: constraints.maxWidth,
              ),
              child: _built ??
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('NOTHING SELECTED'),
                    ),
                  ),
            );

            if (size != null) {
              if (ratio != null) {
                result = AspectRatio(
                  aspectRatio: ratio,
                  child: result,
                );
              }
              result = SizedBox(
                height: size.height,
                width: size.width,
                child: result,
              );
              if (widget.strictSize != true) {
                final scale = max(1.0, constraints.maxHeight / size.height);
                result = Transform.scale(
                  scale: scale,
                  child: result,
                );
              }
            }
            return result;
          },
        ),
      ),
    );
  }
}

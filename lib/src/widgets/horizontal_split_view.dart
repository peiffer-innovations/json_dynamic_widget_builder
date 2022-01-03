// Sourced from: https://medium.com/@leonar.d/how-to-create-a-flutter-split-view-7e2ac700ea12

import 'package:flutter/material.dart';
import 'package:json_dynamic_widget_builder/src/tinycolor/tinycolor.dart';

class HorizontalSplitView extends StatefulWidget {
  const HorizontalSplitView({
    required this.bottom,
    Key? key,
    this.ratio = 0.76,
    required this.top,
  })  : assert(ratio >= 0),
        assert(ratio <= 1),
        super(key: key);

  final Widget bottom;
  final double ratio;
  final Widget top;

  @override
  _HorizontalSplitViewState createState() => _HorizontalSplitViewState();
}

class _HorizontalSplitViewState extends State<HorizontalSplitView> {
  final _dividerHeight = 16.0;

  double? _maxHeight;
  //from 0-1
  late double _ratio;

  double get _height1 => _ratio * _maxHeight!;

  double get _height2 => (1 - _ratio) * _maxHeight!;

  @override
  void initState() {
    super.initState();
    _ratio = widget.ratio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      assert(_ratio <= 1);
      assert(_ratio >= 0);

      _maxHeight ??= constraints.maxHeight - _dividerHeight;

      if (_maxHeight != constraints.maxHeight) {
        _maxHeight = constraints.maxHeight - _dividerHeight;
      }

      return SizedBox(
        height: constraints.maxHeight,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: _height1,
              child: widget.top,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.resizeUpDown,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    _ratio += details.delta.dy / _maxHeight!;
                    if (_ratio > 1) {
                      _ratio = 1;
                    } else if (_ratio < 0.0) {
                      _ratio = 0.0;
                    }
                  });
                },
                child: Container(
                  color:
                      TinyColor(Theme.of(context).canvasColor).darken(5).color,
                  height: _dividerHeight,
                  width: constraints.maxWidth,
                  child: Icon(
                    Icons.drag_handle,
                    size: _dividerHeight,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: _height2,
              child: widget.bottom,
            ),
          ],
        ),
      );
    });
  }
}

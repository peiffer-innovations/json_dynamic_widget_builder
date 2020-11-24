// Sourced from: https://medium.com/@leonar.d/how-to-create-a-flutter-split-view-7e2ac700ea12

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tinycolor/tinycolor.dart';

class VerticalSplitView extends StatefulWidget {
  const VerticalSplitView({
    Key key,
    @required this.left,
    @required this.right,
    this.ratio = 0.33,
  })  : assert(left != null),
        assert(right != null),
        assert(ratio >= 0),
        assert(ratio <= 1),
        super(key: key);

  final Widget left;
  final Widget right;
  final double ratio;

  @override
  _VerticalSplitViewState createState() => _VerticalSplitViewState();
}

class _VerticalSplitViewState extends State<VerticalSplitView> {
  final _dividerWidth = 16.0;

  //from 0-1
  double _ratio;
  double _maxWidth;

  double get _width1 => _ratio * _maxWidth;

  double get _width2 => (1 - _ratio) * _maxWidth;

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

      _maxWidth ??= constraints.maxWidth - _dividerWidth;

      if (_maxWidth != constraints.maxWidth) {
        _maxWidth = constraints.maxWidth - _dividerWidth;
      }

      return SizedBox(
        width: constraints.maxWidth,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: _width1,
              child: widget.left,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    _ratio += details.delta.dx / _maxWidth;
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
                  height: constraints.maxHeight,
                  width: _dividerWidth,
                  child: RotationTransition(
                    turns: AlwaysStoppedAnimation(0.25),
                    child: Icon(Icons.drag_handle),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: _width2,
              child: widget.right,
            ),
          ],
        ),
      );
    });
  }
}

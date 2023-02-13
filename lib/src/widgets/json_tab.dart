import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:highlight/languages/json.dart' as l;
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_dynamic_widget_builder/src/bloc/widget_tree_bloc.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class JsonTab extends StatefulWidget {
  JsonTab({
    this.all = true,
    Key? key,
  }) : super(key: key);

  final bool all;

  @override
  _JsonTabState createState() => _JsonTabState();
}

class _JsonTabState extends State<JsonTab> with SingleTickerProviderStateMixin {
  static final Logger _logger = Logger('Ui');

  final CodeController _controller = CodeController(
    language: l.json,
  );
  final List<StreamSubscription> _subscriptions = [];

  late AnimationController _animationController;
  // String _error;
  String _text = '';
  Timer? _timer;
  late WidgetTreeBloc _widgetTreeBloc;

  @override
  void initState() {
    super.initState();

    _widgetTreeBloc = context.read<WidgetTreeBloc>();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animationController.addListener(() {
      if (mounted == true) {
        setState(() {});
      }

      if (_animationController.value == 1 &&
          _animationController.status == AnimationStatus.completed) {
        dynamic decoded;
        try {
          decoded = json.decode(_text);
          _logger.info('Successfully parsed JSON');
        } catch (e) {
          _logger.severe('Error decoding JSON', e);
        }

        if (decoded != null) {
          try {
            final temp = JsonWidgetData.fromDynamic(decoded);

            if (temp != null) {
              _widgetTreeBloc.widget = temp;
            }
            _logger.info('Successfully built widget');
          } catch (e) {
            _logger.severe('Error building widget', e);
          }
        }
      }
    });

    _controller.addListener(() {
      _timer?.cancel();

      _timer = Timer(const Duration(milliseconds: 200), () {
        final value = _controller.text;

        if (value != _text) {
          _text = value;
          _rebuild();
        }
      });
    });

    _subscriptions.add(_widgetTreeBloc.stream!.listen((event) {
      _rebuild();

      if (mounted == true) {
        setState(() {});
      }
    }));
    _rebuild();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget as JsonTab);

    _rebuild();
  }

  @override
  void dispose() {
    _subscriptions.forEach((sub) => sub.cancel());
    _subscriptions.clear();

    super.dispose();
  }

  void _rebuild() {
    final selection = _controller.selection;
    try {
      final widget = this.widget.all == true
          ? _widgetTreeBloc.widget
          : _widgetTreeBloc.current;
      if (widget != null) {
        _text = const JsonEncoder.withIndent('  ').convert(
          widget.toJson(),
        );
      }
    } catch (e, stack) {
      _logger.info('Error building widget', e, stack);
    }

    _controller.text = _text;
    _controller.setCursor(selection.baseOffset);

    if (mounted == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CodeTheme(
              data: CodeThemeData(styles: draculaTheme),
              child: SingleChildScrollView(
                child: CodeField(
                  controller: _controller,
                  textStyle: const TextStyle(
                    fontFamily: 'Courier New',
                    fontFamilyFallback: ['monospace', 'Courier'],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0.0,
          right: 0.0,
          top: 0.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: _animationController.value == 0.0 ||
                    _animationController.value == 1.0
                ? 0.0
                : 1.0,
            child: LinearProgressIndicator(
              value: _animationController.value,
            ),
          ),
        ),
      ],
    );
  }
}

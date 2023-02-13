import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class Console extends StatefulWidget {
  Console({
    Key? key,
  }) : super(key: key);

  @override
  _ConsoleState createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> {
  static const _kMaxConsole = 50000;

  final ScrollController _controller = ScrollController();
  final List<StreamSubscription> _subscriptions = [];
  List<String> _lines = [];
  String _text = '';

  @override
  void initState() {
    super.initState();

    _subscriptions.add(Logger.root.onRecord.listen((record) {
      _text += '${record.level.name}: ${record.time}: ${record.message}\n';
      if (record.error != null) {
        _text += '${record.error}\n';
      }
      if (record.stackTrace != null) {
        _text += '${record.stackTrace}\n';
      }

      if (_text.length > _kMaxConsole) {
        _text = _text.substring(_text.length - _kMaxConsole, _text.length);
      }

      _lines = _text.split('\n');

      if (mounted == true) {
        setState(() {});
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.positions.isNotEmpty) {
          _controller.jumpTo(_controller.position.maxScrollExtent);
        }
      });
    }));
  }

  @override
  void dispose() {
    _subscriptions.forEach((sub) => sub.cancel());
    _subscriptions.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Container(
            height: 24.0,
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                const Text(
                  'CONSOLE',
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
                const Expanded(
                  child: SizedBox(
                    width: 16.0,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                  ),
                  iconSize: 16.0,
                  onPressed: () {
                    _text = '';
                    _lines = [];
                    setState(() {});
                  },
                  padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 2.0),
                ),
              ],
            ),
          ),
          const Divider(height: 8.0),
          Expanded(
            child: ListView.builder(
              controller: _controller,
              itemBuilder: (BuildContext context, int index) => Text(
                _lines[index],
                style: const TextStyle(
                  fontFamily: 'Courier New',
                  fontFamilyFallback: ['monospace', 'Courier'],
                ),
              ),
              itemCount: _lines.length,
            ),
          ),
        ],
      ),
    );
  }
}

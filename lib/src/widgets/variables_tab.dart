import 'package:flutter/material.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_dynamic_widget_builder/src/bloc/sembast_bloc.dart';
import 'package:json_dynamic_widget_builder/src/models/key_value_pair.dart';
import 'package:provider/provider.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';

class VariablesTab extends StatefulWidget {
  VariablesTab({
    Key? key,
  }) : super(key: key);

  @override
  _VariablesTabState createState() => _VariablesTabState();
}

class _VariablesTabState extends State<VariablesTab> {
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, String> _temp = {};
  final List<KeyValuePair<String, String?>> _vars = [];
  String _emptyUuid = const Uuid().v4();

  @override
  void initState() {
    super.initState();

    _updateValues();
    _updateFocusNodes();
  }

  @override
  void dispose() {
    _focusNodes.forEach((_, node) => node.dispose());
    _focusNodes.clear();

    super.dispose();
  }

  void _updateFocusNodes() {
    for (var i = 0; i <= _vars.length; i++) {
      if (_focusNodes['$i|key'] == null) {
        final node = FocusNode();
        node.addListener(() {
          _updateVariables(i);
        });
        _focusNodes['$i|key'] = node;
      }
    }
  }

  Future<void> _updateValues() async {
    final registry = JsonWidgetRegistry.instance;
    final values = registry.values;
    _vars.clear();

    values.forEach(
      (key, value) => _vars.add(KeyValuePair(key: key, value: value)),
    );

    _vars.sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    registry.clearValues();
    for (var v in _vars) {
      registry.setValue(v.key, v.value);
    }

    final sembastBloc = context.read<SembastBloc>();
    final db = sembastBloc.getDatabase(SembastBloc.db_variables)!;
    final store = StoreRef.main();

    await db.transaction((txn) {
      store.delete(txn);

      for (var v in _vars) {
        store.record(v.key).put(db, v.value);
      }
    });

    if (mounted == true) {
      setState(() {});
    }
  }

  void _updateVariables(int index) {
    final key = _temp['$index|key'];
    final value = _temp['$index|value'];

    if (key == null && value == null && index < _vars.length) {
      _emptyUuid = const Uuid().v4();
      _vars.removeAt(index);
    } else {
      if (key != null) {
        if (index >= _vars.length) {
          _emptyUuid = const Uuid().v4();
          _vars.add(KeyValuePair(key: key, value: value));
        } else {
          final kvp = _vars[index];
          _vars.removeAt(index);
          _vars.insert(index, kvp);
        }
      }
    }

    _updateFocusNodes();
    if (mounted == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'KEY',
                  style: TextStyle(
                    fontFamily: 'Courier New',
                    fontFamilyFallback: ['monospace', 'Courier'],
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'VALUE',
                  style: TextStyle(
                    fontFamily: 'Courier New',
                    fontFamilyFallback: ['monospace', 'Courier'],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1.0),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) => Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      focusNode: _focusNodes['$index|key'],
                      key: ValueKey(
                        '${index < _vars.length ? _vars[index].id : _emptyUuid}.key',
                      ),
                      initialValue:
                          index < _vars.length ? _vars[index].key : '',
                      onChanged: (String value) => _temp['$index|key'] = value,
                    ),
                  ),
                  Container(
                    color: Theme.of(context).dividerColor,
                    height: 40.0,
                    width: 1,
                  ),
                  Expanded(
                    child: TextFormField(
                      focusNode: _focusNodes['$index|value'],
                      key: ValueKey(
                        '${index < _vars.length ? _vars[index].id : _emptyUuid}.value',
                      ),
                      initialValue:
                          index < _vars.length ? _vars[index].value : '',
                      onChanged: (String value) =>
                          _temp['$index|value'] = value,
                    ),
                  ),
                ],
              ),
              itemCount: _vars.length + 1,
            ),
          ),
        ],
      ),
    );
  }
}

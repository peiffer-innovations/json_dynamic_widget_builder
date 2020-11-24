import 'package:flutter/material.dart';
import 'package:json_dynamic_widget_builder/src/widgets/json_tab.dart';
import 'package:json_dynamic_widget_builder/src/widgets/ui_tab.dart';

class Results extends StatefulWidget {
  Results({Key key}) : super(key: key);

  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> with SingleTickerProviderStateMixin {
  bool _all = true;
  int _index = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
                child: Text('VIEW'),
              ),
              Expanded(
                child: SizedBox(width: 16.0),
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: _index == 0 || _index == 1 ? 1.0 : 0.0,
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(32.0),
                  isSelected: [
                    _all,
                    !_all,
                  ],
                  onPressed: (int index) {
                    _all = index == 0;
                    setState(() {});
                  },
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('ALL'),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('SELECTED'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.0),
              Container(
                width: 200.0,
                child: DropdownButtonFormField(
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('OUTPUT'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('JSON'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('VARIABLES'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _index = value),
                  value: _index,
                ),
              ),
            ],
          ),
          Divider(
            height: 1.0,
          ),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                UiTab(all: _all),
                JsonTab(all: _all),
                Center(
                  child: Text('VARIABLES'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

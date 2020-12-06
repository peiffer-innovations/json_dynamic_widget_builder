import 'package:flutter/material.dart';
import 'package:json_dynamic_widget_builder/src/widgets/animated_indexed_stack.dart';
import 'package:json_dynamic_widget_builder/src/widgets/json_tab.dart';
import 'package:json_dynamic_widget_builder/src/widgets/ui_tab.dart';
import 'package:json_dynamic_widget_builder/src/widgets/variables_tab.dart';

class Results extends StatefulWidget {
  Results({Key key}) : super(key: key);

  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> with SingleTickerProviderStateMixin {
  bool _all = true;
  bool _leftAlign = false;
  bool _topAlign = false;
  bool _horizontal = false;
  int _wideRatio = 16;
  int _highRatio = 9;
  int _index = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<String>> _showAspectRatioDialog() async {
    final result = await showDialog<List<String>>(
      builder: (context) {
        var _dialogWide = '$_wideRatio';
        var _dialogHigh = '$_highRatio';

        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(
                [_dialogWide, _dialogHigh],
              ),
              child: Text('Ok'),
            ),
          ],
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50.0,
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Wide',
                  ),
                  initialValue: _dialogWide,
                  keyboardType: TextInputType.number,
                  onChanged: (changed) {
                    _dialogWide = changed;
                  },
                  textAlign: TextAlign.center,
                ),
              ),
              Text(':'),
              SizedBox(
                width: 50.0,
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'High',
                  ),
                  initialValue: _dialogHigh,
                  keyboardType: TextInputType.number,
                  onChanged: (changed) {
                    _dialogHigh = changed;
                  },
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          title: Text('Select the Aspect Ratio'),
        );
      },
      context: context,
    );

    return result;
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
              SizedBox(width: 16.0),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.hardEdge,
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      height: kToolbarHeight,
                      child: Row(
                        children: [
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            opacity: _index == 0 ? 1.0 : 0.0,
                            child: SizedBox(
                              height: 50.0,
                              child: OutlinedButton(
                                onPressed: () async {
                                  final ratio = await _showAspectRatioDialog();
                                  if (ratio != null && ratio?.length == 2) {
                                    setState(() {
                                      _wideRatio =
                                          int.tryParse(ratio[0]) ?? _wideRatio;
                                      _highRatio =
                                          int.tryParse(ratio[1]) ?? _highRatio;
                                    });
                                  }
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  side: MaterialStateProperty.all(
                                    BorderSide(
                                      color: Colors.grey[800],
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  Icons.aspect_ratio_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            opacity: _index == 0 ? 1.0 : 0.0,
                            child: ToggleButtons(
                              borderRadius: BorderRadius.circular(32.0),
                              isSelected: [
                                _horizontal,
                                !_horizontal,
                              ],
                              onPressed: (int index) {
                                _horizontal = index == 0;
                                setState(() {});
                              },
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Icon(Icons.stay_current_portrait),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Icon(Icons.stay_current_landscape),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.0),
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            opacity: _index == 0 ? 1.0 : 0.0,
                            child: ToggleButtons(
                              borderRadius: BorderRadius.circular(32.0),
                              isSelected: [
                                _leftAlign,
                                !_leftAlign,
                              ],
                              onPressed: (int index) {
                                _leftAlign = index == 0;
                                setState(() {});
                              },
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Icon(Icons.format_align_left),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Icon(Icons.format_align_center),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.0),
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            opacity: _index == 0 ? 1.0 : 0.0,
                            child: ToggleButtons(
                              borderRadius: BorderRadius.circular(32.0),
                              isSelected: [
                                _topAlign,
                                !_topAlign,
                              ],
                              onPressed: (int index) {
                                _topAlign = index == 0;
                                setState(() {});
                              },
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Icon(Icons.vertical_align_top),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Icon(Icons.vertical_align_center),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.0),
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
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(32.0),
                            isSelected: [
                              _index == 0,
                              _index == 1,
                              _index == 2,
                            ],
                            onPressed: (int index) {
                              _index = index;
                              setState(() {});
                            },
                            children: [
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('VISUAL'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('JSON'),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('VARIABLES'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            height: 1.0,
          ),
          Expanded(
            child: AnimatedIndexedStack(
              index: _index,
              children: [
                UiTab(
                  all: _all,
                  highRatio: _highRatio,
                  leftAlign: _leftAlign,
                  topAlign: _topAlign,
                  wideRatio: _wideRatio,
                ),
                JsonTab(all: _all),
                VariablesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:json_dynamic_widget_builder/src/models/simulated_device.dart';
import 'package:json_dynamic_widget_builder/src/models/simulated_device_registry.dart';
import 'package:json_dynamic_widget_builder/src/widgets/animated_indexed_stack.dart';
import 'package:json_dynamic_widget_builder/src/widgets/json_tab.dart';
import 'package:json_dynamic_widget_builder/src/widgets/ui_tab.dart';
import 'package:json_dynamic_widget_builder/src/widgets/variables_tab.dart';

class Results extends StatefulWidget {
  Results({Key? key}) : super(key: key);

  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> with SingleTickerProviderStateMixin {
  bool _all = true;
  SimulatedDevice? _device;
  int _index = 0;
  bool _landscape = false;
  bool _strictSize = true;

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
    final deviceRegistry = SimulatedDeviceRegistry();
    final devices = deviceRegistry.devices;

    return Material(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
                child: const Text('VIEW'),
              ),
              const SizedBox(width: 16.0),
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
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _index != 0 || _device == null
                                ? const SizedBox()
                                : ToggleButtons(
                                    borderRadius: BorderRadius.circular(32.0),
                                    isSelected: [
                                      _landscape,
                                      !_landscape,
                                    ],
                                    onPressed: (int index) => setState(
                                      () => _landscape = index == 0,
                                    ),
                                    children: [
                                      const Tooltip(
                                        message: 'LANDSCAPE',
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Icon(
                                              Icons.stay_current_landscape),
                                        ),
                                      ),
                                      const Tooltip(
                                        message: 'PORTRAIT',
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child:
                                              Icon(Icons.stay_current_portrait),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(width: 16.0),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _index != 0
                                ? const SizedBox()
                                : ToggleButtons(
                                    borderRadius: BorderRadius.circular(32.0),
                                    isSelected: [
                                      _strictSize,
                                      _device != null,
                                    ],
                                    onPressed: (int index) async {
                                      if (index == 0) {
                                        setState(
                                          () => _strictSize = !_strictSize,
                                        );
                                      } else {
                                        final device = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              SimpleDialog(
                                            title: const Text('SELECT DEVICE'),
                                            children: [
                                              ListTile(
                                                onTap: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                title: const Text('NONE'),
                                              ),
                                              ...[
                                                for (var device in devices)
                                                  ListTile(
                                                    onTap: () =>
                                                        Navigator.of(context)
                                                            .pop(device),
                                                    subtitle: Text(
                                                      '${device!.dips.width.toInt()} x ${device.dips.height.toInt()}',
                                                    ),
                                                    title: Text(device.name),
                                                    trailing: device.name ==
                                                            _device?.name
                                                        ? const Icon(
                                                            Icons.check_circle,
                                                            color: Colors.green,
                                                          )
                                                        : null,
                                                  ),
                                              ],
                                            ],
                                          ),
                                        );

                                        if (device != null) {
                                          if (device == false) {
                                            _device = null;
                                          } else {
                                            _device = device;
                                          }

                                          setState(() {});
                                        }
                                      }
                                    },
                                    children: [
                                      Tooltip(
                                        message: _strictSize == true
                                            ? 'FILL VIEWPORT'
                                            : 'USE ACTUAL DIPS',
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Icon(_strictSize == true
                                              ? Icons.fullscreen_exit
                                              : Icons.fullscreen),
                                        ),
                                      ),
                                      const Tooltip(
                                        message: 'SELECT SIMULATED DEVICE',
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Icon(Icons.phone_android),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(width: 16.0),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _index != 0 && _index != 1
                                ? const SizedBox()
                                : ToggleButtons(
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
                                      const Tooltip(
                                        message: 'SHOW ENTIRE TREE',
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text('ALL'),
                                        ),
                                      ),
                                      const Tooltip(
                                        message:
                                            'SHOW ONLY THE CURRENTLY SELECTED WIDGET',
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text('SELECTED'),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                          const SizedBox(width: 16.0),
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
                              const Tooltip(
                                message: 'SHOW RENDERED WIDGETS',
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('VISUAL'),
                                ),
                              ),
                              const Tooltip(
                                message: 'SHOW JSON DATA',
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('JSON'),
                                ),
                              ),
                              const Tooltip(
                                message: 'SHOW VARIABLE VALUES',
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('VARIABLES'),
                                ),
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
          const Divider(
            height: 1.0,
          ),
          Expanded(
            child: AnimatedIndexedStack(
              index: _index,
              children: [
                UiTab(
                  all: _all,
                  device: _device,
                  landscape: _landscape,
                  leftAlign: false,
                  strictSize: _strictSize,
                  topAlign: false,
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

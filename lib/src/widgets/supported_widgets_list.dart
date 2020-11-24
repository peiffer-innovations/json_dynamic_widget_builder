import 'package:flutter/material.dart';
import 'package:json_dynamic_widget/json_dynamic_widget_schemas.dart';

class SupportedWidgetsList extends StatelessWidget {
  final List<String> _widgets = JsonDynamicWidgetSchemas.all.keys.toList()
    ..sort();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Widget'),
      ),
      body: Material(
        child: ListView.builder(
          itemCount: _widgets.length,
          itemBuilder: (BuildContext context, int index) => ListTile(
            title: Text(
              _widgets[index].split('/').last,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:json_dynamic_widget_builder/src/widgets/console.dart';
import 'package:json_dynamic_widget_builder/src/widgets/horizontal_split_view.dart';
import 'package:json_dynamic_widget_builder/src/widgets/results.dart';
import 'package:json_dynamic_widget_builder/src/widgets/schema_view.dart';
import 'package:json_dynamic_widget_builder/src/widgets/vertical_split_view.dart';
import 'package:json_dynamic_widget_builder/src/widgets/widgets_panel.dart';

class HomePage extends StatelessWidget {
  HomePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VerticalSplitView(
        left: WidgetsPanel(),
        ratio: 0.2,
        right: VerticalSplitView(
          left: HorizontalSplitView(
            bottom: Console(),
            ratio: 0.85,
            top: Results(),
          ),
          ratio: 0.77,
          right: SchemaView(),
        ),
      ),
    );
  }
}

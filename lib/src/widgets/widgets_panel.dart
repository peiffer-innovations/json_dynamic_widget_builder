import 'package:flutter/material.dart';
import 'package:json_dynamic_widget_builder/src/widgets/tree_view.dart';

class WidgetsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
        builder: (BuildContext context) => TreeView(),
      ),
    );
  }
}

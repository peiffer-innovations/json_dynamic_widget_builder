import 'package:flutter/material.dart';

class ObjectEditorWidget extends StatefulWidget {
  ObjectEditorWidget({
    Key key,
    this.schema,
    this.value,
  }) : super(key: key);

  final dynamic schema;
  final dynamic value;

  @override
  _ObjectEditorWidgetState createState() => _ObjectEditorWidgetState();
}

class _ObjectEditorWidgetState extends State<ObjectEditorWidget> {
  @override
  Widget build(BuildContext context) {}
}

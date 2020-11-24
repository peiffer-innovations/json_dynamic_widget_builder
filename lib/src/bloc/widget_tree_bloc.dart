import 'dart:async';

import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_schema/json_schema.dart';
import 'package:json_theme/json_theme_schemas.dart';

class WidgetTreeBloc {
  StreamController<void> _controller = StreamController<void>.broadcast();

  JsonWidgetData _current;
  JsonWidgetData _widget;

  JsonWidgetData get current => _current;
  Stream<void> get stream => _controller?.stream;
  JsonWidgetData get widget => _widget;

  set current(JsonWidgetData current) {
    _current = current;
    _controller.add(null);
  }

  set widget(JsonWidgetData widget) {
    if (widget == null) {
      _widget = null;
    } else {
      _widget = widget;
    }

    _controller.add(null);
  }

  void dispose() {
    _controller?.close();
    _controller = null;
  }

  // void add(JsonWidgetData parent, JsonWidgetData widget) {
  //   if (parent == null) {
  //     _widget = widget;
  //   } else {
  //     parent.children.add(widget);
  //   }

  //   _controller?.add(null);
  // }

  JsonSchema getSchema(String schemaId) {
    RefProvider refProvider;
    refProvider = (String ref) {
      var schema = SchemaCache().getSchema(ref);
      if (schema == null) {
        throw Exception('Unable to find schema: $ref');
      }

      return JsonSchema.createSchema(
        schema,
        refProvider: refProvider,
      );
    };

    var schemaData = SchemaCache().getSchema(schemaId);
    assert(schemaData != null, 'Cannot find schema: $schemaId');
    var jsonSchema = JsonSchema.createSchema(
      schemaData,
      refProvider: refProvider,
    );

    return jsonSchema;
  }

  void notify() {
    _controller?.add(null);
  }

  void remove(JsonWidgetData parent, JsonWidgetData widget) {
    if (parent == null) {
      _widget = null;
    } else {
      parent.children.remove(widget);
    }
  }
}

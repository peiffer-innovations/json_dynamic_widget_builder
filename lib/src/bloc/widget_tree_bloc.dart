import 'dart:async';

import 'package:json_dynamic_widget/json_dynamic_widget.dart';
// import 'package:json_schema2/json_schema2.dart';
// import 'package:json_theme/json_theme_schemas.dart';

class WidgetTreeBloc {
  StreamController<void>? _controller = StreamController<void>.broadcast();

  JsonWidgetData? _current;
  JsonWidgetData? _widget;

  JsonWidgetData? get current => _current;
  Stream<void>? get stream => _controller?.stream;
  JsonWidgetData? get widget => _widget;

  set current(JsonWidgetData? current) {
    _current = current;
    _controller!.add(null);
  }

  set widget(JsonWidgetData? widget) {
    if (widget == null) {
      _widget = null;
    } else {
      _widget = widget;
    }

    if (_current != null && _widget != null) {
      _current = findInWidget(
        _widget,
        _current!.id,
        _current!.type,
      );
    }

    _controller!.add(null);
  }

  void dispose() {
    _controller?.close();
    _controller = null;
  }

  JsonWidgetData? addWidget(JsonWidgetData parent, JsonWidgetData widget) {
    final children =
        List<JsonWidgetData>.from(parent.children ?? <JsonWidgetData>[]);

    children.add(widget);

    final newParent = parent.copyWith(children: children);

    return replace(parent, newParent);
  }

  dynamic findInValues(dynamic values, JsonWidgetData? widget) {
    dynamic result;

    if (values is Map) {
      if (values['id'] == widget!.id && values['type'] == widget.type) {
        result = values;
      } else {
        values.forEach((key, value) {
          result ??= findInValues(value, widget);
        });
      }
    } else if (values is List) {
      for (var v in values) {
        result = findInValues(v, widget);
        if (result != null) {
          break;
        }
      }
    }

    return result;
  }

  JsonWidgetData? findInWidget(
    JsonWidgetData? widget,
    String id,
    String type,
  ) {
    JsonWidgetData? result;

    if (widget?.id == id && widget?.type == type) {
      result = widget;
    } else {
      widget?.children?.forEach((sub) {
        result ??= findInWidget(sub, id, type);
      });
    }

    return result;
  }

  JsonWidgetData? findParentOfWidget(
    JsonWidgetData? widget,
    String id,
    String type, {
    JsonWidgetData? parent,
  }) {
    JsonWidgetData? result;

    if (widget?.id == id && widget?.type == type) {
      result = parent;
    } else {
      widget?.children?.forEach((sub) {
        result ??= findParentOfWidget(
          sub,
          id,
          type,
          parent: widget,
        );
      });
    }

    return result;
  }

  void notify() {
    _controller?.add(null);
  }

  JsonWidgetData? replace(JsonWidgetData? oldWidget,
      [JsonWidgetData? newWidget]) {
    final values = _widget!.toJson();

    final toReplace = findInValues(values, oldWidget);
    toReplace.clear();

    if (newWidget != null) {
      toReplace.addAll(newWidget.toJson());
    }

    return JsonWidgetData.fromDynamic(values);
  }
}

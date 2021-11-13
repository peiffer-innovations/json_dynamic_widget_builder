import 'package:flutter/material.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_dynamic_widget/json_dynamic_widget_schemas.dart';
// import 'package:json_dynamic_widget_builder/src/bloc/schema_bloc.dart';
// import 'package:provider/provider.dart';

class SupportedWidgetsList extends StatefulWidget {
  SupportedWidgetsList({
    Key? key,
    dynamic values,
  })  : values = values ?? <String, dynamic>{},
        super(key: key);

  final dynamic values;

  @override
  _SupportedWidgetsListState createState() => _SupportedWidgetsListState();
}

class _SupportedWidgetsListState extends State<SupportedWidgetsList> {
  final List<String> _widgets = JsonDynamicWidgetSchemas.all.keys
      .map((e) => e.substring(0, e.length - '.json'.length))
      .toList()
    ..sort();

  // SchemaBloc _schemaBloc;
  String? _type;

  @override
  void initState() {
    super.initState();

    // _schemaBloc = context.read<SchemaBloc>();

    _type = widget.values['type'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Widget'),
      ),
      body: Material(
        child: ListView.builder(
          itemCount: _widgets.length,
          itemBuilder: (BuildContext context, int index) {
            var type = _widgets[index].split('/').last;
            // type = type.substring(0, type.length - '.json'.length);

            return ListTile(
              onTap: () {
                if (_type == type) {
                  Navigator.of(context).pop(null);
                } else {
                  var registry = JsonWidgetRegistry.instance;
                  JsonWidgetBuilder? Function(dynamic,
                          {JsonWidgetRegistry registry}) builder =
                      registry.getWidgetBuilder(type);
                  Navigator.of(context).pop(JsonWidgetData(
                    args: <String, dynamic>{},
                    builder: () {
                      return builder(
                        registry.processDynamicArgs(<String, dynamic>{}).values,
                        registry: registry,
                      )!;
                    },
                    type: type,
                  ));
                }
              },
              selected: _type == type,
              subtitle: _type != type || widget.values['args'] == null
                  ? null
                  : Text(
                      widget.values['args'].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              title: Text(
                type,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: _type != type ? null : Icon(Icons.check_circle),
            );
          },
        ),
      ),
    );
  }
}

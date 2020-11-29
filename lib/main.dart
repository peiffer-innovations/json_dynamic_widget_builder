import 'package:flutter/material.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_dynamic_widget/json_dynamic_widget_schemas.dart';
import 'package:json_dynamic_widget_builder/src/bloc/schema_bloc.dart';
import 'package:json_dynamic_widget_builder/src/bloc/sembast_bloc.dart';
import 'package:json_dynamic_widget_builder/src/bloc/widget_tree_bloc.dart';
import 'package:json_theme/json_theme_schemas.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:sembast/sembast.dart';

import 'src/components/app.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      // ignore: avoid_print
      print('${record.error}');
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print('${record.stackTrace}');
    }
  });

  var schemaBloc = SchemaBloc();
  var sembastBloc = SembastBloc();
  var widgetTreeBloc = WidgetTreeBloc();

  var sCache = SchemaCache();
  sCache.addSchemas(JsonDynamicWidgetSchemas.all);
  sCache.addSchemas(Schemas.all);

  await sembastBloc.initialize();

  var db = sembastBloc.getDatabase(SembastBloc.db_variables);
  var store = StoreRef.main();
  var registry = JsonWidgetRegistry.instance;

  var query = store.query();
  var snapshots = await query.getSnapshots(db);

  for (var snapshot in snapshots) {
    registry.setValue(snapshot.key?.toString(), snapshot.value);
  }

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: schemaBloc),
        Provider.value(value: sembastBloc),
        Provider.value(value: widgetTreeBloc),
      ],
      child: App(),
    ),
  );
}

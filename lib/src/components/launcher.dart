import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_class/json_class.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';
import 'package:json_dynamic_widget/json_dynamic_widget_schemas.dart';
import 'package:json_dynamic_widget_builder/src/bloc/schema_bloc.dart';
import 'package:json_dynamic_widget_builder/src/bloc/sembast_bloc.dart';
import 'package:json_dynamic_widget_builder/src/bloc/widget_tree_bloc.dart';
import 'package:json_dynamic_widget_builder/src/components/app.dart';
import 'package:json_dynamic_widget_builder/src/models/simulated_device.dart';
import 'package:json_dynamic_widget_builder/src/models/simulated_device_registry.dart';
import 'package:json_dynamic_widget_plugin_svg/json_dynamic_widget_plugin_svg.dart';
import 'package:json_theme/json_theme_schemas.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:sembast/sembast.dart';

class Launcher {
  Future<void> launch(
      {Future<void> Function(
        SimulatedDeviceRegistry deviceRegistry,
        JsonWidgetRegistry widgetRegistry,
      )?
          onPostInitialization}) async {
    WidgetsFlutterBinding.ensureInitialized();
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

    final deviceRegistry = SimulatedDeviceRegistry();
    final deviceJson = await rootBundle.loadString('assets/devices.json');
    deviceRegistry.addDevices(
      JsonClass.fromDynamicList(
        json.decode(deviceJson),
        (map) => SimulatedDevice.fromDynamic(map),
      ),
    );

    final schemaBloc = SchemaBloc();
    final sembastBloc = SembastBloc();
    final widgetTreeBloc = WidgetTreeBloc();

    final sCache = SchemaCache();
    sCache.addSchemas(JsonDynamicWidgetSchemas.all);
    sCache.addSchemas(Schemas.all);

    await sembastBloc.initialize();

    final db = sembastBloc.getDatabase(SembastBloc.db_variables)!;
    final store = StoreRef.main();
    final registry = JsonWidgetRegistry.instance;
    JsonSvgPlugin.bind(registry);

    final query = store.query();
    final snapshots = await query.getSnapshots(db);

    for (var snapshot in snapshots) {
      registry.setValue(snapshot.key.toString(), snapshot.value);
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
}

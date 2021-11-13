import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

class SembastBloc {
  static const String db_variables = 'variables.db';

  final Map<String, Database> _databases = {};

  Database? getDatabase(String dbName) => _databases[dbName];

  Future<void> initialize() async {
    DatabaseFactory dbFactory;

    if (kIsWeb) {
      dbFactory = databaseFactoryWeb;
    } else {
      dbFactory = databaseFactoryIo;
    }

    _databases[db_variables] = await dbFactory.openDatabase(db_variables);
  }
}

import 'dart:async';

import 'package:json_schema2/json_schema2.dart';
import 'package:json_theme/json_theme_schemas.dart';

class SchemaBloc {
  StreamController<void> _controller = StreamController<void>.broadcast();

  JsonSchema _current;

  JsonSchema get current => _current;
  Stream<void> get stream => _controller?.stream;

  set current(JsonSchema current) {
    _current = current;
    _controller.add(null);
  }

  void dispose() {
    _controller?.close();
    _controller = null;
  }

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
}

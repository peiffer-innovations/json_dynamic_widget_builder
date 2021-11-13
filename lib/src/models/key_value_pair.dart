import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

@immutable
class KeyValuePair<X, Y> {
  KeyValuePair({
    required this.key,
    required this.value,
  }) : assert(key != null);

  final id = Uuid().v4();
  final X key;
  final Y value;

  KeyValuePair copyWith({
    String? key,
    String? value,
  }) =>
      KeyValuePair(
        key: key ?? this.key,
        value: value ?? this.value,
      );
}

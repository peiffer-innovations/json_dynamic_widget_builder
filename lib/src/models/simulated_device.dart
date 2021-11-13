import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:meta/meta.dart';

@immutable
class SimulatedDevice extends JsonClass {
  SimulatedDevice({
    required this.dips,
    required this.name,
    required this.os,
    required this.scale,
  });

  final Size dips;
  final String name;
  final String os;
  final double scale;

  static SimulatedDevice? fromDynamic(dynamic map) {
    SimulatedDevice? result;

    if (map != null) {
      result = SimulatedDevice(
        dips: Size(
          JsonClass.parseDouble(map['dips'][0])!,
          JsonClass.parseDouble(map['dips'][1])!,
        ),
        name: map['name'],
        os: map['os'],
        scale: JsonClass.parseDouble(map['scale'], 1.0)!,
      );
    }

    return result;
  }

  @override
  Map<String, dynamic> toJson() => {
        'dips': {
          'height': dips.height,
          'width': dips.width,
        },
        'name': name,
        'os': os,
        'scale': scale,
      };
}

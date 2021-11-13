import 'package:json_dynamic_widget_builder/src/models/simulated_device.dart';

class SimulatedDeviceRegistry {
  factory SimulatedDeviceRegistry() => _singleton;
  SimulatedDeviceRegistry._internal();

  static final SimulatedDeviceRegistry _singleton =
      SimulatedDeviceRegistry._internal();

  final Map<String, SimulatedDevice?> _devices = {};

  List<SimulatedDevice?> get devices => _devices.values.toList()
    ..sort((a, b) => a!.name.toLowerCase().compareTo(b!.name.toLowerCase()));

  void addDevices(List<SimulatedDevice?>? devices) =>
      devices?.forEach((device) => _devices[device!.name] = device);

  void clearDevices() => _devices.clear();
}

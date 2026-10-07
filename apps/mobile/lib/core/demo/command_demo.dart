import 'package:flutter/material.dart';

import '../../app/design_system.dart';

/// Fixtures from the visual references; none of these values are live readings.
abstract final class CommandDemo {
  static const healthIndex = 94;
  static const healthyAnimals = 250;
  static const anomalies = '05';
  static const latitude = '-12.645';
  static const longitude = '-55.823';
  static const chlorophyll = '0.82';
  static const confidence = '92';
  static const animals = [
    DemoAnimal(
      'TX-042',
      'PASTO NORTE • LOTE A',
      'Saudável',
      CommandColors.primary,
      Rect.fromLTWH(38, 242, 33, 33),
    ),
    DemoAnimal(
      'TX-089',
      'PASTO LESTE • LOTE B',
      'Em Monitoramento',
      CommandColors.blue,
      Rect.fromLTWH(38, 303, 33, 33),
    ),
    DemoAnimal(
      'TX-012',
      'ISOLAMENTO • CLÍNICA',
      'Crítico',
      CommandColors.error,
      Rect.fromLTWH(38, 363, 33, 33),
    ),
    DemoAnimal(
      'TX-115',
      'PASTO NORTE • LOTE A',
      'Saudável',
      CommandColors.primary,
      Rect.fromLTWH(38, 424, 33, 33),
    ),
  ];
}

class DemoAnimal {
  const DemoAnimal(this.id, this.location, this.status, this.color, this.photo);
  final String id;
  final String location;
  final String status;
  final Color color;
  final Rect photo;
}

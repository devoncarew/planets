import 'dart:math';

import 'package:flutter/material.dart';

final SolarBody sun = _createSun();

typedef LocationCalculator = double Function(SolarBody body, DateTime time);

class SolarBody {
  final String name;
  final Color color;
  final double au;
  final int incrementCount;
  final bool useForScaling;

  final BodySize size;
  final List<SolarBody> satellites;
  final LocationCalculator locationCalculator;

  SolarBody(
    this.name,
    this.color,
    this.au, {
    this.size = BodySize.medium,
    this.satellites = const [],
    this.locationCalculator,
    this.incrementCount,
    this.useForScaling = true,
  });

  String get letter => name.substring(0, 1);

  double get radius {
    return size == BodySize.large ? 20.0 : size == BodySize.medium ? 12.0 : 8.0;
  }

  double getRadiansForTime(DateTime time) {
    return locationCalculator(this, time);
  }
}

// Mercury: 87.97 days (0.24 years)
// Venus: 224.70 days (0.62 years)
// Earth: 365.26 days (1 year)
// Mars: 686.98 days (1.88 years)

// Mercury 0.387 AU
// Venus 0.722 AU
// Earth 1.01 AU
// Mars 1.52 AU

SolarBody _createSun() {
  List<SolarBody> planets = [];

  var scaleTime = (LocationCalculator locationCalculator, double scale) {
    return (SolarBody body, DateTime time) {
      DateTime adjustedTime = DateTime.fromMillisecondsSinceEpoch(
          time.millisecondsSinceEpoch ~/ scale);
      return locationCalculator(body, adjustedTime);
    };
  };

  planets.add(SolarBody(
    'Mercury',
    Colors.red[800],
    0.387,
    size: BodySize.small,
    locationCalculator: scaleTime(_hoursLocation, 0.24),
  ));
  planets.add(SolarBody(
    'Venus',
    Colors.orange[300],
    0.722,
    size: BodySize.medium,
    locationCalculator: scaleTime(_hoursLocation, 0.62),
  ));
  planets.add(SolarBody(
    'Earth',
    Colors.blue,
    1.01,
    size: BodySize.medium,
    incrementCount: 12,
    locationCalculator: _hoursLocation,
    satellites: [
      SolarBody(
        "Moon",
        Colors.grey,
        0.2,
        size: BodySize.small,
        locationCalculator: _secondsLocation,
      ),
    ],
  ));
  planets.add(SolarBody(
    'Mars',
    Colors.red[400],
    1.52,
    size: BodySize.medium,
    incrementCount: 60,
    locationCalculator: _minutesLocation,
  ));
  planets.add(SolarBody(
    'Jupiter',
    Colors.red[600],
    2.7,
    size: BodySize.large,
    useForScaling: false,
    locationCalculator: _hours24Location,
    satellites: [
      SolarBody(
        "Io",
        Colors.grey,
        0.30,
        size: BodySize.small,
        locationCalculator: scaleTime(_secondsLocation, 6.0),
      ),
      SolarBody(
        "Europa",
        Colors.grey,
        0.45,
        size: BodySize.small,
        locationCalculator: scaleTime(_secondsLocation, 8.0),
      ),
      SolarBody(
        "Ganymede",
        Colors.grey,
        0.60,
        size: BodySize.small,
        locationCalculator: scaleTime(_secondsLocation, 11.0),
      ),
      SolarBody(
        "Callisto",
        Colors.grey,
        0.75,
        size: BodySize.small,
        locationCalculator: scaleTime(_secondsLocation, 12.5),
      ),
    ],
  ));

  return new SolarBody(
    'Sun',
    Colors.yellow,
    0.0,
    satellites: planets,
    size: BodySize.large,
  );
}

double _hoursLocation(SolarBody body, DateTime time) {
  double hours = time.hour % 12 + time.minute / 60.0;
  return (hours / 12.0) * 2 * pi - 0.5 * pi;
}

double _hours24Location(SolarBody body, DateTime time) {
  double hours = time.hour + time.minute / 60.0;
  return (hours / 24.0) * 2 * pi - 0.5 * pi;
}

double _minutesLocation(SolarBody body, DateTime time) {
  double minutes = time.minute + time.second / 60.0;
  return (minutes / 60.0) * 2 * pi - 0.5 * pi;
}

double _secondsLocation(SolarBody body, DateTime time) {
  double seconds = time.second + time.millisecond / 1000.0;
  return (seconds / 60.0) * 2 * pi - 0.5 * pi;
}

enum BodySize {
  small,
  medium,
  large,
}

class StarField {
  static Random _random = Random();

  static StarField generate() {
    List<Star> stars = [];

    for (int i = 0; i < 200; i++) {
      stars.add(
        new Star(
          new Point(_random.nextDouble(), _random.nextDouble()),
          _random.nextDouble(),
          _random.nextDouble() * 2.0,
        ),
      );
    }

    return new StarField._(stars);
  }

  final List<Star> stars;

  StarField._(this.stars);
}

class Star {
  final Point location;
  final double intensity;
  final double radius;

  Star(this.location, this.intensity, this.radius);
}

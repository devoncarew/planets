import 'dart:async';
import 'dart:math';
// ignore: undefined_hidden_name
import 'dart:ui' hide Point;

import 'package:flutter/material.dart';

import 'model.dart';

void main() => runApp(PlanetsApp());

class PlanetsApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Planets',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SolarSystemWidget(
        title: 'Flutter Planets',
        mainBody: sun,
      ),
    );
  }
}

class SolarSystemWidget extends StatefulWidget {
  final String title;
  final SolarBody mainBody;

  SolarSystemWidget({
    Key key,
    @required this.title,
    @required this.mainBody,
  }) : super(key: key);

  @override
  _SolarSystemState createState() => _SolarSystemState();
}

class _SolarSystemState extends State<SolarSystemWidget> {
  Timer timer;
  ValueNotifier<DateTime> notifier;

  final StarField _starField = StarField.generate();

  // todo: use initState

  _SolarSystemState() {
    notifier = new ValueNotifier<DateTime>(DateTime.now());
    timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
      notifier.value = DateTime.now();
    });
  }

  @override
  void dispose() {
    super.dispose();

    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final SolarBody body = widget.mainBody;

    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Point center = new Point(
            constraints.maxWidth / 2,
            constraints.maxHeight / 2,
          );
          List<SolarBody> scaleSatellites =
              body.satellites.where((body) => body.useForScaling).toList();
          final double maxAUs = scaleSatellites
              .map((body) => body.au * 2)
              .fold(0, (a, b) => max(a, b));
          // calculate a scaling factor
          final double pxPerAUx =
              (constraints.maxWidth - scaleSatellites.last.radius * 2) / maxAUs;
          final double pxPerAUy =
              (constraints.maxHeight - scaleSatellites.last.radius * 2) / maxAUs;
          final double pxPerAU = min(pxPerAUx, pxPerAUy);

          return CustomPaint(
            painter: new CompositePainter([
              new StarFieldPainter(_starField),
              new OrbitPainter(body, center, pxPerAU),
            ]),
            child: ValueListenableBuilder<DateTime>(
              valueListenable: notifier,
              builder: (BuildContext context, DateTime time, Widget child) {
                List<PlanetWidget> children = [];
                _positionSatellites(body, center, pxPerAU, children, time);
                return Stack(fit: StackFit.expand, children: children);
              },
            ),
          );
        },
      ),
    );
  }

  void _positionSatellites(
    SolarBody solarBody,
    Point<num> center,
    double pxPerAU,
    List<PlanetWidget> children,
    DateTime time,
  ) {
    children.add(new PlanetWidget(center, solarBody));

    for (SolarBody child in solarBody.satellites) {
      // find distance and radians
      final double radians = child.getRadiansForTime(time);
      final Point childPos = center +
          Point(child.au * pxPerAU * cos(radians),
              child.au * pxPerAU * sin(radians));

      _positionSatellites(child, childPos, pxPerAU, children, time);
    }
  }
}

class CompositePainter extends CustomPainter {
  final List<CustomPainter> painters;

  CompositePainter(this.painters);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (CustomPainter painter in painters) {
      painter.paint(canvas, size);
    }
  }
}

class StarFieldPainter extends CustomPainter {
  final StarField starField;

  StarFieldPainter(this.starField);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (Star star in starField.stars) {
      final Paint paint = Paint()
        ..color = Colors.grey[600].withOpacity(star.intensity);

      canvas.drawCircle(
        new Offset(star.location.x * size.width, star.location.y * size.height),
        star.radius,
        paint,
      );
    }
  }
}

class OrbitPainter extends CustomPainter {
  final SolarBody body;
  final Point<num> center;
  final double pxPerAU;

  OrbitPainter(this.body, this.center, this.pxPerAU);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.grey[600]
      ..style = PaintingStyle.stroke;
    final Paint tickPaint = Paint()..color = Colors.grey[600];

    for (SolarBody child in body.satellites) {
      if (child.incrementCount != null) {
        // Draw the orbit path.
        canvas.drawCircle(
            new Offset(center.x, center.y), child.au * pxPerAU, linePaint);

        // Draw n ticks on the path.
        final int max = child.incrementCount;
        List<Offset> ticks = List.generate(max, (int index) {
          double radians = (index.toDouble() / max.toDouble()) * 2.0 * pi;
          return Offset(
            cos(radians) * child.au * pxPerAU + center.x,
            sin(radians) * child.au * pxPerAU + center.y,
          );
        });

        for (Offset tick in ticks) {
          canvas.drawCircle(tick, 2.5, tickPaint);
        }
      }
    }
  }
}

class PlanetWidget extends StatelessWidget {
  final Point origin;
  final SolarBody solarBody;

  PlanetWidget(this.origin, this.solarBody);

  @override
  Widget build(BuildContext context) {
    final double radius = solarBody.radius;

    // todo: use SlideTransition or similar - it avoids layout
    // AnimatedPositioned, Positioned, PositionedTransition, SlideTransition
    return Positioned(
      left: origin.x.toDouble() - radius,
      top: origin.y.toDouble() - radius,
      //duration: Duration(seconds: 1),
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: new BoxDecoration(
          color: solarBody.color,
          shape: BoxShape.circle,
          boxShadow: [
            new BoxShadow(
              color: Colors.grey[900],
              offset: new Offset(2.0, 2.0),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:warroombattlesim/UnitState.dart';

class UnitSelectorOverlay extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final Function(void) onToggled;

  const UnitSelectorOverlay({
    super.key,
    required this.value,
    required this.onToggled,
    required this.onChanged,
  });

  @override
  State<UnitSelectorOverlay> createState() => _UnitselectoroverlayState();
}

class _UnitselectoroverlayState extends State<UnitSelectorOverlay> {

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: false,
      child: GestureDetector(
        onTap: () {
          widget.onToggled(null);
        },
        child: FractionallySizedBox(
          widthFactor: 0.2,
          heightFactor: 0.2,
          child: SizedBox(
            height: 80,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  startAngle: 0,
                  endAngle: 180,
                  isInversed: true,
                  minimum: 0,
                  maximum: 30,
                  showLabels: false,
                  showTicks: true,
                  pointers: <GaugePointer>[
                    MarkerPointer(
                      value: widget.value,
                      enableDragging: true,
                      markerHeight: 25,
                      markerWidth: 25,
                      markerType: MarkerType.circle,
                      color: Colors.lightBlue,
                      borderWidth: 3,
                      borderColor: Colors.black,
                      onValueChanged: (v) {
                        widget.onChanged.call(v);
                      },
                    ),
                  ],
                  axisLineStyle: AxisLineStyle(
                    cornerStyle: CornerStyle.bothCurve,
                    color: Colors.white30,
                    thickness: 25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

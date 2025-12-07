import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:warroombattlesim/UnitState.dart';

class UnitSelectorOverlay extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final Function(void) onToggled;
  final double min;
  final double max;
  final bowTopIsTop;

  const UnitSelectorOverlay({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 30,
    this.bowTopIsTop = true,
    required this.onToggled,
    required this.onChanged,
  });

  @override
  State<UnitSelectorOverlay> createState() => _UnitselectoroverlayState();
}

class _UnitselectoroverlayState extends State<UnitSelectorOverlay> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            startAngle: widget.bowTopIsTop ? 180 : 0,
            endAngle: widget.bowTopIsTop ? 360 : 180,
            isInversed: !widget.bowTopIsTop,
            minimum: widget.min,
            maximum: widget.max,
            showLabels: false,
            showTicks: true,
            canScaleToFit: true,
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
              color: Colors.white70,
              thickness: 20,
            ),
          ),
        ],
      ),
    );
  }
}

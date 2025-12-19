import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:warroombattlesim/UnitState.dart';

class UnitSelectorOverlay extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final VoidCallback onIncr;
  final VoidCallback onDecr;
  final Function(void) onToggled;
  final double min;
  final double max;
  final bowTopIsTop;

  UnitSelectorOverlay({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 30,
    this.bowTopIsTop = true,
    required this.onToggled,
    required this.onChanged,
    required this.onDecr,
    required this.onIncr,
  });

  @override
  State<UnitSelectorOverlay> createState() => _UnitselectoroverlayState();
}

class _UnitselectoroverlayState extends State<UnitSelectorOverlay> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      //crossAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: ElevatedButton(
            onPressed: widget.onDecr,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              padding: const EdgeInsets.all(2),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),

            child: FittedBox(child: Icon(Icons.remove, color: Colors.black)),
          ),
        ),
        Flexible(
          flex: 3,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                startAngle: widget.bowTopIsTop ? 180 : 0,
                endAngle: widget.bowTopIsTop ? 360 : 180,
                radiusFactor: 0.9,
                isInversed: !widget.bowTopIsTop,
                minimum: widget.min,
                maximum: widget.max,
                showLabels: false,
                showTicks: false,
                canScaleToFit: true,
                pointers: <GaugePointer>[
                  MarkerPointer(
                    value: widget.value,
                    enableDragging: true,
                    markerHeight: 25,
                    markerWidth: 25,
                    markerType: MarkerType.circle,
                    color: Colors.blueAccent,
                    borderWidth: 3,
                    borderColor: Colors.black,
                    onValueChanged: (v) {
                      widget.onChanged.call(v);
                    },
                  ),
                ],
                axisLineStyle: AxisLineStyle(
                  cornerStyle: CornerStyle.bothCurve,
                  color: Colors.blueGrey,
                  thickness: 20,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 1,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              padding: const EdgeInsets.all(2),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: widget.onIncr,
            child: FittedBox(child: Icon(Icons.add, color: Colors.black)),
          ),
        ),
      ],
    );
  }
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:warroombattlesim/UnitIdentification.dart';
import 'package:warroombattlesim/UnitSelectorOverlay.dart';
import 'package:warroombattlesim/UnitState.dart';
import 'package:warroombattlesim/utils.dart' as wr_utils;

class UnitSelector extends StatefulWidget {
  UnitSelector({
    super.key,
    required this.state,
    required this.unitIdentification,
  });
  UnitIdentification unitIdentification;
  UnitState state;

  @override
  State<StatefulWidget> createState() => _UniteSelectorState();

  int getUnitCount() {
    return state.unitCount[unitIdentification.columnIndex][unitIdentification
        .unitIdx];
  }

  int getUnitCountStance0() {
    return state.stanceDef[unitIdentification.columnIndex][unitIdentification
        .unitIdx];
  }

  int getUnitCountStance1() {
    return state.stanceOff[unitIdentification.columnIndex][unitIdentification
        .unitIdx];
  }

  double getStanceFraction() {
    return state.stanceFractions[unitIdentification
        .columnIndex][unitIdentification.unitIdx];
  }
}

class _UniteSelectorState extends State<UnitSelector> {
  final LayerLink _link = LayerLink();
  var _overlayController = OverlayPortalController();

  ButtonStyle get_button_style(double radius, bool isLand, bool isAir) {
    if (isAir) {
      return ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        shape: CircleBorder(),
        padding: EdgeInsets.zero,
      );
    } else if (isLand) {
      return ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius / 8), // <--add this
        ),
        padding: EdgeInsets.zero,
      );
    } else {
      return ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(radius / 6), // <--add this
        ),
        padding: EdgeInsets.zero,
      );
    }
  }

  void toggle() {
    _overlayController.toggle();
  }

  @override
  Widget build(BuildContext context) {
    List<Image> icons = wr_utils.getStanceIcons(widget.unitIdentification);
    return Column(
      children: [
        Flexible(
          flex: 1,
          child: Text(
            widget.getUnitCount().toString(),
            style: TextStyle(
              background: Paint()
                ..color = Colors.white24
                ..strokeWidth = 20
                ..strokeJoin = StrokeJoin.round
                ..strokeCap = StrokeCap.round
                ..style = PaintingStyle.stroke,
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: CompositedTransformTarget(
            link: _link,
            child: LayoutBuilder(
              builder: (context, BoxConstraints constraints) {
                final borderRadius = constraints.maxWidth;
                return ElevatedButton(
                  clipBehavior: Clip.antiAlias,
                  onPressed: _overlayController.toggle,
                  style: get_button_style(
                    borderRadius,
                    widget.unitIdentification.isLand,
                    widget.unitIdentification.isAir,
                  ),
                  child: wr_utils.getUnitIcon(widget.unitIdentification),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Align(
                  alignment: AlignmentGeometry.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      icons[0],
                      Text(widget.getUnitCountStance0().toString()),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: AlignmentGeometry.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      icons[1],
                      Text(widget.getUnitCountStance1().toString()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:wrbattlesim/UnitIdentification.dart';
import 'package:wrbattlesim/UnitSelectorOverlay.dart';
import 'package:wrbattlesim/UnitState.dart';
import 'package:wrbattlesim/utils.dart' as wr_utils;

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
          borderRadius: BorderRadius.circular(radius / 8),
        ),
        padding: EdgeInsets.zero,
      );
    } else {
      return ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(radius / 4),
        ),
        padding: EdgeInsets.zero,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> icons = wr_utils.getStanceIcons(
      context,
      widget.unitIdentification,
    );

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      icons[0],
                      Text(widget.getUnitCountStance0().toString()),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
        Flexible(
          flex: 2,
          child: LayoutBuilder(
            builder: (context, BoxConstraints constraints) {
              final borderRadius = constraints.maxHeight;
              return IgnorePointer(
                child: ElevatedButton(
                  clipBehavior: Clip.antiAlias,
                  onPressed: () => {},
                  style: get_button_style(
                    borderRadius,
                    widget.unitIdentification.isLand,
                    widget.unitIdentification.isAir,
                  ),
                  child: wr_utils.getUnitIcon(widget.unitIdentification),
                ),
              );
            },
          ),
        ),
        Flexible(flex: 1, child: Text(widget.getUnitCount().toString())),
      ],
    );
  }
}

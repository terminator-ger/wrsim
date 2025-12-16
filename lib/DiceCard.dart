import 'package:flutter/material.dart';
import 'package:warroombattlesim/UnitIdentification.dart';
import 'package:warroombattlesim/UnitSelector.dart';
import 'package:warroombattlesim/UnitSelectorOverlay.dart';
import 'package:warroombattlesim/UnitState.dart';
import 'package:warroombattlesim/utils.dart' as wr_utils;

class DiceCard extends StatefulWidget {
  final Color background;
  final Widget diceLeft;
  final Widget diceRight;
  final bool hasOverlay;
  final bool hasUnitIcon;

  DiceCard({
    super.key,
    required this.hasUnitIcon,
    required this.hasOverlay,
    required this.background,
    required this.diceLeft,
    required this.diceRight,
    required this.state,
    required this.onUnitCountChanged,
    required this.unitIdentification,
    required this.onUnitCountIncreased,
    required this.onUnitCountDecreased,
    required this.onStanceFractionChanged,
    required this.onStanceFractionIncreased,
    required this.onStanceFractionDecreased,
  });

  final UnitIdentification unitIdentification;
  UnitState state;
  ValueChanged<int> onUnitCountChanged;
  ValueChanged<double> onStanceFractionChanged;
  VoidCallback onUnitCountDecreased;
  VoidCallback onUnitCountIncreased;
  VoidCallback onStanceFractionDecreased;
  VoidCallback onStanceFractionIncreased;

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

  @override
  State<DiceCard> createState() => _DiceCardState();
}

class _DiceCardState extends State<DiceCard> {
  Widget getCenterItem() {
    return UnitSelector(
      state: widget.state,
      unitIdentification: widget.unitIdentification,
    );
  }

  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  var _overlayController = OverlayPortalController();

  void _showOverlay(double containerWidth, double containerHeight) {
    _entry?.remove();

    _entry = OverlayEntry(
      builder: (_) => CompositedTransformFollower(
        link: _link,
        targetAnchor: Alignment.center,
        followerAnchor: Alignment.center,
        child: AbsorbPointer(
          absorbing: false,
          child: GestureDetector(
            onTap: _overlayController.toggle,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: containerWidth,
                  child: Visibility(
                    visible: widget.getUnitCount() > 0,
                    child: Visibility(
                      visible:
                          //deactivate for submarines
                          !(widget.unitIdentification.unitIdx == 0 &&
                              !widget.unitIdentification.isAir &&
                              !widget.unitIdentification.isLand),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Flexible(child: icons[0]),
                          UnitSelectorOverlay(
                            value: widget.getStanceFraction(),
                            min: 0.0,
                            max: 1.0,
                            onToggled: (void none) {
                              _overlayController.toggle();
                              return;
                            },
                            onChanged: (double val) {
                              widget.onStanceFractionChanged(val);
                            },
                            onIncr: () {
                              widget.onStanceFractionIncreased();
                            },
                            onDecr: () {
                              widget.onStanceFractionDecreased();
                            },

                            bowTopIsTop: true,
                          ),
                          //Flexible(child: icons[1]),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: containerWidth,
                  child: UnitSelectorOverlay(
                    value: widget.getUnitCount().toDouble(),
                    onToggled: (void none) {
                      _overlayController.toggle();
                      return;
                    },
                    onChanged: (double val) {
                      widget.onUnitCountChanged(val.toInt());
                    },
                    onDecr: widget.onUnitCountDecreased,
                    onIncr: widget.onUnitCountIncreased,
                    bowTopIsTop: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.background,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 50, maxHeight: 100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CompositedTransformTarget(
                link: _link,
                child: GestureDetector(
                  onTap: () =>
                      _showOverlay(constraints.maxWidth, constraints.maxHeight),
                  child: Column(
                    children: [
                      Flexible(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Flexible(flex: 1, child: widget.diceLeft),
                            widget.hasUnitIcon
                                ? Flexible(flex: 1, child: getCenterItem())
                                : Container(),
                            Flexible(flex: 1, child: widget.diceRight),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }
}

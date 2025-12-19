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
  OverlayEntry? _background;
  final _overlayController = OverlayPortalController();

  void _toggleOverlay(double containerWidth, double containerHeight) {
    if (!(_entry == null)) {
      _entry?.remove();
      _entry = null;
      _background?.remove();
      _background = null;
    } else {
      _entry = OverlayEntry(
        builder: (_) => CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.center,
          followerAnchor: Alignment.center,
          child: GestureDetector(
            onTap: _overlayController.toggle,
            child: AbsorbPointer(
              absorbing: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: containerWidth,
                    height: containerHeight * 1.5,
                    child: Visibility(
                      visible: widget.getUnitCount() > 0,
                      child: Visibility(
                        visible:
                            //deactivate for submarines
                            !(widget.unitIdentification.unitIdx == 0 &&
                                !widget.unitIdentification.isAir &&
                                !widget.unitIdentification.isLand),
                        child: UnitSelectorOverlay(
                          value: widget.getStanceFraction(),
                          min: 0.0,
                          max: 1.0,
                          onToggled: (void none) {
                            _overlayController.toggle();
                            return;
                          },
                          onChanged: (double val) {
                            widget.onStanceFractionChanged(val);
                            _entry?.markNeedsBuild();
                          },
                          onIncr: () {
                            widget.onStanceFractionIncreased();
                            _entry?.markNeedsBuild();
                          },
                          onDecr: () {
                            widget.onStanceFractionDecreased();
                            _entry?.markNeedsBuild();
                          },

                          bowTopIsTop: true,
                        ),

                        //Flexible(child: icons[1]),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: containerWidth,
                    height: containerHeight * 1.5,
                    child: UnitSelectorOverlay(
                      value: widget.getUnitCount().toDouble(),
                      onToggled: (void none) {
                        _overlayController.toggle();
                        return;
                      },
                      onChanged: (double val) {
                        widget.onUnitCountChanged(val.toInt());
                        _entry?.markNeedsBuild();
                      },
                      onDecr: () {
                        widget.onUnitCountDecreased();
                        _entry?.markNeedsBuild();
                      },
                      onIncr: () {
                        widget.onUnitCountIncreased();
                        _entry?.markNeedsBuild();
                      },
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
                  onTap: () => _toggleOverlay(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  ),
                  child: AbsorbPointer(
                    absorbing: true,
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

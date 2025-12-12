import 'package:flutter/material.dart';
import 'package:warroombattlesim/UnitIdentification.dart';
import 'package:warroombattlesim/UnitSelectorOverlay.dart';
import 'package:warroombattlesim/UnitState.dart';

class UnitSelector extends StatefulWidget {
  UnitSelector({
    super.key,
    //this.value = 0,
    required this.state,
    required this.onUnitCountChanged,
    required this.unitIdentification,
    required this.onStanceFractionChanged,
  });
  UnitIdentification unitIdentification;
  UnitState state;
  ValueChanged<int> onUnitCountChanged;
  ValueChanged<double> onStanceFractionChanged;

  final Map<String, List<Image>> icons = {
    "air": [
      Image.asset("resources/air.png"),
      Image.asset("resources/air.png"),
      Image.asset("resources/green_air.jpg"),
      Image.asset("resources/red_air.jpg", fit: BoxFit.cover),
      Image.asset("resources/air.png", fit: BoxFit.cover),
    ],
    "lnd": [
      Image.asset("resources/yellow_ground.jpg", fit: BoxFit.cover),
      Image.asset("resources/blue_ground.jpg", fit: BoxFit.cover),
      Image.asset("resources/green_ground.jpg", fit: BoxFit.cover),
      Image.asset("resources/land.png"),
      Image.asset("resources/land.png"),
    ],
    "sea": [
      Image.asset("resources/yellow_sea.jpg", fit: BoxFit.cover),
      Image.asset("resources/blue_sea.jpg", fit: BoxFit.cover),
      Image.asset("resources/green_sea.jpg", fit: BoxFit.cover),
      Image.asset("resources/red_sea.jpg", fit: BoxFit.cover),
      Image.asset("resources/land.png"),
    ],
  };

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

  Image getUnitIcon() {
    late String key;
    if (widget.unitIdentification.isAir) {
      key = "air";
    } else if (widget.unitIdentification.isLand) {
      key = "lnd";
    } else {
      key = "sea";
    }
    return widget.icons[key]!.elementAt(widget.unitIdentification.unitIdx);
  }

  List<Image> getStanceIcons() {
    // air
    if (widget.unitIdentification.isAir &&
        widget.unitIdentification.unitIdx == 3) {
      return [
        Image.asset("resources/stance_air.png", fit: BoxFit.cover),
        Image.asset("resources/bomb.png", fit: BoxFit.cover),
      ];
    } else if (widget.unitIdentification.isAir &&
        widget.unitIdentification.unitIdx == 2) {
      return [
        Image.asset("resources/stance_air.png", fit: BoxFit.cover),
        Image.asset("resources/stance_ground.png", fit: BoxFit.cover),
      ];
      // land
    } else if (widget.unitIdentification.isLand &&
        widget.unitIdentification.unitIdx == 1) {
      return [
        Image.asset("resources/stance_air.png", fit: BoxFit.cover),
        Image.asset("resources/stance_ground.png", fit: BoxFit.cover),
      ];
    } else if (widget.unitIdentification.isLand) {
      return [
        Image.asset("resources/stance_def.png", fit: BoxFit.cover),
        Image.asset("resources/stance_off.png", fit: BoxFit.cover),
      ];
      // sea
    } else if (widget.unitIdentification.unitIdx == 1) {
      return [
        Image.asset("resources/escort.png", fit: BoxFit.cover),
        Image.asset("resources/stance_off.png", fit: BoxFit.cover),
      ];
    } else {
      return [
        Image.asset("resources/stance_air.png", fit: BoxFit.cover),
        Image.asset("resources/stance_off.png", fit: BoxFit.cover),
      ];
    }
  }

  Widget overlayChildBuilder(BuildContext context) {
    List<Image> icons = getStanceIcons();
    return CompositedTransformFollower(
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
                width: 300,
                height: 100,
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
                        Flexible(child: icons[0]),
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
                          bowTopIsTop: true,
                        ),
                        Flexible(child: icons[1]),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                height: 100,
                child: UnitSelectorOverlay(
                  value: widget.getUnitCount().toDouble(),
                  onToggled: (void none) {
                    _overlayController.toggle();
                    return;
                  },
                  onChanged: (double val) {
                    widget.onUnitCountChanged(val.toInt());
                  },
                  bowTopIsTop: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Align(
            alignment: AlignmentGeometry.center,
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
                    child: OverlayPortal(
                      controller: _overlayController,
                      overlayChildBuilder: overlayChildBuilder,
                      child: getUnitIcon(),
                    ),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: AlignmentGeometry.topCenter,
            child: Text(widget.getUnitCount().toString()),
          ),
          Align(
            alignment: AlignmentGeometry.bottomLeft,
            child: Text(widget.getUnitCountStance0().toString()),
          ),
          Align(
            alignment: AlignmentGeometry.bottomRight,
            child: Text(widget.getUnitCountStance1().toString()),
          ),
        ],
      ),
    );
  }
}

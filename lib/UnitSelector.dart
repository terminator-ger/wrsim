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

  double getStanceFracetion() {
    return state.stanceFractions[unitIdentification
        .columnIndex][unitIdentification.unitIdx];
  }
}

class _UniteSelectorState extends State<UnitSelector> {
  final LayerLink _link = LayerLink();
  var _overlayController = OverlayPortalController();

  ButtonStyle get_button_style(bool isLand, bool isAir) {
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
          borderRadius: BorderRadius.circular(10.0), // <--add this
        ),
        padding: EdgeInsets.zero,
      );
    } else {
      return ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // <--add this
        ),
        padding: EdgeInsets.zero,
      );
    }
  }

  void toggle() {
    _overlayController.toggle();
  }

  Image getIcon() {
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

  Widget overlayChildBuilder(BuildContext context) {
    return
    //SizedBox(
    //  height: 100,
    //  width: 50,
    //child:
    Stack(
      children: [
        CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.center,
          followerAnchor: Alignment.center,
          child: Align(
            alignment: AlignmentGeometry.topCenter,
            child: Container(
              width: 170,
              height: 170,
              child: UnitSelectorOverlay(
                value: widget.getUnitCount().toDouble(),
                onToggled: (void none) {
                  _overlayController.toggle();
                  return;
                },
                onChanged: (double val) {
                  ;
                  widget.onUnitCountChanged(val.toInt());
                },
                bowTopIsTop: true,
              ),
            ),
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.center,
          followerAnchor: Alignment.center,
          child: Align(
            alignment: AlignmentGeometry.bottomCenter,
            child: Container(
              width: 170,
              height: 170,
              child: UnitSelectorOverlay(
                value: widget.getStanceFracetion(),
                min: 0.0,
                max: 1.0,
                onToggled: (void none) {
                  _overlayController.toggle();
                  return;
                },
                onChanged: (double val) {
                  ;
                  widget.onStanceFractionChanged(val);
                },
                bowTopIsTop: false,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(widget.getUnitCount().toString()),
        //SizedBox(
        //  height: 99,
        //child:
        CompositedTransformTarget(
          link: _link,
          child: ElevatedButton(
            clipBehavior: Clip.antiAlias,
            onPressed: _overlayController.toggle,
            style: get_button_style(
              widget.unitIdentification.isLand,
              widget.unitIdentification.isAir,
            ),
            child: OverlayPortal(
              controller: _overlayController,
              overlayChildBuilder: overlayChildBuilder,
              child: getIcon(),
            ),
          ),
        ),
        //),
      ],
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wrbattlesim/UnitIdentification.dart';

Image getChartBackgroundIcon(bool isAir, bool isLand) {
  if (isAir) {
    return Image.asset('resources/air_bg.png', fit: BoxFit.contain);
  } else if (isLand) {
    return Image.asset('resources/ground_bg.png', fit: BoxFit.contain);
  } else {
    return Image.asset('resources/sea_bg.png', fit: BoxFit.contain);
  }
}

List<Widget> getStanceIcons(
  BuildContext context,
  UnitIdentification unitIdentification,
) {
  List<double> filter;
  filter = [
    //R  G   B    A  Const
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  if (Theme.of(context).brightness == Brightness.dark) {
    filter = [
      //R  G   B    A  Const
      -1, 0, 0, 0, 255, //
      0, -1, 0, 0, 255, //
      0, 0, -1, 0, 255, //
      0, 0, 0, 1, 0, //
    ];
  }
  // air
  if (unitIdentification.isAir && unitIdentification.unitIdx == 3) {
    return [
      ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: Image.asset("resources/stance_air.png", fit: BoxFit.scaleDown),
      ),
      ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: Image.asset("resources/bomb.png", fit: BoxFit.scaleDown),
      ),
    ];
  } else if (unitIdentification.isAir && unitIdentification.unitIdx == 2) {
    return [
      ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: Image.asset("resources/stance_air.png", fit: BoxFit.scaleDown),
      ),
      ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: Image.asset(
          "resources/stance_ground.png",
          fit: BoxFit.scaleDown,
        ),
      ),
    ];
    // land
  } else if (unitIdentification.isLand && unitIdentification.unitIdx == 1) {
    return [
      ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: Image.asset("resources/stance_air.png", fit: BoxFit.scaleDown),
      ),
      ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: Image.asset(
          "resources/stance_ground.png",
          fit: BoxFit.scaleDown,
        ),
      ),
    ];
  } else if (unitIdentification.isLand) {
    return [
      ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: Image.asset("resources/stance_def.png", fit: BoxFit.scaleDown),
      ),
      ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: Image.asset("resources/stance_off.png", fit: BoxFit.scaleDown),
      ),
    ];
    // sea
  } else if (unitIdentification.unitIdx == 1) {
    return [
      ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: Image.asset("resources/escort.png", fit: BoxFit.scaleDown),
      ),
      ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: Image.asset("resources/stance_off.png", fit: BoxFit.scaleDown),
      ),
    ];
  } else {
    return [
      ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: Image.asset("resources/stance_air.png", fit: BoxFit.scaleDown),
      ),
      ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: Image.asset("resources/stance_off.png", fit: BoxFit.scaleDown),
      ),
    ];
  }
}

Card getNationFlagCard(String side) {
  return Card(
    semanticContainer: true,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    child: Image.asset("resources/$side.png", fit: BoxFit.fill),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    elevation: 5,
    margin: EdgeInsets.all(3),
  );
}

Image getUnitIcon(UnitIdentification unitIdentification) {
  late String key;
  if (unitIdentification.isAir) {
    key = "air";
  } else if (unitIdentification.isLand) {
    key = "lnd";
  } else {
    key = "sea";
  }
  if (icons.containsKey(key)) {
    return icons[key]!.elementAt(unitIdentification.unitIdx);
  }
  throw ArgumentError("");
}

final Map<String, List<Image>> icons = {
  "air": [
    Image.asset("resources/air.png"),
    Image.asset("resources/air.png"),
    Image.asset("resources/green_air.jpg"),
    Image.asset("resources/red_air.jpg", fit: BoxFit.contain),
    Image.asset("resources/air.png", fit: BoxFit.contain),
  ],
  "lnd": [
    Image.asset("resources/yellow_ground.jpg", fit: BoxFit.contain),
    Image.asset("resources/blue_ground.jpg", fit: BoxFit.contain),
    Image.asset("resources/green_ground.jpg", fit: BoxFit.contain),
    Image.asset("resources/land.png"),
    Image.asset("resources/land.png"),
  ],
  "sea": [
    Image.asset("resources/yellow_sea.jpg", fit: BoxFit.contain),
    Image.asset("resources/blue_sea.jpg", fit: BoxFit.contain),
    Image.asset("resources/green_sea.jpg", fit: BoxFit.contain),
    Image.asset("resources/red_sea.jpg", fit: BoxFit.contain),
    Image.asset("resources/land.png"),
  ],
};

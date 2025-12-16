import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:warroombattlesim/UnitIdentification.dart';

List<Image> getStanceIcons(UnitIdentification unitIdentification) {
  // air
  if (unitIdentification.isAir && unitIdentification.unitIdx == 3) {
    return [
      Image.asset("resources/stance_air.png", fit: BoxFit.contain),
      Image.asset("resources/bomb.png", fit: BoxFit.contain),
    ];
  } else if (unitIdentification.isAir && unitIdentification.unitIdx == 2) {
    return [
      Image.asset("resources/stance_air.png", fit: BoxFit.contain),
      Image.asset("resources/stance_ground.png", fit: BoxFit.contain),
    ];
    // land
  } else if (unitIdentification.isLand && unitIdentification.unitIdx == 1) {
    return [
      Image.asset("resources/stance_air.png", fit: BoxFit.contain),
      Image.asset("resources/stance_ground.png", fit: BoxFit.contain),
    ];
  } else if (unitIdentification.isLand) {
    return [
      Image.asset("resources/stance_def.png", fit: BoxFit.contain),
      Image.asset("resources/stance_off.png", fit: BoxFit.contain),
    ];
    // sea
  } else if (unitIdentification.unitIdx == 1) {
    return [
      Image.asset("resources/escort.png", fit: BoxFit.contain),
      Image.asset("resources/stance_off.png", fit: BoxFit.contain),
    ];
  } else {
    return [
      Image.asset("resources/stance_air.png", fit: BoxFit.contain),
      Image.asset("resources/stance_off.png", fit: BoxFit.contain),
    ];
  }
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

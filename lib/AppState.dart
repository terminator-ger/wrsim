import 'dart:math';

import 'package:flutter/material.dart';
import 'package:warroombattlesim/UnitIdentification.dart';
import 'package:warroombattlesim/UnitState.dart';
import 'package:wrdice/wrdice.dart' as wrdice;

class AppState {
  UnitState land = UnitState();
  UnitState air = UnitState();
  UnitState sea = UnitState();

  List<List<int>> diceTotal = [
    [0, 0],
    [0, 0],
  ];

  void reset() {
    land = UnitState();
    air = UnitState();
    sea = UnitState();
    diceTotal = [
      [0, 0],
      [0, 0],
    ];
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:warroombattlesim/UnitIdentification.dart';
import 'package:warroombattlesim/UnitState.dart';
import 'package:wrdice/wrdice.dart' as wrdice;

class AppState {
  late UnitState land;
  late UnitState air;
  late UnitState sea;
  late UnitState diceTotal;

  AppState() {
    reset();
  }

  void reset() {
    land = UnitState(len: 5);
    air = UnitState(len: 5);
    sea = UnitState(len: 5);
    diceTotal = UnitState(len: 1);
  }
}

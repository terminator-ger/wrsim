import 'package:warroombattlesim/UnitState.dart';

class AppState {
  UnitState land = UnitState();
  UnitState air = UnitState();
  UnitState sea = UnitState();

  List<List<int>> diceTotal = [
    [0, 0],
    [0, 0],
  ];

  void reset(){
    land = UnitState();
    air = UnitState();
    sea = UnitState();
    diceTotal = [
    [0, 0],
    [0, 0],
  ];
 
  }
}

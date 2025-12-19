class UnitState {
  final int len;

  late List<List<int>> unitCount;
  late List<List<int>> stanceOff;
  late List<List<int>> stanceDef;
  late List<List<double>> stanceFractions;
  late List<List<int>> diceVsAir;
  late List<List<int>> diceVsGround;

  UnitState({required this.len}) {
    unitCount = [List<int>.filled(len, 0), List<int>.filled(len, 0)];
    stanceOff = [List<int>.filled(len, 0), List<int>.filled(len, 0)];
    stanceDef = [List<int>.filled(len, 0), List<int>.filled(len, 0)];

    stanceFractions = [
      List<double>.filled(len, 0.0),
      List<double>.filled(len, 0.0),
    ];

    diceVsAir = [List<int>.filled(len, 0), List<int>.filled(len, 0)];

    diceVsGround = [List<int>.filled(len, 0), List<int>.filled(len, 0)];
  }
}

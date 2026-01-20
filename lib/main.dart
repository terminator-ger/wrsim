import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wrbattlesim/DiceCard.dart';
import 'package:wrbattlesim/UnitIdentification.dart';
import 'package:wrbattlesim/UnitState.dart';
import 'package:wrbattlesim/UnitSelector.dart';
import 'package:wrbattlesim/utils.dart' as wr_utils;
import 'package:wheel_picker/wheel_picker.dart';
import 'package:wrdice/wrdice.dart' as wrdice;
import 'package:wrdice/wrdice_bindings_generated.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:wrbattlesim/AppState.dart';
import "package:intl/intl.dart";
import 'UnitSelectorOverlay.dart';

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double? y;
}

enum pieKey { Allies, Axis, Draw, MutualDestruction }

class Stats {
  final Map<pieKey, (String, double)> pieData;
  final Map<pieKey, wrdice.DartStats> barData;
  Stats(this.pieData, this.barData);
}

class WarRoomApp extends StatelessWidget {
  const WarRoomApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light(useMaterial3: true),
      dark: ThemeData.dark(useMaterial3: true),
      initial: AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => MaterialApp(
        theme: theme,
        darkTheme: darkTheme,
        home: wrbattlesimApp(),
      ),
    );
  }
}

class wrbattlesimApp extends StatefulWidget {
  const wrbattlesimApp({Key? key}) : super(key: key);

  @override
  State<wrbattlesimApp> createState() => _wrbattlesimAppState();
}

const Color _colour_air = Color.fromARGB(50, 3, 167, 200);
const Color _colour_land = Color.fromARGB(50, 255, 174, 99);
const Color _blue = Color.fromARGB(255, 165, 223, 250);
const Color _red = Color.fromARGB(255, 254, 146, 146);
const List<Color> unitColors = [
  Colors.yellow,
  Colors.blue,
  Colors.green,
  Colors.red,
];

class _wrbattlesimAppState extends State<wrbattlesimApp> {
  int _selectedNavIndex = 0; // 0 = Units, 1 = Pie, 2 = Bar
  bool _isLand = true;
  bool _withBatchCap = true;
  bool _seperatePlots = false;
  late Completer<wrdice.DartSimStats> asyncResult = Completer();
  bool autoBattle = true;

  Completer<wrdice.DartSimStats> addPlotsToResult(
    Future<wrdice.DartSimStats> future,
  ) {
    final completer = Completer<wrdice.DartSimStats>();
    future
        .then((value) {
          _plot(value);
          completer.complete(future);
        })
        .catchError(completer.completeError);
    return completer;
  }

  void _plot(wrdice.DartSimStats value) {
    setState(() {
      statistics = Stats(
        {
          pieKey.Allies: ('Allies', value.br.winA * 100),
          pieKey.Axis: ('Axis', value.br.winB * 100),
          pieKey.Draw: ('Draw', value.br.draw * 100),
          pieKey.MutualDestruction: (
            'Mutual Destruction',
            value.br.death * 100,
          ),
        },
        {pieKey.Allies: value.armyA, pieKey.Axis: value.armyB},
      );
    });
  }

  Null Function(int val) updateUnitCount(UnitIdentification x) {
    return (int val) {
      _updateUnitCount(x.columnIndex, val, x.unitIdx, x.isLand, x.isAir);
      if (autoBattle) {
        _calculate();
      }
    };
  }

  Null Function() decreaseUnitCount(UnitIdentification x) {
    return () {
      UnitState state = getUnitState(x.isAir, x.isLand);
      int count = min(
        max(state.unitCount[x.columnIndex][x.unitIdx] - 1, 0),
        30,
      );
      setState(() {
        state.unitCount[x.columnIndex][x.unitIdx] = count;
      });
      _updateStance(
        x.columnIndex,
        state.stanceFractions[x.columnIndex][x.unitIdx],
        x.unitIdx,
        x.isLand,
        x.isAir,
      );
      if (autoBattle) {
        _calculate();
      }
    };
  }

  Null Function() increaseUnitCount(UnitIdentification x) {
    return () {
      UnitState state = getUnitState(x.isAir, x.isLand);
      int count = min(
        max(state.unitCount[x.columnIndex][x.unitIdx] + 1, 0),
        30,
      );
      setState(() {
        state.unitCount[x.columnIndex][x.unitIdx] = count;
      });
      _updateStance(
        x.columnIndex,
        state.stanceFractions[x.columnIndex][x.unitIdx],
        x.unitIdx,
        x.isLand,
        x.isAir,
      );
      if (autoBattle) {
        _calculate();
      }
    };
  }

  Null Function(double val) updateStance(UnitIdentification x) {
    return (double val) {
      _updateStance(x.columnIndex, val, x.unitIdx, x.isLand, x.isAir);
      if (autoBattle) {
        _calculate();
      }
    };
  }

  Null Function() decreaseStanceFraction(UnitIdentification x) {
    return () {
      UnitState unitstate = getUnitState(x.isAir, x.isLand);
      double frac = 1 / unitstate.unitCount[x.columnIndex][x.unitIdx];
      double val = unitstate.stanceFractions[x.columnIndex][x.unitIdx];
      val = max(min(val - frac, 1), 0);
      setState(() {
        unitstate.stanceFractions[x.columnIndex][x.unitIdx] = val;
      });
      unitstate.stanceDef[x.columnIndex][x.unitIdx] =
          ((1 - val) * unitstate.unitCount[x.columnIndex][x.unitIdx]).round();
      unitstate.stanceOff[x.columnIndex][x.unitIdx] =
          ((val) * unitstate.unitCount[x.columnIndex][x.unitIdx]).round();

      //update dice
      updateDice(x.columnIndex);
      if (autoBattle) {
        _calculate();
      }
    };
  }

  Null Function() increaseStanceFraction(UnitIdentification x) {
    return () {
      UnitState unitstate = getUnitState(x.isAir, x.isLand);
      double frac = 1 / unitstate.unitCount[x.columnIndex][x.unitIdx];
      double val = unitstate.stanceFractions[x.columnIndex][x.unitIdx];
      val = max(min(val + frac, 1), 0);
      setState(() {
        unitstate.stanceFractions[x.columnIndex][x.unitIdx] = val;
      });
      unitstate.stanceDef[x.columnIndex][x.unitIdx] =
          ((1 - val) * unitstate.unitCount[x.columnIndex][x.unitIdx]).round();
      unitstate.stanceOff[x.columnIndex][x.unitIdx] =
          ((val) * unitstate.unitCount[x.columnIndex][x.unitIdx]).round();

      //update dice
      updateDice(x.columnIndex);

      if (autoBattle) {
        _calculate();
      }
    };
  }

  void _updateUnitCount(
    int columnIdx,
    int val,
    int unitIdx,
    bool isLand,
    bool isAir,
  ) {
    UnitState state = getUnitState(isAir, isLand);
    setState(() {
      state.unitCount[columnIdx][unitIdx] = val;
    });
    _updateStance(
      columnIdx,
      state.stanceFractions[columnIdx][unitIdx],
      unitIdx,
      isLand,
      isAir,
    );
    if (autoBattle) {
      _calculate();
    }
  }

  UnitState getUnitState(bool isAir, bool isLand) {
    if (isAir) {
      return appState.air;
    } else if (isLand) {
      return appState.land;
    } else {
      return appState.sea;
    }
  }

  void updateDice(int columnIndex) {
    List<wrdice.DartDice> dice_list = wrdice.updateDiceWithBatchCap(
      getArmy(0),
      getArmy(1),
      _withBatchCap,
    );
    for (final (columnIdx, dice) in dice_list.indexed) {
      setState(() {
        appState.air.diceVsAir[columnIndex] = dice.air.vs_air.toList();
        appState.air.diceVsGround[columnIdx] = dice.air.vs_gnd.toList();
        appState.land.diceVsAir[columnIdx] = dice.lnd.vs_air.toList();
        appState.land.diceVsGround[columnIdx] = dice.lnd.vs_gnd.toList();
        appState.sea.diceVsAir[columnIdx] = dice.sea.vs_air.toList();
        appState.sea.diceVsGround[columnIdx] = dice.sea.vs_gnd.toList();
        appState.diceTotal.diceVsAir[columnIdx][0] = dice.total.toList()[0];
        appState.diceTotal.diceVsGround[columnIdx][0] = dice.total.toList()[1];
      });
    }
  }

  wrdice.DartArmy getArmy(int columnIndex) {
    return wrdice.DartArmy(
      appState.land.unitCount[columnIndex],
      appState.air.unitCount[columnIndex],
      appState.sea.unitCount[columnIndex],
      appState.land.stanceOff[columnIndex],
      appState.land.stanceDef[columnIndex],
      appState.air.stanceOff[columnIndex],
      appState.air.stanceDef[columnIndex],
      appState.sea.stanceOff[columnIndex],
      appState.sea.stanceDef[columnIndex],
    );
  }

  wrdice.DartArmy getArmyWithGroundSelection(int columnIndex, bool isLand) {
    if (isLand) {
      return wrdice.DartArmy(
        appState.land.unitCount[columnIndex],
        appState.air.unitCount[columnIndex],
        List<int>.filled(5, 0),
        appState.land.stanceOff[columnIndex],
        appState.land.stanceDef[columnIndex],
        appState.air.stanceOff[columnIndex],
        appState.air.stanceDef[columnIndex],
        List<int>.filled(5, 0),
        List<int>.filled(5, 0),
      );
    } else {
      return wrdice.DartArmy(
        List<int>.filled(5, 0),
        appState.air.unitCount[columnIndex],
        appState.sea.unitCount[columnIndex],
        List<int>.filled(5, 0),
        List<int>.filled(5, 0),
        appState.air.stanceOff[columnIndex],
        appState.air.stanceDef[columnIndex],
        appState.sea.stanceOff[columnIndex],
        appState.sea.stanceDef[columnIndex],
      );
    }
  }

  void _calcBattle(bool isLand) {
    wrdice.DartArmy army_a = getArmyWithGroundSelection(0, isLand);
    wrdice.DartArmy army_b = getArmyWithGroundSelection(1, isLand);
    final bool fa = true;
    final bool bc = true;
    asyncResult = addPlotsToResult(
      wrdice.runBattleAsync(army_a, army_b, fa, bc),
    );
  }

  AppState appState = AppState();

  List<List<OverlayEntry?>> _overlays_air = [
    List.generate(5, (index) {
      return null;
    }),
    List.generate(5, (index) {
      return null;
    }),
  ];

  List<List<OverlayEntry?>> _overlays_sea = [
    List.generate(5, (index) {
      return null;
    }),
    List.generate(5, (index) {
      return null;
    }),
  ];

  List<List<OverlayEntry?>> _overlays_lnd = [
    List.generate(5, (index) {
      return null;
    }),
    List.generate(5, (index) {
      return null;
    }),
  ];

  void _updateStance(
    int columnIndex,
    double value,
    int idx,
    bool isLand,
    bool isAir,
  ) {
    UnitState unitstate = getUnitState(isAir, isLand);
    setState(() {
      unitstate.stanceFractions[columnIndex][idx] = value;
    });
    unitstate.stanceDef[columnIndex][idx] =
        ((1 - value) * unitstate.unitCount[columnIndex][idx]).round();
    unitstate.stanceOff[columnIndex][idx] =
        (value * unitstate.unitCount[columnIndex][idx]).round();

    //update dice
    updateDice(columnIndex);
  }

  Stats? statistics; // results from FFI or mock

  final Image img_dice_air = Image.asset("resources/air.png");
  final Image img_dice_gnd = Image.asset("resources/land.png");

  Widget _getDiceDisplay(List<int> dice, int i, bool isAir) {
    return Stack(
      children: <Widget>[
        Center(child: isAir ? img_dice_air : img_dice_gnd),
        Center(
          child: Text.rich(
            TextSpan(
              text: dice[i].toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isAir ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitSelection(int columnIndex, int i, bool isLand, bool isAir) {
    late UnitState state = getUnitState(isAir, isLand);
    var unit = UnitIdentification(
      isAir: isAir,
      isLand: isLand,
      columnIndex: columnIndex,
      unitIdx: i,
    );

    Color background = isAir ? _colour_air : _colour_land;
    return DiceCard(
      hasUnitIcon: true,
      hasOverlay: true,
      background: background,
      diceLeft: _getDiceDisplay(state.diceVsAir[columnIndex], i, true),
      diceRight: _getDiceDisplay(state.diceVsGround[columnIndex], i, false),
      state: state,
      unitIdentification: unit,
      onUnitCountChanged: updateUnitCount(unit),
      onUnitCountDecreased: decreaseUnitCount(unit),
      onUnitCountIncreased: increaseUnitCount(unit),
      onStanceFractionChanged: updateStance(unit),
      onStanceFractionDecreased: decreaseStanceFraction(unit),
      onStanceFractionIncreased: increaseStanceFraction(unit),
    );
  }

  Widget _diceCard(
    Widget diceLeft,
    Widget diceRight,
    Widget centerItem, {
    Color? background,
  }) {
    return Card(
      color: background,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 50, maxHeight: 100),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(flex: 1, child: diceLeft),
                  Flexible(flex: 1, child: centerItem),
                  Flexible(flex: 1, child: diceRight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnContent(int columnIndex, bool isLand, Color color) {
    List<Widget> units_air = List.generate(2, (i) {
      return _buildUnitSelection(columnIndex, i + 2, isLand, true);
    });
    List<Widget> units_ground = List.generate(isLand ? 3 : 4, (i) {
      return _buildUnitSelection(columnIndex, i, isLand, false);
    });
    return Expanded(
      child: ListView(
        padding: EdgeInsets.only(bottom: 100, top: 100),
        scrollDirection: Axis.vertical,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [units_air, units_ground].expand((x) => x).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnBarPlot(int columnIndex, bool isLand, Color color) {
    List<bool> isAir = [true, false];
    List<Widget> unitGraphs = [];
    if (!_seperatePlots) {
      for (bool _air in isAir) {
        List<int> indexes = [];
        for (int i = 0; i < 5; i++) {
          if (_hasUnitsForPlot(columnIndex, i, isLand, _air)) {
            indexes.add(i);
          }
        }
        if (indexes.length > 0) {
          unitGraphs.add(_buildUnitBarPlot(columnIndex, indexes, isLand, _air));
        }
      }
    } else {
      for (bool _air in isAir) {
        for (int i = 0; i < 5; i++) {
          if (_hasUnitsForPlot(columnIndex, i, isLand, _air)) {
            unitGraphs.add(_buildUnitBarPlot(columnIndex, [i], isLand, _air));
          }
        }
      }
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 5,
                  runSpacing: 3,
                  children: unitGraphs,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSegmentColor(int index) {
    List<Color> colors = [
      _blue,
      _red,
      const Color.fromARGB(255, 197, 197, 196),
      Colors.black45,
    ];
    return colors[index];
  }

  Widget _buildChartLegend() {
    final legendItems = [
      ('Allies', _blue),
      ('Axis', _red),
      ('Draw', const Color.fromARGB(255, 197, 197, 196)),
      ('Mutual Destruction', Colors.black45),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16.0,
        children: legendItems
            .map(
              (item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: item.$2,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(item.$1),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildUnitsPage() {
    Widget lndSeaSelector = Padding(
      padding: const EdgeInsets.all(8),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: true, label: Text('Land')),
          ButtonSegment(value: false, label: Text('Sea')),
        ],
        showSelectedIcon: false,
        selected: {_isLand},
        onSelectionChanged: (v) {
          appState.reset();
          setState(() {
            _isLand = v.first;
          });
          updateDice(0);
          updateDice(1);
          _calcBattle(_isLand);
        },
      ),
    );
    Widget batchCapSelector = Padding(
      padding: const EdgeInsets.all(8),
      child: SegmentedButton<bool>(
        segments: const [ButtonSegment(value: true, label: Text('Batch Cap'))],
        selected: {_withBatchCap},
        showSelectedIcon: false,
        emptySelectionAllowed: true,
        onSelectionChanged: (v) {
          if (v.isEmpty) {
            setState(() {
              _withBatchCap = false;
            });
          } else {
            setState(() {
              _withBatchCap = true;
            });
          }
          updateDice(0);
          updateDice(1);
          _calcBattle(_isLand);
        },
      ),
    );

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [lndSeaSelector, batchCapSelector],
        ),
        Builder(
          builder: (context) {
            if (statistics != null) {
              List<ChartData> data = statistics!.pieData.entries
                  .map((v) => ChartData("Winrate", v.value.$2 / 100))
                  .toList();

              return Flexible(
                flex: 10,
                child: Column(
                  children: [
                    Flexible(
                      child: SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        primaryXAxis: CategoryAxis(isVisible: false),
                        primaryYAxis: NumericAxis(
                          isVisible: false,
                          numberFormat: NumberFormat.percentPattern(),
                        ),
                        series: <CartesianSeries>[
                          StackedBar100Series<ChartData, String>(
                            width: 1.0,
                            spacing: 0,
                            dataSource: data,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            pointColorMapper: (ChartData data, int index) =>
                                _getSegmentColor(
                                  index,
                                ), // Use a helper function
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              showZeroValue: false,
                              labelAlignment: ChartDataLabelAlignment.middle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildChartLegend(),
                  ],
                ),
              );
            } else {
              return Flexible(
                flex: 10,
                child: Column(
                  children: [
                    Flexible(
                      child: SfCartesianChart(
                        legend: Legend(isVisible: true),
                        primaryXAxis: CategoryAxis(isVisible: false),
                        primaryYAxis: NumericAxis(
                          isVisible: false,
                          numberFormat: NumberFormat.percentPattern(),
                        ),
                        series: <CartesianSeries>[
                          StackedBar100Series<ChartData, String>(
                            width: 1.0,
                            spacing: 0,
                            dataSource: [
                              ChartData("Winrate", 0.0),
                              ChartData("Winrate", 0.0),
                            ],
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            pointColorMapper: (ChartData data, int index) =>
                                _getSegmentColor(
                                  index,
                                ), // Use a helper function
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              showZeroValue: false,
                              labelAlignment: ChartDataLabelAlignment.middle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildChartLegend(),
                  ],
                ),
              );
            }
          },
        ),
        // Switch Land / Sea
        Expanded(
          flex: 80,
          child: Row(
            children: [
              Flexible(
                child: Column(
                  children: [
                    _diceCard(
                      _getDiceDisplay(appState.diceTotal.diceVsAir[0], 0, true),
                      _getDiceDisplay(
                        appState.diceTotal.diceVsGround[0],
                        0,
                        false,
                      ),
                      wr_utils.getNationFlagCard("allies"),
                      background: _blue,
                    ),
                    _buildColumnContent(0, _isLand, _blue),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  children: [
                    _diceCard(
                      _getDiceDisplay(appState.diceTotal.diceVsAir[1], 0, true),
                      _getDiceDisplay(
                        appState.diceTotal.diceVsGround[1],
                        0,
                        false,
                      ),
                      wr_utils.getNationFlagCard("axis"),
                      background: _red,
                    ),
                    _buildColumnContent(1, _isLand, _red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _calculate() async {
    // Replace with your real FFI call
    _calcBattle(_isLand);
  }

  bool _hasUnitsForPlot(int columnIndex, int idx, bool isLand, bool isAir) {
    final stats = _getUnitStats(columnIndex, isLand, isAir);
    final units = _getUnitCount(columnIndex, idx, isLand, isAir);
    return (units > 0 && stats[idx].size > 0);
  }

  int _getUnitCount(int columnIndex, int idx, bool isLand, bool isAir) {
    if (isAir) {
      return appState.air.unitCount[columnIndex][idx];
    } else if (isLand) {
      return appState.land.unitCount[columnIndex][idx];
    } else {
      return appState.sea.unitCount[columnIndex][idx];
    }
  }

  List<wrdice.DartSurvived> _getUnitStats(
    int columnIndex,
    bool isLand,
    bool isAir,
  ) {
    late pieKey pk;
    if (columnIndex == 0) {
      pk = pieKey.Allies;
    } else if (columnIndex == 1) {
      pk = pieKey.Axis;
    }
    late List<wrdice.DartSurvived> barData;
    if (isAir) {
      barData = statistics!.barData[pk]!.air;
    } else if (isLand) {
      barData = statistics!.barData[pk]!.land;
    } else {
      barData = statistics!.barData[pk]!.sea;
    }
    return barData;
  }

  Widget _buildUnitBarPlot(
    int columnIndex,
    List<int> indexes,
    bool isLand,
    bool isAir,
  ) {
    late List<wrdice.DartSurvived> barData = _getUnitStats(
      columnIndex,
      isLand,
      isAir,
    );
    SplayTreeMap<int, BarChartGroupData> barroddata =
        SplayTreeMap<int, BarChartGroupData>();
    for (int i in indexes) {
      for (int idx = 0; idx < barData[i].size; idx++) {
        if (barData[i].count[idx] > 0 && barData[i].odds[idx] > 0.01) {
          if (barroddata.containsKey(idx)) {
            barroddata[idx]!.barRods.add(
              BarChartRodData(toY: barData[i].odds[idx], color: unitColors[i]),
            );
            // add rod
          } else {
            barroddata[idx] = BarChartGroupData(
              x: idx,
              showingTooltipIndicators: [],
              barRods: [
                BarChartRodData(
                  toY: barData[i].odds[idx],
                  color: unitColors[i],
                ),
              ],
            );
          }
        }
      }
    }

    return SizedBox(
      height: 250, // Set a fixed height for the chart
      child: Card(
        color: isAir ? _colour_air : _colour_land,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.75,
                  heightFactor: 0.75,
                  child: Opacity(
                    opacity: 0.2,
                    child: wr_utils.getChartBackgroundIcon(isAir, isLand),
                  ),
                ),
              ),
              BarChart(
                BarChartData(
                  maxY: 1.0,
                  //minY: 0.05,
                  //alignment: BarChartAlignment.spaceEvenly,
                  //groupsSpace: 16,
                  gridData: FlGridData(
                    drawHorizontalLine: true,
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 25,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                  ),

                  barGroups: barroddata.values.toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (!asyncResult.isCompleted) {
      return const Center(child: Text("No data yet. Please calculate."));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Seperate plots')),
            ],
            selected: {_seperatePlots},
            showSelectedIcon: false,
            emptySelectionAllowed: true,
            onSelectionChanged: (v) {
              if (v.isEmpty) {
                setState(() {
                  _seperatePlots = false;
                });
              } else {
                setState(() {
                  _seperatePlots = true;
                });
              }
            },
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _diceCard(
                      _getDiceDisplay(appState.diceTotal.diceVsAir[0], 0, true),
                      _getDiceDisplay(
                        appState.diceTotal.diceVsGround[0],
                        0,
                        false,
                      ),
                      wr_utils.getNationFlagCard("allies"),
                      background: _blue,
                    ),
                    _buildColumnBarPlot(0, _isLand, _blue),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _diceCard(
                      _getDiceDisplay(appState.diceTotal.diceVsAir[1], 0, true),
                      _getDiceDisplay(
                        appState.diceTotal.diceVsGround[1],
                        0,
                        false,
                      ),
                      wr_utils.getNationFlagCard("axis"),
                      background: _red,
                    ),
                    _buildColumnBarPlot(1, _isLand, _red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildUnitsPage();
      case 1:
        return _buildBarChart();
      default:
        return const SizedBox();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      AdaptiveTheme.of(context).setSystem();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Units & Statistics")),
      body: SafeArea(child: _buildCurrentPage()),
      floatingActionButton: _selectedNavIndex == 0 && !autoBattle
          ? FloatingActionButton(
              onPressed: _calculate,
              child: const Icon(Symbols.casino_sharp),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "Units"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Statistics",
          ),
        ],
        onTap: (i) => setState(() => _selectedNavIndex = i),
      ),
    );
  }
}

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('FlutterErrorDetails: $details');
  };
  runApp(WarRoomApp());
}

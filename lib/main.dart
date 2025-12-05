import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:warroombattlesim/UnitIdentification.dart';
import 'package:warroombattlesim/UnitState.dart';
import 'package:warroombattlesim/UnitSelector.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:wrdice/wrdice.dart' as wrdice;
import 'package:wrdice/wrdice_bindings_generated.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:warroombattlesim/AppState.dart';

import 'UnitSelectorOverlay.dart';

enum pieKey { Blue, Red, Draw, MutualDestruction }

class Stats {
  final Map<pieKey, (String, double)> pieData;
  final Map<pieKey, wrdice.DartStats> barData;
  Stats(this.pieData, this.barData);
}

class WarRoomBattleSimApp extends StatefulWidget {
  const WarRoomBattleSimApp({Key? key}) : super(key: key);

  @override
  State<WarRoomBattleSimApp> createState() => _WarRoomBattleSimAppState();
}

const Color _blue = Color.fromARGB(255, 165, 223, 250);
const Color _red = Color.fromARGB(255, 254, 146, 146);
const List<Color> unitColors = [
  Colors.yellow,
  Colors.blue,
  Colors.green,
  Colors.red,
];

class _WarRoomBattleSimAppState extends State<WarRoomBattleSimApp> {
  int _selectedNavIndex = 0; // 0 = Units, 1 = Pie, 2 = Bar
  bool _isLand = true;
  bool _withBatchCap = true;
  late Completer<wrdice.DartSimStats> asyncResult = Completer();

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
          pieKey.Blue: ('Blue', value.br.winA * 100),
          pieKey.Red: ('Red', value.br.winB * 100),
          pieKey.Draw: ('Draw', value.br.draw * 100),
          pieKey.MutualDestruction: (
            'Mutual Destruction',
            value.br.death * 100,
          ),
        },
        {pieKey.Blue: value.armyA, pieKey.Red: value.armyB},
      );
    });
  }

  Null Function(int val) updateUnitCount(UnitIdentification x) {
    return (int val) {
      _updateUnitCount(x.columnIndex, val, x.unitIdx, x.isAir, x.isLand);
    };
  }

  Null Function(double val) updateStance(UnitIdentification x) {
    return (double val) {
      _updateStance(x.columnIndex, val, x.unitIdx, x.isAir, x.isLand);
    };
  }

  void _updateUnitCount(
    int columnIdx,
    int val,
    int unitIdx,
    bool isAir,
    bool isLand,
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
      });
      setState(() {
        appState.air.diceVsGround[columnIdx] = dice.air.vs_gnd.toList();
      });
      setState(() {
        appState.land.diceVsAir[columnIdx] = dice.lnd.vs_air.toList();
      });
      setState(() {
        appState.land.diceVsGround[columnIdx] = dice.lnd.vs_gnd.toList();
      });
      setState(() {
        appState.sea.diceVsAir[columnIdx] = dice.sea.vs_air.toList();
      });
      setState(() {
        appState.sea.diceVsGround[columnIdx] = dice.sea.vs_gnd.toList();
      });
      setState(() {
        appState.diceTotal[columnIdx] = dice.total.toList();
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

  final int offset_air = 2;

  void _updateStance(
    int columnIndex,
    double value,
    int idx,
    bool isLand,
    bool isAir,
  ) {
    if (isAir) {
      setState(() {
        appState.air.stanceFractions[columnIndex][idx] = value;
      });
      appState.air.stanceDef[columnIndex][idx] =
          ((1 - value) * appState.air.unitCount[columnIndex][idx]).round();
      appState.air.stanceOff[columnIndex][idx] =
          (value * appState.air.unitCount[columnIndex][idx]).round();
    } else {
      if (isLand) {
        setState(() {
          appState.land.stanceFractions[columnIndex][idx] = value;
        });
        appState.land.stanceDef[columnIndex][idx] =
            ((1 - value) * appState.land.unitCount[columnIndex][idx]).round();
        appState.land.stanceOff[columnIndex][idx] =
            (value * appState.land.unitCount[columnIndex][idx]).round();
      } else {
        setState(() {
          appState.sea.stanceFractions[columnIndex][idx] = value;
        });
        appState.sea.stanceDef[columnIndex][idx] =
            ((1 - value) * appState.sea.unitCount[columnIndex][idx]).round();
        appState.sea.stanceOff[columnIndex][idx] =
            (value * appState.sea.unitCount[columnIndex][idx]).round();
      }
    }
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

    Widget centerItem = UnitSelector(
      state: state,
      onUnitCountChanged: updateUnitCount(unit),
      onStanceFractionChanged: updateStance(unit),
      unitIdentification: unit,
    );

    Widget bottomItem = Visibility(
      visible: state.unitCount[columnIndex][i] > 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(state.stanceDef[columnIndex][i].toString()),
          Flexible(
            child: Slider(
              value: state.stanceFractions[columnIndex][i],
              min: 0.0,
              max: 1.0,
              divisions: state.unitCount[columnIndex][i] > 0
                  ? state.unitCount[columnIndex][i]
                  : 100,
              onChanged: (double value) =>
                  _updateStance(columnIndex, value, i, isLand, isAir),
            ),
          ),
          Text(state.stanceOff[columnIndex][i].toString()),
        ],
      ),
    );

    Color background = isAir
        ? const Color.fromARGB(50, 3, 167, 200)
        : const Color.fromARGB(50, 255, 174, 99);

    return _diceCard(
      background,
      _getDiceDisplay(state.diceVsAir[columnIndex], i, true),
      _getDiceDisplay(state.diceVsGround[columnIndex], i, false),
      centerItem,
      bottomItem,
    );

    @override
    Widget build(BuildContext context) {
      // TODO: implement build
      throw UnimplementedError();
    }
  }

  Widget _diceCard(
    Color background,
    Widget dice_left,
    Widget dice_right,
    Widget centerItem, [
    Widget? bottomItem,
  ]) {
    return Card(
      color: background,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 50, maxHeight: 100),
          child: Column(
            children: [
              Flexible(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(flex: 1, child: dice_left),
                    Flexible(flex: 2, child: centerItem),
                    Flexible(flex: 1, child: dice_right),
                  ],
                ),
              ),
              if (bottomItem != null) ...[Flexible(flex: 1, child: bottomItem)],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumnContent(int columnIndex, bool isLand, Color color) {
    List<Widget> units_air = List.generate(2, (i) {
      return _buildUnitSelection(columnIndex, i + offset_air, isLand, true);
    });
    List<Widget> units_ground = List.generate(isLand ? 3 : 4, (i) {
      return _buildUnitSelection(columnIndex, i, isLand, false);
    });
    return Expanded(
      child:
          //Card(
          //  color: color,
          //  margin: const EdgeInsets.all(8),
          //  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //  child: Padding(
          //    padding: const EdgeInsets.all(10),
          //    child:
          ListView(
            //shrinkWrap: true,
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
    //  ),
    //);
  }

  Widget _buildColumnBarPlot(int columnIndex, bool isLand, Color color) {
    List<bool> isAir = [true, false];
    List<Padding> unitGraphs = [];
    for (bool _air in isAir) {
      for (int i = 0; i < 5; i++) {
        if (_hasUnitsForPlot(columnIndex, i, isLand, _air)) {
          unitGraphs.add(_buildUnitBarPlot(columnIndex, i, isLand, _air));
        }
      }
    }

    return Expanded(
      child: Card(
        color: color,
        margin: const EdgeInsets.all(3),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        selected: {_isLand},
        onSelectionChanged: (v) {
          appState.reset;
          setState(() {
            _isLand = v.first;
          });
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

        // Switch Land / Sea
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Column(
                  children: [
                    _diceCard(
                      Colors.blue,
                      _getDiceDisplay(appState.diceTotal[0], 0, true),
                      _getDiceDisplay(appState.diceTotal[0], 1, false),
                      Text("BlueFor"),
                    ),
                    _buildColumnContent(0, _isLand, _blue),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  children: [
                    _diceCard(
                      Colors.red,
                      _getDiceDisplay(appState.diceTotal[1], 0, true),
                      _getDiceDisplay(appState.diceTotal[1], 1, false),
                      Text("RedFor"),
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

  Widget _buildPieChart() {
    if (!asyncResult.isCompleted) {
      return const Center(child: Text("No data yet. Please calculate."));
    }
    Map<pieKey, Color> colors = {
      pieKey.Blue: _blue,
      pieKey.Red: _red,
      pieKey.Draw: Colors.amberAccent,
      pieKey.MutualDestruction: Colors.brown,
    };
    return Padding(
      padding: const EdgeInsets.all(24),
      child: PieChart(
        PieChartData(
          sections: statistics!.pieData.entries
              .map(
                (e) => PieChartSectionData(
                  value: e.value.$2,
                  title: "${e.value.$1}\n${e.value.$2.toStringAsFixed(2)}%",
                  radius: 80,
                  color: colors[e.key],
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
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
      pk = pieKey.Blue;
    } else if (columnIndex == 1) {
      pk = pieKey.Red;
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

  Padding _buildUnitBarPlot(int columnIndex, int i, bool isLand, bool isAir) {
    late List<wrdice.DartSurvived> barData = _getUnitStats(
      columnIndex,
      isLand,
      isAir,
    );
    late List<BarChartGroupData> barroddata = [];
    for (int idx = 0; idx < barData[i].size; idx++) {
      if (barData[i].count[idx] > 0) {
        barroddata.add(
          BarChartGroupData(
            x: idx,
            showingTooltipIndicators: [],
            barRods: [
              BarChartRodData(toY: barData[i].odds[idx], color: unitColors[i]),
            ],
          ),
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
        height: 250, // Set a fixed height for the chart
        child: BarChart(
          BarChartData(
            maxY: 1.0,
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
                sideTitles: SideTitles(showTitles: true, reservedSize: 25),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 30),
              ),
            ),
            barGroups: barroddata,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    if (!asyncResult.isCompleted) {
      return const Center(child: Text("No data yet. Please calculate."));
    }

    return Expanded(
      child: Row(
        children: [
          _buildColumnBarPlot(0, _isLand, _blue),
          _buildColumnBarPlot(1, _isLand, _red),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildUnitsPage();
      case 1:
        return _buildPieChart();
      case 2:
        return _buildBarChart();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Units & Statistics")),
      body: SafeArea(child: _buildCurrentPage()),
      floatingActionButton: _selectedNavIndex == 0
          ? FloatingActionButton(
              onPressed: _calculate,
              child: const Icon(Symbols.casino_sharp),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.category), label: "Units"),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "Pie"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Bar"),
        ],
        onTap: (i) => setState(() => _selectedNavIndex = i),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: WarRoomBattleSimApp()));
}

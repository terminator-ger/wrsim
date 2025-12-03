import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:wrdice/wrdice.dart' as wrdice;
import 'package:wrdice/wrdice_bindings_generated.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

enum pieKey { Blue, Red, Draw, MutualDestruction }

class Stats {
  final Map<pieKey, (String, double)> pieData;
  final Map<pieKey, wrdice.DartStats> barData;
  Stats(this.pieData, this.barData);
}

class LandSeaStatsApp extends StatefulWidget {
  const LandSeaStatsApp({Key? key}) : super(key: key);

  @override
  State<LandSeaStatsApp> createState() => _LandSeaStatsAppState();
}

const Color _blue = Color.fromARGB(255, 165, 223, 250);
const Color _red = Color.fromARGB(255, 254, 146, 146);
const List<Color> unitColors = [
  Colors.yellow,
  Colors.blue,
  Colors.green,
  Colors.red,
];

class _LandSeaStatsAppState extends State<LandSeaStatsApp> {
  int _selectedNavIndex = 0; // 0 = Units, 1 = Pie, 2 = Bar
  bool _isLand = true;
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

  void updateDice(int columnIndex) {
    List<wrdice.DartDice> dice_list = wrdice.updateDiceWithBatchCap(
      getArmy(0),
      getArmy(1),
      true,
    );
    for (final (columnIdx, dice) in dice_list.indexed) {
      setState(() {
        airDiceVsAir[columnIdx] = dice.air.vs_air.toList();
      });
      setState(() {
        airDiceVsGround[columnIdx] = dice.air.vs_gnd.toList();
      });
      setState(() {
        landDiceVsAir[columnIdx] = dice.lnd.vs_air.toList();
      });
      setState(() {
        landDiceVsGround[columnIdx] = dice.lnd.vs_gnd.toList();
      });
      setState(() {
        seaDiceVsAir[columnIdx] = dice.sea.vs_air.toList();
      });
      setState(() {
        seaDiceVsGround[columnIdx] = dice.sea.vs_gnd.toList();
      });
      setState(() {
        diceTotal[columnIdx] = dice.total.toList();
      });
    }
  }

  wrdice.DartArmy getArmy(int columnIndex) {
    return wrdice.DartArmy(
      landIconValues[columnIndex],
      airIconValues[columnIndex],
      seaIconValues[columnIndex],
      landIconStanceOff[columnIndex],
      landIconStanceDef[columnIndex],
      airIconStanceOff[columnIndex],
      airIconStanceDef[columnIndex],
      seaIconStanceOff[columnIndex],
      seaIconStanceDef[columnIndex],
    );
  }

  wrdice.DartArmy getArmyWithGroundSelection(int columnIndex, bool isLand) {
    if (isLand) {
      return wrdice.DartArmy(
        landIconValues[columnIndex],
        airIconValues[columnIndex],
        List<int>.filled(5, 0),
        landIconStanceOff[columnIndex],
        landIconStanceDef[columnIndex],
        airIconStanceOff[columnIndex],
        airIconStanceDef[columnIndex],
        List<int>.filled(5, 0),
        List<int>.filled(5, 0),
      );
    } else {
      return wrdice.DartArmy(
        List<int>.filled(5, 0),
        airIconValues[columnIndex],
        seaIconValues[columnIndex],
        List<int>.filled(5, 0),
        List<int>.filled(5, 0),
        airIconStanceOff[columnIndex],
        airIconStanceDef[columnIndex],
        seaIconStanceOff[columnIndex],
        seaIconStanceDef[columnIndex],
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

  // Land: 2 top + 3 main = 5 per column
  List<List<int>> landIconValues = [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
  ];
  List<List<int>> landIconStanceOff = [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
  ];
  List<List<int>> landIconStanceDef = [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
  ];
  List<List<double>> landStanceFractions = [
    [0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0],
  ];
  List<List<double>> airStanceFractions = [
    [0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0],
  ];

  List<List<double>> seaStanceFractions = [
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
  ];

  // Sea: 2 top + 4 main = 6 per column
  List<List<int>> airIconValues = [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
  ];
  List<List<int>> airIconStanceOff = [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
  ];
  List<List<int>> airIconStanceDef = [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
  ];

  // Sea: 2 top + 4 main = 6 per column
  List<List<int>> seaIconValues = [
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
  ];
  List<List<int>> seaIconStanceOff = [
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
  ];
  List<List<int>> seaIconStanceDef = [
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
  ];

  List<List<int>> airDiceVsAir = [
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
  ];

  List<List<int>> landDiceVsAir = [
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
  ];

  List<List<int>> seaDiceVsAir = [
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
  ];

  List<List<int>> airDiceVsGround = [
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
  ];

  List<List<int>> landDiceVsGround = [
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
  ];

  List<List<int>> seaDiceVsGround = [
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
  ];

  List<List<int>> diceTotal = [
    [0, 0],
    [0, 0],
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
        airStanceFractions[columnIndex][idx] = value;
      });
      airIconStanceDef[columnIndex][idx] =
          ((1 - value) * airIconValues[columnIndex][idx]).round();
      airIconStanceOff[columnIndex][idx] =
          (value * airIconValues[columnIndex][idx]).round();
    } else {
      if (isLand) {
        setState(() {
          landStanceFractions[columnIndex][idx] = value;
        });
        landIconStanceDef[columnIndex][idx] =
            ((1 - value) * landIconValues[columnIndex][idx]).round();
        landIconStanceOff[columnIndex][idx] =
            (value * landIconValues[columnIndex][idx]).round();
      } else {
        setState(() {
          seaStanceFractions[columnIndex][idx] = value;
        });
        seaIconStanceDef[columnIndex][idx] =
            ((1 - value) * seaIconValues[columnIndex][idx]).round();
        seaIconStanceOff[columnIndex][idx] =
            (value * seaIconValues[columnIndex][idx]).round();
      }
    }
    //update dice
    updateDice(columnIndex);
  }

  Stats? statistics; // results from FFI or mock

  final Image img_dice_air = Image.asset("resources/air.png");
  final Image img_dice_gnd = Image.asset("resources/land.png");

  // Different icons for Land / Sea
  final List<Image> landTopIcons = [
    Image.asset("resources/air.png"),
    Image.asset("resources/air.png"),
    Image.asset("resources/green_air.jpg"),
    Image.asset("resources/red_air.jpg", fit: BoxFit.cover),
    Image.asset("resources/air.png", fit: BoxFit.cover),
  ];

  final List<Image> landMainIcons = [
    Image.asset("resources/yellow_ground.jpg", fit: BoxFit.cover),
    Image.asset("resources/blue_ground.jpg", fit: BoxFit.cover),
    Image.asset("resources/green_ground.jpg", fit: BoxFit.cover),
    Image.asset("resources/land.png"),
    Image.asset("resources/land.png"),
  ];

  final List<Image> seaMainIcons = [
    Image.asset("resources/yellow_sea.jpg", fit: BoxFit.cover),
    Image.asset("resources/blue_sea.jpg", fit: BoxFit.cover),
    Image.asset("resources/green_sea.jpg", fit: BoxFit.cover),
    Image.asset("resources/red_sea.jpg", fit: BoxFit.cover),
    Image.asset("resources/land.png"),
  ];

  Future<void> _showInputDialog(
    int column,
    int iconIndex,
    bool isLand,
    bool isAir,
  ) async {
    late List<List<int>> currentValues;
    if (isAir) {
      currentValues = airIconValues;
    } else {
      if (isLand) {
        currentValues = landIconValues;
      } else {
        currentValues = seaIconValues;
      }
    }

    double tempValue = currentValues[column][iconIndex].toDouble();
    TextEditingController controller = TextEditingController(
      text: tempValue.toInt().toString(),
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter a value"),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Wrap(
                children: [
                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: Slider(
                          min: 0,
                          max: 30,
                          divisions: 30,
                          value: tempValue,
                          label: tempValue.toInt().toString(),
                          onChanged: (value) {
                            setDialogState(() {
                              tempValue = value;
                              controller.text = value.toInt().toString();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null && parsed >= 0 && parsed <= 30) {
                              setDialogState(() {
                                tempValue = parsed.toDouble();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentValues[column][iconIndex] = tempValue.toInt();
                });
                late double value;
                if (isAir) {
                  value = airStanceFractions[column][iconIndex];
                } else if (isLand) {
                  value = landStanceFractions[column][iconIndex];
                } else {
                  value = seaStanceFractions[column][iconIndex];
                }
                _updateStance(column, value, iconIndex, isLand, isAir);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

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
    final topIcons = landTopIcons;
    final mainIcons = isLand ? landMainIcons : seaMainIcons;
    final icons = isAir ? topIcons : mainIcons;
    late List<int> off;
    late List<int> def;
    late List<int> val;
    late List<double> fac;
    late List<int> dice_air;
    late List<int> dice_gnd;

    if (isAir) {
      off = airIconStanceOff[columnIndex];
      def = airIconStanceDef[columnIndex];
      val = airIconValues[columnIndex];
      fac = airStanceFractions[columnIndex];
      dice_air = airDiceVsAir[columnIndex];
      dice_gnd = airDiceVsGround[columnIndex];
    } else if (isLand) {
      off = landIconStanceOff[columnIndex];
      def = landIconStanceDef[columnIndex];
      val = landIconValues[columnIndex];
      fac = landStanceFractions[columnIndex];
      dice_air = landDiceVsAir[columnIndex];
      dice_gnd = landDiceVsGround[columnIndex];
    } else {
      off = seaIconStanceOff[columnIndex];
      def = seaIconStanceDef[columnIndex];
      val = seaIconValues[columnIndex];
      fac = seaStanceFractions[columnIndex];
      dice_air = seaDiceVsAir[columnIndex];
      dice_gnd = seaDiceVsGround[columnIndex];
    }
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

    Widget centerItem = Column(
      children: [
        Flexible(
          flex: 3,
          child: ElevatedButton(
            clipBehavior: Clip.antiAlias,
            onPressed: () => _showInputDialog(columnIndex, i, isLand, isAir),
            style: get_button_style(isLand, isAir),
            child: icons[i],
          ),
        ),
        Flexible(flex: 1, child: Text(val[i].toString())),
      ],
    );
    Widget bottomItem = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(def[i].toString()),
        Flexible(
          child: 
          Slider(
            value: fac[i],
            min: 0.0,
            max: 1.0,
            divisions: val[i] > 0 ? val[i] : 100,
            onChanged: (double value) =>
                _updateStance(columnIndex, value, i, isLand, isAir),
          ),
        ),
        Text(off[i].toString()),
      ],
    );
    Color background = isAir
        ? const Color.fromARGB(50, 3, 167, 200)
        : const Color.fromARGB(50, 255, 174, 99);

    return _diceCard(
      background,
      _getDiceDisplay(dice_air, i, true),
      _getDiceDisplay(dice_gnd, i, false),
      centerItem,
      bottomItem,
    );
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
      child: Card(
        color: color,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
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
        ),
      ),
    );
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
        margin: const EdgeInsets.all(8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 12,
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
    return Column(
      children: [
        // Switch Land / Sea
        Padding(
          padding: const EdgeInsets.all(8),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Land')),
              ButtonSegment(value: false, label: Text('Sea')),
            ],
            selected: {_isLand},
            onSelectionChanged: (v) {
              setState(() {
                _isLand = v.first;
              });
            },
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Column(
                  children: [
                    _diceCard(
                      Colors.blue,
                      _getDiceDisplay(diceTotal[0], 0, true),
                      _getDiceDisplay(diceTotal[0], 1, false),
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
                      _getDiceDisplay(diceTotal[1], 0, true),
                      _getDiceDisplay(diceTotal[1], 1, false),
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
      return airIconValues[columnIndex][idx];
    } else if (isLand) {
      return landIconValues[columnIndex][idx];
    } else {
      return seaIconValues[columnIndex][idx];
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
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 250, // Set a fixed height for the chart
        child: BarChart(
          BarChartData(
            maxY: 1.0,
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
                sideTitles: SideTitles(showTitles: true, reservedSize: 35),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 45),
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
      appBar: AppBar(title: const Text("Units & Statistics")),
      body: _buildCurrentPage(),
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
  runApp(const MaterialApp(home: LandSeaStatsApp()));
}

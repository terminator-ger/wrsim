import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wheel_picker/wheel_picker.dart';
import 'package:wrdice/wrdice.dart' as wrdice;

class Stats {
  final Map<String, double> pieData;
  final List<double> barData;
  Stats(this.pieData, this.barData);
}

class LandSeaStatsApp extends StatefulWidget {
  const LandSeaStatsApp({Key? key}) : super(key: key);

  @override
  State<LandSeaStatsApp> createState() => _LandSeaStatsAppState();
}

class _LandSeaStatsAppState extends State<LandSeaStatsApp> {
  int _selectedNavIndex = 0; // 0 = Units, 1 = Pie, 2 = Bar
  bool _isLand = true;
  late Future<wrdice.DartSimStats> asyncResult;
  asyncResult.then((value) => updatePlots(value));

  void convertAndCalcBattle(List<List<int>> units, bool is_lnd) {
    List<int> lnd_a = List<int>.filled(5, 0);
    List<int> air_a = List<int>.filled(5, 0);
    List<int> sea_a = List<int>.filled(5, 0);
    List<int> lnd_b = List<int>.filled(5, 0);
    List<int> air_b = List<int>.filled(5, 0);
    List<int> sea_b = List<int>.filled(5, 0);
    for (int i = 0; i < 5; i++) {
      if (is_lnd) {
        lnd_a[i] = units[0][i];
        lnd_b[i] = units[1][i];
      } else {
        sea_a[i] = units[0][i];
        sea_b[i] = units[1][i];
      }
      air_a[i] = units[0][i];
      air_b[i] = units[1][i];
    }
    calcBattle(lnd_a, air_a, sea_a, lnd_b, air_b, sea_b);
  }

  void updateDice(int columnIndex){
    wrdice.DartArmy army = getArmy(columnIndex);
    wrdice.DartDice dice = wrdice.updateDice(army);
    
    setState((){airDiceVsAir[columnIndex] = dice.air.vs_air.toList();});
    setState((){airDiceVsGround[columnIndex] = dice.air.vs_gnd.toList();});
    setState((){landDiceVsAir[columnIndex] = dice.lnd.vs_air.toList();});
    setState((){landDiceVsGround[columnIndex] = dice.lnd.vs_gnd.toList();});
    setState((){seaDiceVsAir[columnIndex] = dice.sea.vs_air.toList();});
    setState((){seaDiceVsGround[columnIndex] = dice.sea.vs_gnd.toList();});
  }

  wrdice.DartArmy getArmy(int columnIndex){
    return wrdice.DartArmy(landIconValues[columnIndex], 
                    airIconValues[columnIndex],
                    seaIconValues[columnIndex],
                    landIconStanceOff[columnIndex],
                    landIconStanceDef[columnIndex],
                    airIconStanceOff[columnIndex],
                    airIconStanceDef[columnIndex],
                    seaIconStanceOff[columnIndex],
                    seaIconStanceDef[columnIndex]);
  }

  wrdice.DartArmy getArmyWithGroundSelection(int columnIndex, bool isLand){
    if (isLand){
      return wrdice.DartArmy(
                    landIconValues[columnIndex], 
                    airIconValues[columnIndex],
                    List<int>.filled(5,0),
                    landIconStanceOff[columnIndex],
                    landIconStanceDef[columnIndex],
                    airIconStanceOff[columnIndex],
                    airIconStanceDef[columnIndex],
                    List<int>.filled(5,0),
                    List<int>.filled(5,0));
    } else {
       return wrdice.DartArmy(
                    List<int>.filled(5,0),
                    airIconValues[columnIndex],
                    seaIconValues[columnIndex],
                    List<int>.filled(5,0),
                    List<int>.filled(5,0),
                    airIconStanceOff[columnIndex],
                    airIconStanceDef[columnIndex],
                    seaIconStanceOff[columnIndex],
                    seaIconStanceDef[columnIndex]);
    }
  }


  void _calcBattle(
    bool isLand
  ) {
    wrdice.DartArmy army_a = getArmyWithGroundSelection(0, isLand);
    wrdice.DartArmy army_b = getArmyWithGroundSelection(1, isLand);
    final bool fa = true;
    final bool bc = true;
    asyncResult = wrdice.runBattleAsync(army_a, army_b, fa, bc);
  }


  void calcBattle(
    List<int> lnd_a,
    List<int> air_a,
    List<int> sea_a,
    List<int> lnd_b,
    List<int> air_b,
    List<int> sea_b,
  ) {
    final wrdice.DartArmy da = wrdice.DartArmy(
      lnd_a,
      air_a,
      sea_a,
      List<int>.filled(5, -1),
      List<int>.filled(5, 0),
      List<int>.filled(5, -1),
      List<int>.filled(5, 0),
      List<int>.filled(5, -1),
      List<int>.filled(5, 0),
    );
    final wrdice.DartArmy db = wrdice.DartArmy(
      lnd_b,
      air_b,
      sea_b,
      List<int>.filled(5, -1),
      List<int>.filled(5, 0),
      List<int>.filled(5, -1),
      List<int>.filled(5, 0),
      List<int>.filled(5, -1),
      List<int>.filled(5, 0),
    );

    final bool fa = true;
    final bool bc = true;
    asyncResult = wrdice.runBattleAsync(da, db, fa, bc);
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

  // Different icons for Land / Sea
  final List<IconData> landTopIcons = [
    Icons.numbers_rounded,
    Icons.numbers_rounded,
    Icons.landscape, 
    Icons.agriculture,
    Icons.numbers_rounded,
    ];
  final List<IconData> landMainIcons = [
    Icons.terrain,
    Icons.forest,
    Icons.grass,
    Icons.numbers_rounded,
    Icons.numbers_rounded,
  ];

  final List<IconData> seaMainIcons = [
    Icons.water,
    Icons.waves,
    Icons.surfing,
    Icons.beach_access,
    Icons.numbers_rounded,
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
              return Row(
                children: [
                  Expanded(
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
                  Expanded(
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
                if (isAir){
                  value = airStanceFractions[column][iconIndex];
                } else if (isLand){
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: Text(dice_air[i].toString()),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    icons[i],
                    size: 30,
                    color: isLand ? Colors.brown : Colors.blueAccent,
                  ),
                  onPressed: () =>
                      _showInputDialog(columnIndex, i, isLand, isAir),
                ),
                Text(val[i].toString()),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text(dice_gnd[i].toString()),
            ),
          ],
        ),
        Row(
          children: [
            Text(def[i].toString()),
            Expanded(
              child: Slider(
                value: fac[i],
                min: 0.0,
                max: 1.0,
                onChanged: (double value) =>
                    _updateStance(columnIndex, value, i, isLand, isAir),
              ),
            ),
            Text(off[i].toString()),
          ],
        ),
      ],
    );
  }

  Widget _buildColumnContent(int columnIndex, bool isLand) {
    final iconValues = isLand ? landIconValues : seaIconValues;

    // Top: first two icons
    List<int> topValues = iconValues[columnIndex].take(2).toList();
    // Main: remaining icons
    List<int> mainValues = iconValues[columnIndex].skip(2).toList();

    return Expanded(
      child: Card(
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
                    children: List.generate(topValues.length, (i) {
                      return _buildUnitSelection(columnIndex, i+offset_air, isLand, true);
                    }),
                  ),
                  const Divider(thickness: 1.2),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 12,
                    children: List.generate(mainValues.length, (i) {
                      return _buildUnitSelection(columnIndex, i, isLand, false);
                    }),
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
              _buildColumnContent(0, _isLand),
              _buildColumnContent(1, _isLand),
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
    if (!asyncResultCalcluated) {
      return const Center(child: Text("No data yet. Please calculate."));
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: PieChart(
        PieChartData(
          sections: statistics!.pieData.entries
              .map(
                (e) => PieChartSectionData(
                  value: e.value,
                  title: "${e.key}\n${e.value.toStringAsFixed(0)}%",
                  radius: 80,
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

  Widget _buildBarChart() {
    if (statistics == null) {
      return const Center(child: Text("No data yet. Please calculate."));
    }

    final barData = statistics!.barData;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) =>
                    Text('Icon ${value.toInt() + 1}'),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(barData.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(toY: barData[i], width: 16)],
            );
          }),
        ),
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
              child: const Icon(Icons.calculate),
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

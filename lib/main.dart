import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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

  // Land: 2 top + 3 main = 5 per column
  List<List<int>> landIconValues = [
    [0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0],
  ];

  // Sea: 2 top + 4 main = 6 per column
  List<List<int>> seaIconValues = [
    [0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0],
  ];

  Stats? statistics; // results from FFI or mock

  // Different icons for Land / Sea
  final List<IconData> landTopIcons = [Icons.landscape, Icons.agriculture];
  final List<IconData> landMainIcons = [
    Icons.terrain,
    Icons.forest,
    Icons.grass,
  ];

  final List<IconData> seaTopIcons = [Icons.sailing, Icons.anchor];
  final List<IconData> seaMainIcons = [
    Icons.water,
    Icons.waves,
    Icons.surfing,
    Icons.beach_access,
  ];

  Future<void> _showInputDialog(int column, int iconIndex, bool isLand) async {
    List<List<int>> currentValues = isLand ? landIconValues : seaIconValues;
    double tempValue = currentValues[column][iconIndex].toDouble();
    TextEditingController controller =
        TextEditingController(text: tempValue.toInt().toString());

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
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  currentValues[column][iconIndex] = tempValue.toInt();
                });
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColumnContent(int columnIndex, bool isLand) {
    final iconValues = isLand ? landIconValues : seaIconValues;
    final topIcons = isLand ? landTopIcons : seaTopIcons;
    final mainIcons = isLand ? landMainIcons : seaMainIcons;

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
          child: Column(
            children: [
              // --- Top Row (2 icons)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(topValues.length, (i) {
                  return Column(
                    children: [
                      IconButton(
                        icon: Icon(topIcons[i],
                            size: 32,
                            color: isLand ? Colors.green[700] : Colors.teal),
                        onPressed: () => _showInputDialog(columnIndex, i, isLand),
                      ),
                      Text(topValues[i].toString()),
                    ],
                  );
                }),
              ),
              const Divider(thickness: 1.2),
              // --- Main Icons
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: List.generate(mainValues.length, (i) {
                  int realIndex = i + 2;
                  return Column(
                    children: [
                      IconButton(
                        icon: Icon(mainIcons[i],
                            size: 30,
                            color: isLand ? Colors.brown : Colors.blueAccent),
                        onPressed: () =>
                            _showInputDialog(columnIndex, realIndex, isLand),
                      ),
                      Text(mainValues[i].toString()),
                    ],
                  );
                }),
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
    await Future.delayed(const Duration(milliseconds: 400)); // simulate
    setState(() {
      statistics = Stats(
        {"Success": 50, "Failure": 30, "Draw": 20},
        [10, 18, 25, 22, 30, 15],
      );
      _selectedNavIndex = 1; // go to pie chart
    });
  }

  Widget _buildPieChart() {
    if (statistics == null) {
      return const Center(child: Text("No data yet. Please calculate."));
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: PieChart(
        PieChartData(
          sections: statistics!.pieData.entries
              .map((e) => PieChartSectionData(
                    value: e.value,
                    title: "${e.key}\n${e.value.toStringAsFixed(0)}%",
                    radius: 80,
                    titleStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ))
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
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: barData[i], width: 16),
            ]);
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

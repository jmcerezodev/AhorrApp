import 'package:ahorrapp/core/filter_lists/filter_lists.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartHistory extends StatefulWidget {
  const ChartHistory({super.key});

  @override
  State<ChartHistory> createState() => _ChartHistoryState();
}

class _ChartHistoryState extends State<ChartHistory> {
  late ScrollController _scrollController;
  int touchedGroupIndex = -1; // Mes seleccionado
  int touchedRodIndex = -1;   // Barra específica seleccionada (0, 1 o 2)

  @override
  void initState() {
    super.initState();
    final currentMonthIndex = DateTime.now().month - 1;
    double initialOffset = (currentMonthIndex * 83.0) - 120.0;
    if (initialOffset < 0) initialOffset = 0;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size.width,
      height: size.height * 0.35,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: _ChartLegend(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isDark ? 0.05 : 0.1,
                    child: Image.asset(
                      'assets/Logo.png',
                      width: size.width * 0.35,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      width: 1000, 
                      padding: const EdgeInsets.only(right: 30, left: 20),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxY(context),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) => colorScheme.surface,
                              tooltipBorder: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
                              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              tooltipRoundedRadius: 12,
                              tooltipMargin: 20,
                              fitInsideVertically: true,
                              fitInsideHorizontally: true,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                String type = "";
                                if (rodIndex == 0) type = "Ingresos";
                                if (rodIndex == 1) type = "Gastos";
                                if (rodIndex == 2) type = "Ahorros";
                                return BarTooltipItem(
                                  '$type\n',
                                  TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(
                                      text: '${rod.toY.toStringAsFixed(2)}€',
                                      style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                );
                              },
                            ),
                            touchCallback: (FlTouchEvent event, barTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    barTouchResponse == null ||
                                    barTouchResponse.spot == null) {
                                  touchedGroupIndex = -1;
                                  touchedRodIndex = -1;
                                  return;
                                }
                                touchedGroupIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                                touchedRodIndex = barTouchResponse.spot!.touchedRodDataIndex;
                              });
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 15,
                                    child: Text(
                                      months[value.toInt()],
                                      style: TextStyle(
                                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                                        fontWeight: FontWeight.w900, 
                                        fontSize: 11
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: _getMaxY(context) / 4 > 0 ? _getMaxY(context) / 4 : 100,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: colorScheme.onSurface.withValues(alpha: 0.05),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: _crearBarGroups(context, _getMaxY(context)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _crearBarGroups(BuildContext context, double maxY) {
    final historyCubit = context.watch<HistoryCubit>();
    final sortLists = FilterLists();
    final year = context.watch<DateCubit>().state.year;
    final colorScheme = Theme.of(context).colorScheme;

    final List<double> incomes = sortLists.calculateTotalIncomes(historyCubit.state.historyList, year);
    final List<double> expenses = sortLists.calculateTotalExpenses(historyCubit.state.historyList, year);
    final List<double> savings = sortLists.calculateTotalSavings(historyCubit.state.historyList, year);

    return List.generate(12, (index) {
      final bool isGroupTouched = index == touchedGroupIndex;
      return BarChartGroupData(
        x: index,
        barRods: [
          _buildRod(incomes[index], Colors.green.shade400, maxY, isGroupTouched && touchedRodIndex == 0),
          _buildRod(expenses[index], Colors.red.shade400, maxY, isGroupTouched && touchedRodIndex == 1),
          _buildRod(savings[index], colorScheme.primary, maxY, isGroupTouched && touchedRodIndex == 2),
        ],
        barsSpace: 6,
      );
    });
  }

  BarChartRodData _buildRod(double value, Color color, double maxY, bool isThisRodTouched) {
    // Si hay algo tocado pero NO es esta barra, la atenuamos más
    final bool anyRodTouchedInGroup = touchedRodIndex != -1;
    final double alpha = isThisRodTouched ? 1.0 : (anyRodTouchedInGroup ? 0.3 : 0.8);

    return BarChartRodData(
      toY: value,
      color: color.withValues(alpha: alpha),
      width: 12, 
      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      backDrawRodData: BackgroundBarChartRodData(
        show: true,
        toY: maxY,
        color: isThisRodTouched ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.02),
      ),
    );
  }

  double _getMaxY(BuildContext context) {
    final historyCubit = context.read<HistoryCubit>();
    final sortLists = FilterLists();
    final year = context.read<DateCubit>().state.year;
    final incomes = sortLists.calculateTotalIncomes(historyCubit.state.historyList, year);
    final expenses = sortLists.calculateTotalExpenses(historyCubit.state.historyList, year);
    final savings = sortLists.calculateTotalSavings(historyCubit.state.historyList, year);
    
    double max = 100;
    for (var val in incomes) { if (val > max) max = val; }
    for (var val in expenses) { if (val > max) max = val; }
    for (var val in savings) { if (val > max) max = val; }
    return max * 1.5;
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: Colors.green.shade400, label: 'Ingresos'),
        const SizedBox(width: 15),
        _LegendItem(color: Colors.red.shade400, label: 'Gastos'),
        const SizedBox(width: 15),
        _LegendItem(color: colorScheme.primary, label: 'Ahorros'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 8, 
            color: colorScheme.onSurface.withValues(alpha: 0.5), 
            fontWeight: FontWeight.w800, 
            letterSpacing: 1
          ),
        ),
      ],
    );
  }
}

import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/filter_lists/filter_lists.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
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
  int touchedGroupIndex = -1; 
  int touchedRodIndex = -1;   

  @override
  void initState() {
    super.initState();
    final currentMonthIndex = DateTime.now().month - 1;
    // Ajuste dinámico del offset basado en el ancho escalado
    double initialOffset = (currentMonthIndex * 83.w) - 120.w;
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 320.h, // Altura escalada
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(25.w),
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
        padding: EdgeInsets.fromLTRB(0, 20.h, 0, 10.h),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: const _ChartLegend(),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isDark ? 0.05 : 0.1,
                    child: Image.asset(
                      'assets/Logo.png',
                      width: 35.wp,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      width: 1000.w, // Ancho total escalado del área de scroll
                      padding: EdgeInsets.only(right: 30.w, left: 20.w),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _getMaxY(context),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) => colorScheme.surface,
                              tooltipBorder: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
                              tooltipPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              tooltipBorderRadius: BorderRadius.circular(12.w),
                              tooltipMargin: 20.h,
                              fitInsideVertically: true,
                              fitInsideHorizontally: true,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                String type = "";
                                if (rodIndex == 0) type = "Ingresos";
                                if (rodIndex == 1) type = "Gastos";
                                if (rodIndex == 2) type = "Ahorros";
                                return BarTooltipItem(
                                  '$type\n',
                                  TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 10.sp, fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(
                                      text: '${HumanizeNumbers().format(rod.toY)}€',
                                      style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 13.sp),
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
                                reservedSize: 40.h,
                                getTitlesWidget: (value, meta) {
                                  const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
                                  return SideTitleWidget(
                                    meta: meta,
                                    space: 15.h,
                                    child: Text(
                                      months[value.toInt()],
                                      style: TextStyle(
                                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                                        fontWeight: FontWeight.w900, 
                                        fontSize: 11.sp
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
        barsSpace: 6.w,
      );
    });
  }

  BarChartRodData _buildRod(double value, Color color, double maxY, bool isThisRodTouched) {
    final bool anyRodTouchedInGroup = touchedRodIndex != -1;
    final double alpha = isThisRodTouched ? 1.0 : (anyRodTouchedInGroup ? 0.3 : 0.8);

    return BarChartRodData(
      toY: value,
      color: color.withValues(alpha: alpha),
      width: 12.w, 
      borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
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
    
    double maxVal = 100;
    for (var val in incomes) { if (val > maxVal) maxVal = val; }
    for (var val in expenses) { if (val > maxVal) maxVal = val; }
    for (var val in savings) { if (val > maxVal) maxVal = val; }
    return maxVal * 1.5;
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
        SizedBox(width: 15.w),
        _LegendItem(color: Colors.red.shade400, label: 'Gastos'),
        SizedBox(width: 15.w),
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
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 8.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.5), 
            fontWeight: FontWeight.w800, 
            letterSpacing: 1
          ),
        ),
      ],
    );
  }
}

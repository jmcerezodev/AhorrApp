import 'package:ahorrapp/core/filter_lists/filter_lists.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartHistory extends StatelessWidget {
  const ChartHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height * 0.35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.orange.shade100.withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
        child: Column(
          children: [
            const _ChartLegend(),
            const SizedBox(height: 20),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Icono de fondo con más presencia
                  Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      'assets/Logo.png',
                      width: size.width * 0.35,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const _BarChartWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: Colors.green.shade400, label: 'Ingresos'),
        const SizedBox(width: 25),
        _LegendItem(color: Colors.red.shade400, label: 'Gastos'), // Leyenda actualizada a Rojo
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
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 9, color: Colors.grey.shade400, fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
      ],
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  const _BarChartWidget();

  List<BarChartGroupData> _crearBarGroups(BuildContext context, HistoryCubit historyCubit) {
    final sortLists = FilterLists();
    final year = context.watch<DateCubit>().state.year;

    final List<double> listIncomesResult = sortLists.calculateTotalIncomes(historyCubit.state.historyList, year);
    final List<double> listExpensesResult = sortLists.calculateTotalExpenses(historyCubit.state.historyList, year);

    return List.generate(12, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: listIncomesResult[index],
            color: Colors.green.shade400,
            width: 7,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(listIncomesResult, listExpensesResult),
              color: Colors.grey.shade50,
            ),
          ),
          BarChartRodData(
            toY: listExpensesResult[index],
            color: Colors.red.shade400, // Cambiado a Rojo para Gastos
            width: 7,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(listIncomesResult, listExpensesResult),
              color: Colors.grey.shade50,
            ),
          ),
        ],
        barsSpace: 2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyCubit = context.watch<HistoryCubit>();
    final sortLists = FilterLists();
    final year = context.read<DateCubit>().state.year;
    final incomes = sortLists.calculateTotalIncomes(historyCubit.state.historyList, year);
    final expenses = sortLists.calculateTotalExpenses(historyCubit.state.historyList, year);
    final maxY = _getMaxY(incomes, expenses);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey.shade900,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            tooltipRoundedRadius: 12,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toStringAsFixed(2)}€',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                const months = ['E', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                return SideTitleWidget(
                  meta: meta,
                  space: 10,
                  child: Text(
                    months[value.toInt()],
                    style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.bold, fontSize: 10),
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
          horizontalInterval: maxY / 4 > 0 ? maxY / 4 : 100,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade50,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _crearBarGroups(context, historyCubit),
      ),
    );
  }

  double _getMaxY(List<double> incomes, List<double> expenses) {
    double max = 100;
    for (var val in incomes) { if (val > max) max = val; }
    for (var val in expenses) { if (val > max) max = val; }
    return max * 1.2;
  }
}

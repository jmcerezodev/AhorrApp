import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoGlogalWidget extends StatelessWidget {
  const InfoGlogalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final historyState = context.watch<HistoryCubit>().state;
    final totalBalance = context.watch<TotalMoneyCubit>().state.totalMoney;
    final colorScheme = Theme.of(context).colorScheme;
    
    // CORREGIDO: Ahora usamos el nuevo enum y el campo 'status'
    final bool isLoading = historyState.status == HistoryStatus.loading || historyState.isSyncing;

    return FadeInUp(
      from: 20,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        child: Column(
          children: [
            const Text(
              'BALANCE TOTAL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white54,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 10),
            
            if (isLoading)
              const SizedBox(height: 40, width: 40, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            else
              Text(
                '${totalBalance.toStringAsFixed(2)}€',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

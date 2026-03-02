import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/network/connectivity_service.dart';
import 'package:ahorrapp/presentation/screens/home_screen.dart';
import 'package:ahorrapp/presentation/screens/recurrent_expenses/recurrent_expenses_screen.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';

class MainNavigatorScreen extends StatefulWidget {
  const MainNavigatorScreen({super.key});

  @override
  State<MainNavigatorScreen> createState() => _MainNavigatorScreenState();
}

class _MainNavigatorScreenState extends State<MainNavigatorScreen> {
  int _selectedIndex = 2; // El botón central (Inicio) es el índice 2

  final List<Widget> _screens = [
    const RecurrentExpensesScreen(), // Pestaña de Gastos Recurrentes
    const Center(child: Text('Lista de la Compra\n(Próximamente)', textAlign: TextAlign.center)),
    const HomeScreen(), // Botón central: Inicio
    const Center(child: Text('Escaneo de Tickets\n(Próximamente)', textAlign: TextAlign.center)),
    const Center(child: Text('Más Ajustes\n(Próximamente)', textAlign: TextAlign.center)),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const SideMenuWidget(),
      body: Column(
        children: [
          // BANNER DE DESCONEXIÓN (Respetando el Notch)
          StreamBuilder<NetworkStatus>(
            stream: getIt<ConnectivityService>().status,
            initialData: getIt<ConnectivityService>().currentStatus,
            builder: (context, snapshot) {
              if (snapshot.data == NetworkStatus.offline) {
                return SafeArea(
                  bottom: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    color: Colors.orange.shade800.withValues(alpha: 0.9),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Modo Local: Los datos se sincronizarán al volver la conexión.',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          // CONTENIDO DE LA PANTALLA
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        color: Colors.grey.shade400,
        activeColor: Colors.orange,
        initialActiveIndex: _selectedIndex,
        items: const [
          TabItem(icon: Icons.repeat_rounded, title: 'Fijos'),
          TabItem(icon: Icons.shopping_basket_rounded, title: 'Compra'),
          TabItem(icon: Icons.home_rounded, title: 'Inicio'),
          TabItem(icon: Icons.qr_code_scanner_rounded, title: 'Tickets'),
          TabItem(icon: Icons.grid_view_rounded, title: 'Más'),
        ],
        onTap: (int i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

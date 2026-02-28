import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authAppwrite = AuthAppwrite();

  @override
  void initState() {
    super.initState();
    authAppwrite.checkUserAuthentication(context);
  }

  @override
  Widget build(BuildContext context) {
    final String yearNow = Date().year();
    final String userName = Preferences.name;

    // Este es el tono naranja muy claro (naranja + blanco) que viste en el resplandor
    const backgroundColor = Color(0xFFFFFBF5); 

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const SideMenuWidget(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera Personalizada
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Icons.notes_rounded, color: Colors.black87, size: 28),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Hola, $userName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Bienvenido de nuevo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade300, // Acento naranja sutil en el texto
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Contenido principal
            const InfoGlogalWidget(),
            const SizedBox(height: 5),
            const DateCustomWidget(),
            const SizedBox(height: 15),
            const ExpensesIncomesCustomWidget(),
            const SizedBox(height: 25),
            
            // Historial expandible
            const Expanded(
              child: HistoryCustomWidget(),
            ),
            
            // Copyright
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'JMCerezoDev - $yearNow ®',
                  style: TextStyle(
                    color: Colors.orange.shade200,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

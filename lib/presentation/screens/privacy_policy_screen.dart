import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  final String _privacyPolicyMarkdown = '''
# Política de Privacidad de AhorrApp

**Fecha de entrada en vigor: 1 de enero de 2024**

En AhorrApp, valoramos tu privacidad y la seguridad de tus datos financieros. Esta política describe cómo manejamos tu información.

## 1. Recolección de Datos
AhorrApp recolecta los siguientes datos:
- **Correo electrónico y nombre:** Para la creación y gestión de tu cuenta.
- **Datos financieros:** Ingresos, gastos y ahorros que registres manualmente.
- **Imágenes de tickets:** Si utilizas el escáner de tickets, procesamos la imagen localmente y en la nube.

## 2. Uso de la Información
Tus datos se utilizan exclusivamente para:
- Proporcionarte el servicio de gestión financiera.
- Sincronizar tus datos entre múltiples dispositivos a través de **Appwrite**.
- Procesar tickets mediante **OpenAI** (solo enviamos el texto extraído, nunca tus datos personales).

## 3. Almacenamiento y Seguridad
- Tus datos se guardan localmente en tu dispositivo (**Isar**) y se sincronizan de forma segura con nuestros servidores.
- Utilizamos **biometría local** para proteger el acceso a la aplicación.
- Tienes el control total: puedes eliminar todos tus datos desde el menú de gestión de cuenta.

## 4. Terceros
No vendemos ni compartimos tus datos con anunciantes. Utilizamos proveedores de confianza como Appwrite (Base de datos) y OpenAI (Procesamiento de texto de tickets).
''';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1112) : const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: const Text('POLÍTICA DE PRIVACIDAD'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Markdown(
                data: _privacyPolicyMarkdown,
                padding: const EdgeInsets.all(25.0),
                styleSheet: MarkdownStyleSheet(
                  h1: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
                  h2: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold, height: 2.0),
                  p: TextStyle(color: isDarkMode ? Colors.white70 : Colors.blueGrey.shade800, fontSize: 15, height: 1.5),
                  strong: TextStyle(color: isDarkMode ? Colors.white : Colors.blueGrey.shade900, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri url = Uri.parse('https://jmcerezo.dev/politicasprivacidad/ahorrapp.html');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.language_rounded),
                label: const Text('VER VERSIÓN WEB OFICIAL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

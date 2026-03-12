import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  final String _privacyPolicyMarkdown = '''
# Política de Privacidad AhorrApp

En AhorrApp, diseñamos nuestra tecnología para que tu tranquilidad financiera vaya de la mano con la seguridad de tus datos. No vendemos ni compartimos tu información personal con fines comerciales.

## 1. Tratamiento de IA
Procesado híbrido de seguridad: utilizamos **Google ML Kit** para la extracción local de datos en tu dispositivo. Solo el texto procesado se envía a **OpenAI** para su clasificación financiera, garantizando que tus imágenes originales nunca se compartan con terceros.

## 2. Seguridad Biométrica
Protección de acceso mediante la interfaz nativa de tu sistema operativo (huella o rostro). ADN AhorrApp **no accede, no almacena ni conoce** tus datos biométricos; solo recibe la validación segura del hardware de tu dispositivo.

## 3. Infraestructura Privada (VPS)
Tus datos residen en la plataforma **Appwrite**, alojada exclusivamente en nuestro propio **Servidor VPS (Servidor Privado Virtual)** gestionado por el desarrollador. Esto garantiza la soberanía digital absoluta, evitando el uso de nubes públicas comerciales.

## 4. Derechos y Portabilidad
Garantizamos el control total sobre tu información:
- **Exportación:** Generación de reportes financieros en **PDF** con el diseño oficial de la app.
- **Eliminación:** Borrado total, inmediato y permanente de tu cuenta y todos los datos asociados desde el menú de ajustes.
''';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const orangePrimary = Color(0xFFFFA500);
    const boneWhite = Color(0xFFFFFBF5);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F1112) : boneWhite,
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
                  h1: const TextStyle(
                    color: orangePrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  h2: const TextStyle(
                    color: orangePrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 2.0,
                  ),
                  p: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.blueGrey.shade800,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  pPadding: const EdgeInsets.only(bottom: 12.0),
                  strong: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.blueGrey.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri url = Uri.parse(
                    'https://jmcerezo.dev/politicasprivacidad/ahorrapp.html',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.language_rounded),
                label: const Text('VER VERSIÓN WEB OFICIAL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangePrimary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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

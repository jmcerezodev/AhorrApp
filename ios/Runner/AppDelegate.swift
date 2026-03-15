import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  // Creamos una vista oscura para ocultar el contenido en la multitarea
  private var blurView: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GeneratedPluginRegistrant.register(with: self)
    setupSecurityChannel()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setupSecurityChannel() {
    if let controller = window?.rootViewController as? FlutterViewController {
      let securityChannel = FlutterMethodChannel(name: "dev.jmcerezo.ahorrapp/security",
                                                binaryMessenger: controller.binaryMessenger)

      securityChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if (call.method == "setSecure") {
          // En iOS, setSecure suele manejar si queremos ocultar la app en la multitarea
          // Puedes guardar este estado en una variable si lo necesitas
          result(true)
        } else {
          result(FlutterMethodNotImplemented)
        }
      })
    }
  }

  // --- LÓGICA DE SEGURIDAD VISUAL (Igual que en apps bancarias) ---

  // Se ejecuta cuando el usuario desliza hacia arriba para ver las apps abiertas
  override func applicationWillResignActive(_ application: UIApplication) {
    // Si quieres que siempre se oculte, o basado en tus Preferences:
    showBlurScreen()
  }

  // Se ejecuta cuando la app vuelve a primer plano
  override func applicationDidBecomeActive(_ application: UIApplication) {
    removeBlurScreen()
  }

  private func showBlurScreen() {
    if blurView == nil {
      let blurEffect = UIBlurEffect(style: .dark)
      let view = UIVisualEffectView(effect: blurEffect)
      view.frame = window?.bounds ?? UIScreen.main.bounds
      blurView = view
      window?.addSubview(view)
    }
  }

  private func removeBlurScreen() {
    blurView?.removeFromSuperview()
    blurView = nil
  }
}
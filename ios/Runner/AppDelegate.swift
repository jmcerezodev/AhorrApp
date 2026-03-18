import Flutter
import UIKit
import VisionKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  // Vista oscura para ocultar el contenido en la multitarea
  private var blurView: UIView?

  // Resultado pendiente del escáner de documentos VisionKit
  private var pendingDocumentScanResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GeneratedPluginRegistrant.register(with: self)
    setupSecurityChannel()
    setupDocumentScannerChannel()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Canal de seguridad

  private func setupSecurityChannel() {
    if let controller = window?.rootViewController as? FlutterViewController {
      let securityChannel = FlutterMethodChannel(name: "dev.jmcerezo.ahorrapp/security",
                                                binaryMessenger: controller.binaryMessenger)
      securityChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if (call.method == "setSecure") {
          result(true)
        } else {
          result(FlutterMethodNotImplemented)
        }
      })
    }
  }

  // MARK: - Canal de escáner de documentos (VisionKit nativo)
  //
  // Implementación propia en lugar del plugin cunning_document_scanner porque
  // ese plugin llama a result() ANTES de dismiss(), lo que en iOS 15 produce un
  // deadlock: el MethodChannel de Flutter no puede procesar la respuesta mientras
  // VNDocumentCameraViewController sigue presentado.
  // Aquí la llamada a result(...) se hace DENTRO del closure de dismiss.

  private func setupDocumentScannerChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    let channel = FlutterMethodChannel(
      name: "dev.jmcerezo.ahorrapp/document_scanner",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "scanDocument" {
        self?.startDocumentScan(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func startDocumentScan(result: @escaping FlutterResult) {
    guard VNDocumentCameraViewController.isSupported else {
      result(FlutterError(code: "UNAVAILABLE",
                          message: "VisionKit no disponible en este dispositivo",
                          details: nil))
      return
    }
    pendingDocumentScanResult = result
    let scanner = VNDocumentCameraViewController()
    scanner.delegate = self
    DispatchQueue.main.async { [weak self] in
      self?.window?.rootViewController?.present(scanner, animated: true)
    }
  }

  // MARK: - Seguridad visual (blur en segundo plano)
  //
  // IMPORTANTE: se usa applicationDidEnterBackground (no applicationWillResignActive)
  // porque VNDocumentCameraViewController dispara willResignActive al abrirse,
  // lo que colocaría el blur encima del escáner.

  override func applicationDidEnterBackground(_ application: UIApplication) {
    showBlurScreen()
  }

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

// MARK: - VNDocumentCameraViewControllerDelegate

extension AppDelegate: VNDocumentCameraViewControllerDelegate {

  func documentCameraViewController(
    _ controller: VNDocumentCameraViewController,
    didFinishWith scan: VNDocumentCameraScan
  ) {
    // CORRECCIÓN DEL BUG DEL PLUGIN: dismiss primero, result dentro del closure.
    // Si se llama a result() antes de dismiss() en iOS 15, el Future de Dart nunca resuelve.
    controller.dismiss(animated: true) { [weak self] in
      let tempDir = NSTemporaryDirectory()
      let timestamp = Int(Date().timeIntervalSince1970 * 1000)
      var paths: [String] = []
      for i in 0..<scan.pageCount {
        let image = scan.imageOfPage(at: i)
        let path = tempDir + "scan_\(timestamp)_\(i).jpg"
        if let data = image.jpegData(compressionQuality: 0.95) {
          try? data.write(to: URL(fileURLWithPath: path))
          paths.append(path)
        }
      }
      self?.pendingDocumentScanResult?(paths)
      self?.pendingDocumentScanResult = nil
    }
  }

  func documentCameraViewControllerDidCancel(
    _ controller: VNDocumentCameraViewController
  ) {
    controller.dismiss(animated: true) { [weak self] in
      self?.pendingDocumentScanResult?([String]())
      self?.pendingDocumentScanResult = nil
    }
  }

  func documentCameraViewController(
    _ controller: VNDocumentCameraViewController,
    didFailWithError error: Error
  ) {
    controller.dismiss(animated: true) { [weak self] in
      self?.pendingDocumentScanResult?(
        FlutterError(code: "SCAN_FAILED", message: error.localizedDescription, details: nil)
      )
      self?.pendingDocumentScanResult = nil
    }
  }
}

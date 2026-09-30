import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var storageChannel: FlutterMethodChannel?
  private var accessed: [String: URL] = [:]

  override func awakeFromNib() {
    let controller = FlutterViewController()
    let frame = self.frame
    contentViewController = controller
    setFrame(frame, display: true)
    RegisterGeneratedPlugins(registry: controller)
    storageChannel = FlutterMethodChannel(name: "reeldeck/storage", binaryMessenger: controller.engine.binaryMessenger)
    storageChannel?.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      do {
        switch call.method {
        case "pick":
          let panel = NSOpenPanel()
          panel.canChooseDirectories = true
          panel.canChooseFiles = false
          panel.allowsMultipleSelection = false
          panel.prompt = "选择视频目录"
          panel.beginSheetModal(for: self) { response in
            guard response == .OK, let url = panel.url else { result(nil); return }
            do { result(try self.authorize(url)) }
            catch { result(FlutterError(code: "permission", message: error.localizedDescription, details: nil)) }
          }
        case "resolve":
          let args = call.arguments as? [String: Any]
          guard let locator = args?["locator"] as? String,
                let data = Data(base64Encoded: locator) else { result(nil); return }
          if let url = self.accessed[locator] {
            result(["path": url.path, "locator": locator]); return
          }
          var stale = false
          let url = try URL(resolvingBookmarkData: data,
            options: [.withSecurityScope, .withoutUI], relativeTo: nil,
            bookmarkDataIsStale: &stale)
          _ = url.startAccessingSecurityScopedResource()
          self.accessed[locator] = url
          let updated = stale ? try url.bookmarkData(options: .withSecurityScope,
            includingResourceValuesForKeys: nil, relativeTo: nil).base64EncodedString() : locator
          result(["path": url.path, "locator": updated])
        case "fullscreen":
          self.toggleFullScreen(nil); result(nil)
        default: result(FlutterMethodNotImplemented)
        }
      } catch { result(FlutterError(code: "storage", message: error.localizedDescription, details: nil)) }
    }
    super.awakeFromNib()
  }

  private func authorize(_ url: URL) throws -> [String: String] {
    _ = url.startAccessingSecurityScopedResource()
    let data = try url.bookmarkData(options: .withSecurityScope,
      includingResourceValuesForKeys: nil, relativeTo: nil)
    let locator = data.base64EncodedString()
    accessed[locator] = url
    return ["name": url.lastPathComponent, "path": url.path, "locator": locator]
  }

  deinit {
    for url in accessed.values { url.stopAccessingSecurityScopedResource() }
  }
}

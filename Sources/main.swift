import AppKit

// Menu bar toggle: "Stay Awake" = no sleep on lid close or idle, screen never dims,
// BetterDisplay running. Off = normal Mac sleep, BetterDisplay quit.
// pmset calls run through sudo -n; /etc/sudoers.d/stayawake allows exactly these commands.

let onCommands = [
  ["-a", "disablesleep", "1"], ["-a", "sleep", "0"], ["-a", "displaysleep", "0"],
]
let offCommands = [
  ["-a", "disablesleep", "0"], ["-a", "sleep", "1"],
  ["-b", "displaysleep", "2"], ["-c", "displaysleep", "10"],
]

@discardableResult
func run(_ path: String, _ args: [String]) -> (Int32, String) {
  let p = Process()
  p.executableURL = URL(fileURLWithPath: path)
  p.arguments = args
  let pipe = Pipe()
  p.standardOutput = pipe
  p.standardError = pipe
  do { try p.run() } catch { return (-1, "\(error)") }
  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  p.waitUntilExit()
  return (p.terminationStatus, String(decoding: data, as: UTF8.self))
}

func isAwake() -> Bool {
  run("/usr/bin/pmset", ["-g"]).1.range(of: #"SleepDisabled\s+1"#, options: .regularExpression) != nil
}

func setAwake(_ on: Bool) -> Bool {
  for args in on ? onCommands : offCommands {
    if run("/usr/bin/sudo", ["-n", "/usr/bin/pmset"] + args).0 != 0 { return false }
  }
  if on {
    run("/usr/bin/open", ["-g", "-a", "BetterDisplay"])
  } else {
    NSRunningApplication.runningApplications(withBundleIdentifier: "pro.betterdisplay.BetterDisplay")
      .forEach { $0.terminate() }
  }
  return true
}

final class App: NSObject, NSApplicationDelegate, NSMenuDelegate {
  let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
  let toggle = NSMenuItem(title: "Stay Awake", action: #selector(flip), keyEquivalent: "")

  func applicationDidFinishLaunching(_ note: Notification) {
    let menu = NSMenu()
    menu.delegate = self
    toggle.target = self
    menu.addItem(toggle)
    menu.addItem(.separator())
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
    item.menu = menu
    refresh()
  }

  func menuWillOpen(_ menu: NSMenu) { refresh() }

  func refresh() {
    let on = isAwake()
    toggle.state = on ? .on : .off
    let symbol = on ? "cup.and.saucer.fill" : "moon.zzz"
    item.button?.image = NSImage(systemSymbolName: symbol, accessibilityDescription: on ? "Staying awake" : "Sleep allowed")
  }

  @objc func flip() {
    if !setAwake(!isAwake()) {
      let alert = NSAlert()
      alert.messageText = "Couldn't change sleep settings"
      alert.informativeText = "The sudoers rule at /etc/sudoers.d/stayawake is missing."
      alert.runModal()
    }
    refresh()
  }
}

let app = NSApplication.shared
let delegate = App()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()

import QtQuick
import Quickshell.Io
import qs.Ui

// Bar icon for NetworkManager WireGuard connections. Shows the active tunnel's
// name; a left click opens the Omarchy menu with every WireGuard connection
// plus "Off". The switching itself lives in switch.sh so it can also be run
// from a terminal or a keybinding.
BarWidget {
  id: root

  property var active: []

  readonly property string switchScript: Qt.resolvedUrl("switch.sh").toString().replace(/^file:\/\//, "")

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function refresh() { if (!statusProc.running) statusProc.running = true }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.active.length > 0 && !root.vertical ? "󰖂 " + root.active.join("+") : "󰖂"
    active: root.active.length > 0
    dimmed: root.active.length === 0
    tooltipText: root.active.length > 0 ? "WireGuard: " + root.active.join(", ") : "WireGuard off"
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton && !switchProc.running) switchProc.running = true
      else if (mouseButton === Qt.MiddleButton) root.refresh()
    }
  }

  Process {
    id: statusProc
    command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show", "--active"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var names = []
        var lines = String(text || "").split("\n")
        for (var i = 0; i < lines.length; i++) {
          var cut = lines[i].lastIndexOf(":")
          if (cut > 0 && lines[i].substring(cut + 1) === "wireguard")
            names.push(lines[i].substring(0, cut).replace(/\\:/g, ":"))
        }
        root.active = names
      }
    }
  }

  // The menu blocks until a choice is made; refresh as soon as it returns
  // instead of waiting for the next poll.
  Process {
    id: switchProc
    command: ["bash", root.switchScript]
    onExited: root.refresh()
  }

  Timer {
    interval: Math.max(1, Number(root.setting("intervalSec", 3))) * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }
}

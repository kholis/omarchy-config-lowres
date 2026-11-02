import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// GlobalProtect VPN status widget for the Omarchy bar.
//
// Shows a shield icon and the elapsed connection time while the GlobalProtect
// tunnel interface is UP, and disappears entirely when the tunnel is down.
// Click the widget for a popup with connect/disconnect actions.
//
// Settings (shell.json layout entry or bar settings UI):
//   interface - tunnel interface name (default "gpd0")
//   portal    - portal hostname used by the Connect button (default "")
//
// Connect timestamp detection order:
//   1. marker file $XDG_RUNTIME_DIR/gp-vpn-since (written on observed
//      transitions; survives bar reloads, resets at logout)
//   2. mtime of /opt/paloaltonetworks/globalprotect/ipt_mangle.txt, which the
//      GlobalProtect daemon rewrites when it applies tunnel routing rules
//   3. current time
//
// NOTE: interface state must be read from /sys/.../flags bit 0 (IFF_UP) —
// operstate reports "unknown" for point-to-point tunnels.
BarWidget {
  id: root
  moduleName: "io.github.kholis.gp-vpn"

  readonly property string iface: setting("interface", "gpd0")
  readonly property string portal: setting("portal", "")
  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR") || "/run/user/1000"

  property bool connected: false
  property real sinceEpoch: 0
  property string elapsed: ""
  property string lastPoll: "<none>"
  property bool menuOpen: false

  function fmtElapsed(seconds) {
    var d = Math.floor(seconds / 86400)
    var h = Math.floor((seconds % 86400) / 3600)
    var m = Math.floor((seconds % 3600) / 60)
    var s = Math.floor(seconds % 60)
    var hh = (h < 10 ? "0" : "") + h
    var mm = (m < 10 ? "0" : "") + m
    var ss = (s < 10 ? "0" : "") + s
    return (d > 0 ? d + "d " : "") + hh + ":" + mm + ":" + ss
  }

  function fmtClock(epoch) {
    var dt = new Date(epoch * 1000)
    var hh = (dt.getHours() < 10 ? "0" : "") + dt.getHours()
    var mm = (dt.getMinutes() < 10 ? "0" : "") + dt.getMinutes()
    return hh + ":" + mm
  }

  function refreshElapsed() {
    if (!connected || sinceEpoch <= 0) return
    elapsed = fmtElapsed(Date.now() / 1000 - sinceEpoch)
  }

  visible: connected
  implicitWidth: content.implicitWidth
  implicitHeight: barSize

  IpcHandler {
    target: "io.github.kholis.gp-vpn"
    function refresh(): void {
      if (!pollProc.running) pollProc.running = true
    }
    function status(): string {
      return "iface=" + root.iface
        + " connected=" + root.connected
        + " visible=" + root.visible
        + " lastPoll='" + root.lastPoll + "'"
        + " elapsed='" + root.elapsed + "'"
        + " since=" + Math.round(root.sinceEpoch)
        + " portal='" + root.portal + "'"
    }
  }

  // One shot: prints "up <connect-epoch>" or "down 0"; maintains the marker
  // file. Uses flags bit 0 (IFF_UP) because operstate is "unknown" on tunnels.
  Process {
    id: pollProc
    command: ["bash", "-c",
      "f=$(cat /sys/class/net/" + root.iface + "/flags 2>/dev/null) || f=0; " +
      "m=\"" + root.runtimeDir + "/gp-vpn-since\"; " +
      "if [ \"$((f & 1))\" != \"1\" ]; then rm -f \"$m\" 2>/dev/null; echo 'down 0'; exit 0; fi; " +
      "if ! [ -s \"$m\" ]; then " +
      "  s=$(stat -c %Y /opt/paloaltonetworks/globalprotect/ipt_mangle.txt 2>/dev/null || date +%s); " +
      "  printf '%s\\n' \"$s\" > \"$m\" 2>/dev/null || true; " +
      "fi; " +
      "if [ -s \"$m\" ]; then echo \"up $(cat \"$m\")\"; else echo \"up $(date +%s)\"; fi"
    ]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.lastPoll = String(text || "").trim()
        var parts = root.lastPoll.split(/\s+/)
        var up = parts[0] === "up"
        var since = parts.length > 1 ? parseFloat(parts[1]) : 0
        if (up && since > 0) {
          root.connected = true
          root.sinceEpoch = since
          root.refreshElapsed()
        } else {
          root.connected = false
          root.sinceEpoch = 0
          root.elapsed = ""
        }
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!pollProc.running) pollProc.running = true
  }

  Timer {
    interval: 1000
    running: root.connected
    repeat: true
    onTriggered: root.refreshElapsed()
  }

  Process {
    id: disconnectProc
    command: ["globalprotect", "disconnect"]
  }

  Process {
    id: connectProc
    command: ["bash", "-c", "globalprotect connect --portal '" + root.portal + "'"]
  }

  Row {
    id: content
    anchors.centerIn: parent
    spacing: Style.space(2)

    BarIconButton {
      id: button
      bar: root.bar
      width: implicitWidth
      height: implicitHeight
      text: "\uf132"
      slotSize: Style.bar.statusSlot
      fontSize: Style.font.caption
      tooltipText: root.connected
        ? "GlobalProtect VPN — connected since " + root.fmtClock(root.sinceEpoch)
        : "GlobalProtect VPN"
      onPressed: root.menuOpen = !root.menuOpen
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      leftPadding: Style.space(2)
      rightPadding: Style.space(6)
      text: root.elapsed
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
    }
  }

  PopupCard {
    id: menu
    anchorItem: root
    owner: root
    bar: root.bar
    open: root.menuOpen
    contentWidth: menu.fittedContentWidth(Style.space(260))
    contentHeight: menu.fittedContentHeight(menuColumn.implicitHeight)

    Column {
      id: menuColumn
      anchors.fill: parent
      spacing: Style.space(8)

      Text {
        text: "GlobalProtect VPN"
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: true
      }

      Text {
        text: root.connected
          ? "Connected since " + root.fmtClock(root.sinceEpoch) + " — " + root.elapsed
          : "Disconnected"
        color: Qt.darker(root.foreground, 1.3)
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }

      Text {
        visible: root.portal !== ""
        text: "Portal: " + root.portal
        color: Qt.darker(root.foreground, 1.3)
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
      }

      Button {
        text: root.connected ? "Disconnect" : "Connect"
        iconText: root.connected ? "\uf0c1" : "\uf127"
        foreground: root.foreground
        horizontalPadding: 10
        verticalPadding: 4
        fontSize: Style.font.bodySmall
        iconSize: Style.font.bodySmall
        enabled: root.connected || root.portal !== ""
        onClicked: {
          if (root.connected) {
            if (!disconnectProc.running) disconnectProc.running = true
          } else {
            if (!connectProc.running) connectProc.running = true
          }
          root.menuOpen = false
        }
      }
    }
  }
}

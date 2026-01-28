Write-Host "🪟 Installing Tailscale..."
winget install Tailscale.Tailscale -e --accept-package-agreements --accept-source-agreements

$zsh = "$env:USERPROFILE\.zshrc"
if (!(Test-Path $zsh)) { New-Item -ItemType File -Path $zsh }

Add-Content $zsh @'
# === Smart SSH with Tailscale ===
__ts_on() {
  command -v tailscale >/dev/null 2>&1 || return 1
  tailscale status --json 2>/dev/null | python3 - <<'PY'
import sys, json
try:
    d=json.load(sys.stdin)
except: exit(1)
state=d.get("BackendState","")
self_=d.get("Self",{}) or {}
exit(0 if state=="Running" and self_.get("Online") else 1)
PY
}

arty() {
  local USER="arty"
  local TS_IP="100.64.10.5"
  local NORMAL_IP="192.168.1.50"
  local PORT="22"

  if __ts_on && ping -c 1 "$TS_IP" >/dev/null 2>&1; then
    echo "🔐 Tailscale → $TS_IP"
    ssh -p "$PORT" "$USER@$TS_IP"
  else
    echo "🌐 LAN → $NORMAL_IP"
    ssh -p "$PORT" "$USER@$NORMAL_IP"
  fi
}
'@

Write-Host "✅ Installed! Restart terminal."

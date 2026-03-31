#!/bin/bash
# Play Windows system sounds from WSL via PowerShell
# Usage: sounds.sh [done|notify|alert]
PS="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
SOUND="${1:-done}"

case "$SOUND" in
  done)   SYMSOUND="Asterisk" ;;    # task complete
  notify) SYMSOUND="Exclamation" ;; # notification / needs input
  alert)  SYMSOUND="Hand" ;;        # permission request
  *)      SYMSOUND="Asterisk" ;;
esac

"$PS" -NoProfile -NonInteractive -WindowStyle Hidden -Command "
Add-Type -AssemblyName System.Windows.Forms
[System.Media.SystemSounds]::${SYMSOUND}.PlaySync()
" 2>/dev/null &

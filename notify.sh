#!/bin/bash
# WSL Windows toast notification for Claude Code
MESSAGE="${1:-Claude notification}"

# Full path needed — Claude Code overrides PATH, stripping Windows system dirs
PS="/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

# XML-encode special chars
ESCAPED=$(printf '%s' "$MESSAGE" | sed \
    's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&apos;/g')

# Fire-and-forget in background so hook exits immediately
"$PS" -NoProfile -NonInteractive -WindowStyle Hidden -Command "
\$ErrorActionPreference = 'SilentlyContinue'
\$msg = '${ESCAPED}'
try {
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
    \$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    \$xml.LoadXml('<toast><visual><binding template=\"ToastGeneric\"><text>Claude Code</text><text>' + \$msg + '</text></binding></visual></toast>')
    \$toast = [Windows.UI.Notifications.ToastNotification]::new(\$xml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe').Show(\$toast)
} catch {
    Add-Type -AssemblyName System.Windows.Forms
    \$n = New-Object System.Windows.Forms.NotifyIcon
    \$n.Icon = [System.Drawing.SystemIcons]::Information
    \$n.BalloonTipTitle = 'Claude Code'
    \$n.BalloonTipText = \$msg
    \$n.Visible = \$true
    \$n.ShowBalloonTip(4000)
    Start-Sleep -Milliseconds 5000
    \$n.Dispose()
}
" 2>/dev/null &

# CyberPatriots Hardening Script for Windows 10 and Windows Server

# Select Operating System
$osSelection = Read-Host "Select the operating system (Enter 1 for Windows 10, 2 for Windows Server)"

# Firewall and Antivirus Configuration
if ($osSelection -eq '1') {
    # Windows 10 Configuration
    
    # Enable Firewall for all profiles
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
    Write-Host "Firewall for Windows 10 is now enabled."

    # Disable unused services (example: remote desktop)
    Set-Service -Name TermService -StartupType Disabled
    Write-Host "Remote Desktop disabled."

    # Configure Automatic Updates
    Set-Service -Name wuauserv -StartupType Automatic
    Write-Host "Automatic Updates enabled."

    # Force Windows Update Check
    Write-Host "Checking for updates..."
    Start-Process -FilePath "powershell" -ArgumentList "saps powershell Start-WUScan -AsJob" -Wait
    Write-Host "Update check initiated."

    # Enable Windows Defender (assuming it's installed)
    Set-MpPreference -DisableRealtimeMonitoring $false
    Start-MpScan -ScanType QuickScan
    Write-Host "Windows Defender scan started."

    # Disable guest account for additional security
    net user guest /active:no
    Write-Host "Guest account disabled."
}
elseif ($osSelection -eq '2') {
    # Windows Server Configuration
    
    # Enable Firewall for all profiles
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
    Write-Host "Firewall for Windows Server is now enabled."

    # Disable unnecessary roles (example: Remote Desktop if not in use)
    Set-Service -Name TermService -StartupType Disabled
    Write-Host "Remote Desktop disabled."

    # Configure Automatic Updates
    Set-Service -Name wuauserv -StartupType Automatic
    Write-Host "Automatic Updates enabled."

    # Force Windows Update Check
    Write-Host "Checking for updates..."
    Start-Process -FilePath "powershell" -ArgumentList "saps powershell Start-WUScan -AsJob" -Wait
    Write-Host "Update check initiated."

    # Enable Windows Defender (assuming it's installed)
    Set-MpPreference -DisableRealtimeMonitoring $false
    Start-MpScan -ScanType QuickScan
    Write-Host "Windows Defender scan started."

    # Additional security hardening (example: disable SMBv1)
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
    Write-Host "SMBv1 protocol disabled for extra security."
}
else {
    Write-Host "Invalid selection. Please enter 1 for Windows 10 or 2 for Windows Server."
}

# Final Message
Write-Host "Security hardening process completed."

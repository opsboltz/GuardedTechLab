# Question
$osSelection = Read-Host "Select the operating system (Enter 1 for Windows 10, 2 for Windows Server)"

# Firewall and Antivirus Configuration
if ($osSelection -eq '1') {
    # Configuration for Windows 10 Firewall
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
    Write-Host "Firewall for Windows 10 is now enabled."

    # Example: Start-Process -FilePath "YourAntivirusCommand"
    Write-Host "Additional antivirus setup for Windows 10 completed."
}
elseif ($osSelection -eq '2') {
    # Config for windows 10 server Firewall
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
    Write-Host "Firewall for Windows Server is now enabled."

    # Example: Start-Process -FilePath "YourAntivirusCommand"
    Write-Host "Additional antivirus setup for Windows Server completed."
}
else {
    Write-Host "Invalid selection. Please enter 1 for Windows 10 or 2 for Windows Server."
}

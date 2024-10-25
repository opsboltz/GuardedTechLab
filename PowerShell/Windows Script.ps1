# CyberPatriots Hardening Script for Windows 10 and Windows Server

# Function to check and list enabled services
function Check-EnabledServices {
    $services = @{
        "1" = @{ Name = "TermService"; DisplayName = "RDP (Remote Desktop)" }
        "2" = @{ Name = "sshd"; DisplayName = "SSH (OpenSSH Server)" }
        "3" = @{ Name = "ftpsvc"; DisplayName = "FTP (FTP Server)" }
        "4" = @{ Name = "LanmanServer"; DisplayName = "SMB (Server Message Block)" }
    }

    Write-Host "`nEnabled Services:`n"

    foreach ($service in $services.GetEnumerator()) {
        $status = (Get-Service -Name $service.Value.Name -ErrorAction SilentlyContinue).Status
        Write-Host "$($service.Key): $($service.Value.DisplayName) - Status: $status"
    }
    
    return $services
}

# Function to enable or disable a service
function Manage-Service {
    param (
        [string]$serviceName,
        [string]$serviceDisplayName
    )

    $currentStatus = (Get-Service -Name $serviceName -ErrorAction SilentlyContinue).Status
    if ($currentStatus -eq 'Running') {
        $response = Read-Host "Do you want to disable $serviceDisplayName? (Enter Y for Yes, N for No)"
        if ($response -eq 'Y') {
            Set-Service -Name $serviceName -StartupType Disabled
            Write-Host "$serviceDisplayName has been disabled."
        } else {
            Write-Host "$serviceDisplayName remains enabled."
        }
    } else {
        $response = Read-Host "Do you want to enable $serviceDisplayName? (Enter Y for Yes, N for No)"
        if ($response -eq 'Y') {
            Set-Service -Name $serviceName -StartupType Automatic
            Start-Service -Name $serviceName
            Write-Host "$serviceDisplayName has been enabled."
        } else {
            Write-Host "$serviceDisplayName remains disabled."
        }
    }
}

# Additional Security Measures
function Apply-SecurityMeasures {
    Write-Host "`nApplying additional security measures..."
    
    # Disable guest account for additional security
    net user guest /active:no
    Write-Host "Guest account disabled."

    # Disable SMBv1
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
    Write-Host "SMBv1 protocol disabled for extra security."

    # Enable Windows Firewall
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
    Write-Host "Firewall is now enabled."
}

# Main Script Execution
$osSelection = Read-Host "Select the operating system (Enter 1 for Windows 10, 2 for Windows Server)"

if ($osSelection -eq '1') {
    Write-Host "`nConfiguring Windows 10..."
} elseif ($osSelection -eq '2') {
    Write-Host "`nConfiguring Windows Server..."
} else {
    Write-Host "Invalid selection. Please enter 1 for Windows 10 or 2 for Windows Server."
    exit
}

# Configure Automatic Updates
Set-Service -Name wuauserv -StartupType Automatic
Write-Host "Automatic Updates enabled."

# Force Windows Update Check
Write-Host "Checking for updates..."
Start-Process -FilePath "powershell" -ArgumentList "saps powershell Start-WUScan -AsJob" -Wait
Write-Host "Update check initiated."

# Enable Windows Defender (assuming it's installed)
try {
    Set-MpPreference -DisableRealtimeMonitoring $false
    Start-MpScan -ScanType QuickScan
    Write-Host "Windows Defender scan started."
} catch {
    Write-Host "Error enabling Windows Defender: $_"
}

# Service Management Loop
while ($true) {
    $services = Check-EnabledServices
    Write-Host "Enter the number of the service to manage, or 'exit' to continue with the script:"
    
    $input = Read-Host
    if ($input -eq 'exit') {
        break
    } elseif ($services.ContainsKey($input)) {
        $service = $services[$input]
        Manage-Service -serviceName $service.Name -serviceDisplayName $service.DisplayName
    } else {
        Write-Host "Invalid input. Please enter a valid number or 'exit'."
    }
}

# Apply additional security measures
Apply-SecurityMeasures

# Final Message
Write-Host "Security hardening process completed."

Write-Host "                                                                                
                                                                                
                                                        
                                                                                
                              ░ ▓▓▓▓▓▓▓                                         
                           ░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                                     
                         ░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                                   
                         ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                                  
                       ░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ░░░░░                           
                        ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                         
                      ░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░                      
                   ░ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                      
                ░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ░░                                     
                ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                     ░▓▓▓░                
               ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░              
             ░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓    ░▓▓▓▓▓▓           ▓▓▓▓▓▓▓▓▒             
             ░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓    ▓▓▓▓░                 ░▓▓▓▓             
             ░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓     ▓▓▓ ░░░░░░░░░░░░░      ░▓▓░            
              ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░    ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░   ░▓             
              ░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                  ░░▓▓▓▓░   ░             
               ░ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░                 ▓▓▓▓░                 
                   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓                   
                      ░   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ░                   
                                                                                
                                                                   
                                                                                
" -ForegroundColor White  
                                                                            
###################################
### Luuk Leenheer @ Score Utica ###
###           30-5-2024         ###
###################################

# Functions #


# Scriptblock #


# Variables #
$userDesktop = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop))
$outputCsv = "$UserDesktop\servers.csv"
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isServer = (Get-WmiObject Win32_OperatingSystem).ProductType -eq 3
$osVersion = [System.Environment]::OSVersion.Version

##################################################################################################################################

# Script #

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Host "`nActiveDirectory module not found. Attempting to install..." 

    # Check if the script is running with administrative privileges
    if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "`nThis script needs to be run as an administrator."
        Pause
    }

    # Check if the script is running on Windows Server
    if ($isServer) {
        try {
            Install-WindowsFeature -Name "RSAT-AD-PowerShell" | Out-Null
            Write-Host "`nActiveDirectory module installed successfully." -ForegroundColor Green
        } catch {
            Write-Error "`nFailed to install the ActiveDirectory module: $_"
            Pause 
        }
    } else {
        try {
            if ($osVersion.Major -ge 10) {
                Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" | Out-Null
                Write-Host "`nActiveDirectory module installed successfully." -ForegroundColor Green
            } else {
                Write-Host "`nUnsupported OS version." -ForegroundColor Red
            }
        } catch {
            Write-Host "`nFailed to install the ActiveDirectory module: $_" -ForegroundColor Red
        }
    }
} else {
    Import-Module ActiveDirectory
    Write-Host "`nActiveDirectory module imported." -ForegroundColor Green
}

$servers = Get-ADComputer -Filter {OperatingSystem -like "*Windows Server*"} -Property DNSHostName |
    Select-Object @{Name="ServerName";Expression={$_.DNSHostName}} | Export-Csv -Path "$outputCsv" -NoTypeInformation
    Write-Host "`nExport finished, $outputCsv"
    
Pause
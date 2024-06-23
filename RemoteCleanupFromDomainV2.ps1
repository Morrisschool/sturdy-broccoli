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

<# Changelog

   17-6-2024: Added CCM Cache cleanup & Throttled Parallelism
   10-6-2024: Converted runbook code to Invoke-Command & Removed debug code

#>

# Functions #
function Get-FilePath {
    Add-Type -AssemblyName System.Windows.Forms
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = "CSV files (*.csv)|*.csv"
    $fileDialog.Multiselect = $false
    $fileDialog.ShowDialog() | Out-Null
    return $fileDialog.FileName
}

# Scriptblock #
$cleanupScriptBlock = {

    # Clean Update Cache
    $WUService = Get-Service wuauserv
    if ($WUService.Status -eq "Running") { $WUService | Stop-Service -Force | Out-Null } 
    $UpdateCachePath = Join-Path $env:windir "SoftwareDistribution\Download"
    Get-ChildItem -Path $UpdateCachePath -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    $WUService | Start-Service | Out-Null

    # Clean CCM Cache
    $CachePath = ([wmi]"ROOT\ccm\SoftMgmtAgent:CacheConfig.ConfigKey='Cache'").Location
    $CcmCache = Get-WmiObject -Query "SELECT * FROM CacheInfoEx" -Namespace "ROOT\ccm\SoftMgmtAgent"
    $CcmCache | ForEach-Object { Remove-Item -Path $_.Location -Recurse -Force -ErrorAction SilentlyContinue }
    $CcmCache | Remove-WmiObject -ErrorAction SilentlyContinue
    $CacheFoldersDisk = (Get-ChildItem $CachePath).FullName
    $CacheFoldersWMI = Get-WmiObject -Query "SELECT * FROM CacheInfoEx" -Namespace "ROOT\ccm\SoftMgmtAgent"
    $CacheFoldersDisk | ForEach-Object { if ($_ -notin $CacheFoldersWMI.Location) { Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue } }
    $CacheFoldersWMI | ForEach-Object { if ($_.Location -notin $CacheFoldersDisk) { $_ | Remove-WmiObject -ErrorAction SilentlyContinue } }

    try {
        $diskSpace = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$env:SystemDrive'" | Select-Object -ExpandProperty FreeSpace
        $diskSpaceGB = [math]::Round($diskSpace / 1GB, 2)
        
        if ($diskSpaceGB -lt 5) {
            Write-Host "`nFree disk space on $($env:COMPUTERNAME) after cleanup: $diskSpaceGB GB" -ForegroundColor Red
        } else {
            Write-Host "`nFree disk space on $($env:COMPUTERNAME) after cleanup: $diskSpaceGB GB" -ForegroundColor Green
        }
    } catch {
        Write-Host "$($env:COMPUTERNAME): Error retrieving disk space: $_" -ForegroundColor Red
    }
}

# Variables #
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
$results = @()
$objNotifyIcon = New-Object System.Windows.Forms.NotifyIcon
$objNotifyIcon.Icon = [System.Drawing.SystemIcons]::Information
$objNotifyIcon.BalloonTipIcon = "Info" 
$objNotifyIcon.BalloonTipText = "All servers have been cleaned up" 
$objNotifyIcon.BalloonTipTitle = "Windows Cleanup Script"
$objNotifyIcon.Visible = $True

##################################################################################################################################

# Script #
Write-Host "`nPlease select a CSV file containing the server hostnames, Make sure not to remove or change the 'ServerName' column"
$csvPath = Get-FilePath
if (-not $csvPath) {
    Write-Host "`nNo file selected, exiting script." -ForegroundColor Red
    Pause
}

# Prompt the user to choose whether they want to exclude a server from cleanup
$choice = Read-Host "`nDo you want to exclude a server from cleanup? (y/n)"

if ($choice -eq 'y') {
    # Prompt the user to enter the hostname of the server they do not wish to cleanup
    $excludedHostname = Read-Host "`nPlease enter the FQDN (f.e. TC5UTIL02.merford.local / AM5-APP-05.healthlinkeurope.com ) of the server you wish not to cleanup"
}
elseif ($choice -eq 'n') {
}


# Filter and import servers
$serverList = Import-Csv -Path $csvPath | 
    Select-Object -ExpandProperty ServerName | 
    Where-Object { 
        $_ -ne $env:COMPUTERNAME -and 
        $_ -ne $excludedHostname
    }

$credential = Get-Credential -Credential $null

Write-Host "`nStarting Cleanups"
Invoke-Command -ComputerName $serverList -ScriptBlock $cleanupScriptBlock -ArgumentList $SystemDrive -Credential $credential -ErrorAction Inquire -ThrottleLimit 5
Write-Host "`nAll servers have been cleaned up"
Pause
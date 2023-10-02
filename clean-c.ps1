<#
### Version 1.2 BETA
### Changelog
## 18-02-2021
# Added Cleanup local profiles
# Removed a lot of write-host to make it easier to use with invoke-command
# Disabeld running cleanmgr when running via invoke-command
# Started this changelog!
control smscfgrc
## 22-09-2021
# Excluded Jurgen and Hans adm profiles from profile cleanup UM2109 3023
# Auto start control smscfgrc at the end of the script
# Moved script to Score Utica ICT - Documenten\Script Repository\File Services\Cleanup Script
#>
Function Start-Cleanup {
    ## Allows the use of -WhatIf
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
    ## Delete data older then $daystodelete
    [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=0)]
    $DaysToDelete = 7,
    ## LogFile path for the transcript to be written to
    [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=1)]
    $LogFile = ("$env:TEMP\" + (get-date -format "MM-d-yy-HH-mm") + '.log'),
    ## All verbose outputs will get logged in the transcript($logFile)
    [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=2)]
    $VerbosePreference = "Continue",
    ## All errors should be withheld from the console
    [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=3)]
    $ErrorActionPreference = "SilentlyContinue"
    )
    ## Begin the timer
    $Starters = (Get-Date)
    ## Check $VerbosePreference variable, and turns -Verbose on
    Function global:Write-Verbose ( [string]$Message ) {
    if ( $VerbosePreference -ne 'SilentlyContinue' ) {
    }
    }
    ## Tests if the log file already exists and renames the old file if it does exist
    if(Test-Path $LogFile){
    ## Renames the log to be .old
    Rename-Item $LogFile $LogFile.old -Force
    } else {
    ## Starts a transcript in C:\temp so you can see which files were deleted
    write-host (Start-Transcript -Path $LogFile) -ForegroundColor Green
    }
    ## Removes local sup and adm user folders. Excluding Hans and Jurgen admin accounts Added by Rik
    $localprofiles = Get-WmiObject win32_userprofile | Where-Object {($_.LocalPath -like "C:\Users\sup.*") -or ($_.LocalPath -like "C:\Users\adm.*") -and ($_.LocalPath -notlike "C:\Users\adm.hans") -and ($_.LocalPath -notlike "C:\Users\adm.jurgen")}
    foreach ($profile in $localprofiles){
    $profile | Remove-WmiObject -Verbose
    }
    
    ## https://www.itninja.com/blog/view/manage-purge-local-windows-user-profiles
    
    ## Stops the windows update service so that c:\windows\softwaredistribution can be cleaned up
    #Get-Service -Name wuauserv | Stop-Service -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    ## Deletes the contents of windows software distribution.
    Get-ChildItem "C:\Windows\SoftwareDistribution\Download" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -recurse -ErrorAction SilentlyContinue
    ## Deletes the contents of the Windows Temp folder.
    Get-ChildItem "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays( - $DaysToDelete)) } | Remove-Item -force -recurse -ErrorAction SilentlyContinue
    ## Removes *.log from C:\windows\CBS
    if(Test-Path C:\Windows\logs\CBS\){
    Get-ChildItem "C:\Windows\logs\CBS\*.log" -Recurse -Force -ErrorAction SilentlyContinue |
    remove-item -force -recurse -ErrorAction SilentlyContinue
    } else {
    }
    
    ## Removes C:\Config.Msi
    if (test-path C:\Config.Msi){
    remove-item -Path C:\Config.Msi -force -recurse -ErrorAction SilentlyContinue
    } else {
    }
    ## Removes c:\Intel
    if (test-path c:\Intel){
    remove-item -Path c:\Intel -force -recurse -ErrorAction SilentlyContinue
    } else {
    }
    ## Removes c:\PerfLogs
    if (test-path c:\PerfLogs){
    remove-item -Path c:\PerfLogs -force -recurse -ErrorAction SilentlyContinue
    } else {
    }
    ## Removes $env:windir\memory.dmp
    if (test-path $env:windir\memory.dmp){
    remove-item $env:windir\memory.dmp -force -ErrorAction SilentlyContinue
    } else {
    }
    ## Removes rouge folders
    ## Removes Windows Error Reporting files
    if (test-path C:\ProgramData\Microsoft\Windows\WER){
    Get-ChildItem -Path C:\ProgramData\Microsoft\Windows\WER -Recurse | Remove-Item -force -recurse -ErrorAction SilentlyContinue
    } else {
    }
    ## Removes System and User Temp Files - lots of access denied will occur.
    ## Cleans up c:\windows\temp
    if (Test-Path $env:windir\Temp\) {
    Remove-Item -Path "$env:windir\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue
    } else {
    }
    ## Cleans up minidump
    if (Test-Path $env:windir\minidump\) {
    Remove-Item -Path "$env:windir\minidump\*" -Force -Recurse -ErrorAction SilentlyContinue
    } else {
    }
    ## Cleans up all users windows error reporting
    if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\WER\") {
    Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\WER\*" -Force -Recurse -ErrorAction SilentlyContinue
    } else {
    }
    
    ## Removes the hidden recycling bin.
    if (Test-path 'C:\$Recycle.Bin'){
    Remove-Item 'C:\$Recycle.Bin' -Recurse -Force -ErrorAction SilentlyContinue
    } else {
    }
    ## Turns errors back on
    $ErrorActionPreference = "Continue"
    ## Checks the version of PowerShell
    ## If PowerShell version 4 or below is installed the following will process
    if ($PSVersionTable.PSVersion.Major -le 4) {
    ## Empties the recycling bin, the desktop recyling bin
    $Recycler = (New-Object -ComObject Shell.Application).NameSpace(0xa)
    $Recycler.items() | ForEach-Object {
    ## If PowerShell version 4 or bewlow is installed the following will process
    Remove-Item -Include $_.path -Force -Recurse
    }
    } elseif ($PSVersionTable.PSVersion.Major -ge 5) {
    ## If PowerShell version 5 is running on the machine the following will process
    Clear-RecycleBin -DriveLetter C:\ -Force
    }
    ## Starts cleanmgr.exe
    Function Start-CleanMGR {
    Try{
    Start-Process -FilePath Cleanmgr -ArgumentList '/sagerun:1' -Wait -Verbose
    }
    Catch [System.Exception]{
    write-host "cleanmgr is not installed! To use this portion of the script you must install the following windows features:" -ForegroundColor Red -NoNewline
    write-host "[ERROR]" -ForegroundColor Red -BackgroundColor black
    }
    }
    if ($PSSenderInfo) {
    write-host "Not starting cleanmgr because it is running remotely"
    }
    else {
    write-host "Running locally starting cleanmgr"
    Start-CleanMGR
    }
    ## gathers disk usage after running the cleanup cmdlets.
    $After = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,
    @{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },
    @{ Name = "Size (GB)" ; Expression = {"{0:N1}" -f ( $_.Size / 1gb)}},
    @{ Name = "FreeSpace (GB)" ; Expression = {"{0:N1}" -f ( $_.Freespace / 1gb ) } },
    @{ Name = "PercentFree" ; Expression = {"{0:P1}" -f ( $_.FreeSpace / $_.Size ) } } |
    Format-Table -AutoSize | Out-String
    write-host $After
    ## Restarts wuauserv
    #Get-Service -Name wuauserv | Start-Service -ErrorAction SilentlyContinue
    ## Stop timer
    $Enders = (Get-Date)
    ## Calculate amount of seconds your code takes to complete.
    Write-host "Elapsed Time: $(($Enders - $Starters).totalseconds) seconds"
    ## Sends hostname to the console for ticketing purposes.
    write-host (Hostname) -ForegroundColor Green
    ## Sends the date and time to the console for ticketing purposes.
    write-host (Get-Date | Select-Object -ExpandProperty DateTime) -ForegroundColor Green
    ## Sends the disk usage after running the cleanup script to the console for ticketing purposes.
    Write-Verbose "After: $After"
    ## Completed Successfully!
    write-host (Stop-Transcript) -ForegroundColor Green
    write-host "Script finished" -NoNewline -ForegroundColor Green
    write-host "Starting Configuration Manager Cleanup: Cache > Instellingen configureren > Bestanden verwijderen" -ForegroundColor Green
    control smscfgrc
    }
    Start-Cleanup
    

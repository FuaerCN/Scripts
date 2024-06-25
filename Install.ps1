[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
$SplitPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$Software = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName


function System-Settings {
    Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose 2>&1>$null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main" -Name "DisableFirstRunCustomize" -Value 2
    
    Write-Host "Extend Partition Size ..."
    $Size = (Get-PartitionSupportedSize -DriveLetter C)
    Resize-Partition -DriveLetter C -Size $Size.SizeMax 2>&1>$null

    Write-Host "Change Virtual RAM ..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name 'VisualFXSetting' -Value 2
    $computerSystem = Get-WmiObject -Class Win32_ComputerSystem -EnableAllPrivileges
    $computerSystem.AutomaticManagedPagefile = $false
    $computerSystem.Put() | Out-Null
    $pageFileSetting = Get-WmiObject -Class Win32_PageFileSetting
    $pageFileSetting.InitialSize = 20000
    $pageFileSetting.MaximumSize = 30000
    $pageFileSetting.Put() | Out-Null

    Write-Host "Never check for updates (not recommended)"
    New-Item HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name WindowsUpdate 2>&1>$null
    New-Item HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name AU 2>&1>$null
    New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name NoAutoUpdate -Value 1 2>&1>$null
    Set-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name NoAutoUpdate -Value 1 2>&1>$null

    Write-Host "Activate Windows ..."
    slmgr //B /ato
    slmgr //B /xpr
}

function Install-AzureCLI {
    If (-Not ($Software -like 'Microsoft Azure CLI')) {
        Write-Host "Installing Azure CLI ..."
        Invoke-WebRequest -Uri https://azcliprod.blob.core.windows.net/msi/azure-cli-2.33.1.msi -OutFile .\AzureCLI.msi
        Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
        rm .\AzureCLI.msi
    }
}

function Install-Chrome {
    If (-Not ($Software -like 'Google Chrome')) {
        Write-Host "Installing Chrome ..."
        (New-Object System.Net.WebClient).DownloadFile("https://dl.google.com/chrome/install/chrome_installer.exe", "chrome_installer.exe")
        Start-Process -FilePath "chrome_installer.exe" -Args '/silent /install'  -Verb RunAs -Wait
        Remove-Item -Path "chrome_installer.exe"
    }
    #Chrome Bookmarks: %LocalAppData%\Google\Chrome\User Data\Default\
    If ((Test-Path "$SplitPath\Bookmarks") -eq "True") { 
        Write-Host "Chrome Bookmarks ..."
        New-Item -Path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default" -ItemType Directory -Force 2>&1>$null
        Copy-Item -Path "$SplitPath\Bookmarks" "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Bookmarks" -force
    }
}

function Install-PowerShell {
    If (($PSVersionTable.PSVersion.Major) -lt 5) {
        Write-Host "Installing PowerShell 5.1 ..."
        $Caption = (Get-WmiObject -class Win32_OperatingSystem).Caption
        If ( $Caption -match 'Server 2012 R2') {
            (New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu", "Win8.1AndW2K12R2-KB3191564-x64.msu")
            Start-Process -FilePath 'C:\Windows\System32\wusa.exe' -ArgumentList '"Win8.1AndW2K12R2-KB3191564-x64.msu" /quiet /norestart' -Wait -NoNewWindow
            Remove-Item -Path 'Win8.1AndW2K12R2-KB3191564-x64.msu'
            Restart-Computer -Force
        } ElseIf  ( $Caption -match 'Server 2012') {
            Invoke-WebRequest -Uri https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/W2K12-KB3191565-x64.msu -OutFile .\W2K12-KB3191565-x64.msu
            Start-Process -FilePath 'C:\Windows\System32\wusa.exe' -ArgumentList '"W2K12-KB3191565-x64.msu" /quiet /norestart' -Wait -NoNewWindow
            rm .\W2K12-KB3191565-x64.msu
            Restart-Computer -Force
        } Else {
            Write-Error $Caption
        }
    } else {
        Write-Host "Installing Module ..."
        Install-PackageProvider -Name NuGet -Force
        Install-Module -Scope AllUsers AzureAD,MSOnline,PnP.PowerShell,Microsoft.Online.SharePoint.PowerShell,ExchangeOnlineManagement,NameIT -Force
    }
}


While($InNumber -ne 0) {
    Invoke-Command {cls}
    Write-Host "###############################################" -ForegroundColor Green
    Write-Host "#  0. Install All                             #"
    Write-Host "#  1. System Settings                         #"
    Write-Host "#  2. Install Chrome                          #"
    Write-Host "#  3. Install AzureCLI                        #"
    Write-Host "#  4. Install PowerShell                      #"
    Write-Host "###############################################" -ForegroundColor Green
    
    $InNumber = Read-Host 'Please Input The Number to Operate'
    
    switch($InNumber)
    {
    1 {
    #System Settings
    System-Settings
    } 
    2 {
    #Install Chrome
    Install-Chrome
    }
    3 {
    #Install AzureCLI
    Install-AzureCLI
    }
    4 {
    #Install PowerShell
    Install-PowerShell
    }
    #
    0 {
    #Install All
    System-Settings
    Install-Chrome
    Install-AzureCLI
    Install-PowerShell
    }
    
    Default { Write-Host "Please enter the corresponding number" -ForegroundColor Red}
    
    }
    Pause
}

<#
.SYNOPSIS
   VmwareHardenedLoader - All-in-One VM Cloaking & Driver Installer
   Spoof edilecek profil: Lenovo Ideapad Gaming 3 15IHU6 + NVIDIA GTX 1060
.NOTES
   Yalnizca VMware Workstation sanal makinede calistirilmalidir!
#>

#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"

# ============================================================
# Hedef Donanim Profili (Tum spooflar buradan beslenir)
# ============================================================
$HW = @{
    Manufacturer    = "LENOVO"
    ProductName     = "Ideapad Gaming 3 15IHU6"
    Family          = "82K1"
    SKU             = "LENOVO_MT_82K1_BU_idea_FM_IdeaPad Gaming 3 15IHU6"
    BIOSVendor      = "LENOVO"
    BIOSVersion     = "H4CN37WW(V2.06)"
    BIOSMajor       = 2
    BIOSMinor       = 37
    BaseBoardMfg    = "LENOVO"
    BaseBoardProduct = "LNVNB161216"
    BaseBoardVersion = "SDK0T76463 WIN"
    SystemVersion   = "IdeaPad Gaming 3 15IHU6"
    GPU_Desc        = "NVIDIA GeForce GTX 1060 6GB"
    GPU_ChipType    = "GeForce GTX 1060"
    GPU_Provider    = "NVIDIA"
    GPU_MatchId     = "pci\ven_10de&dev_1c03"
    GPU_BiosString  = "Version 86.06.3C.00.20"
    OEMID           = "LENOVO"
    DiskId          = "CT500MX500SSD1"
}

# Kullanici onayi
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   VmwareHardenedLoader - All-in-One Installer       ║" -ForegroundColor Cyan
Write-Host "  ║   Hedef Profil: $($HW.ProductName)     ║" -ForegroundColor DarkCyan
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [!] Bu islem sistem donanim bilgilerini spoof edecektir." -ForegroundColor Yellow
Write-Host "  [!] Yalnizca VMware sanal makinede calistirin!" -ForegroundColor Red
Write-Host ""
$title = "Devam etmek istiyor musunuz?"
$message = "Donanim bilgileri degistirilecek."
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Evet", "Isleme devam et."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&Hayir", "Islemi iptal et."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 1) 
if ($result -eq 1) {
    Write-Host "Islem iptal edildi." -ForegroundColor Yellow
    exit
}

$stepTotal = 5
$stepCurrent = 0
function Step([string]$msg) {
    $script:stepCurrent++
    Write-Host ""
    Write-Host "  [$script:stepCurrent/$stepTotal] $msg" -ForegroundColor Green
    Write-Host "  $('-' * 50)" -ForegroundColor DarkGray
}

# ============================================================
# ADIM 1: SMBIOS / BIOS Registry Spoofing
# ============================================================
Step "SMBIOS & BIOS kayitlari spoof ediliyor..."
$SystemKeyPath = "HKLM:\HARDWARE\DESCRIPTION\System"
try {
    Set-ItemProperty -Path $SystemKeyPath -Name "BaseBoardManufacturer" -Value $HW.BaseBoardMfg -Type String -Force
    Set-ItemProperty -Path "$SystemKeyPath\BIOS" -Name "BaseBoardManufacturer" -Value $HW.BaseBoardMfg -Type String -Force
    Set-ItemProperty -Path "$SystemKeyPath\BIOS" -Name "BaseBoardProduct" -Value $HW.BaseBoardProduct -Type String -Force
    Set-ItemProperty -Path "$SystemKeyPath\BIOS" -Name "BaseBoardVersion" -Value $HW.BaseBoardVersion -Type String -Force
    Set-ItemProperty -Path "$SystemKeyPath\BIOS" -Name "BiosMajorRelease" -Value $HW.BIOSMajor -Type DWord -Force
    Set-ItemProperty -Path "$SystemKeyPath\BIOS" -Name "BiosMinorRelease" -Value $HW.BIOSMinor -Type DWord -Force
    Set-ItemProperty -Path "$SystemKeyPath\BIOS" -Name "BIOSVendor" -Value $HW.BIOSVendor -Type String -Force
    Set-ItemProperty -Path "$SystemKeyPath\BIOS" -Name "BIOSVersion" -Value $HW.BIOSVersion -Type String -Force
    Set-ItemProperty -Path "$SystemKeyPath\BIOS" -Name "SystemManufacturer" -Value $HW.Manufacturer -Type String -Force
    Set-ItemProperty -Path "$SystemKeyPath\BIOS" -Name "SystemProductName" -Value $HW.ProductName -Type String -Force
    Set-ItemProperty -Path "$SystemKeyPath\BIOS" -Name "SystemFamily" -Value $HW.Family -Type String -Force
    Set-ItemProperty -Path "$SystemKeyPath\BIOS" -Name "SystemSKU" -Value $HW.SKU -Type String -Force
    Set-ItemProperty -Path "$SystemKeyPath\BIOS" -Name "SystemVersion" -Value $HW.SystemVersion -Type String -Force
    Write-Host "    [OK] BIOS kayitlari spoof edildi" -ForegroundColor Green
} catch {
    Write-Host "    [WARN] BIOS spoof'ta bazi hatalar: $_" -ForegroundColor Yellow
}

# ============================================================
# ADIM 2: VMware Izlerini Temizleme (Process, Registry, Files)
# ============================================================
Step "VMware izleri temizleniyor..."
try {
    & {
        $all = $true
        $reg = $true
        $procs = $true
        $files = $true
        
#################################################
## VMwareCloak.ps1: A script that attempts to hide the VMware Workstation hypervisor from malware by modifying registry keys, killing associated processes, and removing uneeded driver/system files.
## Written and tested on Windows 7 and Windows 10. Should work for Windows 11 as well!
## Many thanks to pafish for some of the ideas - https://github.com/a0rtega/pafish
##################################################
## Author: d4rksystem (Kyle Cucci)
## Version: 0.4
##################################################

# Define command line parameters


if ($all) {
    $reg = $true
    $procs = $true
    $files = $true
}

# Menu / Helper stuff
Write-Output ""
Write-Output "VMwareCloak.ps1 by @d4rksystem (Kyle Cucci)"
Write-Output "Usage: VMwareCloak.ps1 -<option>"
Write-Output "Example Usage: VMwareCloak.ps1 -all"
Write-Output "Options:"
Write-Output "all: Enable all options."
Write-Output "reg: Make registry changes."
Write-Output "procs: Kill processes."
Write-Output "files: Make file system changes."
Write-Output "Tips: Run as System or you will get a lot of errors!"
Write-Output "Warning: Only run in a virtual machine!"
Write-Output "*****************************************"
Write-Output ""

# -------------------------------------------------------------------------------------------------------
# Define random string generator function

function Get-RandomString {

    $charSet = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
    
    for ($i = 0; $i -lt 10; $i++ ) {
        $randomString += $charSet | Get-Random
    }

    return $randomString
}

# -------------------------------------------------------------------------------------------------------
# Stop VMware Processes

$process_list = "vmtoolsd", "vm3dservice", "VGAuthService", "VMwareService", "Vmwaretray", "Vmwareuser", "TPAutoConnSvc"

if ($procs) {

    Write-Output '[*] Attempting to kill VMware processes...'

    foreach ($p in $process_list) {

        $process = Get-Process "$p" -ErrorAction SilentlyContinue

        if ($process) {
            $process | Stop-Process -Force
            Write-Output "[*] $p process killed!"
        }

        if (!$process) {
            Write-Output "[!] $p process does not exist!"
        }
     }        
}

# -------------------------------------------------------------------------------------------------------
# Modify VMware registry keys

if ($reg) {

   # Remove or rename VMware-related registry keys

    if (Get-ItemProperty -Path "HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 3\Scsi Bus 1\Target Id 0\Logical Unit Id 0\" -Name "Identifier" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 3\Scsi Bus 1\Target Id 0\Logical Unit Id 0\Identifier"
        Set-ItemProperty -Path "HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 3\Scsi Bus 1\Target Id 0\Logical Unit Id 0\" -Name "Identifier" -Value $HW.DiskId

     } Else {

        Write-Output '[!] Reg Key HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 3\Scsi Bus 1\Target Id 0\Logical Unit Id 0\Identifier" does not seem to exist! Skipping this one...'
    }

    if (Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e97d-e325-11ce-bfc1-08002be10318}\0133\" -Name "DriverDesc" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e97d-e325-11ce-bfc1-08002be10318}\0133\DriverDesc"
        Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e97d-e325-11ce-bfc1-08002be10318}\0133\" -Name "DriverDesc" -Value "Intel(R) USB 3.0 eXtensible Host Controller"

     } Else {

        Write-Output '[!] Reg Key HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e97d-e325-11ce-bfc1-08002be10318}\0133\DriverDesc does not seem to exist! Skipping this one...'
    }

    if (Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e97d-e325-11ce-bfc1-08002be10318}\0133\" -Name "InfSection" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:SYSTEM\ControlSet001\Control\Class\{4d36e97d-e325-11ce-bfc1-08002be10318}\0133\InfSection"
        Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e97d-e325-11ce-bfc1-08002be10318}\0133\" -Name "InfSection" -Value "XHCI_Install"

     } Else {

        Write-Output '[!] Reg Key HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e97d-e325-11ce-bfc1-08002be10318}\0133\InfSection does not seem to exist! Skipping this one...'
    }

    if (Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System" -Name "SystemBiosVersion" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\HARDWARE\DESCRIPTION\System\SystemBiosVersion..."
        Set-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System" -Name "SystemBiosVersion" -Value $HW.BIOSVersion

     } Else {

        Write-Output '[!] Reg Key HKLM:\HARDWARE\DESCRIPTION\System\SystemBiosVersion does not seem to exist! Skipping this one...'
    }

    if (Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BIOSVendor" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\HARDWARE\DESCRIPTION\System\BIOS\BIOSVendor..."
	Set-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BIOSVendor" -Value "American Megatrends International, LLC."

     } Else {

        Write-Output '[!] Reg Key HKLM:\HARDWARE\DESCRIPTION\System\BIOS\BIOSVendor does not seem to exist! Skipping this one...'
    }

    if (Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BIOSVersion" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\HARDWARE\DESCRIPTION\System\BIOS\BIOSVersion..."
        Set-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BIOSVersion" -Value  1.70

     } Else {

        Write-Output '[!] Reg Key HKLM:\HARDWARE\DESCRIPTION\System\BIOS\BIOSVersion does not seem to exist! Skipping this one...'
    }

    if (Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemManufacturer" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\HARDWARE\DESCRIPTION\System\BIOS\SystemManufacturer..."
        Set-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemManufacturer" -Value $HW.Manufacturer

     } Else {

        Write-Output '[!] Reg Key HKLM:\HARDWARE\DESCRIPTION\System\BIOS\SystemManufacturer does not seem to exist! Skipping this one...'
    }
	
	if (Get-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemProductName" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\HARDWARE\DESCRIPTION\System\BIOS\SystemProductName..."
        Set-ItemProperty -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemProductName" -Value $HW.ProductName

     } Else {

        Write-Output '[!] Reg Key HKLM:\HARDWARE\DESCRIPTION\System\BIOS\SystemProductName does not seem to exist! Skipping this one...'
    }
	
	if (Get-ItemProperty -Path "HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0" -Name "Identifier" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0\Identifier..."
        Set-ItemProperty -Path "HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0" -Name "Identifier" -Value $HW.DiskId

     } Else {

        Write-Output '[!] Reg Key HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0\Identifier does not seem to exist! Skipping this one...'
    }

	if (Get-ItemProperty -Path "HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 1\Scsi Bus 0\Target Id 0\Logical Unit Id 0" -Name "Identifier" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 1\Scsi Bus 0\Target Id 0\Logical Unit Id 0\Identifier..."
        Set-ItemProperty -Path "HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 1\Scsi Bus 0\Target Id 0\Logical Unit Id 0" -Name "Identifier" -Value $HW.DiskId

     } Else {

        Write-Output '[!] Reg Key HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 1\Scsi Bus 0\Target Id 0\Logical Unit Id 0\Identifier does not seem to exist! Skipping this one...'
    }

	if (Get-ItemProperty -Path "HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 2\Scsi Bus 0\Target Id 0\Logical Unit Id 0" -Name "Identifier" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 2\Scsi Bus 0\Target Id 0\Logical Unit Id 0\Identifier..."
        Set-ItemProperty -Path "HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 2\Scsi Bus 0\Target Id 0\Logical Unit Id 0" -Name "Identifier" -Value $HW.DiskId

     } Else {

        Write-Output '[!] Reg Key HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 2\Scsi Bus 0\Target Id 0\Logical Unit Id 0\Identifier does not seem to exist! Skipping this one...'
    }
	
	if (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinSAT" -Name "PrimaryAdapterString" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinSAT\PrimaryAdapterString..."
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinSAT\" -Name "PrimaryAdapterString" -Value  $(Get-RandomString)

     } Else {

        Write-Output '[!] Reg Key HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinSAT\PrimaryAdapterString does not seem to exist! Skipping this one...'
    }
	
	if (Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\SystemInformation" -Name "SystemManufacturer" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\SYSTEM\ControlSet001\Control\SystemInformation\SystemManufacturer..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\SystemInformation" -Name "SystemManufacturer" -Value $HW.Manufacturer

     } Else {

        Write-Output '[!] Reg Key HKLM:\SYSTEM\ControlSet001\Control\SystemInformation\SystemManufacturer does not seem to exist! Skipping this one...'
    }
	
	if (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "SystemManufacturer" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation\SystemManufacturer..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "SystemManufacturer" -Value $HW.Manufacturer

     } Else {

        Write-Output '[!] Reg Key HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation\SystemManufacturer does not seem to exist! Skipping this one...'
    }
	
	if (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "SystemProductName" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation\SystemProductName..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "SystemProductName" -Value $HW.ProductName

     } Else {

        Write-Output '[!] Reg Key HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation\SystemProductName does not seem to exist! Skipping this one...'
    }

	if (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\disk\Enum" -Name "0" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\SYSTEM\CurrentControlSet\Services\disk\Enum\0..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\disk\Enum" -Name "0" -Value "SCSI\Disk&Ven_Crucial&Prod_CT500MX500SSD1\5&12345678&0&000000"

     } Else {

        Write-Output '[!] Reg Key HKLM:\SYSTEM\CurrentControlSet\Services\disk\Enum\0 does not seem to exist! Skipping this one...'
    }	
	
	if (Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\SystemInformation" -Name "SystemProductName" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\SYSTEM\ControlSet001\Control\SystemInformation\SystemProductName..."
        Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\SystemInformation" -Name "SystemProductName" -Value $HW.ProductName

     } Else {

        Write-Output '[!] Reg Key HKLM:\SYSTEM\ControlSet001\Control\SystemInformation\SystemProductName does not seem to exist! Skipping this one...'
    }
		
   if (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "VMware User Process" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Removing Reg Key HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\VMware User Process..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "VMware User Process"

     } Else {

        Write-Output '[!] Reg Key HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\VMware User Process does not seem to exist! Skipping this one...'
    }

    if (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "VMware VM3DService Process" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Removing Reg Key HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\VMware VM3DService Process..."
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "VMware VM3DService Process"

     } Else {

        Write-Output '[!] Reg Key HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\VMware VM3DService Process does not seem to exist! Skipping this one...'
    }

    if (Get-ItemProperty -Path "HKLM:\SOFTWARE\RegisteredApplications" -Name "VMware Host Open" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Removing Reg Key HKLM:\SOFTWARE\RegisteredApplications\VMware Host Open"
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\RegisteredApplications" -Name "VMware Host Open"

    } Else {

        Write-Output '[!] Reg Key HKLM:\SOFTWARE\RegisteredApplications\VMware Host Open does not seem to exist, or has already been renamed! Skipping this one...'
    }

    if (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\RegisteredApplications" -Name "VMware Host Open" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Removing Reg Key HKLM:\SOFTWARE\WOW6432Node\RegisteredApplications\VMware Host Open"
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\RegisteredApplications" -Name "VMware Host Open"

    } Else {

        Write-Output '[!] Reg Key HKLM:\SOFTWARE\WOW6432Node\RegisteredApplications\VMware Host Open does not seem to exist, or has already been renamed! Skipping this one...'
    }
	
	if (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Store\Configuration" -Name "OEMID" -ErrorAction SilentlyContinue) {

	Write-Output "[*] Modifying Reg Key HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Store\Configuration\OEMID"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Store\Configuration" -Name "OEMID" -Value $HW.OEMID

    } Else {

        Write-Output '[!] Reg Key HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Store\Configuration\OEMID does not seem to exist, or has already been renamed! Skipping this one...'
    }
	
	if (Get-Item -Path "HKLM:\SOFTWARE\VMware, Inc." -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\SOFTWARE\VMware, Inc."
        Rename-Item -Path "HKLM:\SOFTWARE\VMware, Inc." -NewName $(Get-RandomString)

    } Else {

        Write-Output '[!] Reg Key HKLM:\SOFTWARE\VMware, Inc. does not seem to exist, or has already been renamed! Skipping this one...'
    }
	
	if (Get-Item -Path "HKLM:\SOFTWARE\Classes\Applications\VMwareHostOpen.exe" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Modifying Reg Key HKLM:\SOFTWARE\Classes\Applications\VMwareHostOpen.exe"
        Rename-Item -Path "HKLM:\SOFTWARE\Classes\Applications\VMwareHostOpen.exe" -NewName $(Get-RandomString)

    } Else {

        Write-Output '[!] Reg Key HKLM:\SOFTWARE\Classes\Applications\VMwareHostOpen.exe does not seem to exist, or has already been renamed! Skipping this one...'
    }

    if (Get-Item -Path "HKLM:\SOFTWARE\Classes\VMwareHostOpen.AssocURL" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Modifying Reg Key HKLM:\SOFTWARE\Classes\VMwareHostOpen.AssocURL"
        Rename-Item -Path "HKLM:\SOFTWARE\Classes\VMwareHostOpen.AssocURL" -NewName $(Get-RandomString)

    } Else {

        Write-Output '[!] Reg Key HKLM:\SOFTWARE\Classes\VMwareHostOpen.AssocURL does not seem to exist, or has already been renamed! Skipping this one...'
    }

    if (Get-Item -Path "HKLM:\SOFTWARE\Classes\VMwareHostOpen.AssocFile" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Modifying Reg Key HKLM:\SOFTWARE\Classes\VMwareHostOpen.AssocFile"
        Rename-Item -Path "HKLM:\SOFTWARE\Classes\VMwareHostOpen.AssocFile" -NewName $(Get-RandomString)

    } Else {

        Write-Output '[!] Reg Key HKLM:\SOFTWARE\Classes\VMwareHostOpen.AssocFile does not seem to exist, or has already been renamed! Skipping this one...'
    }
	
	if (Get-Item -Path "HKLM:\SYSTEM\ControlSet001\Services\VGAuthService" -ErrorAction SilentlyContinue) {

        Write-Output "[*] Renaming Reg Key HKLM:\SYSTEM\ControlSet001\Services\VGAuthService..."
        Rename-Item -Path "HKLM:\SYSTEM\ControlSet001\Services\VGAuthService" -NewName $(Get-RandomString)

     } Else {

        Write-Output '[!] Reg Key HKLM:\SYSTEM\ControlSet001\Services\VGAuthService does not seem to exist! Skipping this one...'
    }
}

# -------------------------------------------------------------------------------------------------------
# Rename VMware Files

if ($files) {
	
	# Rename VMware directories

	Write-Output "[*] Attempting to rename C:\Program Files\Common Files\VMware directory..."

    	$VMwareCommonFiles = "C:\Program Files\Common Files\VMware"

    	if (Test-Path -Path $VMwareCommonFiles) {
        	Rename-Item $VMwareCommonFiles "C:\Program Files\Common Files\$(Get-RandomString)"
   	 }

    	else {
			Write-Output "[!] C:\Program Files\Common Files\VMware directory does not exist!"
    	}

    	Write-Output "[*] Attempting to rename C:\Program Files\VMware directory..."

    	$VMwareProgramDir = "C:\Program Files\VMware"

    	if (Test-Path -Path $VMwareProgramDir) {
        	Rename-Item $VMwareProgramDir "C:\Program Files\$(Get-RandomString)"
    	}

     	else {
        	Write-Output "[!] C:\Program Files\VMware directory does not exist!"
   	}
	
	# Rename VMware driver files

    Write-Output "[*] Attempting to rename VMware driver files in C:\Windows\System32\drivers\..."
	
	$path = "C:\Windows\System32\drivers\"
	
	$file_list ="vmhgfs.sys",
		"vmmemctl.sys",
		"vmmouse.sys",
		"vmrawdsk.sys",
		"vmusbmouse.sys"
	
    	foreach ($file in $file_list) {

		Write-Output "[*] Attempting to rename $file..."
		
		try {
			# We are renaming these files, as opposed to removing them, because Windows doesn't care if we just rename them :)
			Rename-Item "$path$file" "$path$(Get-RandomString).sys" -ErrorAction Stop
		}
		
		catch {
			Write-Output "[!] File does not seem to exist! Skipping..."
		}
	}

	$wildcardPattern = "vm3*.sys"
	$filesToRename = Get-ChildItem -Path $path -Filter $wildcardPattern
	
	foreach ($file in $filesToRename) {
   
    		Write-Output "[*] Attempting to rename $file..."
			Rename-Item "$path$file" "$path$(Get-RandomString).dll"
	}
	
	# Rename VMware system files (System32)
	
    Write-Output "[*] Attempting to rename DLL files in C:\Windows\System32\..."
	
	$path = "C:\Windows\System32\"
	
	$file_list = "vmhgfs.dll", "VMWSU.DLL"

    	foreach ($file in $file_list) {

		Write-Output "[*] Attempting to rename $file..."
		
		try {
			Rename-Item "$path$file" "$path$(Get-RandomString).dll" -ErrorAction Stop
		}
		
		catch {
			Write-Output "[!] File does not seem to exist! Skipping..."
		}
	}
	
	$wildcardPattern1 = "vm3*.dll"
	$wildcardPattern2 = "vmGuestLib*.dll"
	
	$filesToRename1 = Get-ChildItem -Path $path -Filter $wildcardPattern1
	$filesToRename2 = Get-ChildItem -Path $path -Filter $wildcardPattern2
	
	foreach ($file in $filesToRename1) {
   
    		Write-Output "[*] Attempting to rename $file..."
    		Rename-Item "$path$file" "$path$(Get-RandomString).dll"
	}
	
	foreach ($file in $filesToRename2) {
   
    		Write-Output "[*] Attempting to rename $file..."
    		Rename-Item "$path$file" "$path$(Get-RandomString).dll"
	}
	
	# Rename VMware system files (SysWOW64)
	
    Write-Output "[*] Attempting to rename system files in C:\Windows\SysWOW64\..."
	
	$path = "C:\Windows\SysWOW64\"
	
	$file_list = "vmhgfs.dll", "VMWSU.DLL"

    	foreach ($file in $file_list) {

		Write-Output "[*] Attempting to rename $file..."
		
		try {
			Rename-Item "$path$file" "$path$(Get-RandomString).dll" -ErrorAction Stop
		}
		
		catch {
			Write-Output "[!] File does not seem to exist! Skipping..."
		}
	}
	
	$wildcardPattern1 = "vm3*.dll"
	$wildcardPattern2 = "vmGuestLib*.dll"
	
	$filesToRename1 = Get-ChildItem -Path $path -Filter $wildcardPattern1
	$filesToRename2 = Get-ChildItem -Path $path -Filter $wildcardPattern2
	
	foreach ($file in $filesToRename1) {
   
    		Write-Output "[*] Attempting to rename $file..."
    		Rename-Item "$path$file" "$path$(Get-RandomString).dll"
	}
	
	foreach ($file in $filesToRename2) {
   
    		Write-Output "[*] Attempting to rename $file..."
    		Rename-Item "$path$file" "$path$(Get-RandomString).dll"
	}
}
	
Write-Output ""
Write-Output "** VMware izleri temizlendi."



    }
} catch {
    Write-Warning "VMware gizleme adiminda bazi hatalar alindi (normal olabilir): $_"
}

# ============================================================
# ADIM 3: GPU Adapter Registry Spoofing (Display Class GUID)
# ============================================================
Step "GPU adapter kayitlari spoof ediliyor..."
$gpuClassBase = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
$gpuSpoofed = $false
for ($idx = 0; $idx -lt 4; $idx++) {
    $subKey = "$gpuClassBase\$('{0:D4}' -f $idx)"
    if (-not (Test-Path $subKey)) { continue }
    $desc = (Get-ItemProperty -Path $subKey -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc
    if ($desc -and ($desc -match "VMware|SVGA|vm3d")) {
        Write-Output "    [*] VMware GPU bulundu: index $idx -> $desc"
        Set-ItemProperty -Path $subKey -Name "DriverDesc" -Value $HW.GPU_Desc -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $subKey -Name "HardwareInformation.AdapterString" -Value $HW.GPU_Desc -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $subKey -Name "HardwareInformation.ChipType" -Value $HW.GPU_ChipType -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $subKey -Name "HardwareInformation.BiosString" -Value $HW.GPU_BiosString -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $subKey -Name "ProviderName" -Value $HW.GPU_Provider -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $subKey -Name "MatchingDeviceId" -Value $HW.GPU_MatchId -Force -ErrorAction SilentlyContinue
        Write-Host "    [OK] GPU spoof edildi: $($HW.GPU_Desc)" -ForegroundColor Green
        $gpuSpoofed = $true
    }
}
if (-not $gpuSpoofed) {
    Write-Host "    [INFO] VMware GPU registry key bulunamadi (driver tarafinda halledilecek)" -ForegroundColor DarkYellow
}

# ============================================================
# ADIM 4: VMware Servislerini Durdur & Devre Disi Birak
# ============================================================
Step "VMware servisleri durduruluyor..."
$vmServices = @("VMTools", "VMwarePhysicalDiskHelper", "vm3dservice", "VGAuthService", "VMAuthdService", "vmvss", "vmci", "vmhgfs")
foreach ($svc in $vmServices) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Output "    [OK] $svc durduruldu ve devre disi birakildi"
    }
}

# ============================================================
# ADIM 5: VmLoader Driver Yukleme
# ============================================================
Step "VmLoader driver hazirlaniyor ve yukleniyor..."
$driverUrl = "https://github.com/r0llie/xd/raw/refs/heads/main/vmloader.sys"
$driverPath = "C:\xd.sys"
try {
    Write-Host "    [*] Driver indiriliyor: $driverUrl" -ForegroundColor Cyan
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $driverUrl -OutFile $driverPath -UseBasicParsing
    Write-Host "    [OK] Driver indirildi: $driverPath ($(( Get-Item $driverPath ).Length) bytes)" -ForegroundColor Green
} catch {
    Write-Error "Driver indirilemedi! Hata: $_"
    Read-Host "Devam etmek icin ENTER'a basin"
    exit
}

sc.exe create vmloader binPath= "\??\C:\xd.sys" type= "kernel" start= "system"
sc.exe start vmloader
reg delete "HKLM\HARDWARE\ACPI\DSDT\PTLTD_" /f

Write-Host "" -ForegroundColor Green
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║   [OK] Tum islemler tamamlandi!                     ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Loglari inceleyin. Yeniden baslatmak icin ENTER'a basin." -ForegroundColor Yellow
Read-Host
shutdown -r -t 00 -f



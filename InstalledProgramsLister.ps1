<#
    Author: Robin Ramaekers <mail@robin-ramaekers.be>
    Notes:
        This script will list all installed application according to the uninstall registry keys.
        A searchable gridview will show and will copy the uninstallstring of the selected application to the clipboard when cliking OK.
#>

Function Get-ApplicationInfo {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $Path
    )

    $Keyinfo = Get-Item -Path (($Path -replace "HKEY_LOCAL_MACHINE", "HKLM:") -replace "HKEY_CURRENT_USER", "HKCU:")
    if ($Path.split('\') -contains "WOW6432Node") {
        $Type = "32-bit"
    }
    else {
        $Type = "64-bit"
    }

    if (($Path.split('\') -contains "HKLM") -or ($Path.Split('\') -contains "HKEY_LOCAL_MACHINE")) {
        $Node = "Machine"
    }
    else {
        $Node = "User"
    }

    if (($null -eq $KeyInfo.getValue("Publisher")) -and ($null -eq $KeyInfo.getValue("Publisher")) -and ($null -eq $KeyInfo.getValue("Publisher"))) {
       return $null
    }
    else {
        $installedProgram = [PSCustomObject]@{
            KeyName = [io.path]::GetFileName($_.Name)
            Vendor = $KeyInfo.GetValue("Publisher")
            Name = $KeyInfo.GetValue("DisplayName")
            Version = $KeyInfo.GetValue("DisplayVersion")
            Type = $Type
            Node = $Node
            UninstallString = $KeyInfo.GetValue("UninstallString")
        }
    }

    return $installedProgram
}

$InstalledPrograms = @()
Get-childitem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall" | select-Object -property "Name" | ForEach-Object {
    $installedProgram = Get-ApplicationInfo $_.Name
    if ($null -ne $installedProgram) {
        $InstalledPrograms += $installedProgram
    }
}

Get-childitem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall" | select-Object -property "Name" | ForEach-Object {
    $installedProgram = Get-ApplicationInfo $_.Name
    if ($null -ne $installedProgram) {
        $InstalledPrograms += $installedProgram
    }

}

Get-childitem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | Select-Object -Property "Name" | ForEach-Object {
    $installedProgram = Get-ApplicationInfo $_.Name
    if ($null -ne $installedProgram) {
        $InstalledPrograms += $installedProgram
    }

}

$SelectedApplication = $InstalledPrograms | Select-Object -Property "Vendor", "Name", "Version", "Type", "Node", "UninstallString" | Out-GridView -Title "Installed applications" -OutputMode Single
$SelectedApplication.UninstallString | Set-Clipboard

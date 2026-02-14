
param (
    [string]$VMName = "ChangeMe",         	  # Mandatory: VM name
    [string]$VHDPath = "ChangeMe",        	  # Path to VM VHD (manual install)
											     
    [string]$GPUid,                       	  #
    [string]$GPUName,                     	  #
											     
    [switch]$ExportDisplay = $false,      	  # Export registry settings for display (manual & optional)
    [switch]$CopyDriverStore = $false     	  # Copy driver store files (manual) --> ... = $true
)


if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {

                                             # Uncomment to limit VM VRAM
    Add-VMGpuPartitionAdapter -VMName $VMName #-MaxPartitionVRAM 5GB -MinPartitionVRAM 1GB

    Set-VM -GuestControlledCacheTypes $true -VMName $VMName
    Set-VM -LowMemoryMappedIoSpace 1GB -VMName $VMName
    Set-VM -HighMemoryMappedIoSpace 32GB -VMName $VMName
    Set-VMFirmware -VMName $vm -EnableSecureBoot off

    $GPUName = Get-PnpDevice -Class Display | Select-Object -ExpandProperty Name
    $GPUid = Get-PnpDevice -Class Display | Select-Object -ExpandProperty ClassGuid

    Start-Sleep -Seconds 2
}

if ($CopyDriverStore) {

    Mount-vhd $VHDPath

    $displayDriverValue = (Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Class\$GPUid\0000").PSObject.Properties |
                           Where-Object { $_.Name -like "*DisplayDrivers*" } | Select-Object -ExpandProperty Value
    
    $firstDriverPath = ($displayDriverValue -split ",")[0].Trim()
    $folderName = ($firstDriverPath -split "\\")[-2]
    $folderPath = Split-Path $firstDriverPath -Parent

    $drive = (Get-DiskImage -ImagePath $VHDPath | Get-Disk | Get-Partition | Where-Object DriveLetter).DriveLetter

    Write-Host "Copying display driver for $GPUName"
    Copy-Item -Path $folderPath -Destination ${drive}:\windows\system32\hostdriverstore\FileRepository\$folderName -Recurse -Force

    Dismount-VHD $VHDPath
    Start-Sleep -Seconds 2
}

if ($ExportDisplay) {

    Mount-vhd $VHDPath
    Write-Host "Exporting display settings for $GPUName"

    reg export "HKLM\System\CurrentControlSet\Control\Class\${GPUid}\0000" "${drive}:\temp.reg"
    $input  = "V:\temp.reg"

    Get-Content "${drive}:\temp.reg" | ForEach-Object {

    if ($_ -match '^\[HKEY_.*\\0000\]$') {$_ -replace '\\0000\]', '\0001]'}
        else { $_}} | Set-Content "${drive}:\DisplaySettings.reg" -Encoding Unicode

    Write-Host "Remember to run the .reg file, located in 'c:\' inside the VM"
    Remove-Item "${drive}:\temp.reg"

    Dismount-VHD $VHDPath
}
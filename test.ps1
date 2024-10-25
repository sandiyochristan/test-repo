# Function to format and display the output
function Format-Output {
    param (
        [string]$Title,
        [PSCustomObject]$Data
    )
    Write-Host "=== $Title ===" -ForegroundColor Cyan
    $Data | Format-Table -AutoSize
    Write-Host ""
}

# Get OS Information
$os = Get-CimInstance Win32_OperatingSystem
$osInfo = [PSCustomObject]@{
    "OS Name"        = $os.Caption
    "Version"        = $os.Version
    "Architecture"   = $os.OSArchitecture
    "Manufacturer"   = $os.Manufacturer
    "Build Number"   = $os.BuildNumber
    "Install Date"   = $os.InstallDate
}

# Get Computer System Information
$computer = Get-CimInstance Win32_ComputerSystem
$computerInfo = [PSCustomObject]@{
    "Computer Name"       = $computer.Name
    "Domain"              = $computer.Domain
    "Model"               = $computer.Model
    "Total Physical Memory (GB)" = [math]::round($computer.TotalPhysicalMemory / 1GB, 2)
}

# Get Processor Information
$processor = Get-CimInstance Win32_Processor
$processorInfo = [PSCustomObject]@{
    "Processor"          = $processor.Name
    "Cores"              = $processor.NumberOfCores
    "Logical Processors" = $processor.NumberOfLogicalProcessors
}

# Get Disk Information
$disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
$diskInfo = foreach ($disk in $disks) {
    [PSCustomObject]@{
        "Drive"              = $disk.DeviceID
        "File System"        = $disk.FileSystem
        "Size (GB)"          = [math]::round($disk.Size / 1GB, 2)
        "Free Space (GB)"    = [math]::round($disk.FreeSpace / 1GB, 2)
    }
}

# Check for Hypervisor
$hypervisorInfo = if ((Get-WmiObject -Class Win32_ComputerSystem).HypervisorPresent) {
    "Hyper-V"
} elseif (Get-WmiObject -Query "SELECT * FROM Win32_ComputerSystemProduct WHERE Version LIKE 'VirtualBox%'") {
    "VirtualBox"
} elseif (Get-WmiObject -Query "SELECT * FROM Win32_ComputerSystemProduct WHERE Version LIKE 'VMware%'") {
    "VMware"
} elseif ($env:AZURE_VM_NAME) {
    "Azure"
} elseif ($env:AWS_EXECUTION_ENV) {
    "AWS"
} elseif ($env:GCP_PROJECT) {
    "Google Cloud Platform"
} else {
    "Not Running on a Hypervisor"
}

# Output Hypervisor Information
$hypervisorDetails = [PSCustomObject]@{
    "Hypervisor" = $hypervisorInfo
}

# Display all information
Format-Output -Title "Operating System Information" -Data $osInfo
Format-Output -Title "Computer System Information" -Data $computerInfo
Format-Output -Title "Processor Information" -Data $processorInfo
Format-Output -Title "Disk Information" -Data $diskInfo
Format-Output -Title "Hypervisor Information" -Data $hypervisorDetails

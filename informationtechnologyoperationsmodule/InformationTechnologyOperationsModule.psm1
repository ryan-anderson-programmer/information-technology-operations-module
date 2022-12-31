##################################################################################
#                                                                                #
#    Copyright 2022 Ryan E. Anderson                                             #
#                                                                                #
#    Licensed under the Apache License, Version 2.0 (the "License");             #
#    you may not use this file except in compliance with the License.            #
#    You may obtain a copy of the License at                                     #
#                                                                                #
#        http://www.apache.org/licenses/LICENSE-2.0                              #
#                                                                                #
#    Unless required by applicable law or agreed to in writing, software         #
#    distributed under the License is distributed on an "AS IS" BASIS,           #
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    #
#    See the License for the specific language governing permissions and         #
#    limitations under the License.                                              #
#                                                                                #
##################################################################################

######################################################
#                                                    #
#    InformationTechnologyOperationsModule v0.1.0    #
#                                                    #
#    By Ryan E. Anderson                             #
#                                                    #
#    Copyright (C) 2022 Ryan E. Anderson             #
#                                                    #
######################################################

Set-StrictMode -Version Latest

function Invoke-ShouldContinue {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCmdlet]
        $Context,
        [Parameter(Mandatory)]
        [string]
        $Query,
        [Parameter(Mandatory)]
        [string]
        $Caption
    )
    $Context.ShouldContinue($Query, $Caption)
}

function Invoke-ShouldProcess {
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCmdlet]
        $Context,
        [Parameter(Mandatory)]
        [string]
        $Target,
        [Parameter(Mandatory)]
        [string]
        $Action
    )
    $Context.ShouldProcess($Target, $Action)
}

<#
    .SYNOPSIS
    This function starts virtual machines hosted on an instance of Hyper-V.

    .DESCRIPTION
    This function starts virtual machines hosted on an instance of Hyper-V after evaluating memory usage. This function supports wildcards.

    .PARAMETER Name
    This is a list of names that identify virtual machines.

    .PARAMETER Threshold
    The total memory capacity is decreased by this percentage, to a threshold, beyond which a VM cannot start. This value must be between 0.05 and 0.95. This parameter has a default value of 0.20, which is 20%.

    .PARAMETER AsJob
    This is a switch that can be used to start VMs as background jobs.

    .PARAMETER Force
    This is a switch that can be used to force the initialization of virtual machines after determining that resource usage could exceed a reasonable amount.

    .EXAMPLE
    # Start virtual machines using an exact match.
    Start-InformationTechnologyOperationVirtualMachine -Name OS-EN-US-User

    .EXAMPLE
    # Start virtual machines using a wildcard.
    Start-InformationTechnologyOperationVirtualMachine -Name Windows*

    .EXAMPLE
    # Start virtual machines using names separated by commas.
    Start-InformationTechnologyOperationVirtualMachine -Name 'Windows*','Linux*','OS-EN-US-User'

    .EXAMPLE
    # Start virtual machines with a threshold that is specified by a user.
    Start-InformationTechnologyOperationVirtualMachine -Name Windows* -Threshold 0.50

    .EXAMPLE
    # Bypass the prompt so that execution can stop immediately after determining that memory usage for a VM would exceed a threshold.
    Start-InformationTechnologyOperationVirtualMachine -Name Windows* -Force

    .EXAMPLE
    # Start a VM as a background job.
    Start-InformationTechnologyOperationVirtualMachine -Name 'Ubuntu-22.10' -Threshold 0.55 -AsJob -Force

    .NOTES
    Names are not case-sensitive. Names will not be trimmed during processing.
#>
function Start-InformationTechnologyOperationVirtualMachine {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param
    (
        [Parameter(Position = 0, Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]
        $Name,
        [Parameter(Position = 1, Mandatory = $false, ValueFromPipelineByPropertyName)]
        [ValidateRange(0.05, 0.95)]
        [float]
        $Threshold = 0.20,
        [Parameter(Position = 2, Mandatory = $false, ValueFromPipelineByPropertyName)]
        [switch]
        $AsJob,
        [Parameter(Position = 3, Mandatory = $false, ValueFromPipelineByPropertyName)]
        [switch]
        $Force
    )
    begin {
        [int]$lineCount = 0

        $title = 'InformationTechnologyOperationsModule v0.1.0'
        $author = 'By Ryan E. Anderson'
        $copyrightText = 'Copyright (C) 2022 Ryan E. Anderson'

        $authorLength = $author.Length
        $copyrightTextLength = $copyrightText.Length
        $titleLength = $title.Length

        $lengths = @($authorLength, $copyrightTextLength, $titleLength)

        $maximumLength = ($lengths | Measure-Object -Maximum).Maximum

        $horizontalBorderLength = $maximumLength + 10 # m spaces on either side times n sides = 5 * 2 = 10

        $horizontalBorder = '#' * $horizontalBorderLength

        $verticalBorderPosition = $horizontalBorderLength - 1

        $emptyRowFormat = '{0}{1,' + $verticalBorderPosition + '}'

        Write-Information -MessageData $horizontalBorder -InformationAction Continue
        Write-Information -MessageData ([string]::Format($emptyRowFormat, '#', '#')) -InformationAction Continue
        Write-Information -MessageData ([string]::Format('{0,-5}{1}{2,' + ($maximumLength - $titleLength + 5) + '}', '#', $title, '#')) -InformationAction Continue
        Write-Information -MessageData ([string]::Format($emptyRowFormat, '#', '#')) -InformationAction Continue
        Write-Information -MessageData ([string]::Format('{0,-5}{1}{2,' + ($maximumLength - $authorLength + 5) + '}', '#', $author, '#')) -InformationAction Continue
        Write-Information -MessageData ([string]::Format($emptyRowFormat, '#', '#')) -InformationAction Continue
        Write-Information -MessageData ([string]::Format('{0,-5}{1}{2,' + ($maximumLength - $copyrightTextLength + 5) + '}', '#', $copyrightText, '#')) -InformationAction Continue
        Write-Information -MessageData ([string]::Format($emptyRowFormat, '#', '#')) -InformationAction Continue
        Write-Information -MessageData ($horizontalBorder + [Environment]::NewLine) -InformationAction Continue
    }
    process {
        try {
            # Don't consider $Confirm when executing with force and manually setting $ConfirmPreference because it might not be set.
            if ($Force) {
                $ConfirmPreference = 'None'
            }

            $statusVirtualMachineManagementService = (Get-Service -Name 'vmms').Status
            $statusVirtualMachineComputeService = (Get-Service -Name 'vmcompute').Status

            Write-Information -MessageData ([string]::Format("({0}) The status of the Hyper-V 'vmms' service is {1}...", ++$lineCount, $statusVirtualMachineManagementService)) -InformationAction Continue
            Write-Information -MessageData ([string]::Format("({0}) The status of the Hyper-V 'vmcompute' service is {1}...", ++$lineCount, $statusVirtualMachineComputeService)) -InformationAction Continue

            if ($statusVirtualMachineManagementService -eq 'Running' -and $statusVirtualMachineComputeService -eq 'Running') {
                Write-Information -MessageData ([string]::Format('({0}) Evaluating system memory...', ++$lineCount)) -InformationAction Continue

                [float]$totalMemoryUsage = 0
                [float]$memoryCapacityOfAllRunningVirtualMachines = 0

                Get-VM -ErrorAction Stop | Where-Object { $_.State -eq 'Running' } | ForEach-Object { $memoryCapacityOfAllRunningVirtualMachines += $_.MemoryAssigned } # Assign the total memory capacity of all virtual machines that are currently running.

                $operatingSystem = Get-CimInstance -ClassName 'CIM_OperatingSystem' | Select-Object TotalVisibleMemorySize, FreePhysicalMemory

                [float]$memoryCapacityOfCurrentSystem = [Math]::Round($operatingSystem.TotalVisibleMemorySize / 1mb, 2) # Convert capacity to GB.
                [float]$memoryUsedByCurrentSystem = [Math]::Round($memoryCapacityOfCurrentSystem - $operatingSystem.FreePhysicalMemory / 1mb, 2) # Convert capacity to GB.
                [float]$memoryThreshold = [Math]::Round($memoryCapacityOfCurrentSystem - $Threshold * $memoryCapacityOfCurrentSystem, 2) # Use a percentage decrease for the threshold to ensure that memory usage does not exceed a reasonable amount.

                $totalMemoryUsage += $memoryUsedByCurrentSystem

                Write-Information -MessageData ([string]::Format('({0}) The capacity of physical memory is {1} GB.', ++$lineCount, $memoryCapacityOfCurrentSystem)) -InformationAction Continue
                Write-Information -MessageData ([string]::Format('({0}) The current usage of physical memory is {1} GB.', ++$lineCount, $memoryUsedByCurrentSystem)) -InformationAction Continue

                [float]$memoryRatio = [Math]::Round($memoryUsedByCurrentSystem / $memoryCapacityOfCurrentSystem, 4)

                Write-Information -MessageData ([string]::Format('({0}) The ratio of used physical memory to total physical memory is {1} or {2}%.', ++$lineCount, $memoryRatio, 100 * $memoryRatio)) -InformationAction Continue
                Write-Information -MessageData ([string]::Format('({0}) The memory threshold for this system is {1} GB, which is {2}% of all memory that is available.', ++$lineCount, $memoryThreshold, 100 - [Math]::Round(100 * $Threshold, 2))) -InformationAction Continue
                Write-Information -MessageData ([string]::Format('({0}) The memory capacity of all virtual machines that are currently running is {1} GB (This is startup or allocated memory.).', ++$lineCount, [Math]::Round($memoryCapacityOfAllRunningVirtualMachines / 1gb, 2))) -InformationAction Continue
                Write-Information -MessageData ([string]::Format("({0}) Evaluating each entry from the provided list of names as either the name of a single VM instance or a wildcard prefix followed by '*' for a set of VMs (The name of a VM is not case-sensitive, and white space will not be trimmed.)...", ++$lineCount)) -InformationAction Continue
                Write-Information -MessageData ([string]::Format('({0}) The provided list of names is {1}.', ++$lineCount, [string]::Join(',', $Name))) -InformationAction Continue

                :outer for ($i = 0; $i -lt $Name.Count; $i++) {
                    $virtualMachineName = $Name[$i]

                    $virtualMachineInstances = New-Object 'System.Collections.Generic.List[System.Object]'

                    $temporaryVirtualMachineInstances = Get-VM -Name $virtualMachineName -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Off' } | Select-Object

                    if ($temporaryVirtualMachineInstances -is 'System.Object[]') {
                        $virtualMachineInstances.AddRange($temporaryVirtualMachineInstances)
                    }
                    elseif ($temporaryVirtualMachineInstances -is 'Microsoft.HyperV.PowerShell.VirtualMachine') {
                        $virtualMachineInstances.Add($temporaryVirtualMachineInstances)
                    }
                    else {
                        Write-Information -MessageData ([string]::Format("({0}) A VM named '{1}' could not be started. If a machine named '{1}' exists, then make sure that it is not already in a running state.", ++$lineCount, $virtualMachineName)) -InformationAction Continue

                        continue
                    }

                    for ($j = 0; $j -lt $virtualMachineInstances.Count; $j++) {
                        $virtualMachineInstance = $virtualMachineInstances[$j]

                        $virtualMachineInstanceName = $virtualMachineInstance.VMName

                        Write-Information -MessageData ([string]::Format("({0}) Checking memory for '{1}'...", ++$lineCount, $virtualMachineInstanceName)) -InformationAction Continue

                        [float]$virtualMachineInstanceStartupMemory = [Math]::Round($virtualMachineInstance.MemoryStartup / 1gb, 2)
                        [float]$temporaryMemory = $totalMemoryUsage + $virtualMachineInstanceStartupMemory

                        Write-Information -MessageData ([string]::Format("({0}) The startup memory for '{1}' is {2} GB.", ++$lineCount, $virtualMachineInstanceName, $virtualMachineInstanceStartupMemory)) -InformationAction Continue
                        Write-Information -MessageData ([string]::Format("({0}) The total memory after starting '{1}' will be {2} GB.", ++$lineCount, $virtualMachineInstanceName, $temporaryMemory)) -InformationAction Continue

                        if ($Force -or (Invoke-ShouldProcess -Context $PSCmdlet -Target $virtualMachineInstanceName -Action 'Initialize VMs')) {
                            if ($temporaryMemory -gt $memoryThreshold) {
                                Write-Information -MessageData ([string]::Format("({0}) The VM named '{1}' could not be started because doing so would cause the total usage to exceed a reasonable amount: {2} GB > {3} GB.", ++$lineCount, $virtualMachineInstanceName, $temporaryMemory, $memoryThreshold)) -InformationAction Continue

                                if (-not $Force -and -not (Invoke-ShouldContinue -Context $PSCmdlet -Query 'Do you want to continue initializing the current set of VMs?' -Caption 'Continue VM Initialization')) {
                                    break outer
                                }
                            }

                            Write-Information -MessageData ([string]::Format("({0}) Starting '{1}' with total memory usage at {2} GB...", ++$lineCount, $virtualMachineInstanceName, $totalMemoryUsage)) -InformationAction Continue

                            Start-VM -Name $virtualMachineInstanceName -AsJob:$AsJob

                            $totalMemoryUsage += $virtualMachineInstanceStartupMemory

                            Write-Information -MessageData ([string]::Format("({0}) The VM '{1}' was started; total memory usage is now at {2} GB.", ++$lineCount, $virtualMachineInstanceName, $totalMemoryUsage)) -InformationAction Continue
                        }
                    }
                }
            }
            else {
                Write-Information -MessageData ([string]::Format('({0}) Hyper-V initialization did not succeed because a Hyper-V service is not running...', ++$lineCount)) -InformationAction Continue
            }
        }
        catch {
            Write-Warning ([string]::Format('({0}) {1}', ++$lineCount, $_.Exception))
            Write-Information -MessageData ([string]::Format('({0}) An unexpected error that could not be resolved to a specific classification occurred.', ++$lineCount)) -InformationAction Continue
        }
    }
    end {
        Write-Information -MessageData ([string]::Format('({0}) The task of starting VMs that are hosted on the current Hyper-V instance has completed.', ++$lineCount)) -InformationAction Continue
    }
}
Set-Alias sitovm Start-InformationTechnologyOperationVirtualMachine
Export-ModuleMember -Function Start-InformationTechnologyOperationVirtualMachine -Alias sitovm
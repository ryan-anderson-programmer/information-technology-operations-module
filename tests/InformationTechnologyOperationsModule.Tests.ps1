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

#########################################################################################################################
#                                                                                                                       #
#    InformationTechnologyOperationsModule v0.1.0 Start-InformationTechnologyOperationVirtualMachine Unit Test Suite    #
#                                                                                                                       #
#    By Ryan E. Anderson                                                                                                #
#                                                                                                                       #
#    Copyright (C) 2022 Ryan E. Anderson                                                                                #
#                                                                                                                       #
#########################################################################################################################

InModuleScope 'InformationTechnologyOperationsModule' {
    Describe 'Invoke-ShouldContinue' {
        BeforeAll {
            function Get-CommandUnderTest {
                Get-Command 'Invoke-ShouldContinue'
            }

            function Invoke-Commandlet {
                [CmdletBinding()]
                param($ScriptBlock)
                . $ScriptBlock
            }

            function Test-ShouldContinue {
                [CmdletBinding()]
                param($Context, $Query, $Caption)
            
                Invoke-ShouldContinue -Context $Context -Query $Query -Caption $Caption
            }
        }

        It 'Should have a parameter named Context' {
            Get-CommandUnderTest | Should -HaveParameter 'Context' -Type 'System.Management.Automation.PSCmdlet' -Mandatory
        }

        It 'Should have a parameter named Query' {
            Get-CommandUnderTest | Should -HaveParameter 'Query' -Type 'string' -Mandatory
        }

        It 'Should have a parameter named Caption' {
            Get-CommandUnderTest | Should -HaveParameter 'Caption' -Type 'string' -Mandatory
        }

        Invoke-Commandlet {
            $Context = $PSCmdlet
            $Context.CommandRuntime = New-Object ItoCommandRuntimeProxy.ItoCommandRuntimeProxy

            It 'Should always return true' {
                Test-ShouldContinue -Context $Context -Query 'Continue testing?' -Caption 'Testing' | Should -Be $true
            }
        }
    }
    
    Describe 'Invoke-ShouldProcess' {
        BeforeAll {
            function Get-CommandUnderTest {
                Get-Command 'Invoke-ShouldProcess'
            }
        }

        It 'Should have a parameter named Context' {
            Get-CommandUnderTest | Should -HaveParameter 'Context' -Type 'System.Management.Automation.PSCmdlet' -Mandatory
        }

        It 'Should have a parameter named Target' {
            Get-CommandUnderTest | Should -HaveParameter 'Target' -Type 'string' -Mandatory
        }

        It 'Should have a parameter named Action' {
            Get-CommandUnderTest | Should -HaveParameter 'Action' -Type 'string' -Mandatory
        }
    }

    Describe 'Start-InformationTechnologyOperationVirtualMachine' {
        $runningHyperVService = [PSCustomObject]@{
            Status = 'Running'
        }  
    
        $runningVirtualMachine = [PSCustomObject]@{
            Name           = $null
            State          = 'Running'
            MemoryAssigned = 2048
        }

        $cimInstanceMemoryInformation = [PSCustomObject]@{ 
            TotalVisibleMemorySize = 16222208
            FreePhysicalMemory     = 4821588
        }

        Context 'When a Hyper-V service is not running' {
            Mock Write-Information { }

            Mock Get-Service {             
                [PSCustomObject]@{
                    Status = 'Stopped'
                }  
            }

            $null = Start-InformationTechnologyOperationVirtualMachine -Name 'Windows' -Threshold 0.30

            It 'Calls Write-Information 13 times to print status messages' {
                Assert-MockCalled Write-Information -Exactly 13
            }

            It 'Calls Get-Service to determine whether vmms is running' {
                Assert-MockCalled Get-Service -ParameterFilter { $Name -eq 'vmms' } -Exactly 1
            }
        }

        Context 'When virtual machine instances that correspond to two different wildcards can be found' {
            $offVirtualMachine1 = [PSCustomObject]@{
                Name          = 'Ubuntu*'
                State         = 'Off'
                VMName        = 'Ubuntu-22.10'
                MemoryStartup = 2048
            }

            $offVirtualMachine2 = [PSCustomObject]@{
                Name          = 'Ubuntu*'
                State         = 'Off'
                VMName        = 'Ubuntu-22.04.5-LTS'
                MemoryStartup = 2048
            }
 
            $offVirtualMachine3 = [PSCustomObject]@{
                Name          = 'Linux-Mint*'
                State         = 'Off'
                VMName        = 'Linux-Mint-Cinnamon'
                MemoryStartup = 2048
            }

            $offVirtualMachine4 = [PSCustomObject]@{
                Name          = 'Linux-Mint*'
                State         = 'Off'
                VMName        = 'Linux-Mint-Ulyssa'
                MemoryStartup = 2048
            }

            Mock Write-Information { }
            
            Mock Get-Service { $runningHyperVService }

            Mock Get-VM -ParameterFilter { $Name -eq $null } -MockWith { @( $runningVirtualMachine ) }
            Mock Get-VM -ParameterFilter { $Name -eq @('Ubuntu*') } -MockWith { @( $offVirtualMachine1, $offVirtualMachine2 ) }
            Mock Get-VM -ParameterFilter { $Name -eq ('Linux-Mint*') } -MockWith { @( $offVirtualMachine3, $offVirtualMachine4 ) }
    
            Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'CIM_OperatingSystem' } -MockWith { $cimInstanceMemoryInformation }

            Mock Start-VM { }

            $null = Start-InformationTechnologyOperationVirtualMachine -Name 'Ubuntu*', 'Linux-Mint*' -Confirm:$false

            It 'Calls Write-Information 40 times to print status messages' {
                Assert-MockCalled Write-Information -Exactly 40
            }

            It 'Calls Get-Service to determine whether vmms is running' {
                Assert-MockCalled Get-Service -ParameterFilter { $Name -eq 'vmms' } -Exactly 1
            }

            It 'Calls Get-Service to determine whether vmcompute is running' {
                Assert-MockCalled Get-Service -ParameterFilter { $Name -eq 'vmcompute' } -Exactly 1
            }

            It 'Calls Get-VM to assign memory information' {
                Assert-MockCalled Get-VM -ParameterFilter { $Name -eq $null } -Exactly 1
            }

            It 'Calls Get-CimInstance to return information about resource usage' {
                Assert-MockCalled Get-CimInstance -ParameterFilter { $ClassName -eq 'CIM_OperatingSystem' } -Exactly 1
            }

            It 'Calls Get-VM to get instances for Ubuntu*' {
                Assert-MockCalled Get-VM -ParameterFilter { $Name -eq @('Ubuntu*') } -Exactly 1
            }

            It 'Calls Get-VM to get instances for Linux-Mint*' {
                Assert-MockCalled Get-VM -ParameterFilter { $Name -eq @('Linux-Mint*') } -Exactly 1
            }

            It 'Calls Start-VM 4 times to start instances' {
                Assert-MockCalled Start-VM -Exactly 4
            }
        }

        Context 'When a single virtual machine instance that requires excessive memory usage can be found, execution is not forced, and initialization should continue' {
            Mock Write-Information { }
            
            Mock Get-Service { $runningHyperVService }

            $hyperVVirtualMachineTypeName = 'Microsoft.HyperV.PowerShell.VirtualMachine'

            $offVirtualMachineWithMemoryStartup = New-MockObject -Type $hyperVVirtualMachineTypeName

            $offVirtualMachineWithMemoryStartup | Add-Member -TypeName $hyperVVirtualMachineTypeName -NotePropertyName 'Name' -NotePropertyValue 'Ubuntu-22.04.5-LTS' -Force
            $offVirtualMachineWithMemoryStartup | Add-Member -TypeName $hyperVVirtualMachineTypeName -NotePropertyName 'State' -NotePropertyValue 'Off' -Force
            $offVirtualMachineWithMemoryStartup | Add-Member -TypeName $hyperVVirtualMachineTypeName -NotePropertyName 'MemoryStartup' -NotePropertyValue 2147484000 -Force
            
            Mock Get-VM -ParameterFilter { $Name -eq $null } -MockWith { @( $runningVirtualMachine ) }
            Mock Get-VM -ParameterFilter { $Name -eq @('Ubuntu-22.04.5-LTS') } -MockWith { @( $offVirtualMachineWithMemoryStartup ) }
        
            Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'CIM_OperatingSystem' } -MockWith { $cimInstanceMemoryInformation }

            Mock Invoke-ShouldProcess { $true }
            Mock Invoke-ShouldContinue { $true }

            Mock Start-VM { }

            $null = Start-InformationTechnologyOperationVirtualMachine -Name 'Ubuntu-22.04.5-LTS' -Threshold 0.30

            It 'Calls Write-Information 26 times to print status messages' {
                Assert-MockCalled Write-Information -Exactly 26
            }

            It 'Calls Get-Service to determine whether vmms is running' {
                Assert-MockCalled Get-Service -ParameterFilter { $Name -eq 'vmms' } -Exactly 1
            }

            It 'Calls Get-Service to determine whether vmcompute is running' {
                Assert-MockCalled Get-Service -ParameterFilter { $Name -eq 'vmcompute' } -Exactly 1
            }

            It 'Calls Get-VM to assign memory information' {
                Assert-MockCalled Get-VM -ParameterFilter { $Name -eq $null } -Exactly 1
            }

            It 'Calls Get-CimInstance to return information about resource usage' {
                Assert-MockCalled Get-CimInstance -ParameterFilter { $ClassName -eq 'CIM_OperatingSystem' } -Exactly 1
            }

            It 'Calls Get-VM to get instances for Ubuntu-22.04.5-LTS' {
                Assert-MockCalled Get-VM -ParameterFilter { $Name -eq @('Ubuntu-22.04.5-LTS') } -Exactly 1
            }

            It 'Calls Invoke-ShouldProcess ($PSCmdlet.ShouldProcess()) to process the initialization of instances' {
                Assert-MockCalled Invoke-ShouldProcess -Exactly 1
            }

            It 'Calls Invoke-ShouldContinue ($PSCmdlet.ShouldContinue()) to immediately stop the initialization of instances' {
                Assert-MockCalled Invoke-ShouldContinue -Exactly 1
            }

            It 'Calls Start-VM 1 time to start an instance' {
                Assert-MockCalled Start-VM -Exactly 1
            }
        }

        Context 'When a single virtual machine instance that requires excessive memory usage can be found, execution is not forced, and initialization should not continue' {
            Mock Write-Information { }
            
            Mock Get-Service { $runningHyperVService }

            $hyperVVirtualMachineTypeName = 'Microsoft.HyperV.PowerShell.VirtualMachine'

            $offVirtualMachineWithMemoryStartup = New-MockObject -Type $hyperVVirtualMachineTypeName

            $offVirtualMachineWithMemoryStartup | Add-Member -TypeName $hyperVVirtualMachineTypeName -NotePropertyName 'Name' -NotePropertyValue 'Ubuntu-22.04.5-LTS' -Force
            $offVirtualMachineWithMemoryStartup | Add-Member -TypeName $hyperVVirtualMachineTypeName -NotePropertyName 'State' -NotePropertyValue 'Off' -Force
            $offVirtualMachineWithMemoryStartup | Add-Member -TypeName $hyperVVirtualMachineTypeName -NotePropertyName 'MemoryStartup' -NotePropertyValue 2147484000 -Force
            
            Mock Get-VM -ParameterFilter { $Name -eq $null } -MockWith { @( $runningVirtualMachine ) }
            Mock Get-VM -ParameterFilter { $Name -eq @('Ubuntu-22.04.5-LTS') } -MockWith { @( $offVirtualMachineWithMemoryStartup ) }
        
            Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'CIM_OperatingSystem' } -MockWith { $cimInstanceMemoryInformation }

            Mock Invoke-ShouldProcess { $true }
            Mock Invoke-ShouldContinue { $false }

            $null = Start-InformationTechnologyOperationVirtualMachine -Name 'Ubuntu-22.04.5-LTS' -Threshold 0.30

            It 'Calls Write-Information 24 times to print status messages' {
                Assert-MockCalled Write-Information -Exactly 24
            }

            It 'Calls Get-Service to determine whether vmms is running' {
                Assert-MockCalled Get-Service -ParameterFilter { $Name -eq 'vmms' } -Exactly 1
            }

            It 'Calls Get-Service to determine whether vmcompute is running' {
                Assert-MockCalled Get-Service -ParameterFilter { $Name -eq 'vmcompute' } -Exactly 1
            }

            It 'Calls Get-VM to assign memory information' {
                Assert-MockCalled Get-VM -ParameterFilter { $Name -eq $null } -Exactly 1
            }

            It 'Calls Get-CimInstance to return information about resource usage' {
                Assert-MockCalled Get-CimInstance -ParameterFilter { $ClassName -eq 'CIM_OperatingSystem' } -Exactly 1
            }

            It 'Calls Get-VM to get instances for Ubuntu-22.04.5-LTS' {
                Assert-MockCalled Get-VM -ParameterFilter { $Name -eq @('Ubuntu-22.04.5-LTS') } -Exactly 1
            }

            It 'Calls Invoke-ShouldProcess ($PSCmdlet.ShouldProcess()) to process the initialization of instances' {
                Assert-MockCalled Invoke-ShouldProcess -Exactly 1
            }

            It 'Calls Invoke-ShouldContinue ($PSCmdlet.ShouldContinue()) to immediately stop the initialization of instances' {
                Assert-MockCalled Invoke-ShouldContinue -Exactly 1
            }
        }

        Context 'When a single virtual machine instance that requires excessive memory usage can be found and execution is forced' {
            Mock Write-Information { }
            
            Mock Get-Service { $runningHyperVService }

            $hyperVVirtualMachineTypeName = 'Microsoft.HyperV.PowerShell.VirtualMachine'

            $offVirtualMachineWithMemoryStartup = New-MockObject -Type $hyperVVirtualMachineTypeName

            $offVirtualMachineWithMemoryStartup | Add-Member -TypeName $hyperVVirtualMachineTypeName -NotePropertyName 'Name' -NotePropertyValue 'Ubuntu-22.04.5-LTS' -Force
            $offVirtualMachineWithMemoryStartup | Add-Member -TypeName $hyperVVirtualMachineTypeName -NotePropertyName 'State' -NotePropertyValue 'Off' -Force
            $offVirtualMachineWithMemoryStartup | Add-Member -TypeName $hyperVVirtualMachineTypeName -NotePropertyName 'MemoryStartup' -NotePropertyValue 2147484000 -Force
            
            Mock Get-VM -ParameterFilter { $Name -eq $null } -MockWith { @( $runningVirtualMachine ) }
            Mock Get-VM -ParameterFilter { $Name -eq @('Ubuntu-22.04.5-LTS') } -MockWith { @( $offVirtualMachineWithMemoryStartup ) }
        
            Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'CIM_OperatingSystem' } -MockWith { $cimInstanceMemoryInformation }
            
            Mock Start-VM { }

            $null = Start-InformationTechnologyOperationVirtualMachine -Name 'Ubuntu-22.04.5-LTS' -Threshold 0.30 -Force

            It 'Calls Write-Information 26 times to print status messages' {
                Assert-MockCalled Write-Information -Exactly 26
            }

            It 'Calls Get-Service to determine whether vmms is running' {
                Assert-MockCalled Get-Service -ParameterFilter { $Name -eq 'vmms' } -Exactly 1
            }

            It 'Calls Get-Service to determine whether vmcompute is running' {
                Assert-MockCalled Get-Service -ParameterFilter { $Name -eq 'vmcompute' } -Exactly 1
            }

            It 'Calls Get-VM to assign memory information' {
                Assert-MockCalled Get-VM -ParameterFilter { $Name -eq $null } -Exactly 1
            }

            It 'Calls Get-CimInstance to return information about resource usage' {
                Assert-MockCalled Get-CimInstance -ParameterFilter { $ClassName -eq 'CIM_OperatingSystem' } -Exactly 1
            }

            It 'Calls Get-VM to get instances for Ubuntu-22.04.5-LTS' {
                Assert-MockCalled Get-VM -ParameterFilter { $Name -eq @('Ubuntu-22.04.5-LTS') } -Exactly 1
            }

            It 'Calls Start-VM 1 time to start an instance' {
                Assert-MockCalled Start-VM -Exactly 1
            }
        }
    
        Context 'When a virtual machine instance cannot be found' {
            Mock Write-Information { }

            Mock Get-Service { $runningHyperVService }
        
            Mock Get-VM -ParameterFilter { $Name -eq $null } -MockWith { @( $runningVirtualMachine ) }
            Mock Get-VM -ParameterFilter { $Name -eq @('Windows') } -MockWith { }
    
            Mock Get-CimInstance { $cimInstanceMemoryInformation }

            $null = Start-InformationTechnologyOperationVirtualMachine -Name 'Windows' -Threshold 0.30

            It 'Calls Write-Information 21 times to print status messages' {
                Assert-MockCalled Write-Information -Exactly 21
            }

            It 'Calls Get-Service to determine whether vmms is running' {
                Assert-MockCalled Get-Service -ParameterFilter { $Name -eq 'vmms' } -Exactly 1
            }

            It 'Calls Get-Service to determine whether vmcompute is running' {
                Assert-MockCalled Get-Service -ParameterFilter { $Name -eq 'vmcompute' } -Exactly 1
            }

            It 'Calls Get-VM to assign memory information' {
                Assert-MockCalled Get-VM -ParameterFilter { $Name -eq $null } -Exactly 1
            }

            It 'Calls Get-CimInstance to return information about resource usage' {
                Assert-MockCalled Get-CimInstance -Exactly 1
            }

            It 'Calls Get-VM to get instances' {
                Assert-MockCalled Get-VM -ParameterFilter { $Name -eq @('Windows') } -Exactly 1
            }
        }
    
        Context 'When an exception/error is encountered' {
            Mock Write-Information { }

            Mock Get-Service { $runningHyperVService }

            Mock Get-VM { throw VirtualizationException }
        
            Mock Write-Warning { }

            $null = Start-InformationTechnologyOperationVirtualMachine -Name 'Windows' -Threshold 0.30

            It 'Calls Write-Information 14 times to print status messages' {
                Assert-MockCalled Write-Information -Exactly 14
            }

            It 'Calls Get-Service to determine whether vmms is running' {
                Assert-MockCalled Get-Service -ParameterFilter { $Name -eq 'vmms' } -Exactly 1
            }

            It 'Calls Get-Service to determine whether vmcompute is running' {
                Assert-MockCalled Get-Service -ParameterFilter { $Name -eq 'vmcompute' } -Exactly 1
            }

            It 'Calls Get-VM to assign memory and an exception is thrown' {
                Assert-MockCalled Get-VM -Exactly 1
            }

            It 'Calls Write-Warning 1 time to print a status message' {
                Assert-MockCalled Write-Warning -Exactly 1
            }
        }
    }
}
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

##################################################################################################
#                                                                                                #
#    InformationTechnologyOperationsModule v0.1.0 Start Virtual Machine From Pipeline Example    #
#                                                                                                #
#    By Ryan E. Anderson                                                                         #
#                                                                                                #
#    Copyright (C) 2022 Ryan E. Anderson                                                         #
#                                                                                                #
##################################################################################################

Set-StrictMode -Version Latest

Import-Module InformationTechnologyOperationsModule

function Get-VMInput {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [string[]]
        $Name, 
        [float]
        $Threshold, 
        [switch]
        $AsJob
    )
    [PSCustomObject]@{
        Name      = 'Ubuntu*'
        Threshold = 0.20
        AsJob     = $true
    }
}

Get-VMInput -Name 'Ubuntu*' -Threshold 0.20 -AsJob | Start-InformationTechnologyOperationVirtualMachine -Force

Read-Host 'Press any key to continue'
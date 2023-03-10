#! /usr/bin/pwsh

##################################################################################
#                                                                                #
#    Copyright 2023 Ryan E. Anderson                                             #
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

###################################################################
#                                                                 #
#    InformationTechnologyOperationsModule v0.1.0 Build Script    #
#                                                                 #
#    By Ryan E. Anderson                                          #
#                                                                 #
#    Copyright (C) 2023 Ryan E. Anderson                          #
#                                                                 #
###################################################################

<#
    .SYNOPSIS
    This script will build and import InformationTechnologyOperationsModule for development and testing.

    .DESCRIPTION
    This script will build and import InformationTechnologyOperationsModule for development and testing. Files from a previous build may be removed by the use of a switch.

    .PARAMETER Clean
    This is a switch that can be used to ensure that the output from a previous build is cleaned. The dotnet restore, dotnet build, and dotnet test commands are executed in sequence when this switch is true.

    .PARAMETER Lock
    This is a switch that can be used to ensure that restoration of packages is performed in a locked mode.

    .PARAMETER Test
    This is a switch that can be used to specify whether testing should be performed.
#>
[CmdletBinding()]
param(
    [switch]$Clean,
    [switch]$Lock,
    [switch]$Test
)

Set-StrictMode -Version Latest

$deploymentOutputPath = (Join-Path $PSScriptRoot '..\deployment\informationtechnologyoperationsmodule')

if ($Clean -and (Test-Path $deploymentOutputPath)) {
    Remove-Item $deploymentOutputPath -Recurse -Force
}

if ($Test) {
    try {
        . (Join-Path -Path $PSScriptRoot -ChildPath '..\tests\setup\SetUpTestEnvironment.ps1' -ErrorAction Stop) -Clean:$Clean -Lock:$Lock -InstallTestDependencies
    }
    catch {
        Write-Warning $_.Exception
        Write-Warning -Message 'Testing cannot proceed because issues were encountered during the setup process.'

        exit
    }
}

if (Get-Module -Name InformationTechnologyOperationsModule) {
    Remove-Module -Name InformationTechnologyOperationsModule -Force # Remove any extra modules from the current session.
}

function Copy-DeploymentContent ($Content) {
    foreach ($item in $Content) {
        $source, $destination = $item

        $null = New-Item -Force $destination -ItemType Directory

        Get-ChildItem $source -File | Copy-Item -Destination $destination
    }
}

$null = New-Item $deploymentOutputPath -ItemType Directory -Force

$sourcePath = (Join-Path $PSScriptRoot '..\informationtechnologyoperationsmodule')

$deploymentContent = @(
    , ((Join-Path $PSScriptRoot '..\LICENSE'), $deploymentOutputPath)
    , ((Join-Path $PSScriptRoot '..\README.md'), $deploymentOutputPath)
    , ((Join-Path $sourcePath 'InformationTechnologyOperationsModule.psm1'), $deploymentOutputPath)
    , ((Join-Path $sourcePath 'InformationTechnologyOperationsModule.psd1'), $deploymentOutputPath)
)

Copy-DeploymentContent -Content $deploymentContent

Import-Module (Join-Path $PSScriptRoot '..\informationtechnologyoperationsmodule\InformationTechnologyOperationsModule.psd1') -Force

if ($Test) {
    Invoke-Pester (Join-Path $PSScriptRoot '..\tests') -CodeCoverage (Join-Path $PSScriptRoot '..\informationtechnologyoperationsmodule\InformationTechnologyOperationsModule.psm1')
}
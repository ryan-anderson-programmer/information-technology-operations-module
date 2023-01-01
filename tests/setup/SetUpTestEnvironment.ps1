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

#################################################################
#                                                               #
#    InformationTechnologyOperationsModule v0.1.0 Test Setup    #
#                                                               #
#    By Ryan E. Anderson                                        #
#                                                               #
#    Copyright (C) 2023 Ryan E. Anderson                        #
#                                                               #
#################################################################

<#
    .SYNOPSIS
    This script will build and import dependencies that are needed for testing.

    .DESCRIPTION
    This script will build and import dependencies that are needed for testing. Files from a previous build may be removed by the use of a switch.

    .PARAMETER Clean
    This is a switch that can be used to ensure that the output from a previous build will be cleaned. The dotnet restore, dotnet build, and dotnet test commands are executed in sequence when this switch is true.

    .PARAMETER Lock
    This is a switch that can be used to ensure that restoration of packages will be performed in a locked mode.

    .PARAMETER InstallTestDependencies
    This is a switch that can be used to ensure that dependencies for testing are installed.
#>
[CmdletBinding()]
param(
    [switch]$Clean,
    [switch]$Lock,
    [switch]$InstallTestDependencies
)

Set-StrictMode -Version Latest

try {
    $pesterModules = @(Get-Module -Name 'Pester' -ListAvailable)

    if (($null -eq $pesterModules) -or ($pesterModules.Length -eq 0)) {
        if (-not $InstallTestDependencies) {
            throw 'No Pester modules could be found.'
        }

        Install-Module -Name 'Pester' -RequiredVersion '4.10.1' -Confirm:$false -Force -SkipPublisherCheck # Install the most recent dependency that is supported.
    }

    $version = $pesterModules[0].Version

    if ($version -lt ([Version] '3.4.4') -or $version -gt ([Version] '4.10.1')) {
        if (-not $InstallTestDependencies) {
            throw 'The most recent version of Pester that is installed is not supported. Only versions 3.4.4-4.10.1 are supported.'
        }

        Install-Module -Name 'Pester' -RequiredVersion '4.10.1' -Confirm:$false -Force -SkipPublisherCheck # Install the most recent dependency that is supported.
    }
}
catch {
    Write-Warning -Message 'Testing cannot proceed because issues were encountered while trying to find a supported version of Pester.'

    throw
}

Import-Module 'Pester'

[int]$lineCount = 0

$dotNetCSharpCommandRuntimeProxyBasePath = (Join-Path $PSScriptRoot 'ItoCommandRuntimeProxy')

$dotNetCSharpCommandRuntimeProxySolutionPath = (Join-Path $dotNetCSharpCommandRuntimeProxyBasePath 'ItoCommandRuntimeProxy.sln')

if ($Clean) {
    if ($PSVersionTable.PSVersion -lt [Version]'5.1') {
        throw 'To create a clean build of dependencies that are needed for testing InformationTechnologyOperationsModule, PowerShell 5.1 or greater must be used.'
    }

    Write-Information -MessageData ([string]::Format('({0}) Restoring dependencies for ItoCommandRuntimeProxy at {1}...', ++$lineCount, $dotNetCSharpCommandRuntimeProxySolutionPath)) -InformationAction Continue

    if ($Lock) {
        dotnet restore $dotNetCSharpCommandRuntimeProxySolutionPath --locked-mode
    }
    else {
        dotnet restore $dotNetCSharpCommandRuntimeProxySolutionPath
    }

    Write-Information -MessageData ([string]::Format('({0}) Building ItoCommandRuntimeProxy at {1}...', ++$lineCount, $dotNetCSharpCommandRuntimeProxySolutionPath)) -InformationAction Continue

    dotnet build $dotNetCSharpCommandRuntimeProxySolutionPath --no-restore -c Release

    if (0 -ne $LASTEXITCODE) {
        throw 'The build failed.'
    }

    Write-Information -MessageData ([string]::Format('({0}) Testing ItoCommandRuntimeProxy at {1}...', ++$lineCount, $dotNetCSharpCommandRuntimeProxySolutionPath)) -InformationAction Continue

    dotnet test $dotNetCSharpCommandRuntimeProxySolutionPath -c Release
}

Import-Module (Join-Path $dotNetCSharpCommandRuntimeProxyBasePath 'ItoCommandRuntimeProxy\bin\Release\net452\ItoCommandRuntimeProxy.dll')
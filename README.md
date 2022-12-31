# InformationTechnologyOperationsModule

## About

### Author

Ryan E. Anderson

---

### Description

This module contains utilities that can be used to simplify the execution of tasks that are part of IT operations.

---

### Version

0.1.0

---

### License

Apache-2.0

---

## Using the Module

The InformationTechnologyOperationsModule exports one function, which is documented below. Please, execute the script named Build.ps1 to build dependencies and import InformationTechnologyOperationsModule. The Build.ps1 script also runs tests and analyzes code coverage. More information about testing is provided in the next section.

### Start-InformationTechnologyOperationsVirtualMachine (sitovm)

This function or command starts virtual machines hosted on an instance of Hyper-V after evaluating memory usage. This function supports wildcards and initialization of multiple virtual machines per execution.

#### SupportsShouldProcess:$true

#### ConfirmImpact:High

#### Parameters

##### Name

This is a list of names that identify virtual machines.

##### Threshold

The total memory capacity is decreased by this percentage, to a threshold, beyond which a VM cannot start. This value must be between 0.05 and 0.95. This parameter has a default value of 0.20, which is 20%.

##### AsJob

This is a switch that can be used to start VMs as background jobs.

##### Force

This is a switch that can be used to force the initialization of virtual machines after determining that resource usage could exceed a reasonable amount.

#### Examples

Below are some examples for how to use the Start-InformationTechnologyOperationVirtualMachine command.

##### Example 1: Start Virtual Machines With a List of Names

```powershell
Start-InformationTechnologyOperationVirtualMachine -Name 'Ubuntu-22.10', 'Linux-Mint-Cinnamon' -Threshold 0.25
```

##### Example 2: Start Virtual Machines With a Wildcard

```powershell
Start-InformationTechnologyOperationVirtualMachine -Name 'Ubuntu*' -Threshold 0.25
```

##### Example 3: Start a Virtual Machine With an Alias

This example demonstrates how to use the exported alias to start virtual machines.

```powershell
sitovm -Name 'Ubuntu-22.10' -Threshold 0.25
```

#### Remarks About Start-InformationTechnologyOperationVirtualMachine

- Exercise caution before executing the Start-InformationTechnologyOperationVirtualMachine command with force; doing so could cause excessive usage of resources or memory.
- If -Confirm:$false is used, then a user will be prompted to continue if the -Force switch is not present.
- If -Confirm is used without the presence of -Force, then no prompts will be suppressed.
- If the -Force switch is the only switch that is present, then all prompts will be suppressed.

#### Using the Provided Windows Batch File

A Windows batch script (Start-Information-Technology-Operations-Virtual-Machine.bat) has been provided to conveniently initialize virtual machines. The script may be edited to use a different list of names and/or threshold. The script needs to be executed with administrator privileges.

---

## Testing the Module

### Pester

Pester can be used to test this module to obtain information about code coverage. A suite of unit tests has been created to examine different contexts or scenarios and attain optimal coverage of the code. Dependencies for testing can be built using either Build.ps1 or SetUpTestEnvironment.ps1. Below is a command for analyzing code coverage with Pester.

```powershell
Invoke-Pester '.\tests' -CodeCoverage '.\informationtechnologyoperationsmodule\InformationTechnologyOperationsModule.psm1'
```
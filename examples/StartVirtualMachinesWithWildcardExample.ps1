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

###################################################################################################
#                                                                                                 #
#    InformationTechnologyOperationsModule v0.1.0 Start Virtual Machines With Wildcard Example    #
#                                                                                                 #
#    By Ryan E. Anderson                                                                          #
#                                                                                                 #
#    Copyright (C) 2022 Ryan E. Anderson                                                          #
#                                                                                                 #
###################################################################################################

Set-StrictMode -Version Latest

Import-Module InformationTechnologyOperationsModule

Start-InformationTechnologyOperationVirtualMachine -Name 'Ubuntu*' -Threshold 0.25 -Confirm:$false # Any VM that has a name that begins with Ubuntu will be started with this command.

Read-Host 'Press any key to continue'
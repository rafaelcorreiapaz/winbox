# WinBox PowerShell profile
#
# Copyright 2015, Adam Edwards
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Enable readline support
#
import-module psreadline
Set-PSReadlineOption -EditMode Emacs

# Get the username and whether we're elevated for display
# in the title and prompt
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal] $identity
$titleprefix = ""
if (test-path variable:/PSDebugContext) { $titleprefix = 'Debug: ' }
elseif($principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{ $titleprefix = "Administrator: " }

#
# The title will look like one of the following:
#
#   myusername@myhost
#   Administrator: myusername@myhost
#
(get-host).ui.rawui.windowtitle = "$titleprefix$($env:username)@$($env:computername)"

#
# Set a useful two-line prompt that uses color for readability and status.
# The format is 'host: lastexitcode: currentdirectory `newline `username >'.
#
# Here's example output:
#
#   myhost: 0x00000001: c:\dosbox\config.sys
#   myuser >
#
function prompt
{
    $lasterror = $?
    $lastexit = $lastexitcode
    $errorcolor = 'green'
    $exitcolor = 'green'
    if (! $lasterror) { $errorcolor = 'red' }
    if ($lastexit -ne 0) { $exitcolor = 'red' }

    write-host -nonewline -foregroundcolor $errorcolor "($env:computername)"
    write-host -nonewline -foregroundcolor gray ': '
    write-host -nonewline -foregroundcolor $exitcolor "0x$(($lastexit).ToString("X8"))"
    write-host -nonewline -foregroundcolor gray ": "
    write-host -foregroundcolor yellow "$($executionContext.SessionState.Path.CurrentLocation)"
    write-host -nonewline -foregroundcolor cyan "($env:username)"
    "$('>' * ($nestedPromptLevel + 1)) "
}

# Make the man alias show full help by default
. ~\get-help-full.ps1
set-alias -option allscope man get-help-full

# Useful shortcut to get to Documents folder
. ~\set-location-docs.ps1
new-alias docs set-location-docs


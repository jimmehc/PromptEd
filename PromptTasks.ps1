$script:promptTasks = [ordered]@{}
    
function script:Invoke-PromptTasks
{
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [int]$realLASTEXITCODE
    )

    foreach($task in $script:promptTasks.Values)
    {
        $task.Invoke()
        $LASTEXITCODE = $realLASTEXITCODE
    }
}

function Add-PromptTask
{
    <#
    .SYNOPSIS
        Add a ScriptBlock or function to the list of PromptTasks. 
    .DESCRIPTION
        Function to add a ScriptBlock or function to the current list of PromptTasks.
    .PARAMETER Name
        Name of the PromptTask being added.
    .PARAMETER Function
        Scriptblock or function to add as a PromptTask to run against all computers.
    .EXAMPLE
        Add-PromptTask UpdateWindowTitle { $Host.UI.RawUI.WindowTitle = (pwd) }
    .EXAMPLE
        PS C:\> function foo{ $Host.UI.RawUI.WindowTitle = (pwd) }

        Add-PromptTask UpdateWindowTitle $function:foo
    .FUNCTIONALITY
        PowerShell Language
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Name,
        [Parameter(Position=1, Mandatory=$true)]
        [System.Management.Automation.ScriptBlock] $Function
    )

    if($script:promptTasks[$Name] -eq $null)
    {
        $script:promptTasks[$Name] = $Function
    }
    else
    {
        Write-Error "A prompt task with the name, $Name, already exists"
    }
}

function Remove-PromptTask
{
    <#
    .SYNOPSIS
        Remove an existing PromptTask.
    .DESCRIPTION
        Function to remove a ScriptBlock or function from the current list of PromptTasks.
    .PARAMETER Name
        Name of the PromptTask being removed.
    .EXAMPLE
        Remove-PromptTask UpdateWindowTitle
    .FUNCTIONALITY
        PowerShell Language
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Name
    )

    $script:promptTasks.Remove($Name)
}

function Get-PromptTask
{
    <#
    .SYNOPSIS
        Get the list of current PromptTasks.
    .DESCRIPTION
        Retuns the list of current PromptTasks.
    .FUNCTIONALITY
        PowerShell Language
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    $script:promptTasks
}


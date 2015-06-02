
$script:promptTasks = [ordered]@{}
    
function script:Invoke-PromptTasks
{
    $script:promptTasks.Values | %{ $_.Invoke() }
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

$script:oldPrompt = $function:prompt
$script:currentPrompt = $script:oldPrompt

function script:Write-Prompt
{
    $script:currentPrompt.Invoke()
}

function global:prompt
{
    script:Invoke-PromptTasks
    script:Write-Prompt
    return " "
}

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {            
    $function:prompt = $script:oldPrompt            
}
   
$script:prompts = @{}

function Set-Prompt
{
    <#
    .SYNOPSIS
        Sets the current prompt. 
    .DESCRIPTION
        Sets the current prompt to one of the builtin prompts, or a custom function.
    .PARAMETER BuiltIn
        Name of a BuiltIn prompt function.
    .PARAMETER Custom
        A custom ScriptBlock or function to set as the current prompt.
    .EXAMPLE
        PS C:\> Set-Prompt UNAtCNBrackets
        [jimmeh@jimmehsbox] C:\$ 
    .EXAMPLE
        PS C:\> Set-Prompt { "Hello >" }
        Hello >
    .FUNCTIONALITY
        PowerShell Language
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    [CmdletBinding(DefaultParameterSetName="BuiltIn")]
    param(
        [Parameter(Position=0, Mandatory=$true, ParameterSetName="BuiltIn")]
        [PromptType]$BuiltIn,
        [Parameter(Position=0, Mandatory=$true, ParameterSetName="Custom")]
        [System.Management.Automation.ScriptBlock]$PromptFunction
    )

    switch ($PsCmdlet.ParameterSetName) 
    {
        "BuiltIn" { $script:currentPrompt = $script:prompts[$BuiltIn] }
        "Custom"  { $script:currentPrompt = $PromptFunction }
    }
}

$script:promptChar = '$'

function Set-PromptChar
{
    <#
    .SYNOPSIS
        Sets the "prompt character".
    .DESCRIPTION
        Sets the character between the path and cursor in common prompts.
    .PARAMETER Char
        The character to set as the prompt character.
    .EXAMPLE
        [jimmeh@jimmehsbox] C:\$ Set-PromptChar '>'
        [jimmeh@jimmehsbox] C:\>
    .FUNCTIONALITY
        PowerShell Language
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [char]$Char
    )

    $script:promptChar = $Char
}

function Get-PromptChar
{
    <#
    .SYNOPSIS
        Gets the "prompt character".
    .DESCRIPTION
        Gets the character between the path and cursor in common prompts.
    .EXAMPLE
        [jimmeh@jimmehsbox] C:\$ Get-PromptChar
        $
    .FUNCTIONALITY
        PowerShell Language
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    $script:promptChar
}

$script:promptColors = 
    @{
        Path = $Host.UI.RawUI.ForegroundColor;
        Preamble = [ConsoleColor]::Magenta;
     }

function Set-PromptColor
{
    <#
    .SYNOPSIS
        Sets a color for use in prompts.
    .DESCRIPTION
        Sets a color, associated with a specific name, which is used in available prompts.
    .PARAMETER Name
        The name associated with the color being set.
    .EXAMPLE
        (Imagine "C:\" is displayed in white.)
        [jimmeh@jimmehsbox] C:\$ Set-PromptColor "Path" Red
        (Now imagine "C:\" is displayed in red.)
        [jimmeh@jimmehsbox] C:\$
    .FUNCTIONALITY
        PowerShell Language
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateScript({$script:promptColors.ContainsKey($_)})]
        [string]$Name,
        [Parameter(Position=1, Mandatory=$true)]
        [ConsoleColor]$Color
    )

    $script:promptColors[$Name] = $Color
}

function Get-PromptColor
{
    <#
    .SYNOPSIS
        Gets a color used by some or all available prompts, or all colors used.
    .DESCRIPTION
        Gets a color, associated with a specific name, which is used in available prompts, or all colors used.
    .PARAMETER Name
        The name associated with the color being gotten.  Not mandatory.
    .EXAMPLE
        (Imagine "C:\" is displayed in green.)
        [jimmeh@jimmehsbox] C:\$ Get-PromptColor "Path"
        Green
    .EXAMPLE
        (Imagine "C:\" is displayed in green, and "[jimmeh@jimmehsbox]" in magenta.)
        [jimmeh@jimmehsbox] C:\$ Get-PromptColor
        Name                           Value
        ----                           -----
        Preamble                       Magenta
        Path                           Green
    .FUNCTIONALITY
        PowerShell Language
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$false)]
        [ValidateScript({$script:promptColors.ContainsKey($_)})]
        [string]$Name
    )

    if(![string]::IsNullOrEmpty($Name))
    {
        $script:promptColors[$Name]
    }
    else
    {
        $script:promptColors
    }
}

function Get-BuiltInPrompts
{
    <#
    .SYNOPSIS
        Gets the names of all available builtin prompts.
    .DESCRIPTION
        Gets the names of all available builtin prompts.
    .EXAMPLE
        [jimmeh@jimmehsbox] C:\$ Get-BuiltInPrompts
        UNAtCN
        UNAtCNBrackets
        JustPath
    .FUNCTIONALITY
        PowerShell Language
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    $script:prompts.Keys
}

function script:Get-CurrentLocation
{
    "$($executionContext.SessionState.Path.CurrentLocation)$($script:promptChar * ($nestedPromptLevel + 1))".Replace("Microsoft.PowerShell.Core\FileSystem::", "")
}

Add-Type -TypeDefinition @"
   public enum PromptType
    {
        UNAtCNBrackets,
        UNAtCN,
        JustPath
    }
"@

$script:prompts[[PromptType]::UNAtCNBrackets] = { 
    Write-Host -ForeGroundColor $script:promptColors["Preamble"] "[$($env:USERNAME)@$($env:COMPUTERNAME)]".ToLower() -nonewline; 
    Write-Host -ForeGroundColor $script:promptColors["Path"] " $(script:Get-CurrentLocation)" -NoNewLine
}

$script:prompts[[PromptType]::UNAtCN] = { 
    Write-Host -ForeGroundColor $script:promptColors["Preamble"] "$($env:USERNAME)@$($env:COMPUTERNAME):".ToLower() -nonewline; 
    Write-Host -ForeGroundColor $script:promptColors["Path"] " $(script:Get-CurrentLocation)" -NoNewLine
}

$script:prompts[[PromptType]::JustPath] = {
    Write-Host -ForeGroundColor $script:promptColors["Path"] (script:Get-CurrentLocation) -NoNewLine
}


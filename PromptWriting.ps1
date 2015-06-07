param(
    [Parameter(Position=0, Mandatory=$true)]
    [PSModuleInfo]$PromptEdModule
)

$script:oldPrompt = $function:prompt
$script:currentPrompt = $script:oldPrompt

function script:Write-Prompt
{
    $script:currentPrompt.Invoke()
}

function global:prompt
{
    $realLASTEXITCODE = $LASTEXITCODE
    
    script:Invoke-PromptTasks $realLASTEXITCODE
    script:Write-Prompt

    $LASTEXITCODE = $realLASTEXITCODE
    return " "
}

$PromptEdModule.OnRemove = {            
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
    .PARAMETER Name
        Name of a built-in prompt function.
    .PARAMETER ScriptBlock
        A custom ScriptBlock or function to set as the current prompt.
    .EXAMPLE
        PS C:\> Set-Prompt UNAtCNBrackets
        [jimmeh@jimmehsbox] C:\$ 
    .EXAMPLE
        PS C:\> Set-Prompt { Write-Host "Hello >" -NoNewLine }
        Hello >
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    [CmdletBinding(DefaultParameterSetName="BuiltIn")]
    param(
        [Parameter(Position=0, Mandatory=$true, ParameterSetName="BuiltIn")]
        [string]$Name,
        [Parameter(Position=0, Mandatory=$true, ParameterSetName="Custom")]
        [System.Management.Automation.ScriptBlock]$ScriptBlock
    )

    switch ($PsCmdlet.ParameterSetName) 
    {
        "BuiltIn" { $script:currentPrompt = $script:prompts[$Name] }
        "Custom"  { $script:currentPrompt = $ScriptBlock }
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

function Get-BuiltInPromptNames
{
    <#
    .SYNOPSIS
        Gets the names of all available built-in prompts.
    .DESCRIPTION
        Gets the names of all available built-in prompts.
    .EXAMPLE
        [jimmeh@jimmehsbox] C:\$ Get-BuiltInPrompts
        UNAtCN
        UNAtCNBrackets
        JustPath
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    $script:prompts.Keys
}

function Add-BuiltInPrompt
{
    <#
    .SYNOPSIS
        Adds a built-in prompt.
    .DESCRIPTION
        Adds a function or ScriptBlock to the built-in prompts list.
    .PARAMETER Name
        The name of the new built-in prompt.
    .PARAMETER Prompt
        A ScriptBlock or function to add to the built-in prompts list.
    .EXAMPLE
        [jimmeh@jimmehsbox] C:\$ Add-BuiltInPrompt HelloWorld { Write-Host -ForeGroundColor (Get-PromptColor Preamble) "HelloWorld $(Get-PromptChar)" -NoNewLine }
    .EXAMPLE
        [jimmeh@jimmehsbox] C:\$ function HelloWorldPrompt { Write-Host -ForeGroundColor (Get-PromptColor Preamble) "HelloWorld $(Get-PromptChar)" -NoNewLine }
        [jimmeh@jimmehsbox] C:\$ AddBuiltInPrompt HelloWorld $function:HelloWorldPrompt
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Name,
        [Parameter(Position=1, Mandatory=$true)]
        [ScriptBlock]$Prompt
    )

    if($script:prompts.ContainsKey($Name))
    {
        Write-Error "A prompt with the name, $Name, already exists on the built-in prompts list."
        return
    }

    $script:prompts[$Name] = $Prompt
}

function Remove-BuiltInPrompt
{
    <#
    .SYNOPSIS
        Removes a built-in prompt.
    .DESCRIPTION
        Removes a function or ScriptBlock from the built-in prompts list.
    .PARAMETER Name
        The name of the built-in prompt to remove.
    .EXAMPLE
        [jimmeh@jimmehsbox] C:\$ Remove-Prompt UNAtCN
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Name
    )

    if(!$script:prompts.ContainsKey($Name))
    {
        Write-Error "No prompt with the name, $Name, exists on the built-in prompts list."
        return
    }

    $script:prompts.Remove($Name)
}

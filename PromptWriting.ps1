param(
    [Parameter(Position=0, Mandatory=$true)]
    [PSModuleInfo]$PromptEdModule
)

$script:oldPrompt = $function:prompt
$script:promptElements = @()
$script:promptElements += $script:oldPrompt

function script:Write-Prompt
{
    for($i = 0; $i -lt $script:promptElements.Count; $i++)
    {
        $script:promptElements[$i].Invoke()
        if($i -ne $script:promptElements.Count - 1)
        {
            if($script:promptElements[$i+1] -ne $function:pe_NoSeparator)
            {
                Write-Host " " -NoNewLine
            }
            else
            {
                $i++
            }
        }
    }
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

function Get-PromptElements
{
    . { 
        for($i = 0; $i -lt $script:promptElements.Length; $i++)
        {
            [pscustomobject]@{Index = $i; PromptElement = $script:promptElements[$i]}
        } 
    } | Format-List
}

function script:GetRealIndex
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [int]$Index,
        [Parameter(Mandatory=$true, Position=1)]
        [int]$Length
    )

    if($Index -lt 0)
    {
        $Index = $Length + $Index
    }

    return $Index;
}

function script:ValidateIndex
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [int]$Index,
        [Parameter(Mandatory=$true, Position=1)]
        [int]$Length
    )

    if($Index -lt 0 -or $Index -gt $Length)
    {
        Write-Error "Invalid index.  Valid index values: -$Length to $Length."
        return $false
    }

    return $true;
}

function Add-PromptElement
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [ScriptBlock]$PromptElement,
        [Parameter(Position=1, Mandatory=$false)]
        [int]$Index = $script:promptElements.Length
    )

    if(!$script:promptElements -or $Index -eq $script:promptElements.Length)
    {
        $script:promptElements += $PromptElement
        return
    }

    $Index = script:GetRealIndex $Index $script:promptElements.Length

    if(!(script:ValidateIndex $Index $script:promptElements.Length))
    {
        return
    }

    $newPromptElements = @()
    for($i = 0; $i -lt $script:promptElements.Length; $i++)
    {
        if($i -eq $Index)
        {
            $newPromptElements += $PromptElement
        }
        $newPromptElements += $script:promptElements[$i]
    }
    $script:promptElements = $newPromptElements
}

function Remove-PromptElement
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [int]$Index
    )

    if(!$script:promptElements)
    {
        Write-Error "No prompt elements to remove."
        return
    }

    $Index = script:GetRealIndex $Index $script:promptElements.Length

    if(!(script:ValidateIndex $Index $script:promptElements.Length))
    {
        return
    }

    $newPromptElements = @()
    for($i = 0; $i -lt $script:promptElements.Length; $i++)
    {
        if($i -eq $Index)
        {
            continue
        }
        $newPromptElements += $script:promptElements[$i]
    }
    $script:promptElements = $newPromptElements
}

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
        [string]$Name
    )

    $script:promptElements = @()
    foreach($element in $script:prompts[$Name])
    {
        $script:promptElements += $element
    }
}

$script:promptColors = 
    @{
        Path = $Host.UI.RawUI.ForegroundColor;
        Preamble = [ConsoleColor]::Magenta;
        Time = [ConsoleColor]::Blue;
        Brackets = [ConsoleColor]::Green;
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
        Adds a prompt to the built-in prompts list.
    .PARAMETER Name
        The name of the new built-in prompt.
    .PARAMETER Prompt
        An array of prompt elements (functions/ScriptBlocks) which construct the prompt.
    .EXAMPLE
    .EXAMPLE
    .LINK
        https://github.com/jimmehc/PromptEd
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Name,
        [Parameter(Position=1, Mandatory=$true)]
        [ScriptBlock[]]$PromptElements
    )

    if($script:prompts.ContainsKey($Name))
    {
        Write-Error "A prompt with the name, $Name, already exists on the built-in prompts list."
        return
    }

    $script:prompts[$Name] = $PromptElements
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
        [jimmeh@jimmehsbox] C:\$ Remove-BuiltInPrompt Simple
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

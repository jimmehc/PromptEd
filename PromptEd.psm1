
$script:promptTasks = [ordered]@{}
    
function Invoke-PromptTasks
{
    $script:promptTasks.Values | %{ $_.Invoke() }
}

function Add-PromptTask
{
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
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Name
    )

    $script:promptTasks.Remove($Name)
}

function Get-PromptTask
{
    $script:promptTasks
}

$script:currentPrompt = $function:prompt
function Write-Prompt
{
    $currentPrompt.Invoke()
}

function prompt
{
    Invoke-PromptTasks
    Write-Prompt
    return " "
}
 
$script:prompts = @{}

function Set-Prompt
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true, ParameterSetName="BuiltInStr")]
        [ValidateScript({[PromptType]$_})]
        [string]$promptTypeStr,
        [Parameter(Mandatory=$true, ParameterSetName="BuiltIn")]
        [PromptType]$BuiltIn,
        [Parameter(Position=0, Mandatory=$true, ParameterSetName="Custom")]
        [System.Management.Automation.ScriptBlock]$promptFunc
    )

    switch ($PsCmdlet.ParameterSetName) 
    {
        "BuiltInStr" { $script:currentPrompt = $script:prompts[[PromptType]$promptType] }
        "BuiltIn" { $script:currentPrompt = $script:prompts[$BuiltIn] }
        "Custom"  { $script:currentPrompt = $promptFunc }
    }
}

function Get-BuiltInPrompts
{
    $script:prompts.Keys
}

function script:Get-CurrentLocation
{
    "$($executionContext.SessionState.Path.CurrentLocation)$('$' * ($nestedPromptLevel + 1))".Replace("Microsoft.PowerShell.Core\FileSystem::","")
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
    Write-Host -ForeGroundColor magenta "[$($env:USERNAME)@$($env:COMPUTERNAME)]".ToLower() -nonewline; 
    Write-Host " $(script:Get-CurrentLocation)" -NoNewLine
}

$script:prompts[[PromptType]::UNAtCN] = { 
    Write-Host -ForeGroundColor magenta "$($env:USERNAME)@$($env:COMPUTERNAME):".ToLower() -nonewline; 
    Write-Host " $(script:Get-CurrentLocation)" -NoNewLine
}

$script:prompts[[PromptType]::JustPath] = {
     
    Write-Host (script:Get-CurrentLocation) -NoNewLine
}


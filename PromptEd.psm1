
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

$script:oldPrompt = $function:prompt
$script:currentPrompt = $script:oldPrompt
function Write-Prompt
{
    $currentPrompt.Invoke()
}

function global:prompt
{
    Invoke-PromptTasks
    Write-Prompt
    return " "
}

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {            
    $function:prompt = $script:oldPrompt            
}
   
$script:prompts = @{}

function Set-Prompt
{
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
    param(
        [Parameter(Position=0, Mandatory=$true)]
        [char]$Char
    )

    $script:promptChar = $Char
}

function Get-PromptChar
{
    $script:promptChar
}

$script:promptColors = 
    @{
        Path = $Host.UI.RawUI.ForegroundColor;
        Preamble = [ConsoleColor]::Magenta;
     }

function Set-PromptColor
{
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


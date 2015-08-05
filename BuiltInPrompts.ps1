# Define some colors for use in prompts
Add-PromptColor Path $Host.UI.RawUI.ForegroundColor
Add-PromptColor Preamble Magenta
Add-PromptColor Time Blue
Add-PromptColor Brackets Green

# Helper functions common to various prompt elements
function script:Get-CurrentLocation
{
    "$($executionContext.SessionState.Path.CurrentLocation)"
}

function script:Get-DefaultPathOutput
{
    "$(Get-CurrentLocation)".Replace("Microsoft.PowerShell.Core\FileSystem::", "").Replace($env:USERPROFILE,"~")
}

# Prompt element definitions
function pe_UNAtCN { 
    Write-Host -ForeGroundColor $script:promptColors["Preamble"] "$($env:USERNAME)@$($env:COMPUTERNAME)".ToLower() -NoNewLine; 
}

function pe_UNAtCNBrackets { 
    Write-Host -ForeGroundColor $script:promptColors["Brackets"] "[" -NoNewLine
    pe_UNAtCN
    Write-Host -ForeGroundColor $script:promptColors["Brackets"] "]" -NoNewLine
}

function pe_FullPath {
    Write-Host -ForeGroundColor $script:promptColors["Path"] (script:Get-DefaultPathOutput) -NoNewLine
}

function pe_UNCNWithPath{
    pe_UNAtCN
    pe_FullPath
}

function pe_UNCNWithPathAndBrackets{
    Write-Host -ForeGroundColor $script:promptColors["Preamble"] "[" -NoNewLine
    pe_UNAtCN
    Write-Host -ForeGroundColor $script:promptColors["Preamble"] ":" -NoNewLine
    pe_FullPath
    Write-Host -ForeGroundColor $script:promptColors["Path"] "]" -NoNewLine
}

function pe_NewLine {
    Write-Host ""
}

function pe_DollarSign {
    Write-Host "$" -NoNewLine
}

function pe_Lamda {
    Write-Host "λ" -NoNewLine
}

function pe_GreaterThan{
    Write-Host ">" -NoNewLine
}

function pe_BracketedTime{
    Write-Host -ForeGroundColor $script:promptColors["Time"] -NoNewLine "[$(Get-Date -Format "ddd MMM dd HH:mm:ss")]"
}

function pe_PoshGitStatus{
    if(Get-Module posh-git)
    {
        Write-VcsStatus
    }
}

function pe_NoSeparator { <# No Separator #> }

# Built-in prompt definitions
Add-BuiltInPrompt JustPath @(
    $function:pe_FullPath,
    $function:pe_NoSeparator,
    $function:pe_GreaterThan
)

Add-BuiltInPrompt Simple @(
    $function:pe_UNAtCNBrackets,
    $function:pe_FullPath,
    $function:pe_NoSeparator,
    $function:pe_DollarSign
)

Add-BuiltInPrompt SimpleLamda @(
    $function:pe_UNCNWithPathAndBrackets,
    $function:pe_Lamda
)

Add-BuiltInPrompt Timestamped @(
    $function:pe_BracketedTime,
    $function:pe_UNCNWithPathAndBrackets,
    $function:pe_NoSeparator,
    $function:pe_PoshGitStatus,
    $function:pe_NewLine,
    $function:pe_NoSeparator,
    $function:pe_Lamda
)


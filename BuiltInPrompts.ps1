function script:Get-CurrentLocation
{
    "$($executionContext.SessionState.Path.CurrentLocation)$($script:promptChar * ($nestedPromptLevel + 1))".Replace("Microsoft.PowerShell.Core\FileSystem::", "")
}

Add-BuiltInPrompt UNAtCNBrackets { 
    Write-Host -ForeGroundColor $script:promptColors["Preamble"] "[$($env:USERNAME)@$($env:COMPUTERNAME)]".ToLower() -nonewline; 
    Write-Host -ForeGroundColor $script:promptColors["Path"] " $(script:Get-CurrentLocation)" -NoNewLine
}

Add-BuiltInPrompt UNAtCN { 
    Write-Host -ForeGroundColor $script:promptColors["Preamble"] "$($env:USERNAME)@$($env:COMPUTERNAME):".ToLower() -nonewline; 
    Write-Host -ForeGroundColor $script:promptColors["Path"] " $(script:Get-CurrentLocation)" -NoNewLine
}

Add-BuiltInPrompt JustPath {
    Write-Host -ForeGroundColor $script:promptColors["Path"] (script:Get-CurrentLocation) -NoNewLine
}


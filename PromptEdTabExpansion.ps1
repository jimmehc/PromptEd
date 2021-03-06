function BuiltInPromptCompletion
{
    param($commandName,
            $parameterName,
            $wordToComplete,
            $commandAst,
            $fakeBoundParameters)

    Get-BuiltInPromptNames | Where-Object { $_ -match "^$wordToComplete" } | ForEach-Object{ New-CompletionResult $_ }
}

if(Get-Module TabExpansion++)
{
    Register-ArgumentCompleter -CommandName "Set-Prompt","Remove-Prompt" -ParameterName "Name" -ScriptBlock $function:BuiltInPromptCompletion

    return
}

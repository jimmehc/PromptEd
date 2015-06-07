function BuiltInPromptCompletion
{
    [ArgumentCompleter(Parameter="Name", Command="Set-Prompt")]
    param($commandName,
            $parameterName,
            $wordToComplete,
            $commandAst,
            $fakeBoundParameters)

    Get-BuiltInPromptNames | Where-Object { $_ -match "^$wordToComplete" } | ForEach-Object{ New-CompletionResult $_ }
}

if(Get-Module TabExpansion++)
{
    Register-ArgumentCompleter -CommandName "Set-Prompt","Remove-Prompt" -ParameterName "BuiltIn" -ScriptBlock $function:BuiltInPromptCompletion

    return
}

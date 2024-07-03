if ($host.UI.RawUI.WindowTitle.Contains('(Dev)')) {
    $env:AZURE_CONFIG_DIR = Join-Path $([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)) ".azure/Dev"
    az account set --subscription "1553f57f-d882-4a7e-9055-e6b1b49abc6a"

    (@(&"oh-my-posh" init powershell --config="$env:POSH_THEMES_PATH\craver.omp.json" --print) -join "`n") | Invoke-Expression

    Register-ArgumentCompleter -Native -CommandName az -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        $completion_file = New-TemporaryFile #TODO: put this into the dedicated folder
        $env:ARGCOMPLETE_USE_TEMPFILES = "1"
        $env:_ARGCOMPLETE_STDOUT_FILENAME = $completion_file
        $env:COMP_LINE = $wordToComplete
        $env:COMP_POINT = $cursorPosition
        $env:_ARGCOMPLETE = 1
        $env:_ARGCOMPLETE_SUPPRESS_SPACE = 0
        $env:_ARGCOMPLETE_IFS = "'n"
        az 2>&1 | Out-Null
        Get-Content $completion_file | Sort-Object | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
        Remove-Item $completion_file, Env:\_ARGCOMPLETE_STDOUT_FILENAME, env:\ARGCOMPLETE_USE_TEMPFILES, env:\COMP_LINE, env:\COMP_POINT, env:\_ARGCOMPLETE, env:\_ARGCOMPLETE_SUPPRESS_SPACE, env:\_ARGCOMPLETE_IFS
    }
}
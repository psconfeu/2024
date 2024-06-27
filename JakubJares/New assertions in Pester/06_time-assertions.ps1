(Get-Item "C:\Windows\System32\notepad.exe").CreationTime |
    Should-BeAfter 1week -Ago


{ Start-Sleep -Second 1 } 
    | Should-BeFasterThan 1s

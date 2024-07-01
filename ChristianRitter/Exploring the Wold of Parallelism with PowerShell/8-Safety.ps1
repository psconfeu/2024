
# Messing things up.. Shout-Out to Chris Dent and Mathias Jessen

$d = [System.Collections.Generic.Dictionary[int,string]]::new()
1..10000 | ForEach-Object -ThrottleLimit 500 -Parallel {
    Start-Sleep -Milliseconds (Get-Random -Minimum 50 -Maximum 250)
    ($using:d).Add($_, 'Nothing')
}
$d.Count


# make it safe

$d = [System.Collections.Concurrent.ConcurrentDictionary[int,string]]::new()
1..10000 | ForEach-Object -ThrottleLimit 500 -Parallel {
    Start-Sleep -Milliseconds (Get-Random -Minimum 50 -Maximum 100)
    ($using:d)[$_] = 'Nothing'
}
$d.Count


# Dont do this
1..100 | ForEach-Object -Parallel {

    "Hello from PSConfEU_$($_)" | Out-FIle C:\Temp\HelloFrom9.txt -Append
} -ThrottleLimit 10
(get-content C:\Temp\Hellofrom7.txt).Count
# Do this instead

$Safe = 1..100 | ForEach-Object -Parallel {

    "Hello from PSConfEU_$($_)"
} -ThrottleLimit 10


$Safe | Out-File C:\Temp\HelloFrom10.txt
(get-content C:\Temp\Hellofrom8.txt).Count
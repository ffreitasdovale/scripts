$Computers = Get-Adcomputer -filter * -SearchBase "OU=OU,DC=dominio,DC=com" | select -expandproperty name 

foreach ($computer in $computers) {

$test = test-connection $computer -quiet -count 1

if ($test -eq true) {

shutdown /m \\$computer /r /f /t 0 }
}

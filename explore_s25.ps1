$shell = New-Object -ComObject Shell.Application
$computer = $shell.NameSpace(17) # 17 is My Computer / This PC
$s25 = $computer.Items() | Where-Object { $_.Name -like "*S25*" -or $_.Name -like "*Galaxy*" }

if ($s25) {
    Write-Output "[+] Found phone: $($s25.Name)"
    $phoneFolder = $s25.GetFolder
    $items = $phoneFolder.Items()
    if ($items.Count -eq 0) {
        Write-Output "[!] Phone folder is empty or locked. Please unlock the phone screen and allow access."
    } else {
        Write-Output "[+] Storage devices/folders on phone:"
        $items | ForEach-Object {
            Write-Output "  - $($_.Name)"
        }
    }
} else {
    Write-Output "[-] S25 Phone not found in This PC"
}

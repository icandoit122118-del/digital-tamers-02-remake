$root = 'D:\digimon-re'
$out = "$root\out\fonts"
New-Item -ItemType Directory -Force -Path $out | Out-Null
Set-Content -Path "$root\in_fonts.txt" -Value @($out, 'N', 'N') -Encoding ascii
cmd /c "`"$root\tools\cli\UndertaleModCli.exe`" load `"$root\game.droid`" -s `"$root\tools\cli\Scripts\Resource Exporters\ExportAllFonts.csx`" < `"$root\in_fonts.txt`" > `"$root\log_fonts.txt`" 2>&1"
Get-Content "$root\log_fonts.txt" -Tail 6
Get-ChildItem $out | Select-Object Name, Length | Format-Table -AutoSize | Out-String

$ErrorActionPreference = 'Continue'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$apk = 'C:\Users\icand\OneDrive\Desktop\' + [regex]::Unescape('\ub514\uc9c0\ubaac \uc6d0\ubcf8.apk')
$root = 'D:\digimon-re'
$z = [IO.Compression.ZipFile]::OpenRead($apk)
$n = 0
foreach ($e in $z.Entries) {
    if ($e.FullName -match '^assets/[^/]+\.(ogg|dat)$' -and $e.FullName -notmatch 'game\.droid') {
        [IO.Compression.ZipFileExtensions]::ExtractToFile($e, (Join-Path $root $e.Name), $true)
        $n++
    }
}
$z.Dispose()
"extracted next to game.droid: $n files"
# rerun sound export: external audio = Y, group = N
$cli = "$root\tools\cli\UndertaleModCli.exe"
$sd  = "$root\tools\cli\Scripts\Resource Exporters"
$out = "$root\out\sounds"
Set-Content -Path "$root\in_sounds2.txt" -Value @($out, 'Y', 'N', 'N', 'N') -Encoding ascii
cmd /c "`"$cli`" load `"$root\game.droid`" -s `"$sd\ExportAllSounds.csx`" < `"$root\in_sounds2.txt`" > `"$root\log_sounds2.txt`" 2>&1"
Get-Content "$root\log_sounds2.txt" -Tail 4
$s = Get-ChildItem $out -Recurse -File
'total {0}; empty(<=44B): {1}' -f $s.Count, ($s | Where-Object { $_.Length -le 44 }).Count
$s | Group-Object Extension | ForEach-Object { '{0}: {1}' -f $_.Name, $_.Count }
Get-ChildItem $out -Directory | ForEach-Object { 'subdir: ' + $_.Name + ' (' + (Get-ChildItem $_.FullName -File).Count + ')' }

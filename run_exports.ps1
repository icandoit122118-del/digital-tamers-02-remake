$ErrorActionPreference = 'Continue'
$root = 'D:\digimon-re'
$cli  = "$root\tools\cli\UndertaleModCli.exe"
$sd   = "$root\tools\cli\Scripts\Resource Exporters"
$jobs = @(
    @{ s='ExportAllStringsJSON.csx'; o="$root\out\strings.json" },
    @{ s='ExportAllSprites.csx';     o="$root\out\sprites" },
    @{ s='ExportAllSounds.csx';      o="$root\out\sounds" }
)
foreach ($j in $jobs) {
    $name = $j.s
    Write-Output ("=== START {0} {1}" -f $name, (Get-Date -Format T))
    if ($name -like '*JSON*') { New-Item -ItemType Directory -Force -Path (Split-Path $j.o) | Out-Null } else { New-Item -ItemType Directory -Force -Path $j.o | Out-Null }
    $inp = "$root\in_$name.txt"
    Set-Content -Path $inp -Value $j.o -Encoding ascii
    $log = "$root\log_$name.txt"
    cmd /c "`"$cli`" load `"$root\game.droid`" -s `"$sd\$name`" < `"$inp`" > `"$log`" 2>&1"
    Write-Output ("=== END {0} exit={1} {2}" -f $name, $LASTEXITCODE, (Get-Date -Format T))
    Get-Content $log -Tail 3
}
Write-Output 'ALL DONE'

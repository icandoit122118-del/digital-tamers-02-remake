$ErrorActionPreference = 'Continue'
$g = 'D:\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
$proj = 'D:\digimon-re\godot'
$shots = 'D:\digimon-re\out\shots'
New-Item -ItemType Directory -Force -Path $shots | Out-Null
foreach ($room in 'room_Training','room_Agumon_House','room_Tamer_Info') {
    $png = "$shots\$room.png"
    Remove-Item $png -ErrorAction SilentlyContinue
    Write-Output "--- $room"
    & $g --path $proj --rendering-driver opengl3 -- "--room=$room" "--shot=$png" 2>&1 | Where-Object { $_ -match 'ROOM|SHOT|ERROR|error|WARNING' } | Select-Object -First 8
    if (Test-Path $png) { '{0} bytes' -f (Get-Item $png).Length } else { 'NO SCREENSHOT' }
}

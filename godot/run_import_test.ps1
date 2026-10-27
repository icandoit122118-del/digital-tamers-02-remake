$ErrorActionPreference = 'Continue'
$g = 'D:\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
$proj = 'D:\digimon-re\godot'
$dst = "$proj\import_test"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
$ogg = Get-ChildItem 'D:\digimon-re\out\sounds' -Filter *.ogg | Select-Object -First 3
$wav = Get-ChildItem 'D:\digimon-re\out\sounds' -Filter *.wav | Select-Object -First 3
foreach ($f in @($ogg) + @($wav)) { Copy-Item $f.FullName $dst }
Copy-Item 'D:\digimon-re\out\sprites\spr_Training_Main_HUD\*' $dst
Get-ChildItem $dst | Select-Object -First 12 | ForEach-Object { $_.Name }
& $g --headless --path $proj --import 2>&1 | Select-Object -Last 8
'--- .import files'
Get-ChildItem $dst -Filter *.import | ForEach-Object { $_.Name }
'--- imported cache'
(Get-ChildItem "$proj\.godot\imported" -File -ErrorAction SilentlyContinue | Group-Object Extension | ForEach-Object { '{0}: {1}' -f $_.Name, $_.Count })

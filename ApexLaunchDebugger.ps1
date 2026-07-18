# Apex Legends Launch Error Diagnostic Script (ApexLaunchDebugger.ps1)
# This script is intended to be run with Administrator privileges.

# Localized ErrorAction for safety, but not silent globally to catch bugs
$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Language Auto-Detection (Japanese / English)
$isJa = ([System.Globalization.CultureInfo]::CurrentUICulture.Name -match "ja")

# Text Resources Dictionary
$T = @{
    Title = if ($isJa) { "  Apex Legends 起動エラー診断ツール v2.2" } else { "  Apex Legends Launch Debugger v2.2" }
    Starting = if ($isJa) { "診断を開始します。調査が完了するまでお待ちください..." } else { "Starting diagnosis. Please wait until completed..." }
    StartTime = if ($isJa) { "開始時刻: " } else { "Start Time: " }
    ReportTitle = if ($isJa) { "      Apex Legends 起動エラー診断レポート" } else { "      Apex Legends Launch Diagnosis Report" }
    GeneratedAt = if ($isJa) { "      生成日時: " } else { "      Generated At: " }
    
    SysInfoHead = if ($isJa) { "--- [システム基本情報] ---" } else { "--- [System Information] ---" }
    SysInfoCollect = if ($isJa) { "[1/6] システム基本情報を収集しています..." } else { "[1/6] Collecting system information..." }
    
    InstallHead = if ($isJa) { "--- [インストール情報] ---" } else { "--- [Installation Information] ---" }
    InstallSearch = if ($isJa) { "[2/6] Apex Legends のインストール先を探索しています..." } else { "[2/6] Searching for Apex Legends installation..." }
    InstallFound = if ($isJa) { "検出されたインストール先: " } else { "Detected installation directory: " }
    InstallFailed = if ($isJa) { "Apex Legends のインストール先を自動検出できませんでした。手動起動モードで監視を行います。" } else { "Could not auto-detect installation path. Entering manual monitoring mode." }
    InstallPathRep = if ($isJa) { "インストール先: " } else { "Installation Path: " }
    InstallExeRep = if ($isJa) { "実行ファイル: " } else { "Executable Path: " }
    InstallFailedRep = if ($isJa) { "インストール先: 自動検出に失敗しました（手動起動での監視を行います）" } else { "Installation Path: Auto-detect failed (will monitor manual launch)" }
    
    BadwareHead = if ($isJa) { "--- [Easy Anti-Cheat 競合・ブロック候補ソフトウェア] ---" } else { "--- [Easy Anti-Cheat Block/Conflict Candidates] ---" }
    BadwareScan = if ($isJa) { "[3/6] Easy Anti-Cheatが検知対象とする「Badware」や不要な仮想ドライバを検査しています..." } else { "[3/6] Scanning for 'Badware' and virtual drivers flagged by EAC..." }
    BadwareRewasd = if ($isJa) { " - 【ReWASD】(仮想コントローラーツール) がインストール、またはサービスが起動しています。" } else { " - [ReWASD] (Virtual controller software) is installed or its service is running." }
    BadwareDaemon = if ($isJa) { " - 【DAEMON Tools】(仮想ドライブツール) のインストール、または関連プロセスの起動を確認しました。" } else { " - [DAEMON Tools] (Virtual drive software) is installed or its process is running." }
    BadwareAhk = if ($isJa) { " - 【AutoHotkey】(マクロ/スクリプトツール) のインストール、または起動を確認しました。" } else { " - [AutoHotkey] (Macro/scripting tool) is installed or running." }
    BadwareCe = if ($isJa) { " - 【Cheat Engine】(メモリ変更ツール/デバッガ) が検出されました。" } else { " - [Cheat Engine] (Memory modifier/debugger) is detected." }
    BadwareOther = if ($isJa) { " - 【{0}】(キーマッピングツール/仮想コントローラー) が現在実行されています。" } else { " - [{0}] (Keymapper/virtual controller) is currently running." }
    BadwareVigem = if ($isJa) { " - 【ViGEmBus (仮想コントローラドライバ)】を検出。ReWASDや他のゲームパッド偽装ソフトの残骸の可能性があります。" } else { " - [ViGEmBus (Virtual Controller Driver)] detected. Could be leftover from ReWASD or other controller emulators." }
    BadwareDaemonDrv = if ($isJa) { " - 【Disc Soft / DAEMON Tools 関連ドライバ】を検出。仮想ドライブソフトの残骸の可能性があります。" } else { " - [Disc Soft / DAEMON Tools Driver] detected. Could be leftover from virtual drive software." }
    BadwareWarning = if ($isJa) { "警告: アンチチートに「Badware」と判定されるソフトウェア・ドライバが検出されました！" } else { "WARNING: Software or drivers flagged as 'Badware' by anti-cheat were detected!" }
    BadwareNone = if ($isJa) { "代表的なブロック対象ソフトウェア (ReWASD, DAEMON Tools 等) は検出されませんでした。" } else { "No typical blocked software (ReWASD, DAEMON Tools, etc.) was detected." }
    BadwareNoneConsole = if ($isJa) { "代表的な競合ソフトウェアは検出されませんでした。" } else { "No typical conflicting software detected." }
    
    ConflictHead = if ($isJa) { "--- [現在実行中のその他競合候補プロセス] ---" } else { "--- [Other Currently Running Conflict Candidates] ---" }
    ConflictScan = if ($isJa) { "[4/6] 競合する可能性のあるプロセスをチェックしています..." } else { "[4/6] Checking for other potentially conflicting processes..." }
    ConflictNone = if ($isJa) { "競合の可能性が疑われる顕著なプロセスは見つかりませんでした。" } else { "No notable conflicting processes were found." }
    ConflictVs = if ($isJa) { " - 【ウイルスセキュリティZERO】(Sourcenext製のセキュリティソフトがインストール/稼働しています。EACやゲームの起動を誤検知で遮断する事例があります)" } else { " - [Virus Security ZERO] (Security software by Sourcenext is running. Known to cause false-positive launch blocks with EAC)" }
    
    LaunchHead = if ($isJa) { "--- [起動監視結果] ---" } else { "--- [Launch Monitor Results] ---" }
    LaunchTry = if ($isJa) { "[5/6] Apex Legends の起動を試みます..." } else { "[5/6] Attempting to launch Apex Legends..." }
    LaunchStart = if ($isJa) { "ゲームを起動します..." } else { "Launching game..." }
    LaunchSteam = if ($isJa) { "Steam経由で起動を試みます..." } else { "Attempting launch via Steam..." }
    LaunchDirect = if ($isJa) { "直接実行ファイルを起動します..." } else { "Launching executable directly..." }
    LaunchManualMsg = if ($isJa) { "ゲームの場所が特定できませんでした。お手数ですが、通常通り Steam や EA App から Apex Legends を起動してください。起動を検知するまで監視を継続します（タイムアウト60秒）..." } else { "Game location not found. Please launch Apex Legends normally via Steam or EA App. Monitoring will continue until detected (Timeout 60s)..." }
    LaunchWatching = if ($isJa) { "プロセス 'r5apex' または 'r5apex_dx12' または 'EasyAntiCheat' の検知を開始します..." } else { "Monitoring for processes 'r5apex', 'r5apex_dx12', or 'EasyAntiCheat'..." }
    LaunchDetected = if ($isJa) { "Apex Legends プロセス ({0}) (PID: {1}) を検出しました。生存を監視します..." } else { "Detected Apex Legends process ({0}) (PID: {1}). Monitoring process lifetime..." }
    LaunchEnded = if ($isJa) { "Apex Legends プロセスが終了しました。" } else { "Apex Legends process terminated." }
    LaunchTimeout = if ($isJa) { "タイムアウト：Apex Legends の起動が検知されませんでした。" } else { "Timeout: Apex Legends launch was not detected." }
    LaunchTimeoutRep = if ($isJa) { "結果: 指定時間内（60秒）に r5apex.exe または r5apex_dx12.exe の起動を検知できませんでした。" } else { "Result: Could not detect launch of r5apex.exe or r5apex_dx12.exe within 60 seconds." }
    LaunchTimeoutWarning = if ($isJa) { "注意: ゲームが起動画面すら表示されずに即座にクラッシュしたか、あるいは起動されなかった可能性があります。" } else { "Note: The game may have crashed instantly before drawing any window, or failed to launch entirely." }
    LaunchTimeoutSub = if ($isJa) { "補足: アンチチート(EAC)のバナー表示時点でブロックされた場合、ゲーム本体のプロセスは起動しません。" } else { "Additional Info: If blocked at the Easy Anti-Cheat (EAC) splash screen, the game executable itself will not start." }
    LaunchSuccessRep = if ($isJa) { "結果: {0} (PID: {1}) の起動を検知し、その後終了しました。" } else { "Result: Detected launch of {0} (PID: {1}), which then terminated." }
    
    LogScanHead = if ($isJa) { "--- [Windows イベントログのエラー検出 (起動前後)] ---" } else { "--- [Windows Event Log Error Detection (Around Launch)] ---" }
    LogScanCollect = if ($isJa) { "[6/6] エラーに関連するイベントログとファイルの調査を行っています..." } else { "[6/6] Scanning event logs and crash diagnostic files..." }
    LogScanFound = if ($isJa) { "エラー関連のイベントログが見つかりました！" } else { "Error-related event logs found!" }
    LogScanNone = if ($isJa) { "Windowsイベントログに Apex Legends 関連の直接的なエラーは記録されていませんでした。" } else { "No direct Apex Legends-related errors were recorded in the Windows Event Logs." }
    LogScanNoneConsole = if ($isJa) { "イベントログには直接的なエラーは見つかりませんでした。" } else { "No direct errors found in the event logs." }
    
    EacHead = if ($isJa) { "--- [Easy Anti-Cheat ログ調査] ---" } else { "--- [Easy Anti-Cheat Log Scan] ---" }
    EacLogFile = if ($isJa) { "ログファイル: " } else { "Log File: " }
    EacLastWrite = if ($isJa) { "最終更新日時: " } else { "Last Modified: " }
    EacFoundMsg = if ($isJa) { "【検出されたEACエラー/警告メッセージ】:" } else { "[Detected EAC Error/Warning Messages]:" }
    EacNoneMsg = if ($isJa) { "  直近のログにエラーや警告メッセージは見つかりませんでした。" } else { "  No errors or warnings found in recent logs." }
    EacNoneAll = if ($isJa) { "Easy Anti-Cheat 関連の目立ったエラーログは検出されませんでした。" } else { "No notable Easy Anti-Cheat-related error logs were detected." }
    
    AdviceHead = if ($isJa) { "--- [診断に基づく推奨アクション] ---" } else { "--- [Recommended Actions Based on Diagnosis] ---" }
    AdviceEacBlock = if ($isJa) { "💡 【最優先：Easy Anti-Cheat によるブロックの解除】" } else { "💡 [Priority: Resolve Easy Anti-Cheat Block]" }
    AdviceEacBlockDesc = if ($isJa) { "   アンチチートの監視機能（Easy Anti-Cheat）によりブロック対象とされる外部ソフトやドライバが検出されました。これが『Integrity error 0x80000002 / Badware Detected』の直接的な原因です。" } else { "   Software or drivers flagged by Easy Anti-Cheat were detected. This is the direct cause of 'Integrity error 0x80000002 / Badware Detected'." }
    AdviceRewasdTitle = if ($isJa) { "   ▶ ReWASD / 仮想コントローラドライバの対処方法:" } else { "   ▶ reWASD / Virtual Controller Driver Solution:" }
    AdviceRewasdDesc = if ($isJa) { "     - ReWASDは現在Apex Legendsで完全にブロックされています。アプリをアンインストールしてください。また、すでに削除済みの場合は『ViGEmBus』等の残骸ドライバが残存していないかデバイスマネージャー等から確認・削除してください。" } else { "     - reWASD is completely blocked in Apex Legends. Please uninstall the app. If already uninstalled, check and remove leftover drivers like 'ViGEmBus' in Device Manager." }
    AdviceDaemonTitle = if ($isJa) { "   ▶ DAEMON Tools / 仮想ドライブドライバの対処方法:" } else { "   ▶ DAEMON Tools / Virtual Drive Driver Solution:" }
    AdviceDaemonDesc = if ($isJa) { "     - 仮想ドライブの残骸ドライバ（Disc Soft / dtsoft 等）が誤検知されています。アプリを完全にアンインストールし、デバイスマネージャーの『ストレージコントローラー』内に仮想バスドライバが残っている場合は削除してください。" } else { "     - Leftover virtual drive drivers (Disc Soft, dtsoft, etc.) are causing false positives. Fully uninstall the app and remove any virtual bus drivers from the 'Storage controllers' category in Device Manager." }
    AdviceAhkTitle = if ($isJa) { "   ▶ AutoHotkeyの対処方法:" } else { "   ▶ AutoHotkey Solution:" }
    AdviceAhkDesc = if ($isJa) { "     - バックグラウンドでAutoHotkeyのスクリプトが動いている場合は、タスクバー（右下）等から終了させてください。" } else { "     - If AutoHotkey scripts are running in the background, close them from the system tray (bottom-right)." }
    
    AdviceVsTitle = if ($isJa) { "💡 【ウイルスセキュリティZERO（Sourcenext製）の干渉】" } else { "💡 [Virus Security ZERO (Sourcenext) Conflict]" }
    AdviceVsDesc = if ($isJa) { "   ご使用のセキュリティソフト『ウイルスセキュリティZERO』が、ゲームの起動プロセスやEasy Anti-Cheat의 動作を誤検知してブロックしている可能性が非常に高いです。`n   対処法:`n     1. ウイルスセキュリティの保護機能を一時的に「無効」にし、ゲームが起動するか確認してください。`n     2. 起動した場合は、設定画面でApexのインストールフォルダをスキャン除外（監視対象外）リストに登録してください。" } else { "   The security software 'Virus Security ZERO' might be blocking the game launch or Easy Anti-Cheat due to false positives.`n   Solution:`n     1. Temporarily disable the protection features of Virus Security and check if the game launches.`n     2. If it launches, add the Apex Legends installation directory to the scan exclusion list." }
    
    AdviceNtdllTitle = if ($isJa) { "💡 【システムファイルの破損】" } else { "💡 [System File Corruption]" }
    AdviceNtdllDesc = if ($isJa) { "   Windowsの基本システム（ntdll.dll）でのエラーが記録されています。`n   対処法: コマンドプロンプトを管理者権限で起動し、『sfc /scannow』を実行してシステム修復を行ってください。" } else { "   An error was recorded in the Windows core system file (ntdll.dll).`n   Solution: Open Command Prompt as Administrator and run 'sfc /scannow' to repair system files." }
    
    AdviceGpuTitle = if ($isJa) { "💡 【グラフィックドライバのエラー】" } else { "💡 [Graphics Driver Error]" }
    AdviceGpuDesc = if ($isJa) { "   GPUドライバまたはグラフィックスモジュールでクラッシュした形跡があります。`n   対処法: グラフィックドライバを最新版（または動作が安定している以前のバージョン）に更新してください。" } else { "   There is evidence of a crash in the GPU driver or graphics module.`n   Solution: Update your graphics card drivers to the latest version (or rollback to a stable older version)." }
    
    AdviceConflictTitle = if ($isJa) { "💡 【オーバーレイ・常駐アプリの競合】" } else { "💡 [Overlay / Background App Conflict]" }
    AdviceConflictDesc = if ($isJa) { "   Discord や OBS、その他の常駐ユーティリティが動作しています。`n   対処法: DiscordやGeForce Experience等の設定から『ゲーム内オーバーレイ』機能を無効にするか、これらの常駐アプリを一度完全に終了した状態でApexの起動をお試しください。" } else { "   Discord, OBS, or other background utilities are running.`n   Solution: Disable 'In-Game Overlay' features in Discord or GeForce Experience, or close these applications completely before launching Apex." }
    
    AdviceGeneralTitle = if ($isJa) { "💡 【その他の可能性と一般的な対処手順】" } else { "💡 [Other Possibilities & General Troubleshooting]" }
    AdviceGeneralDesc = if ($isJa) { "   明らかな競合アプリは検出されませんでしたが、EACの起動バナー時点で終了しているため、以下の手順をお試しください。`n   1. SteamまたはEA Appで『ゲームファイルの整合性を確認 (修復)』を行う。`n   2. デバイスマネージャーの『システムデバイス』や『ストレージコントローラー』内に、古い仮想ドライブ/コントローラードライバが残っていないか確認する。`n   3. Windows Defenderやウイルス対策ソフトの保護機能を一時的にオフにして起動するか試す。" } else { "   No obvious conflicting applications were detected, but since the launch failed at the EAC splash screen, please try these general steps:`n   1. Perform 'Verify integrity of game files' (Steam) or 'Repair' (EA App).`n   2. Check for hidden virtual controller/drive drivers under 'System devices' or 'Storage controllers' in Device Manager.`n   3. Temporarily turn off Windows Defender or antivirus protection." }
    
    EndReport = if ($isJa) { "診断は以上です。このレポートファイルを保存し、サポートやコミュニティへの相談時に共有してください。" } else { "Diagnosis complete. Save this report file and share it when seeking support or consulting the community." }
    EndConsole = if ($isJa) { "診断が完了しました！`nレポートファイルを作成しました:`n  {0}" } else { "Diagnosis completed!`nReport file created at:`n  {0}" }
    EndNotepad = if ($isJa) { "レポートをメモ帳で表示します..." } else { "Opening report in Notepad..." }
    PressKeyExit = if ($isJa) { "何かキーを押すとこのウィンドウを閉じます..." } else { "Press any key to close this window..." }
    WriteFailed = if ($isJa) { "警告: レポートファイルの保存に失敗しました。パス: {0}" } else { "WARNING: Failed to save the report file. Path: {0}" }
}

$startTime = Get-Date

# 1. Output setup
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host $T.Title -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host $T.Starting -ForegroundColor Yellow
Write-Host "$($T.StartTime)$($startTime.ToString('yyyy/MM/dd HH:mm:ss'))" -ForegroundColor Gray
Write-Host

$report = [System.Collections.Generic.List[string]]::new()
$report.Add("==============================================================")
$report.Add($T.ReportTitle)
$report.Add("$($T.GeneratedAt)$($startTime.ToString('yyyy/MM/dd HH:mm:ss'))")
$report.Add("==============================================================")
$report.Add("")

# 2. Collect System Info
Write-Host $T.SysInfoCollect -ForegroundColor Cyan
$os = Get-CimInstance Win32_OperatingSystem
$gpu = Get-CimInstance Win32_VideoController
$cpu = Get-CimInstance Win32_Processor

$report.Add($T.SysInfoHead)
$report.Add("OS: $($os.Caption) (Version: $($os.Version), Build: $($os.BuildNumber))")
$report.Add("CPU: $($cpu.Name)")
if ($gpu -is [array]) {
    foreach ($g in $gpu) {
        $report.Add("GPU: $($g.Name) (Driver: $($g.DriverVersion))")
    }
} else {
    $report.Add("GPU: $($gpu.Name) (Driver: $($gpu.DriverVersion))")
}
$report.Add("")

# 3. Installation Search
Write-Host $T.InstallSearch -ForegroundColor Cyan
$apexPaths = @()

$steamUninstall = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 1172470" -ErrorAction SilentlyContinue
if ($steamUninstall -and $steamUninstall.InstallLocation) { $apexPaths += $steamUninstall.InstallLocation }
$eaPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\EA Games\Apex" -ErrorAction SilentlyContinue
if ($eaPath -and $eaPath.InstallDir) { $apexPaths += $eaPath.InstallDir }
$eaPathWow = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\EA Games\Apex" -ErrorAction SilentlyContinue
if ($eaPathWow -and $eaPathWow.InstallDir) { $apexPaths += $eaPathWow.InstallDir }

$defaultPaths = @(
    "C:\Program Files (x86)\Steam\steamapps\common\Apex Legends",
    "C:\Program Files\EA Games\Apex",
    "D:\SteamLibrary\steamapps\common\Apex Legends",
    "D:\EA Games\Apex",
    "E:\SteamLibrary\steamapps\common\Apex Legends",
    "E:\EA Games\Apex"
)
foreach ($dp in $defaultPaths) { if (Test-Path $dp) { $apexPaths += $dp } }
$apexPaths = $apexPaths | Select-Object -Unique | Where-Object { Test-Path $_ }

$detectedExe = $null
$installDir = $null

if ($apexPaths.Count -gt 0) {
    $installDir = $apexPaths[0]
    $exePath = Join-Path $installDir "r5apex.exe"
    $exePathDx12 = Join-Path $installDir "r5apex_dx12.exe"
    
    if (Test-Path $exePath) {
        $detectedExe = $exePath
    } elseif (Test-Path $exePathDx12) {
        $detectedExe = $exePathDx12
    }
    
    if ($detectedExe) {
        Write-Host "$($T.InstallFound)$installDir" -ForegroundColor Green
        $report.Add($T.InstallHead)
        $report.Add("$($T.InstallPathRep)$installDir")
        $report.Add("$($T.InstallExeRep)$detectedExe")
        $report.Add("")
    }
}

if (-not $detectedExe) {
    Write-Host $T.InstallFailed -ForegroundColor Yellow
    $report.Add($T.InstallHead)
    $report.Add($T.InstallFailedRep)
    $report.Add("")
}

# 4. Badware (0x80000002) Scanning
Write-Host $T.BadwareScan -ForegroundColor Cyan
$badwareList = @()

# 4.1 ReWASD
$rewasdDetected = $false
if (Test-Path "C:\Program Files\reWASD") { $rewasdDetected = $true }
if (Test-Path "C:\Program Files (x86)\reWASD") { $rewasdDetected = $true }
$rewasdService = Get-Service -Name "Game Controller Mapper" -ErrorAction SilentlyContinue
if ($rewasdService) { $rewasdDetected = $true }
if (Get-Process -Name "reWASD" -ErrorAction SilentlyContinue) { $rewasdDetected = $true }
if ($rewasdDetected) { $badwareList += $T.BadwareRewasd }

# 4.2 DAEMON Tools
$daemonDetected = $false
if (Test-Path "C:\Program Files\DAEMON Tools Lite") { $daemonDetected = $true }
if (Test-Path "C:\Program Files (x86)\DAEMON Tools Lite") { $daemonDetected = $true }
if (Get-Process -Name "DTAgent" -ErrorAction SilentlyContinue) { $daemonDetected = $true }
$dtService = Get-Service -Name "DiscSoft*" -ErrorAction SilentlyContinue
if ($dtService) { $daemonDetected = $true }
if ($daemonDetected) { $badwareList += $T.BadwareDaemon }

# 4.3 AutoHotkey
$ahkDetected = $false
if (Test-Path "C:\Program Files\AutoHotkey") { $ahkDetected = $true }
if (Get-Process -Name "AutoHotkey" -ErrorAction SilentlyContinue) { $ahkDetected = $true }
if ($ahkDetected) { $badwareList += $T.BadwareAhk }

# 4.4 Cheat Engine
$ceDetected = $false
if (Test-Path "C:\Program Files\Cheat Engine*") { $ceDetected = $true }
if (Get-Process -Name "CheatEngine*" -ErrorAction SilentlyContinue) { $ceDetected = $true }
if ($ceDetected) { $badwareList += $T.BadwareCe }

# 4.5 JoyToKey / DS4Windows
$otherKbm = @()
if (Get-Process -Name "JoyToKey" -ErrorAction SilentlyContinue) { $otherKbm += "JoyToKey" }
if (Get-Process -Name "DS4Windows" -ErrorAction SilentlyContinue) { $otherKbm += "DS4Windows" }
foreach ($k in $otherKbm) { $badwareList += ($T.BadwareOther -f @($k)) }

# 4.6 Leftover Drivers
$pnpDevices = Get-PnpDevice -ErrorAction SilentlyContinue
$vigemDetected = $false
$daemonDriverDetected = $false
foreach ($dev in $pnpDevices) {
    if ($dev.FriendlyName -like "*ViGEm*" -or $dev.InstanceId -like "*ViGEm*") { $vigemDetected = $true }
    if ($dev.FriendlyName -like "*Virtual Bus*" -or $dev.FriendlyName -like "*Disc Soft*" -or $dev.FriendlyName -like "*DAEMON Tools*") { $daemonDriverDetected = $true }
}
if ($vigemDetected) { $badwareList += $T.BadwareVigem }
if ($daemonDriverDetected) { $badwareList += $T.BadwareDaemonDrv }

$report.Add($T.BadwareHead)
if ($badwareList.Count -gt 0) {
    Write-Host $T.BadwareWarning -ForegroundColor Red
    foreach ($bw in $badwareList) {
        $report.Add($bw)
        Write-Host $bw -ForegroundColor Red
    }
} else {
    $report.Add($T.BadwareNone)
    Write-Host $T.BadwareNoneConsole -ForegroundColor Green
}
$report.Add("")

# 5. General Conflicting Processes
Write-Host $T.ConflictScan -ForegroundColor Cyan
$suspiciousProcesses = @{
    "discord" = "Discord (Overlay feature might conflict)"
    "obs64" = "OBS Studio (Capture hook might conflict)"
    "obs32" = "OBS Studio (Capture hook might conflict)"
    "MSIAfterburner" = "MSI Afterburner (Overlay/OSD features might conflict)"
    "RTSS" = "RivaTuner Statistics Server (Overlay feature might conflict)"
    "Overwolf" = "Overwolf (Overlay feature might conflict)"
    "lghub" = "Logitech G HUB (Macro profiles might conflict with EAC)"
    "RzSynapse" = "Razer Synapse (Device configuration utility)"
    "ProcessHacker" = "Process Hacker (Security tool blocked by EAC)"
    "avp" = "Kaspersky Antivirus"
    "Mcshield" = "McAfee Antivirus"
    "AvastSvc" = "Avast Antivirus"
    "bdagent" = "Bitdefender Antivirus"
    "rtkAudService" = "Realtek Audio Service"
    "K7TSrv" = "K7 Security"
    "V3Svc" = "AhnLab V3 Security"
    "VirusSecurity" = "Virus Security ZERO (Sourcenext)"
    "K7PkgSrv" = "K7 Security"
}

$runningSuspicious = @()
$processes = Get-Process | Select-Object ProcessName -Unique
foreach ($p in $processes) {
    if ($suspiciousProcesses.ContainsKey($p.ProcessName)) {
        $runningSuspicious += " - $($p.ProcessName) ($($suspiciousProcesses[$p.ProcessName]))"
    }
}

# Virus Security ZERO check
$vsDetected = $false
if (Test-Path "C:\Program Files\Sourcenext\VirusSecurity") { $vsDetected = $true }
if (Test-Path "C:\Program Files (x86)\Sourcenext\VirusSecurity") { $vsDetected = $true }
if (Get-Process -Name "*VirusSecurity*" -ErrorAction SilentlyContinue) { $vsDetected = $true }
if ($vsDetected) { $runningSuspicious += $T.ConflictVs }

$report.Add($T.ConflictHead)
if ($runningSuspicious.Count -gt 0) {
    foreach ($rs in $runningSuspicious) {
        $report.Add($rs)
        Write-Host $rs -ForegroundColor Yellow
    }
} else {
    $report.Add($T.ConflictNone)
}
$report.Add("")

# 6. Launch & Monitor
Write-Host $T.LaunchTry -ForegroundColor Cyan

if ($detectedExe) {
    Write-Host $T.LaunchStart -ForegroundColor Yellow
    if ($installDir -match "steamapps") {
        Write-Host $T.LaunchSteam -ForegroundColor Gray
        Start-Process "steam://rungameid/1172470"
    } else {
        Write-Host $T.LaunchDirect -ForegroundColor Gray
        Start-Process -FilePath $detectedExe -WorkingDirectory $installDir
    }
} else {
    Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
    Write-Host $T.LaunchManualMsg -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
}

$watchTimeoutSec = 60
$elapsed = 0
$processDetected = $false
$processId = $null
$detectedProcName = ""

Write-Host $T.LaunchWatching -ForegroundColor Gray
while ($elapsed -lt $watchTimeoutSec) {
    $apexProc = Get-Process -Name "r5apex", "r5apex_dx12" -ErrorAction SilentlyContinue
    $eacProc = Get-Process -Name "*EasyAntiCheat*" -ErrorAction SilentlyContinue
    
    if ($apexProc) {
        $processDetected = $true
        $firstProc = $apexProc | Select-Object -First 1
        $processId = $firstProc.Id
        $detectedProcName = $firstProc.ProcessName
        Write-Host ($T.LaunchDetected -f @($detectedProcName, $processId)) -ForegroundColor Green
        
        while (Get-Process -Id $processId -ErrorAction SilentlyContinue) {
            Start-Sleep -Seconds 1
        }
        
        Write-Host $T.LaunchEnded -ForegroundColor Yellow
        break
    } elseif ($eacProc) {
        # EAC is running, wait
    }
    
    Start-Sleep -Seconds 1
    $elapsed++
}

$report.Add($T.LaunchHead)
if (-not $processDetected) {
    Write-Host $T.LaunchTimeout -ForegroundColor Red
    $report.Add($T.LaunchTimeoutRep)
    $report.Add($T.LaunchTimeoutWarning)
    $report.Add($T.LaunchTimeoutSub)
    $report.Add("")
} else {
    $report.Add($T.LaunchSuccessRep -f @($detectedProcName, $processId))
    $report.Add("")
}

# 7. Scan logs
Write-Host $T.LogScanCollect -ForegroundColor Cyan

$eventLogs = Get-WinEvent -FilterHashtable @{
    LogName = 'Application'
    Level = 2 # Error
    StartTime = $startTime.AddSeconds(-10)
} -ErrorAction SilentlyContinue

$foundErrors = @()
if ($eventLogs) {
    foreach ($log in $eventLogs) {
        if ($log.Message -match "r5apex" -or $log.Message -match "EasyAntiCheat" -or $log.Message -match "Apex") {
            $foundErrors += $log
        }
    }
}

$systemLogs = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    Level = 2 # Error
    StartTime = $startTime.AddSeconds(-10)
} -ErrorAction SilentlyContinue

if ($systemLogs) {
    foreach ($log in $systemLogs) {
        if ($log.Message -match "EasyAntiCheat" -or $log.Message -match "nvlddmkm" -or $log.Message -match "amdkmdap" -or $log.Message -match "Display") {
            $foundErrors += $log
        }
    }
}

$report.Add($T.LogScanHead)
if ($foundErrors.Count -gt 0) {
    Write-Host $T.LogScanFound -ForegroundColor Red
    foreach ($err in $foundErrors) {
        $report.Add("【Time / TimeCreated】: $($err.TimeCreated.ToString('yyyy/MM/dd HH:mm:ss'))")
        $report.Add("【Source】: $($err.ProviderName)")
        $report.Add("【Event ID】: $($err.Id)")
        $report.Add("【Content / Message】:")
        $report.Add($err.Message)
        $report.Add("--------------------------------------------------")
    }
} else {
    $report.Add($T.LogScanNone)
    Write-Host $T.LogScanNoneConsole -ForegroundColor Gray
}
$report.Add("")

# EAC log check
$report.Add($T.EacHead)
$eacLogPaths = @(
    "$env:APPDATA\EasyAntiCheat\gamelauncher.log",
    "$env:LOCALAPPDATA\EasyAntiCheat\EasyAntiCheat.log",
    "$env:LOCALAPPDATA\EasyAntiCheat\EasyAntiCheat_EOS.log"
)
if ($installDir) { $eacLogPaths += Join-Path $installDir "EasyAntiCheat\gamelauncher.log" }
$eacLogPaths = $eacLogPaths | Select-Object -Unique | Where-Object { Test-Path $_ }

$eacErrorsFound = $false
foreach ($lp in $eacLogPaths) {
    if (Test-Path $lp) {
        $report.Add("$($T.EacLogFile)$lp")
        $lastWrite = (Get-Item $lp).LastWriteTime
        $report.Add("$($T.EacLastWrite)$($lastWrite.ToString('yyyy/MM/dd HH:mm:ss'))")
        
        $logContent = Get-Content -Path $lp -Tail 50 -ErrorAction SilentlyContinue
        $errLines = $logContent | Where-Object { $_ -match "Error" -or $_ -match "Failed" -or $_ -match "Violation" -or $_ -match "Block" }
        
        if ($errLines) {
            $eacErrorsFound = $true
            $report.Add($T.EacFoundMsg)
            foreach ($el in $errLines) { $report.Add("  $el") }
        } else {
            $report.Add($T.EacNoneMsg)
        }
        $report.Add("--------------------------------------------------")
    }
}
if (-not $eacErrorsFound) { $report.Add($T.EacNoneAll) }
$report.Add("")

# 8. Advice Output
$report.Add($T.AdviceHead)
$adviceCount = 0

if ($badwareList.Count -gt 0) {
    $report.Add($T.AdviceEacBlock)
    $report.Add($T.AdviceEacBlockDesc)
    
    if ($rewasdDetected -or $vigemDetected) {
        $report.Add($T.AdviceRewasdTitle)
        $report.Add($T.AdviceRewasdDesc)
    }
    if ($daemonDetected -or $daemonDriverDetected) {
        $report.Add($T.AdviceDaemonTitle)
        $report.Add($T.AdviceDaemonDesc)
    }
    if ($ahkDetected) {
        $report.Add($T.AdviceAhkTitle)
        $report.Add($T.AdviceAhkDesc)
    }
    $adviceCount++
}

if ($vsDetected) {
    $report.Add($T.AdviceVsTitle)
    $report.Add($T.AdviceVsDesc)
    $adviceCount++
}

if ($foundErrors.Count -gt 0) {
    $hasNtdll = $false
    $hasGpuErr = $false
    
    foreach ($err in $foundErrors) {
        if ($err.Message -match "ntdll.dll") { $hasNtdll = $true }
        if ($err.Message -match "nvlddmkm" -or $err.Message -match "amdkmdap" -or $err.Message -match "d3d") { $hasGpuErr = $true }
    }
    
    if ($hasNtdll) {
        $report.Add($T.AdviceNtdllTitle)
        $report.Add($T.AdviceNtdllDesc)
        $adviceCount++
    }
    if ($hasGpuErr) {
        $report.Add($T.AdviceGpuTitle)
        $report.Add($T.AdviceGpuDesc)
        $adviceCount++
    }
}

if ($runningSuspicious.Count -gt 0 -and $adviceCount -eq 0) {
    $report.Add($T.AdviceConflictTitle)
    $report.Add($T.AdviceConflictDesc)
    $adviceCount++
}

if ($adviceCount -eq 0) {
    $report.Add($T.AdviceGeneralTitle)
    $report.Add($T.AdviceGeneralDesc)
}
$report.Add("")
$report.Add("==============================================================")
$report.Add($T.EndReport)

# Write report file (with OneDrive safety fallback)
$desktopReportPath = $null
$fallbackReportPath = "C:\Apex_Diagnostic_Report.txt"
$tempReportPath = Join-Path $env:TEMP "Apex_Diagnostic_Report.txt"

# Safely construct desktop path to avoid Join-Path null errors
if ($desktopPath) {
    $desktopReportPath = Join-Path $desktopPath "Apex_Diagnostic_Report.txt"
} else {
    # Resolve desktop path using Registry or Environment if [Environment]::GetFolderPath failed
    $regDesktop = Get-ItemPropertyValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Desktop" -ErrorAction SilentlyContinue
    if ($regDesktop) {
        $desktopReportPath = Join-Path $regDesktop "Apex_Diagnostic_Report.txt"
    } else {
        $desktopReportPath = Join-Path $env:USERPROFILE "Desktop\Apex_Diagnostic_Report.txt"
    }
}

$finalReportPath = $null

# Try Desktop
if ($desktopReportPath) {
    try {
        $report | Out-File -FilePath $desktopReportPath -Encoding utf8 -Force -ErrorAction Stop
        $finalReportPath = $desktopReportPath
    } catch {
        Write-Host ($T.WriteFailed -f @($desktopReportPath)) -ForegroundColor Yellow
    }
}

# Try C:\ if Desktop fails
if (-not $finalReportPath) {
    try {
        $report | Out-File -FilePath $fallbackReportPath -Encoding utf8 -Force -ErrorAction Stop
        $finalReportPath = $fallbackReportPath
    } catch {
        Write-Host ($T.WriteFailed -f @($fallbackReportPath)) -ForegroundColor Yellow
    }
}

# Try Temp as ultimate fallback
if (-not $finalReportPath) {
    try {
        $report | Out-File -FilePath $tempReportPath -Encoding utf8 -Force -ErrorAction Stop
        $finalReportPath = $tempReportPath
    } catch {
        Write-Host ($T.WriteFailed -f @($tempReportPath)) -ForegroundColor Red
    }
}

Write-Host
Write-Host "=============================================" -ForegroundColor Green
if ($finalReportPath) {
    Write-Host ($T.EndConsole -f @($finalReportPath)) -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host $T.EndNotepad -ForegroundColor Gray
    
    # Open in notepad
    Start-Process "notepad.exe" -ArgumentList "`"$finalReportPath`""
} else {
    Write-Host "Failed to save diagnostic report to any location." -ForegroundColor Red
    Write-Host "=============================================" -ForegroundColor Red
}

Write-Host
Write-Host $T.PressKeyExit -ForegroundColor Gray
Read-Host

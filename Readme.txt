=====================================================================
            Apex Legends Launch Debugger / 起動エラー診断ツール
=====================================================================

[English]
This tool identifies the cause of Apex Legends startup failures and 
generates a report with recommended solutions.

■ Files in this folder:
  1. ApexLaunchDebugger.bat - Execution batch file (Right-click & run as Admin)
  2. ApexLaunchDebugger.ps1 - Diagnostic program core
  3. Readme.txt              - This instruction file

--- How to Use ---

[Method 1: Batch File (Standard)]
1. Extract (unzip) the downloaded ZIP file first. Do NOT run it directly inside the ZIP.
2. Right-click "ApexLaunchDebugger.bat" and select "Run as Administrator".
3. Click "Yes" when the UAC prompt appears.
4. If it doesn't start automatically, launch Apex manually via Steam or EA App.
5. Wait for the game to crash. A report will be generated.

[Method 2: PowerShell (Alternative - If Method 1 instantly closes)]
1. Open the extracted folder, right-click an empty space, and select "Open in Terminal".
2. Paste this command and press Enter:
   Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\ApexLaunchDebugger.ps1`"" -Verb RunAs
3. A new administrator PowerShell window will open to start the diagnosis.

*Note*: The tool monitors launches for 60 seconds. Launch the game immediately after starting the tool.

---------------------------------------------------------------------

[日本語]
このツールは、Apex Legends が起動エラーで立ち上がらない原因を特定し、
対処方法のレポートを作成するためのプログラムです。

■ フォルダ内のファイル構成：
  1. ApexLaunchDebugger.bat - 診断開始用のバッチファイル
  2. ApexLaunchDebugger.ps1 - 診断プログラム本体
  3. Readme.txt              - この説明ファイル

--- 使い方 ---

【方法1: バッチファイルを使用する (標準)】
1. ダウンロードしたZIPファイルを必ず解凍（すべて展開）してください。
   ※ZIPファイルの中のまま起動するとエラーになります。
2. 解凍したフォルダ内にある「ApexLaunchDebugger.bat」を【右クリック】し、
   【管理者として実行】を選択して起動します。
3. ユーザーアカウント制御 (UAC) 画面が表示されたら、「はい」を押します。
4. 自動起動しない場合は、手動で Steam や EA App からゲームを起動してください。
5. 診断レポートが作成されるのを待ちます。

【方法2: ターミナルからPowerShellで実行する (代替案 - バッチがすぐ閉じる場合)】
1. 解凍したフォルダを開き、何もない場所を右クリックして「ターミナルで開く」を選択します。
2. 表示された画面に以下のコマンドを貼り付けて Enter キーを押します：
   Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PWD\ApexLaunchDebugger.ps1`"" -Verb RunAs
3. 新しいPowerShell画面が管理者権限で起動し、診断が開始されます。

※注意点：監視時間はツール起動後60秒間です。ツールを起動したらすぐにゲームを起動してください。
ゲームがロゴ画面で落ちたり、メニュー画面に行くまでに落ちた場合、即座に検出されてレポートが開きます。

=====================================================================

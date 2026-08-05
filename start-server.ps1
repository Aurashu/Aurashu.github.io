$ErrorActionPreference = 'Stop'
$project = 'C:\Users\21817\Documents\mywebsite'
$log = Join-Path $env:TEMP 'mkdocs-serve.log'

Get-CimInstance Win32_Process |
    Where-Object { $_.CommandLine -like '*mkdocs*' -and $_.ProcessId -ne $PID } |
    ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force
        Write-Host "已结束残留进程 $($_.ProcessId) ($($_.Name))"
    }
Start-Sleep -Seconds 1

$cmdline = "cmd /c cd /d `"$project`" && py -m mkdocs serve --dev-addr=0.0.0.0:8000 > `"$log`" 2>&1"
$proc = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{ CommandLine = $cmdline }
Write-Host "已后台启动（完全分离，不再占用会话），进程ID: $($proc.ProcessId)"

Start-Sleep -Seconds 8
Write-Host "=== 服务日志 ==="
if (Test-Path $log) { Get-Content $log -Tail 20 }

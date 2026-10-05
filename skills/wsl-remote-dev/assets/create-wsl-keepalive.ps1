# WSL Keepalive 计划任务创建脚本
# 作用：创建开机自启的 Windows 计划任务，后台持有 WSL 防止 WSL 3.x 空闲关闭 VM
# 用法: powershell -ExecutionPolicy Bypass -File create-wsl-keepalive.ps1

$script = @'
while ($true) {
    try { wsl -d Ubuntu -- bash -c "sleep 300" } catch {}
    Start-Sleep -Seconds 2
}
'@
$scriptPath = "$env:USERPROFILE\wsl-keepalive.ps1"
Set-Content -Path $scriptPath -Value $script -Encoding UTF8
Write-Output "脚本已写入: $scriptPath"

# 创建计划任务（登录时自启，后台运行）
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

Register-ScheduledTask -TaskName "WSL-Keepalive" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force | Out-Null
Write-Output "==== 计划任务已注册: WSL-Keepalive ===="

# 立即启动
Start-ScheduledTask -TaskName "WSL-Keepalive"
Start-Sleep -Seconds 3
Get-ScheduledTask -TaskName "WSL-Keepalive" | Select-Object TaskName,State | Format-Table -AutoSize

# 同时写 .wslconfig（vmIdleTimeout 必须用大正数，-1 无效会被当默认60秒）
$wslconfig = "$env:USERPROFILE\.wslconfig"
if (-not (Test-Path $wslconfig) -or -not (Get-Content $wslconfig -Raw).Contains('vmIdleTimeout')) {
    Add-Content -Path $wslconfig -Value "`n[wsl2]`nvmIdleTimeout=999999999`nmemory=4GB`nlocalhostForwarding=true" -Encoding UTF8
    Write-Output ".wslconfig 已更新（vmIdleTimeout=999999999）"
} else {
    Write-Output ".wslconfig 已含 vmIdleTimeout，跳过"
}

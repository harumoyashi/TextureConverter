$files = Get-Item *.jpg
$mipLevel = 5

foreach($f in $files){
    Start-Process -FilePath TextureConverter.exe -ArgumentList $f" -ml "$mipLevel -Wait
}
pause
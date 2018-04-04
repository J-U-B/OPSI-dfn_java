#====================================================================
# Beispiel-Code zum extrahieren des MSI-Paketes fuer JRE9/10
# aus dem EXE-Installer (Installation im System-kontext)
# 
# req.: PowerShell 5.0
#
# Jens Boettge <boettge@mpi-halle.mpg.de>  2018-03-29 - 2018-04-02
#====================================================================

$jre_installer = "d:\__temp\jre\jre-10_windows-x64_bin.exe"
$jre_inst_args = "INSTALL_SILENT=1 REBOOT=0 /LV* C:\temp\jre10_install_exe.log"
$psexec = "c:\applic32\Sysinternals\PsExec.exe"
#$psexecargs = @("-accepteula", "-s", "-i", $jre_installer+$jre_inst_args)
$psexecargs = @("-accepteula -s -i", $jre_installer+$jre_inst_args)
$tgt_dir = "d:\__temp\jre\msi"
#$tmp_dir = $env:LOCALAPPDATA + "Low\Oracle\Java\jre10_x64"
$tmp_dir = $env:SYSTEMROOT + "\system32\config\systemprofile\AppData\LocalLow\Oracle\Java\jre10_x64"
$DBG=$false


write-host "JRE temporary direcory: $tmp_dir"
write-host "MSI target direcory   : $tgt_dir"
if (-not (Test-Path -PathType Container $tgt_dir ))
{
    New-Item -Path $tgt_dir -ItemType Directory | out-null
}

$files_done=@()
$app = Start-Process $psexec -ArgumentList $psexecargs -PassThru -ErrorAction Ignore
#...alternativ mit -NoNewWindow starten
while (get-process -id $app.id -erroraction Ignore)
{
    sleep(0.2)
    if (-not ($DBG)) {write-host "." -NoNewline}
    Get-ChildItem -Path $tmp_dir -File  -attributes !Temporary -filter '*.msi' -ErrorAction Ignore | foreach  {
        $s=$_.name
        if ($DBG) {write-host "* $s"} 
        if ( (-not($_.PSIsContainer))  -and (-not($files_done.contains($s))) ) 
        { 
            write-host "`r`nCopying $s to $tgt_dir"
            Copy-Item -force -Path $tmp_dir\$s -Destination $tgt_dir\
            $files_done+=$s
        }  
    }
}

if (($app) -and ($app.HasExited))
{
    # Wenn das Programm mit psexec und -NoNewWindow gestartet wurde, ist kein exitcode verfuegbar
    write-host $app.ExitCode
    $msg = "`r`nDone with exit code: {0}" -f $app.ExitCode
    write-host $msg
    exit $app.ExitCode
} else { 
    write-host "`r`nInstaller is still running!"
    exit -1
}
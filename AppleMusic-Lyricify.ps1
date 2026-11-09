param(
    [ValidateSet('Enable', 'Disable', 'Watch', 'Check')]
    [string]$Mode = 'Check'
)

$ErrorActionPreference = 'Stop'
$appleFamily = 'AppleInc.AppleMusicWin_nzyj5cx40ttqa'
$fusionFamily = '63265WXRIW.193470E81A0DE_8ybqz4qm5hwha'
$shortcutPath = Join-Path ([Environment]::GetFolderPath('Startup')) 'Apple Music - Lyricify Fusion.lnk'
$powerShell = Join-Path $PSHOME 'powershell.exe'
$watchArguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}" -Mode Watch' -f $PSCommandPath

if ($Mode -eq 'Disable') {
    if (Test-Path -LiteralPath $shortcutPath) {
        Remove-Item -LiteralPath $shortcutPath
    }
    Write-Host 'Link disabled. The background watcher will stop within a few seconds.'
    return
}

if ($Mode -eq 'Enable') {
    $appIds = @(Get-StartApps | Select-Object -ExpandProperty AppID)
    foreach ($family in @($appleFamily, $fusionFamily)) {
        if ("$family!App" -notin $appIds) {
            throw "The expected Microsoft Store app is missing: $family"
        }
    }

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $powerShell
    $shortcut.Arguments = $watchArguments
    $shortcut.WorkingDirectory = $PSScriptRoot
    $shortcut.Save()
    Start-Process -FilePath $powerShell -ArgumentList $watchArguments -WindowStyle Hidden
    Write-Host 'Link enabled for this Windows account.'
    return
}

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Text;
using System.Diagnostics;
using System.Collections.Generic;

public static class MusicAppIdentity {
    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr OpenProcess(int access, bool inherit, int id);
    [DllImport("kernel32.dll")]
    private static extern bool CloseHandle(IntPtr handle);
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
    private static extern int GetPackageFamilyName(IntPtr handle, ref int length, StringBuilder name);

    public static Dictionary<string, List<Process>> Find(int session, string apple, string fusion) {
        var apps = new Dictionary<string, List<Process>>(StringComparer.OrdinalIgnoreCase);
        apps.Add(apple, new List<Process>());
        apps.Add(fusion, new List<Process>());
        var name = new StringBuilder(256);
        foreach (Process process in Process.GetProcesses()) {
            bool keep = false;
            try {
                if (process.SessionId != session) continue;
                IntPtr handle = OpenProcess(0x1000, false, process.Id);
                if (handle == IntPtr.Zero) continue;
                try {
                    int length = name.Capacity;
                    List<Process> matches;
                    if (GetPackageFamilyName(handle, ref length, name) == 0 &&
                        apps.TryGetValue(name.ToString(), out matches)) {
                        matches.Add(process);
                        keep = true;
                    }
                } finally {
                    CloseHandle(handle);
                }
            } catch (InvalidOperationException) {
                // The process exited during enumeration.
            } catch (System.ComponentModel.Win32Exception) {
                // The process could not be inspected.
            } finally {
                if (!keep) process.Dispose();
            }
        }
        return apps;
    }
}
"@

$session = [Diagnostics.Process]::GetCurrentProcess().SessionId
function Get-MusicApps {
    [MusicAppIdentity]::Find($session, $appleFamily, $fusionFamily)
}

if ($Mode -eq 'Check') {
    $apps = Get-MusicApps
    foreach ($family in @($appleFamily, $fusionFamily)) {
        foreach ($app in $apps[$family]) {
            '{0}: {1} (PID {2}, window {3})' -f $family, $app.ProcessName, $app.Id, $app.MainWindowHandle
            $app.Dispose()
        }
    }
    return
}

$mutex = New-Object Threading.Mutex($false, 'Local\AppleMusicLyricifyFusionLink')
$locked = $false
$managed = @{}
$wasOpen = $false
$launchUntil = [datetime]::MinValue
$missingSince = $null
try {
    try { $locked = $mutex.WaitOne(0) }
    catch [Threading.AbandonedMutexException] { $locked = $true }
    if (-not $locked) { return }

    while (Test-Path -LiteralPath $shortcutPath) {
        $apps = Get-MusicApps
        try {
            $now = [datetime]::UtcNow
            # Apple Music can keep its process alive after its window closes.
            # A minimized window still has a main window handle.
            $appleWindowOpen = @($apps[$appleFamily] | Where-Object {
                $_.MainWindowHandle -ne [IntPtr]::Zero
            }).Count -gt 0
            if ($appleWindowOpen) {
                $missingSince = $null
                if (-not $wasOpen -and $apps[$fusionFamily].Count -eq 0) {
                    Start-Process -FilePath explorer.exe -ArgumentList "shell:AppsFolder\$fusionFamily!App"
                    $launchUntil = $now.AddSeconds(20)
                }
                $wasOpen = $true
            } elseif ($wasOpen -and $null -eq $missingSince) {
                $missingSince = $now
            }

            foreach ($app in $apps[$fusionFamily]) {
                try {
                    $key = '{0}:{1}' -f $app.Id, $app.StartTime.Ticks
                    if ($now -le $launchUntil) {
                        $managed[$key] = $true
                    }
                    if ($null -ne $missingSince -and ($now - $missingSince).TotalSeconds -ge 4 -and
                        $managed.ContainsKey($key)) {
                        if ($app.CloseMainWindow()) {
                            [void]$app.WaitForExit(1500)
                        }
                        if (-not $app.HasExited) {
                            $app.Kill()
                        }
                    }
                } catch [InvalidOperationException] {
                    # The app exited on its own.
                } catch [System.ComponentModel.Win32Exception] {
                    # An app that cannot be closed is left running.
                }
            }

            if ($null -ne $missingSince -and ($now - $missingSince).TotalSeconds -ge 4 -and
                $now -ge $launchUntil) {
                $wasOpen = $false
                $missingSince = $null
                $managed.Clear()
            }
        } finally {
            foreach ($family in @($appleFamily, $fusionFamily)) {
                foreach ($app in $apps[$family]) { $app.Dispose() }
            }
        }
        Start-Sleep -Seconds 2
    }
} finally {
    if ($locked) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}

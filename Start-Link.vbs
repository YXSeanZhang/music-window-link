Option Explicit

Dim shell, files, scriptPath, powershellPath, quote
Set shell = CreateObject("WScript.Shell")
Set files = CreateObject("Scripting.FileSystemObject")
scriptPath = files.BuildPath(files.GetParentFolderName(WScript.ScriptFullName), "AppleMusic-Lyricify.ps1")
powershellPath = shell.ExpandEnvironmentStrings("%SystemRoot%") & "\System32\WindowsPowerShell\v1.0\powershell.exe"
quote = Chr(34)
shell.Run quote & powershellPath & quote & " -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File " & quote & scriptPath & quote & " -Mode Watch", 0, False

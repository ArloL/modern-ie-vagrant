reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v bginfo /f
reg add "HKCU\Control Panel\Colors" /v Background /t REG_SZ /d "0 99 177" /f

reg delete "HKCU\Control Panel\Desktop" /v Wallpaper /f
reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /f

add-type -typedefinition "using System;`n using System.Runtime.InteropServices;`n public class PInvoke { [DllImport(`"user32.dll`")] public static extern bool SetSysColors(int cElements, int[] lpaElements, int[] lpaRgbValues); }"
[PInvoke]::SetSysColors(1, @(1), @(0xB16300))

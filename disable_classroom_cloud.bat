@echo off
rem Ensure the script is running as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

setlocal

rem Configuration
set "serviceName=CiCStudent"
set "progDir=C:\Program Files (x86)\NetSupport\classroom.cloud"
set "target=%progDir%\cicStudent.exe"
set "shortcut=%userprofile%\Desktop\cicStudent.lnk"
set "procs=cicStudent.exe cicPlugin.exe cicToolbar.exe"

rem Stop the service (if running) then disable it
echo Stopping service %serviceName%...
sc stop "%serviceName%" >nul 2>&1
timeout /t 1 >nul 2>&1
echo Disabling service %serviceName%...
sc config "%serviceName%" start= disabled >nul 2>&1

rem Kill related processes if they are running
for %%P in (%procs%) do (
    tasklist /FI "IMAGENAME eq %%P" 2>NUL | find /I "%%P" >NUL 2>&1
    if not errorlevel 1 (
        echo Terminating %%P...
        taskkill /F /IM "%%P" >nul 2>&1
    )
)

rem Create a desktop shortcut if the target exists
if exist "%target%" (
    powershell -NoProfile -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%shortcut%');$s.TargetPath='%target%';$s.WorkingDirectory='%progDir%';$s.Save()"
    echo classroom.cloud has been disabled. A shortcut has been placed on your desktop.
) else (
    echo Target not found: "%target%"
    echo No shortcut was created.
)

echo Press any key to exit...
pause >nul

endlocal

@ECHO OFF
echo    ProtoLauncher v 1.2
echo ^|-----------------------^|
echo ^|Created by AndrewPH    ^|
echo ^|-----------------------^|
setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
goto :Init

:Init
set PROTOLOC=%~dpnx0
set PROTOFOLD=%~dp0
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set GAMEFILE=ClassiCube.exe || set GAMEFILE=ClassiCube.64.exe

if not exist "%PROTOFOLD%%GAMEFILE%" goto :SetupGame
if [%1]==[] goto :SetRegistry
echo Game Path:
echo %PROTOFOLD%%GAMEFILE%
echo -----------------------
goto :SplitURL

:SetupGame
call :DownloadGame
call :RunLauncher
goto :SetRegistry


:SplitURL
FOR /F "tokens=2,3,4 delims=/" %%a in (%1) do (
	set PROTOIPPORT=%%a
	set PROTOUSER=%%b
	set PROTOMPPASS=%%c
)

FOR /F "tokens=1,2 delims=:" %%a in ("%PROTOIPPORT%") do (
	set PROTOIP=%%a
	set PROTOPORT=%%b
)

echo     IP: %PROTOIP%
echo   Port: %PROTOPORT%
echo   User: %PROTOUSER%
echo MPPass: %PROTOMPPASS%
goto :RunGame

goto :End

:GetAdmin
set "vbsGetPrivileges=%temp%\PROTOLAUNCH_TMP_adminprivs.vbs"
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
if '%cmdInvoke%'=='1' goto InvokeCmd 
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
del "%vbsGetPrivileges%"
exit /B

:SetRegistry
echo Checking for admin privileges...
net session >nul 2>&1
if not %errorLevel% == 0 goto :GetAdmin
Reg.exe add "HKEY_CLASSES_ROOT\mc" /ve /t REG_SZ /d "URL:mc" /f
Reg.exe add "HKEY_CLASSES_ROOT\mc" /v "URL Protocol" /t REG_SZ /d "" /f
Reg.exe add "HKEY_CLASSES_ROOT\mc\Shell\Open\Command" /ve /t REG_SZ /d "\"%PROTOLOC%\" \"%%1\"" /f
echo Your registry has been set up correctly!
echo Please re-run this batch file if you move the game files.
echo You can now click mc:// links on the internet to join
echo -----------------------
pause
goto :End

:RunGame
echo Updating Game from latest dev
call :UpdateGame
echo Running Game...
"%PROTOFOLD%%GAMEFILE%" %PROTOUSER% %PROTOMPPASS% %PROTOIP% %PROTOPORT%
goto :End

:UpdateGame
call :DownloadGame
goto :eof

:DownloadGame
set "vbsDownloadGame=%temp%\PROTOLAUNCH_TMP_download.vbs"
set "gameDownload=http://static.classicube.net/ClassicalSharp/c_client/latest/%GAMEFILE%"

> %vbsDownloadGame% ECHO strHDLocation = "%PROTOFOLD%%GAMEFILE%"
>> %vbsDownloadGame% ECHO Set xmlHttp = CreateObject("Microsoft.XMLHTTP")
>> %vbsDownloadGame% ECHO xmlHttp.Open "GET", "%gameDownload%" , False
>> %vbsDownloadGame% ECHO xmlHttp.Send()
>> %vbsDownloadGame% ECHO Set objADOStream = CreateObject("ADODB.Stream")
>> %vbsDownloadGame% ECHO objADOStream.Open
>> %vbsDownloadGame% ECHO objADOStream.Type = 1 'adTypeBinary
>> %vbsDownloadGame% ECHO objADOStream.Write xmlHttp.ResponseBody
>> %vbsDownloadGame% ECHO objADOStream.Position = 0    'Set the stream position to the start
>> %vbsDownloadGame% ECHO Set objFSO = Createobject("Scripting.FileSystemObject")
>> %vbsDownloadGame% ECHO If objFSO.Fileexists(strHDLocation) Then objFSO.DeleteFile strHDLocation
>> %vbsDownloadGame% ECHO Set objFSO = Nothing
>> %vbsDownloadGame% ECHO objADOStream.SaveToFile strHDLocation
>> %vbsDownloadGame% ECHO objADOStream.Close
>> %vbsDownloadGame% ECHO Set objADOStream = Nothing

"%SystemRoot%\System32\WScript.exe" "%vbsDownloadGame%"

if not exist "%PROTOFOLD%%GAMEFILE%" goto :DownloadGame
goto :eof

:RunLauncher
echo Opening the launcher to download files.
echo Close the launcher when it's done to continue setup.
"%PROTOFOLD%%GAMEFILE%"
echo Setting up the registry now...
goto :eof

:MissingFail
echo Missing %GAMEFILE%
goto :Fail

:PrivFail
echo Requesting admin
goto :Fail

:Fail
echo Error in running. Please check above output for more information.
pause
goto :End

:End
echo Closing...

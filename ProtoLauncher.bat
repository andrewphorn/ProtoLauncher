@ECHO OFF
echo    ProtoLauncher v 1.1
echo ^|-----------------------^|
echo ^|Created by AndrewPH to ^|
echo ^|launch ClassicalSharp  ^|
echo ^|from mc:// links online^|
echo ^|-----------------------^|
setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
goto :Init

:Init
set PROTOLOC=%~dpnx0
set PROTOFOLD=%~dp0
set GAMEFILE=ClassicalSharp.exe

if not exist "%PROTOFOLD%%GAMEFILE%" goto :DownloadGame
if [%1]==[] goto :SetRegistry
echo Game Path:
echo %PROTOFOLD%ClassicalSharp.exe
echo -----------------------
goto :SplitURL

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
echo Please re-run this batch file if you move ClassicalSharp.
echo You can now click mc:// links on the internet to join
echo -----------------------
pause
goto :End

:RunGame
echo Running Game...
"%~dp0/%GAMEFILE%" %PROTOUSER% %PROTOMPPASS% %PROTOIP% %PROTOPORT%
goto :End

:DownloadGame
set "vbsDownloadGame=%temp%\PROTOLAUNCH_TMP_download.vbs"
set "gameZipFile=%temp%\protolaunch_game_latest.zip"
set "gameZipDownload=http://static.classicube.net/ClassicalSharp/latest.Release.zip"

> %vbsDownloadGame% ECHO strHDLocation = "%gameZipFile%"
>> %vbsDownloadGame% ECHO Set xmlHttp = CreateObject("Microsoft.XMLHTTP")
>> %vbsDownloadGame% ECHO xmlHttp.Open "GET", "%gameZipDownload%" , False
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
goto :UnzipGame

:UnzipGame
set "vbsUnzipGame=%temp%\PROTOLAUNCH_TMP_unzip.vbs"
> %vbsUnzipGame% ECHO Dim ArgObj, var1, var2, strFileZIP
>> %vbsUnzipGame% ECHO Set ArgObj = WScript.Arguments
>> %vbsUnzipGame% ECHO strFileZIP = "%temp%\protolaunch_game_latest.zip"
>> %vbsUnzipGame% ECHO Set WshShell = CreateObject("Wscript.Shell")
>> %vbsUnzipGame% ECHO Dim outFolder, objShell, objSource, objTarget
>> %vbsUnzipGame% ECHO outFolder = "%PROTOFOLD%"
>> %vbsUnzipGame% ECHO Set objShell = CreateObject( "Shell.Application" )
>> %vbsUnzipGame% ECHO Set objSource = objShell.NameSpace(strFileZIP).Items()
>> %vbsUnzipGame% ECHO objShell.NameSpace(outFolder).CopyHere objSource, 256
>> %vbsUnzipGame% ECHO WScript.Echo("We will now be launching ClassicalSharp's Launcher. Please close it once it's done downloading files.")
"%SystemRoot%\System32\WScript.exe" "%vbsUnzipGame%"
goto :RunLauncher

:RunLauncher
echo Opening the launcher to download files.
echo Close the launcher when it's done to continue setup.
"%~dp0/Launcher.exe"
echo Cleaning up after myself. Deleting temporary scripts.
del "%vbsUnzipGame%"
del "%vbsDownloadGame%"
del "%gameZipFile%"
echo Setting up the registry now...
goto :SetRegistry

:MissingFail
echo Missing ClassicalSharp.exe
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

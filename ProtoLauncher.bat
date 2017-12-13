@ECHO OFF
echo    ProtoLauncher v 1.0
echo ^|-----------------------^|
echo ^|Created by AndrewPH to ^|
echo ^|launch ClassicalSharp  ^|
echo ^|from mc:// links online^|
echo ^|-----------------------^|
goto :Init

:Init
set PROTOLOC=%0
set PROTOFOLD=%~dp0

if not exist "%PROTOFOLD%ClassicalSharp.exe" goto :MissingFail
if [%1]==[] goto :SetRegistry
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

:SetRegistry
echo Checking for admin privileges...
net session >nul 2>&1
if not %errorLevel% == 0 goto :PrivFail
Reg.exe add "HKEY_CLASSES_ROOT\mc" /ve /t REG_SZ /d "URL:mc" /f
Reg.exe add "HKEY_CLASSES_ROOT\mc" /v "URL Protocol" /t REG_SZ /d "" /f
Reg.exe add "HKEY_CLASSES_ROOT\mc\Shell\Open\Command" /ve /t REG_SZ /d "\"%PROTOLOC%\" \"%%1\"" /f
echo Your registry has been set up correctly!
echo Please re-run this batch file if you move ClassicalSharp.
echo You can now click mc:// links on the internet to join
echo ----------------------------------------
goto :End

:RunGame
echo Running Game...
%~dp0/ClassicalSharp.exe %PROTOUSER% %PROTOMPPASS% %PROTOIP% %PROTOPORT%
goto :End

:MissingFail
echo Missing ClassicalSharp.exe
goto :Fail

:PrivFail
echo You must run this as administrator to set up the registry!
goto :Fail

:Fail
echo Error in running. Please check above output for more information.
goto :End

:End
echo Closing...
pause

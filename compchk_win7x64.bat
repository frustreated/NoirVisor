@echo off
set ddkpath=C:\WinDDK\7600.16385.1\bin\x86
set incpath=C:\WinDDK\7600.16385.1\inc
set libpath=C:\WinDDK\7600.16385.1\lib
set binpath=.\bin\compchk_win7x64
set objpath=.\bin\compchk_win7x64\Intermediate

title Compiling NoirVisor
echo Project: NoirVisor
echo Platform: 64-Bit Windows
echo Powered by zero.tangptr@gmail.com
pause

echo ============Start Compiling============
echo Compiling Windows Driver Framework...
%ddkpath%\amd64\cl.exe .\src\booting\windrv\driver.c /I"%incpath%\crt" /I"%incpath%\api" /I"%incpath%\ddk" /Zi /nologo /W3 /WX /Od /Oy- /D"_AMD64_" /D"_M_AMD64" /D"_WIN64" /D "_NDEBUG" /D"_UNICODE" /D "UNICODE" /Zc:wchar_t /Zc:forScope /FAcs /Fa"%objpath%\driver.cod" /Fo"%objpath%\driver.obj" /Fd"%objpath%\vc90.pdb" /GS- /Gz /TC /c /errorReport:queue

echo Compiling Core Engine of Intel VT-x...
%ddkpath%\amd64\cl.exe .\src\vt_core\vt_main.c /I".\src\include" /Zi /nologo /W3 /WX /Od /Oy- /D"_msvc" /D"_amd64" /Zc:wchar_t /Zc:forScope /FAcs /Fa"%objpath%\vt_main.cod" /Fo"%objpath%\vt_main.obj" /Fd"%objpath%\vc90.pdb" /GS- /Gz /TC /c /errorReport:queue

echo Compiling Core Engine of AMD-V...
%ddkpath%\amd64\cl.exe .\src\svm_core\svm_main.c /I".\src\include" /Zi /nologo /W3 /WX /Od /Oy- /D"_msvc" /D"_amd64" /Zc:wchar_t /Zc:forScope /FAcs /Fa"%objpath%\svm_main.cod" /Fo"%objpath%\svm_main.obj" /Fd"%objpath%\vc90.pdb" /GS- /Gz /TC /c /errorReport:queue

echo Compiling Core of Cross-Platform Framework (XPF)...
%ddkpath%\amd64\cl.exe .\src\xpf_core\windows\debug.c /I"%incpath%\crt" /I"%incpath%\api" /I"%incpath%\ddk" /Zi /nologo /W3 /WX /Od /Oy- /D"_AMD64_" /D"_M_AMD64" /D"_WIN64" /D "_NDEBUG" /D"_UNICODE" /D "UNICODE" /Zc:wchar_t /Zc:forScope /FAcs /Fa"%objpath%\debug.cod" /Fo"%objpath%\debug.obj" /Fd"%objpath%\vc90.pdb" /GS- /Gz /TC /c /errorReport:queue

%ddkpath%\amd64\ml64.exe /W3 /WX /Zf /Zd /Fo"%objpath%\vt_hv64.obj" /c /nologo .\src\xpf_core\windows\vt_hv64.asm

echo ============Start Linking============
%ddkpath%\amd64\link.exe "%objpath%\driver.obj" "%objpath%\vt_main.obj" "%objpath%\svm_main.obj" "%objpath%\windows.obj" "%objpath%\vt_hv64.obj" "%objpath%\ver64.res" /LIBPATH:"%libpath%\win7\amd64" "ntoskrnl.lib" /NOLOGO /DEBUG /PDB:"%objpath%\NoirVisor.pdb" /OUT:"%binpath%\NoirVisor.sys" /SUBSYSTEM:NATIVE /Driver /ENTRY:"NoirDriverEntry" /Machine:X64 /ERRORREPORT:QUEUE

echo ============Start Signing============
%ddkpath%\signtool.exe sign /v /f .\ztnxtest.pfx /t http://timestamp.globalsign.com/scripts/timestamp.dll %binpath%\NoirVisor.sys

pause
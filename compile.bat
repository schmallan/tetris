@echo off
cls
nasm -f win64 -o helloworld.o helloworld.asm
gcc helloworld.o -o helloworld.exe "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.26100.0\um\x64\kernel32.lib"

helloworld.exe

echo ;
echo  ________________________
echo ^| ^exit code: %errorlevel%
echo ^|
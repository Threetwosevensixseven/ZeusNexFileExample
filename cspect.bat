:: Set current directory
::@echo off
C:
CD %~dp0

pskill.exe -t cspect.exe
hdfmonkey.exe put C:\spec\cspect-next-2gb.img nex_example.nex
hdfmonkey.exe put C:\spec\cspect-next-2gb.img autoexec.bas nextzxos\autoexec.bas

cd C:\spec\CSpect2_12_34
CSpect.exe -w2 -zxnext -nextrom -basickeys -exit -brk -tv -mmc=..\cspect-next-2gb.img


pause

echo off

call rebuildmx2cc
if %errorlevel% neq 0 exit /b %errorlevel%

call rebuildmods
if %errorlevel% neq 0 exit /b %errorlevel%

call rebuildted2go
if %errorlevel% neq 0 exit /b %errorlevel%

call makedocs
if %errorlevel% neq 0 exit /b %errorlevel%

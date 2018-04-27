
echo off

..\bin\mx2cc_windows makedocs %*
if %errorlevel% neq 0 exit /b %errorlevel%

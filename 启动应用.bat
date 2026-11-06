@echo off
setlocal EnableExtensions
chcp 65001 >nul
cd /d "%~dp0"

echo ========================================
echo   启动我的 AI 视频工作室...
echo ========================================
echo.

if not exist ".venv\Scripts\python.exe" (
    echo [错误] 未找到项目虚拟环境：.venv\Scripts\python.exe
    echo 请先在项目目录创建虚拟环境并安装 requirements.txt。
    echo.
    pause
    exit /b 1
)

rem 浏览器模式可避开部分 Windows WebView2 的兼容问题。
set "JJYB_BROWSER_MODE=1"
set "HTTP_PROXY="
set "HTTPS_PROXY="
set "ALL_PROXY="
set "NO_PROXY=127.0.0.1,localhost"

.venv\Scripts\python.exe -X utf8 -u frontend\app.py
set "EXIT_CODE=%ERRORLEVEL%"

echo.
if not "%EXIT_CODE%"=="0" echo [ERROR] Application exited with code %EXIT_CODE%.
pause
exit /b %EXIT_CODE%

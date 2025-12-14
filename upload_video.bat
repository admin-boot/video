@echo off
chcp 65001 > nul

REM 设置GitHub仓库URL
set REPO_URL=https://github.com/admin-boot/video.git

REM 检查Git是否安装
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo Git未安装，请先安装Git
    pause
    exit /b 1
)

REM 检查Git LFS是否安装
where git-lfs >nul 2>nul
if %errorlevel% neq 0 (
    echo Git LFS未安装，正在安装...
    git lfs install
    if %errorlevel% neq 0 (
        echo Git LFS安装失败
        pause
        exit /b 1
    )
)

REM 检查是否在Git仓库中
if not exist .git (
    echo 未初始化Git仓库，正在初始化...
    git init
    git remote add origin %REPO_URL%
)

REM 检查远程仓库是否正确
for /f "tokens=2" %%i in ('git remote get-url origin') do set CURRENT_REMOTE=%%i
if not "%CURRENT_REMOTE%" == "%REPO_URL%" (
    echo 远程仓库不正确，正在更新...
    git remote set-url origin %REPO_URL%
)

REM 跟踪mp4文件使用Git LFS
git lfs track "*.mp4"

REM 获取新增的文件列表
setlocal enabledelayedexpansion
set NEW_FILES=
for /f "delims=" %%f in ('git status --porcelain ^| findstr /r "^??"') do (
    set FILE=%%f
    set FILE=!FILE:~3!
    set NEW_FILES=!NEW_FILES! "!FILE!"
)

if "%NEW_FILES%" == "" (
    echo 没有新增文件需要上传
    pause
    exit /b 0
)

REM 获取修改的文件列表
set MODIFIED_FILES=
for /f "delims=" %%f in ('git status --porcelain ^| findstr /r "^ M"') do (
    set FILE=%%f
    set FILE=!FILE:~3!
    set MODIFIED_FILES=!MODIFIED_FILES! "!FILE!"
)

REM 合并新增和修改的文件
set ALL_CHANGED_FILES=%NEW_FILES% %MODIFIED_FILES%

REM 添加所有修改的文件到暂存区
echo 正在添加文件到暂存区...
git add %ALL_CHANGED_FILES%

REM 生成提交信息
set COMMIT_MSG=Add/Update files:
for %%f in (%NEW_FILES%) do (
    set COMMIT_MSG=!COMMIT_MSG!
    set COMMIT_MSG=!COMMIT_MSG!- %%~f
)
for %%f in (%MODIFIED_FILES%) do (
    set COMMIT_MSG=!COMMIT_MSG!
    set COMMIT_MSG=!COMMIT_MSG!- Update: %%~f
)

REM 提交文件
echo 正在提交文件...
git commit -m "%COMMIT_MSG%"

REM 推送文件到GitHub
echo 正在推送文件到GitHub...
echo 注意：大文件上传可能需要较长时间...
git push origin master

if %errorlevel% eq 0 (
    echo 上传成功！
    echo 提交内容：
    echo %COMMIT_MSG%
) else (
    echo 上传失败，请检查网络连接或GitHub权限
)

pause
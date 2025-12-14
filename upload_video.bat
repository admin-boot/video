@echo off

REM Set GitHub repository URL
set REPO_URL=https://github.com/admin-boot/video.git

REM Check if Git is installed
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo Git is not installed. Please install Git first.
    pause
    exit /b 1
)

REM Check if Git LFS is installed
where git-lfs >nul 2>nul
if %errorlevel% neq 0 (
    echo Git LFS is not installed. Installing...
    git lfs install
    if %errorlevel% neq 0 (
        echo Failed to install Git LFS.
        pause
        exit /b 1
    )
)

REM Check if in Git repository
if not exist .git (
    echo Not in a Git repository. Initializing...
    git init
    git remote add origin %REPO_URL%
)

REM Track MP4 files with Git LFS
git lfs track "*.mp4" >nul 2>nul

REM Add all MP4 files
echo Checking MP4 files...
for %%f in (*.mp4) do (
    echo Checking file: %%f
    git add "%%f"
)

REM Commit files
echo Committing files...
git commit -m "Add/Update MP4 files" >nul 2>&1
if errorlevel 1 (
    echo No changes to commit or commit failed.
) else (
    echo Commit successful. Pushing to GitHub...
    git push origin master
    if errorlevel 1 (
        echo Push failed. Check network or GitHub permissions.
    ) else (
        echo Upload successful!
    )
)

pause
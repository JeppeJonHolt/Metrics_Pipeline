# Use a barebones Windows Server Core base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set up environment variables for the installer
ENV DOTNET_SDK_VERSION=8.0.300

# Download and install the .NET SDK
RUN powershell -Command " \
    $ErrorActionPreference = 'Stop'; \
    Invoke-WebRequest -Uri 'https://download.visualstudio.microsoft.com/download/pr/90486d8a-fb5a-41be-bfe4-ad292c06153f/6673965085e00f5b305bbaa0b931cc96/dotnet-sdk-8.0.300-win-x64.exe' -OutFile 'dotnet-sdk-installer.exe'; \
    Start-Process -FilePath .\dotnet-sdk-installer.exe -ArgumentList '/quiet', '/norestart' -NoNewWindow -Wait; \
    Remove-Item -Force .\dotnet-sdk-installer.exe;"

# Add the .NET tools to the PATH
RUN setx /M PATH "%PATH%;C:\Program Files\dotnet"

RUN powershell -NoProfile -ExecutionPolicy Bypass -Command " \
    Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_buildtools.exe' -OutFile 'vs_buildtools.exe'; \
    Start-Process 'vs_buildtools.exe' -ArgumentList '--quiet', '--wait', '--add', 'Microsoft.VisualStudio.Workload.MSBuildTools' -NoNewWindow -Wait; \
    Remove-Item -Force 'vs_buildtools.exe'"

RUN setx /M PATH "%PATH%;C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin"

# Download and install Git for Windows
RUN powershell -Command " \
    $ErrorActionPreference = 'Stop'; \
    Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/download/v2.40.1.windows.1/MinGit-2.40.1-64-bit.zip' -OutFile 'mingit.zip'; \
    Expand-Archive -Path mingit.zip -DestinationPath 'C:\\MinGit'; \
    Remove-Item -Force mingit.zip"

# Add Git to the PATH
RUN setx /M PATH "%PATH%;C:\MinGit\cmd"

# Verify the installation
RUN powershell -Command "dotnet --version"
RUN powershell -Command "git --version"
RUN powershell -Command " \
    if (Get-Command msbuild.exe -ErrorAction SilentlyContinue) { \
        msbuild.exe -version; \
    } else { \
        Write-Host 'MSBuild is not installed'; \
        exit 1; \
    }"

# Set the default command to run when the container starts
CMD ["cmd.exe"]
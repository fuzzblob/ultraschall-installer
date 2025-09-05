## Windows

Dependencies:

- Building on Windows requires Visual Studio 2019 or later.
- Pandoc [https://pandoc.org/installing.html](https://pandoc.org/installing.html)

To build the Windows installer run the following in PowerShell:

```powershell
PS> cd ultraschall-installer/windows/
PS> ./build.ps1
```

## macOS

Building on macOS requires Xcode 11 or later.

```bash
$ cd macos/
$ ./build.sh
```

## Linux

**in development - currently testing only**

- clone this repository
- change directory
- run the build script

```bash
$ cd ultraschall-installer/linux
$ ./build.sh
```

To install Ultraschall, get the installer artifact in `linux/build/artifacts` (tar.gz file):

```bash
$ cd build/artifacts
$ tar -xvzf ULTRASCHALL_R5.1.2-preview.tar.gz
$ cd R5.1.2-preview
$ ./install.sh
```

Optionally pass a path to a portable REAPER install if you want to keep you current Ultraschall or REAPER install intact when testing a new version.

```bash
$ ./install.sh ~/Downloads/reaper_linux_x86_64/REAPER/
```

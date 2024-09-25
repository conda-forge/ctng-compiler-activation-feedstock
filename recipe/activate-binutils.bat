@echo off
set "CONDA_BACKUP_AR=%AR%"
set "AR=@CHOST@-ar.exe"

set "CONDA_BACKUP_AS=%AS%"
set "AS=@CHOST@-as.exe"

set "CONDA_BACKUP_DLLTOOL=%DLLTOOL%"
set "DLLTOOL=@CHOST@-dlltool.exe"

set "CONDA_BACKUP_NM=%NM%"
set "NM=@CHOST@-nm.exe"

set "CONDA_BACKUP_OBJDUMP=%OBJDUMP%"
set "OBJDUMP=@CHOST@-objdump.exe"

set "CONDA_BACKUP_RANLIB=%RANLIB%"
set "RANLIB=@CHOST@-ranlib.exe"

set "CONDA_BACKUP_STRIP=%STRIP%"
set "STRIP=@CHOST@-strip.exe"

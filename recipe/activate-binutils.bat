@echo off
set "CONDA_BACKUP_AR=%AR%"
set "AR=%CHOST%-ar.exe"

set "CONDA_BACKUP_RANLIB=%RANLIB%"
set "RANLIB=%CHOST%-ranlib.exe"

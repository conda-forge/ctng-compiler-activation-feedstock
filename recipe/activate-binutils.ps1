$Env:CONDA_BACKUP_AR=$Env:AR
$Env:AR="@CHOST@-ar.exe"

$Env:CONDA_BACKUP_RANLIB=$Env:RANLIB
$Env:RANLIB="@CHOST@-ranlib.exe"

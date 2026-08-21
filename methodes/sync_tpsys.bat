@echo off
rem ============================================================
rem  Sync supports TPSys - Proto Process
rem  Prend le fichier insert_supports_*.sql le plus recent
rem  du dossier Telechargements, le pousse en SSH sur TPSys
rem  (192.168.1.4) et l'execute dans la base mydata_common_db.
rem  Prerequis (une fois) : cle SSH installee pour tpsys@192.168.1.4
rem ============================================================
setlocal enabledelayedexpansion
set DL=%USERPROFILE%\Downloads
set HOST=tpsys@192.168.1.4

for /f "delims=" %%f in ('dir /b /o-d "%DL%\insert_supports_*.sql" 2^>nul') do (
    set "SQLFILE=%%f"
    goto :found
)
echo [ERREUR] Aucun fichier insert_supports_*.sql dans %DL%
pause
exit /b 1

:found
echo Fichier detecte : %SQLFILE%
echo.
choice /m "Executer ce script sur TPSys (192.168.1.4)"
if errorlevel 2 exit /b 0

echo.
echo --- Copie vers TPSys ---
scp -o StrictHostKeyChecking=accept-new "%DL%\%SQLFILE%" %HOST%:/home/tpsys/
if errorlevel 1 ( echo [ERREUR] Copie SSH impossible - verifier reseau/cle & pause & exit /b 1 )

echo.
echo --- Execution ---
ssh -o StrictHostKeyChecking=accept-new %HOST% "psql -U postgres -d mydata_common_db -f /home/tpsys/%SQLFILE%"
echo.
echo --- Termine. Attendu : BEGIN, DO, N x INSERT 0 1, UPDATE 1, UPDATE n, COMMIT ---
echo --- Si EXCEPTION compteur : script deja passe ou base desynchronisee, rien ecrit ---
pause

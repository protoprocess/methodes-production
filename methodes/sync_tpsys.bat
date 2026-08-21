@echo off
rem ============================================================
rem  Sync supports TPSys - Proto Process  (v3)
rem  Prend le insert_supports_*.sql le plus recent des
rem  Telechargements, le pousse en SSH sur TPSys (192.168.1.4)
rem  et l'execute dans mydata_common_db.
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
set /p REP="Executer ce script sur TPSys (192.168.1.4) ? Taper O puis Entree : "
if /i not "%REP%"=="O" exit /b 0

echo.
echo --- Copie vers TPSys (mot de passe tpsys si demande) ---
scp -o StrictHostKeyChecking=accept-new "%DL%\%SQLFILE%" %HOST%:/home/tpsys/ < CON
if errorlevel 1 ( echo [ERREUR] Copie SSH impossible - verifier reseau / mot de passe & pause & exit /b 1 )

echo.
echo --- Execution ---
ssh -o StrictHostKeyChecking=accept-new %HOST% "psql -U postgres -d mydata_common_db -f /home/tpsys/%SQLFILE%" < CON
echo.
echo --- Termine. Attendu : BEGIN, DO, N x INSERT 0 1, UPDATE, COMMIT ---
echo --- Si EXCEPTION compteur : script deja passe ou base desynchronisee, rien ecrit ---
pause

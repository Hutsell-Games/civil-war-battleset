echo off
cls
echo ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
echo ÿÿÿInstall program for EGA CivilWar BattleSet v2.5
echo ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
echo ÿ
if "%1" == "" goto howto
if "%1" == "c" goto howto
if "%1" == "C" goto howto
if "%1" == "d" goto howto
if "%1" == "D" goto howto
if "%1" == "a:" goto howto
if "%1" == "A:" goto howto
if "%1" == "b:" goto howto
if "%1" == "B:" goto howto
if not exist cwgame.zip goto howto
if not exist install.bat goto howto
echo ÿ
echo Civil War installation
echo This will create a directory called \Civil25 on the '%1' disk
echo and copy the game files into it. It will NOT make any other
echo changes to your system.
echo ÿ
echo Hit Ctrl-C if you do NOT wish to continue
pause
echo Creating directory '\Civil25' on '%1' drive
mkdir %1\Civil25
echo ÿ
echo Copying files...
copy *.* %1\Civil25
echo Changing to Civil War Directory...
%1
cd\Civil25
unzip cwgame.zip
unzip scenario.zip
unzip docs.zip
unzip sounds.zip
echo Cleaning up...
del *.zip
del install.bat
del cw.exe
echo ÿ
echo EGA CivilWar BattleSet is now installed !
echo        To play the game
echo With Title Screen   Skip Title Screen  
echo ================    =================  
echo       CW                 CW25
echo ÿ
echo For sound card sounds type 's' at the command line, for example:
echo       CW s
echo
echo To use the editor type:
echo CS
goto done4
:howto
echo Place Master Disk in drive and go to that drive and type
echo "INSTALL DRIVE:" where DRIVE: is the TARGET drive.
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo NOTE THAT YOU MUST INCLUDE THE COLON AS PART OF THE DRIVE DESIGNATION
echo :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo ÿ
echo EXAMPLE:
echo To copy the game from the A: drive to the C: drive,
echo you would type
echo            A:          [enter]
echo            INSTALL C:  [enter]
echo If your target disk is a drive other than C: use its letter instead.
:done4

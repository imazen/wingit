@echo Requires Python and Py2exe to be installed

set PATH=C:\Python27;C:\Python26;C:\Python25;%PATH%


python pyinstaller-1.5\Makespec.py --onefile keytool.py

pause
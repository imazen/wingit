!define VERSION "1.1.0"
!define PACKAGE "Git"

!define NAME "ICW"
!define REGROOT "Software\Itefix\ICW"

!define UNINSTPROG "uninstall_${NAME}_${PACKAGE}.exe"

!include "${NSISDIR}\Include\WinMessages.nsh"

SetCompressor /SOLID LZMA

!include "MUI.nsh"
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Name "${NAME} ${PACKAGE} ${VERSION}"
OutFile "${NAME}_${PACKAGE}_${VERSION}_installer.exe"
InstallDirRegKey HKLM ${REGROOT} "InstallDirectory"
AutoCloseWindow true

VIAddVersionKey  "ProductName" "${NAME}"
VIAddVersionKey  "CompanyName" "ITeF!x Consulting"
VIAddVersionKey  "FileDescription" "${NAME} ${PACKAGE}"
VIAddVersionKey  "FileVersion" "${VERSION}"
VIProductVersion "${VERSION}.0"

Var installtype

Function .onInit

	StrCpy $installtype "fresh"

	# Check if icw git base is installed 
	ReadRegStr $0 HKLM "${REGROOT}\Base" "version"
	IfErrors 0 Init_Cont_B
	MessageBox MB_OK|MB_ICONSTOP  "${NAME} Base package is required for ${NAME} ${PACKAGE}." /SD IDOK
	Abort
	
	Init_Cont_B:	
	# Check for previous package installations
	ReadRegStr $0 HKLM "${REGROOT}\${PACKAGE}" "version"
	IfErrors Init_End
	StrCpy $installtype "upgrade"

	Init_End:
	
FunctionEnd

# Install section
Section "${NAME} ${PACKAGE}"

	SetAutoClose true

	StrCmp $installtype "upgrade" 0 Install_A
	IfSilent +2
	Banner::show /NOUNLOAD "Upgrading ${PACKAGE} ..."
	
	Call UpgradePackage
	Goto Install_End
	
	Install_A:
	IfSilent +2
	Banner::show /NOUNLOAD "Installing ${PACKAGE} ..."
	
	Call InstallPackage
	
	Install_End:
	Banner::destroy
	WriteUninstaller "$INSTDIR\${UNINSTPROG}"
	
SectionEnd

# Uninstall section
Section "Uninstall"

	SetAutoClose true

	DetailPrint "Remove registry keys"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME} ${PACKAGE}"
	DeleteRegKey HKLM "${REGROOT}\${PACKAGE}"

	DetailPrint "Remove uninstaller"
	Delete $INSTDIR\${UNINSTPROG}
		
	Call un.DeleteFiles

SectionEnd

Function InstallPackage

	Call InstallFiles
	
	; Link /bin/gawk to awk
	NsExec::Exec '"$INSTDIR\bin\bash" -c "/bin/ln /bin/gawk /bin/awk"'


	; Write the version into the registry
	WriteRegStr HKLM "${REGROOT}\${PACKAGE}" "Version" "${VERSION}"

	Banner::destroy
	
FunctionEnd

Function UpgradePackage
	
	Call InstallFiles

	; Update the version info 
	WriteRegStr HKLM "${REGROOT}\${PACKAGE}" "Version" "${VERSION}"

FunctionEnd

Function InstallFiles

	SetOutPath $INSTDIR
	
	File /r bin
	File /r lib
	File /r usr	
	
FunctionEnd

Function un.DeleteFiles
		
FunctionEnd

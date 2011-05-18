!define VERSION "1.0.0"
!define REGROOT "Software\Itefix\ICW"
!define NAME "WindowsGit"
!define UNINSTPROG "uninstall_${NAME}.exe"
!define DEF_SERVICE_ACCOUNT "SvcCOPSSH"

!define COPSSH_PACKAGE "Copssh_4.1.1_Installer.exe"
!define COPSSH_UNINSTALL "uninstall_Copssh.exe"
!define COPSSHCP_UNINSTALL "uninstall_ICW_COPSSHCP.exe"
!define GIT_PACKAGE "ICW_Git_1.0.0_installer.exe"
!define GIT_UNINSTALL "uninstall_ICW_Git.exe"

SetCompressor /SOLID LZMA
InstallDir $PROGRAMFILES\ICW
InstallDirRegKey HKLM ${REGROOT} "InstallDirectory"
Name "${NAME} ${VERSION}"
OutFile "${NAME}_${VERSION}_Installer.exe"

VIAddVersionKey  "ProductName" "${NAME}"
VIAddVersionKey  "CompanyName" "ITeF!x Consulting"
VIAddVersionKey  "FileDescription" "${NAME}"
VIAddVersionKey  "FileVersion" "${VERSION}"
VIProductVersion "${VERSION}.1000"

!include MUI.nsh
;!define MUI_ICON "copssh.ico"
;!define MUI_UNICON "copssh-uninstall.ico"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.TXT"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

!include nsDialogs.nsh
!include LogicLib.nsh
!include WinVer.nsh
!include WinMessages.nsh
!include FileFunc.nsh

!insertmacro GetParameters
!insertmacro GetOptions

Var svcuser
Var svcpassword

Function .onInit

	StrCpy $svcuser ""
	StrCpy $svcpassword ""

	${IfNot} ${AtLeastWinNT4}}
	MessageBox MB_OK "NT4 and above required"
	Quit
	${EndIf}

	InitPluginsDir
	File /oname=$PLUGINSDIR\${COPSSH_PACKAGE} ${COPSSH_PACKAGE}
	File /oname=$PLUGINSDIR\${GIT_PACKAGE} ${GIT_PACKAGE}
	File /oname=$PLUGINSDIR\pwdgen.exe pwdgen.exe
	
	# Check if user / password is defined via command line
	${GetParameters} $0
	${GetOptions} $0 "/u="  $svcuser
	${GetOptions} $0 "/p="  $svcpassword
	
	# Check if user/password is already supplied
	StrCmp $svcuser "" Init_Cont_A 0
	StrCmp $svcpassword "" Init_Cont_A 0
	Goto Init_Cont_B
	
Init_Cont_A:
	# Create default values
	nsExec::ExecToStack "$PLUGINSDIR\pwdgen.exe"
	Pop $0
	Pop $0
	
	StrCpy $svcpassword $0 14
	StrCpy $svcuser ${DEF_SERVICE_ACCOUNT}

Init_Cont_B:

FunctionEnd

# Install section
Section "WindowsGit"

	StrCpy $0 ""
;	IfSilent 0 +2
	StrCpy $0 "/S"
	
	WriteRegStr HKLM ${REGROOT} "InstallDirectory" "$INSTDIR"
	
	DetailPrint "Installing Copssh, please be patient (Service account $svcuser, password $svcpassword) ..."
	nsExec::Exec '"$PLUGINSDIR\${COPSSH_PACKAGE}" $0 /u=$svcuser /p=$svcpassword'
	
	# Create git user with a default password
	nsExec::ExecToStack "$PLUGINSDIR\pwdgen.exe"
	Pop $0
	Pop $0
	DetailPrint "Creating user 'git', password $0"
	nsExec::ExecToLog 'net user git $0 /ADD /COMMENT:"Git user"'
	
	DetailPrint "Installing Git binaries"
	nsExec::Exec '"$PLUGINSDIR\${GIT_PACKAGE}" $0'
	
	; Set installation Directory
	ReadRegStr $INSTDIR HKLM ${REGROOT} "InstallDirectory"
		
	WriteUninstaller ${UNINSTPROG}

	DetailPrint "Creating shortcuts"
	CreateDirectory "$SMPROGRAMS\${NAME}"

	SetOutPath $INSTDIR

	CreateShortCut "$SMPROGRAMS\${NAME}\01. Uninstall Windowsgit.lnk" "$INSTDIR\${UNINSTPROG}"

	; Write the uninstall keys for Windows
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "DisplayName" "${NAME} (remove only)"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "UninstallString" '"$INSTDIR\${UNINSTPROG}"'
	
SectionEnd

# Uninstall section
Section "Uninstall"

	# Uninstall if only base + openssh packages exist, warn otherwise

	DetailPrint "Remove uninstaller"
	Delete $INSTDIR\${UNINSTPROG}
	
	StrCpy $0 ""
;	IfSilent 0 +2
	StrCpy $0 "/S"
	
	DetailPrint "Uninstalling Git"
	nsExec::Exec '"$INSTDIR\${GIT_UNINSTALL}" $0'
	
	DetailPrint "Uninstalling Copssh"
	nsExec::Exec '"$INSTDIR\${COPSSH_UNINSTALL}" $0'
	nsExec::Exec '"$INSTDIR\${COPSSHCP_UNINSTALL}" $0'
	
	DetailPrint "Remove accounts"
	nsExec::Exec "net user SvcCopssh /DELETE"
	nsExec::Exec "net user Git /DELETE"	
	
	RMDir $INSTDIR ; if empty
	
	DetailPrint "Remove uninstall registry keys"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
	
	DetailPrint "Remove shortcuts"
	RmDir /r "$SMPROGRAMS\${NAME}"

SectionEnd

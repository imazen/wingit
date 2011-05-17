!define VERSION "4.1.1"
!define REGROOT "Software\Itefix\ICW"
!define NAME "Copssh"
!define UNINSTPROG "uninstall_${NAME}.exe"
!define DEF_SERVICE_ACCOUNT "SvcCOPSSH"

!define BASE_PACKAGE "ICW_Base_2.1.5_installer.exe"
!define BASE_UNINSTALL "uninstall_ICW_Base.exe"
!define OPENSSHSERVER_NAME "OpenSSHServer"
!define SVCNAME "OpenSSHServer"
!define OPENSSHSERVER_PACKAGE "ICW_OpenSSHServer_3.0.2_installer.exe"
!define OPENSSHSERVER_UNINSTALL "uninstall_ICW_OpenSSHServer.exe"
!define COPSSHCP_PACKAGE "ICW_COPSSHCP_2.1.1_installer.exe"
!define COPSSHCP_UNINSTALL "uninstall_ICW_COPSSHCP.exe"

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
!define MUI_ICON "copssh.ico"
!define MUI_UNICON "copssh-uninstall.ico"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.TXT"
!insertmacro MUI_PAGE_DIRECTORY
Page custom ServiceAccountGUI ServiceAccountGUIPageLeave
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

Var hDialog
Var hsvcaccount
Var hsvcpassword1
Var hsvcpassword2

Function .onInit

	StrCpy $svcuser ""
	StrCpy $svcpassword ""

	${IfNot} ${AtLeastWinNT4}}
	MessageBox MB_OK "NT4 and above required"
	Quit
	${EndIf}

	InitPluginsDir
	File /oname=$PLUGINSDIR\${BASE_PACKAGE} ${BASE_PACKAGE}
	File /oname=$PLUGINSDIR\${OPENSSHSERVER_PACKAGE} ${OPENSSHSERVER_PACKAGE}
	File /oname=$PLUGINSDIR\${COPSSHCP_PACKAGE} ${COPSSHCP_PACKAGE}
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
Section "copSSH"

	StrCpy $0 ""
	IfSilent 0 +2
	StrCpy $0 "/S"
	
	WriteRegStr HKLM ${REGROOT} "InstallDirectory" "$INSTDIR"
	
	DetailPrint "Stop ${SVCNAME} service"
	nsExec::Exec '"$INSTDIR\Bin\cygrunsrv" -E ${SVCNAME}'
	
	DetailPrint "Backup existing configuration files"
	IfFileExists $INSTDIR\etc\sshd_config 0 +2
	Rename $INSTDIR\etc\sshd_config $INSTDIR\etc\sshd_config.pre400
	
	IfFileExists $INSTDIR\etc\passwd 0 +2
	Rename $INSTDIR\etc\passwd $INSTDIR\etc\passwd.pre400
	
	IfFileExists $INSTDIR\etc\group 0 +2
	Rename $INSTDIR\etc\group $INSTDIR\etc\group.pre400
	
	nsExec::Exec '"$PLUGINSDIR\${BASE_PACKAGE}" $0'
	nsExec::Exec '"$PLUGINSDIR\${OPENSSHSERVER_PACKAGE}" $0 /u=$svcuser /p=$svcpassword'
	nsExec::Exec '"$PLUGINSDIR\${COPSSHCP_PACKAGE}" $0'
	
	; Set installation Directory
	ReadRegStr $INSTDIR HKLM ${REGROOT} "InstallDirectory"
	
	SetOutPath $INSTDIR
	File "README.TXT"
	File "LICENSE.CYGWIN.TXT"
	File "LICENSE.OPENSSH.TXT"
	File "LICENSE.COPSSH.TXT"
	
	WriteUninstaller ${UNINSTPROG}

	DetailPrint "Creating shortcuts"
	CreateDirectory "$SMPROGRAMS\${NAME}"

	SetOutPath "$INSTDIR\bin"
	CreateShortCut "$SMPROGRAMS\${NAME}\01. COPSSH Control Panel.lnk" "$INSTDIR\Bin\copsshcp.exe"

	SetOutPath $INSTDIR
	CreateShortCut "$SMPROGRAMS\${NAME}\02. Start a Unix BASH Shell.lnk" "$INSTDIR\Bin\bash.exe" "--login -i"
	CreateShortCut "$SMPROGRAMS\${NAME}\03. Start a Windows CMD Shell.lnk" "cmd.exe" "/K"
	CreateShortCut "$SMPROGRAMS\${NAME}\04. Readme.lnk" "$INSTDIR\README.TXT"
	CreateShortCut "$SMPROGRAMS\${NAME}\05. Documentation.lnk" "$WINDIR\explorer.exe" "$INSTDIR\DOC"
	CreateShortCut "$SMPROGRAMS\${NAME}\06. copSSH web site.lnk" "http://itefix.no/copssh"
	CreateShortCut "$SMPROGRAMS\${NAME}\08. Uninstall COPSSH.lnk" "$INSTDIR\${UNINSTPROG}"

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
	IfSilent 0 +2
	StrCpy $0 "/S"
	
	nsExec::Exec '"$INSTDIR\${OPENSSHSERVER_UNINSTALL}" $0'
	Sleep 5000
	nsExec::Exec '"$INSTDIR\${BASE_UNINSTALL}" $0'
	
	Delete "$INSTDIR\README.TXT"
	Delete "$INSTDIR\LICENSE.CYGWIN.TXT"
	Delete "$INSTDIR\LICENSE.OPENSSH.TXT"
	Delete "$INSTDIR\LICENSE.COPSSH.TXT"
	
	RMDir $INSTDIR ; if empty
	
	DetailPrint "Remove uninstall registry keys"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
	
	DetailPrint "Remove shortcuts"
	RmDir /r "$SMPROGRAMS\${NAME}"

SectionEnd

Function ServiceAccountGUI

	# Skip dialog if the service account is already defined for OpenSSH package (upgrade)
	ReadRegStr $0 HKLM "${REGROOT}\${OPENSSHSERVER_NAME}" "ServiceAccount"	
	StrCmp $0 "" 0 GUI_Serv_Acc_End

	!insertmacro MUI_HEADER_TEXT "Service Account" "OpenSSH server will be setup as a windows service with the logon credentials below:"

	nsDialogs::Create /NOUNLOAD 1018
	Pop $hDialog

	${If} $hDialog == error
		Abort
	${EndIf}

	${NSD_CreateLabel} 10 2 95% 80 "Copssh requires a dedicated service account for full functionality. You can either accept the values suggested by the installer (user: $svcuser, password: $svcpassword) or specify your own values. Existing accounts are allowed. HOWEVER, PLEASE DON'T USE YOUR USER ACCOUNTS OR BUILT-IN ACCOUNTS like administrator FOR THAT PURPOSE. THEY WILL BE DENIED FOR LOGON. In all cases, the account will be entitled with administrator rights and some user privileges depending on the operating system. Check the User Rights Assignment in the Local Security Policy for more information."
	
	${NSD_CreateLabel} 10 90 100 24 "Service account:"
	${NSD_CreateText} 110 90 160 24 ""
	Pop $hsvcaccount
	${NSD_SetText} $hsvcaccount $svcuser
	
	${NSD_CreateLabel} 10 125 100 24 "Type password:"
	${NSD_CreatePassword} 110 125 160 24 ""
	Pop $hsvcpassword1
	${NSD_SetText} $hsvcpassword1 $svcpassword
	
	${NSD_CreateLabel} 10 160 100 24 "Confirm password:"
	${NSD_CreatePassword} 110 160 160 24 ""
	Pop $hsvcpassword2
	${NSD_SetText} $hsvcpassword2 $svcpassword
	
	${NSD_SetFocus} $hsvcaccount

	nsDialogs::Show
	
	GUI_Serv_Acc_End:

FunctionEnd

Function ServiceAccountGUIPageLeave

	# Skip dialog if the service account is already defined for OpenSSH package
	ReadRegStr $0 HKLM "${REGROOT}\${OPENSSHSERVER_NAME}" "ServiceAccount"	
	StrCmp $0 "" 0 Leave_Serv_Acc_End

	${NSD_GetText} $hsvcaccount $svcuser
	${NSD_GetText} $hsvcpassword1 $1
	${NSD_GetText} $hsvcpassword2 $2

	StrCmp $1 $2 +3
	MessageBox MB_OK|MB_ICONSTOP "Passwords do not match. Please start the installer again."
	Quit
	
	StrCpy $svcpassword $1

	Leave_Serv_Acc_End:
FunctionEnd

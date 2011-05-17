!define VERSION "1.0.0"
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

	# Check if icw base is installed 
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

	SetOutPath "$INSTDIR\bin"
File bin\git-update-ref.exe
File bin\git-update-server-info.exe
File bin\git-upload-archive.exe
File bin\git-upload-pack.exe
File bin\git-var.exe
File bin\git-verify-pack.exe
File bin\git-verify-tag.exe
File bin\git-whatchanged.exe
File bin\git-write-tree.exe
File bin\git.exe
File bin\git-add.exe
File bin\git-annotate.exe
File bin\git-apply.exe
File bin\git-archive.exe
File bin\git-bisect--helper.exe
File bin\git-blame.exe
File bin\git-branch.exe
File bin\git-bundle.exe
File bin\git-cat-file.exe
File bin\git-check-attr.exe
File bin\git-checkout.exe
File bin\git-checkout-index.exe
File bin\git-check-ref-format.exe
File bin\git-cherry.exe
File bin\git-cherry-pick.exe
File bin\git-clean.exe
File bin\git-clone.exe
File bin\git-commit.exe
File bin\git-commit-tree.exe
File bin\git-config.exe
File bin\git-count-objects.exe
File bin\git-daemon.exe
File bin\git-describe.exe
File bin\git-diff.exe
File bin\git-diff-files.exe
File bin\git-diff-index.exe
File bin\git-gc.exe
File bin\git-diff-tree.exe
File bin\git-fast-export.exe
File bin\git-fast-import.exe
File bin\git-fetch.exe
File bin\git-fetch-pack.exe
File bin\git-fmt-merge-msg.exe
File bin\git-for-each-ref.exe
File bin\git-format-patch.exe
File bin\git-fsck.exe
File bin\git-fsck-objects.exe
File bin\git-get-tar-commit-id.exe
File bin\git-grep.exe
File bin\git-hash-object.exe
File bin\git-help.exe
File bin\git-http-backend.exe
File bin\git-imap-send.exe
File bin\git-index-pack.exe
File bin\git-init.exe
File bin\git-init-db.exe
File bin\git-log.exe
File bin\git-ls-files.exe
File bin\git-ls-remote.exe
File bin\git-ls-tree.exe
File bin\git-mailinfo.exe
File bin\git-mailsplit.exe
File bin\git-merge.exe
File bin\git-merge-base.exe
File bin\git-merge-file.exe
File bin\git-merge-index.exe
File bin\git-merge-ours.exe
File bin\git-merge-recursive.exe
File bin\git-merge-subtree.exe
File bin\git-merge-tree.exe
File bin\git-mktag.exe
File bin\git-mktree.exe
File bin\git-mv.exe
File bin\git-name-rev.exe
File bin\git-notes.exe
File bin\git-pack-objects.exe
File bin\git-pack-redundant.exe
File bin\git-pack-refs.exe
File bin\git-patch-id.exe
File bin\git-peek-remote.exe
File bin\git-prune.exe
File bin\git-prune-packed.exe
File bin\git-push.exe
File bin\git-read-tree.exe
File bin\git-receive-pack.exe
File bin\git-reflog.exe
File bin\git-remote.exe
File bin\git-remote-ext.exe
File bin\git-remote-fd.exe
File bin\git-replace.exe
File bin\git-repo-config.exe
File bin\git-rerere.exe
File bin\git-rm.exe
File bin\git-reset.exe
File bin\git-revert.exe
File bin\git-rev-list.exe
File bin\git-rev-parse.exe
File bin\git-send-pack.exe
File bin\git-shell.exe
File bin\git-shortlog.exe
File bin\git-show.exe
File bin\git-show-branch.exe
File bin\git-show-index.exe
File bin\git-show-ref.exe
File bin\git-stage.exe
File bin\git-status.exe
File bin\git-stripspace.exe
File bin\git-symbolic-ref.exe
File bin\git-tag.exe
File bin\git-tar-tree.exe
File bin\git-unpack-file.exe
File bin\git-unpack-objects.exe
File bin\git-update-index.exe
	
FunctionEnd

Function un.DeleteFiles
	
Delete $INSTDIR\bin\git-update-ref.exe
Delete $INSTDIR\bin\git-update-server-info.exe
Delete $INSTDIR\bin\git-upload-archive.exe
Delete $INSTDIR\bin\git-upload-pack.exe
Delete $INSTDIR\bin\git-var.exe
Delete $INSTDIR\bin\git-verify-pack.exe
Delete $INSTDIR\bin\git-verify-tag.exe
Delete $INSTDIR\bin\git-whatchanged.exe
Delete $INSTDIR\bin\git-write-tree.exe
Delete $INSTDIR\bin\git.exe
Delete $INSTDIR\bin\git-add.exe
Delete $INSTDIR\bin\git-annotate.exe
Delete $INSTDIR\bin\git-apply.exe
Delete $INSTDIR\bin\git-archive.exe
Delete $INSTDIR\bin\git-bisect--helper.exe
Delete $INSTDIR\bin\git-blame.exe
Delete $INSTDIR\bin\git-branch.exe
Delete $INSTDIR\bin\git-bundle.exe
Delete $INSTDIR\bin\git-cat-file.exe
Delete $INSTDIR\bin\git-check-attr.exe
Delete $INSTDIR\bin\git-checkout.exe
Delete $INSTDIR\bin\git-checkout-index.exe
Delete $INSTDIR\bin\git-check-ref-format.exe
Delete $INSTDIR\bin\git-cherry.exe
Delete $INSTDIR\bin\git-cherry-pick.exe
Delete $INSTDIR\bin\git-clean.exe
Delete $INSTDIR\bin\git-clone.exe
Delete $INSTDIR\bin\git-commit.exe
Delete $INSTDIR\bin\git-commit-tree.exe
Delete $INSTDIR\bin\git-config.exe
Delete $INSTDIR\bin\git-count-objects.exe
Delete $INSTDIR\bin\git-daemon.exe
Delete $INSTDIR\bin\git-describe.exe
Delete $INSTDIR\bin\git-diff.exe
Delete $INSTDIR\bin\git-diff-files.exe
Delete $INSTDIR\bin\git-diff-index.exe
Delete $INSTDIR\bin\git-gc.exe
Delete $INSTDIR\bin\git-diff-tree.exe
Delete $INSTDIR\bin\git-fast-export.exe
Delete $INSTDIR\bin\git-fast-import.exe
Delete $INSTDIR\bin\git-fetch.exe
Delete $INSTDIR\bin\git-fetch-pack.exe
Delete $INSTDIR\bin\git-fmt-merge-msg.exe
Delete $INSTDIR\bin\git-for-each-ref.exe
Delete $INSTDIR\bin\git-format-patch.exe
Delete $INSTDIR\bin\git-fsck.exe
Delete $INSTDIR\bin\git-fsck-objects.exe
Delete $INSTDIR\bin\git-get-tar-commit-id.exe
Delete $INSTDIR\bin\git-grep.exe
Delete $INSTDIR\bin\git-hash-object.exe
Delete $INSTDIR\bin\git-help.exe
Delete $INSTDIR\bin\git-http-backend.exe
Delete $INSTDIR\bin\git-imap-send.exe
Delete $INSTDIR\bin\git-index-pack.exe
Delete $INSTDIR\bin\git-init.exe
Delete $INSTDIR\bin\git-init-db.exe
Delete $INSTDIR\bin\git-log.exe
Delete $INSTDIR\bin\git-ls-files.exe
Delete $INSTDIR\bin\git-ls-remote.exe
Delete $INSTDIR\bin\git-ls-tree.exe
Delete $INSTDIR\bin\git-mailinfo.exe
Delete $INSTDIR\bin\git-mailsplit.exe
Delete $INSTDIR\bin\git-merge.exe
Delete $INSTDIR\bin\git-merge-base.exe
Delete $INSTDIR\bin\git-merge-file.exe
Delete $INSTDIR\bin\git-merge-index.exe
Delete $INSTDIR\bin\git-merge-ours.exe
Delete $INSTDIR\bin\git-merge-recursive.exe
Delete $INSTDIR\bin\git-merge-subtree.exe
Delete $INSTDIR\bin\git-merge-tree.exe
Delete $INSTDIR\bin\git-mktag.exe
Delete $INSTDIR\bin\git-mktree.exe
Delete $INSTDIR\bin\git-mv.exe
Delete $INSTDIR\bin\git-name-rev.exe
Delete $INSTDIR\bin\git-notes.exe
Delete $INSTDIR\bin\git-pack-objects.exe
Delete $INSTDIR\bin\git-pack-redundant.exe
Delete $INSTDIR\bin\git-pack-refs.exe
Delete $INSTDIR\bin\git-patch-id.exe
Delete $INSTDIR\bin\git-peek-remote.exe
Delete $INSTDIR\bin\git-prune.exe
Delete $INSTDIR\bin\git-prune-packed.exe
Delete $INSTDIR\bin\git-push.exe
Delete $INSTDIR\bin\git-read-tree.exe
Delete $INSTDIR\bin\git-receive-pack.exe
Delete $INSTDIR\bin\git-reflog.exe
Delete $INSTDIR\bin\git-remote.exe
Delete $INSTDIR\bin\git-remote-ext.exe
Delete $INSTDIR\bin\git-remote-fd.exe
Delete $INSTDIR\bin\git-replace.exe
Delete $INSTDIR\bin\git-repo-config.exe
Delete $INSTDIR\bin\git-rerere.exe
Delete $INSTDIR\bin\git-rm.exe
Delete $INSTDIR\bin\git-reset.exe
Delete $INSTDIR\bin\git-revert.exe
Delete $INSTDIR\bin\git-rev-list.exe
Delete $INSTDIR\bin\git-rev-parse.exe
Delete $INSTDIR\bin\git-send-pack.exe
Delete $INSTDIR\bin\git-shell.exe
Delete $INSTDIR\bin\git-shortlog.exe
Delete $INSTDIR\bin\git-show.exe
Delete $INSTDIR\bin\git-show-branch.exe
Delete $INSTDIR\bin\git-show-index.exe
Delete $INSTDIR\bin\git-show-ref.exe
Delete $INSTDIR\bin\git-stage.exe
Delete $INSTDIR\bin\git-status.exe
Delete $INSTDIR\bin\git-stripspace.exe
Delete $INSTDIR\bin\git-symbolic-ref.exe
Delete $INSTDIR\bin\git-tag.exe
Delete $INSTDIR\bin\git-tar-tree.exe
Delete $INSTDIR\bin\git-unpack-file.exe
Delete $INSTDIR\bin\git-unpack-objects.exe
Delete $INSTDIR\bin\git-update-index.exe
		
FunctionEnd

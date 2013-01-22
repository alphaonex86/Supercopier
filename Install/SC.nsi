!include Library.nsh
!define LIBRARY_X64
!define LIBRARY_SHELL_EXTENSION
!define LIBRARY_COM

SetCompressor /FINAL /SOLID lzma

; The name of the installer
Name "SuperCopier"

Icon "SuperCopier.ico"

; The file to write
OutFile "SuperCopier-setup.exe"

; The default installation directory
InstallDir $PROGRAMFILES\SuperCopier

XPStyle on
RequestExecutionLevel admin

BrandingText "-= Supercopier =-"

;--------------------------------

Page components
Page directory
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

; First is default
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\French.nlf"

; A LangString for the section name
LangString Sec1Name ${LANG_ENGLISH} "SuperCopier (required)"
LangString Sec1Name ${LANG_FRENCH} "SuperCopier (requis)"
LangString Sec2Name ${LANG_ENGLISH} "Start menu shortcuts"
LangString Sec2Name ${LANG_FRENCH} "Raccourcis dans le menu démarrer"
LangString Sec3Name ${LANG_ENGLISH} "Start when windows starts"
LangString Sec3Name ${LANG_FRENCH} "Démarrer quand windows démarre"
LangString Sec4Name ${LANG_ENGLISH} "Start when install finishes"
LangString Sec4Name ${LANG_FRENCH} "Démarrer à la fin de l'installation"
LangString Sec5Name ${LANG_ENGLISH} "Open README when install finishes"
LangString Sec5Name ${LANG_FRENCH} "Ouvrir le README à la fin de l'installation"
LangString Sec6Name ${LANG_ENGLISH} "Register shell extension (recommended)"
LangString Sec6Name ${LANG_FRENCH} "Enregistrer l'extension du shell (recommandé)"

LangString UninstSC1 ${LANG_ENGLISH} "You must uninstall SuperCopier 1 before installing SuperCopier, would you like to uninstall it?"
LangString UninstSC1 ${LANG_FRENCH} "Vous devez désinstaller SuperCopier 1 avant d'installer SuperCopier, voulez-vous le désinstaller?"
LangString UninstSC1Confirm ${LANG_ENGLISH} "Do you want to force SuperCopier install ? (not recommended !)"
LangString UninstSC1Confirm ${LANG_FRENCH} "Voulez-vous forcer l'installation de SuperCopier ? (non recommandé !)"

LangString MenuAccess ${LANG_ENGLISH} "Menu access"
LangString MenuAccess ${LANG_FRENCH} "Accéder au menu"
LangString UninstSC2 ${LANG_ENGLISH} "Uninstall SuperCopier"
LangString UninstSC2 ${LANG_FRENCH} "Désinstaller SuperCopier"
LangString README ${LANG_ENGLISH} "README"
LangString README ${LANG_FRENCH} "README"

Section $(Sec1Name)

  SectionIn RO

  ; désinstallation SC1
  ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier" "DisplayName"
  StrCmp $0 "SuperCopier"  0 SC1NotInstalled
    MessageBox MB_YESNO $(UninstSC1) IDYES UninstSC1
      MessageBox MB_YESNO $(UninstSC1Confirm) IDYES SC1NotInstalled
      Quit
    UninstSC1:
      ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier" "UninstallString"
      Exec $0
  SC1NotInstalled:

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR\Languages

  ; Put file there
  File /r Languages\*

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

  ; Put file there
  File SuperCopier.exe
  File README.txt
  File SCShellExt.dll
  File SCShellExt64.dll

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier" "DisplayName" "SuperCopier"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier" "UninstallString" '"$INSTDIR\SC2Uninst.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier" "NoRepair" 1
  WriteUninstaller "SC2Uninst.exe"

SectionEnd ; end the section


Section $(Sec6Name)
  RegDLL $INSTDIR\SCShellExt.dll
  !insertmacro InstallLib REGDLL NOTSHARED NOREBOOT_PROTECTED SCShellExt64.dll $INSTDIR\SCShellExt64.dll $INSTDIR
SectionEnd

Section $(Sec2Name)
  Delete "$SMPROGRAMS\SuperCopier\*.*"

  SetShellVarContext current

  CreateDirectory "$SMPROGRAMS\SuperCopier"

  CreateShortCut "$SMPROGRAMS\SuperCopier\SuperCopier.lnk" "$INSTDIR\SuperCopier.exe" "" "$INSTDIR\SuperCopier.exe" 0

  CreateShortCut "$SMPROGRAMS\SuperCopier\$(MenuAccess).lnk" "$INSTDIR\SC2Config.exe" "" "$INSTDIR\SC2Config.exe" 0

  CreateShortCut "$SMPROGRAMS\SuperCopier\$(README).lnk" "$INSTDIR\$(README).txt" "" "$INSTDIR\$(README).txt" 0
  CreateShortCut "$SMPROGRAMS\SuperCopier\$(UninstSC2).lnk" "$INSTDIR\SC2Uninst.exe" "" "$INSTDIR\SC2Uninst.exe" 0
SectionEnd ; end the section

Section $(Sec3Name)
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "SuperCopier.exe" "$INSTDIR\SuperCopier.exe"
SectionEnd ; end the section

Section $(Sec4Name)
  StrCpy $9 "exec"
SectionEnd ; end the section

Section $(Sec5Name)
  StrCpy $8 "README"
SectionEnd ; end the section

Section "Uninstall"

  FindWindow $R0 "" "SuperCopier MainForm"
  IntCmp $R0 0 NotLaunched2
  SendMessage $R0 16 0 0  ; WM_CLOSE

  CloseLoop:
    Sleep 200
    FindWindow $R0 "" "SuperCopier MainForm"
    IntCmp $R0 0 NotLaunched2
    DetailPrint "Waiting SC2 Close..."
    GoTo CloseLoop

  NotLaunched2:


  ; Remove registry keys
  DeleteRegKey HKCU "Software\Supercopier\SuperCopier"
  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "SuperCopier.exe"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SuperCopier"

  UnRegDLL $INSTDIR\SCShellExt.dll

  !insertmacro UnInstallLib REGDLL NOTSHARED NOREBOOT_PROTECTED .$INSTDIR\SCShellExt64.dll

  ; Remove files and uninstaller
  RMDir /r $INSTDIR\Languages
  Delete $INSTDIR\SuperCopier.exe
  Delete /REBOOTOK $INSTDIR\SCShellExt.dll
  Delete /REBOOTOK $INSTDIR\SCShellExt64.dll
  Delete $INSTDIR\README.txt
  Delete $INSTDIR\SC2Uninst.exe

  SetShellVarContext current

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\SuperCopier\*.*"

  ; Remove directories used
  RMDir "$SMPROGRAMS\SuperCopier"
  RMDir "$INSTDIR\Languages"
  RMDir /REBOOTOK "$INSTDIR"

SectionEnd

Function .onInit

	;Language selection dialog

	Push ""
	Push ${LANG_ENGLISH}
	Push English
	Push ${LANG_FRENCH}
	Push Français
	Push A ; A means auto count languages
	       ; for the auto count to work the first empty push (Push "") must remain

  IfSilent NoLang

	LangDLL::LangDialog "Installer Language" "Please select the language of the installer"

 	Pop $LANGUAGE
	StrCmp $LANGUAGE "cancel" 0 +2
		Abort

	NoLang:

  ; fermeture de supercopier 1 & 2

  FindWindow $R0 "" "SCHiddenFormStarted"
  IntCmp $R0 0 NotLaunched1
  SendMessage $R0 16 0 0  ; WM_CLOSE
  NotLaunched1:

  FindWindow $R0 "" "SuperCopier MainForm"
  IntCmp $R0 0 NotLaunched2
  SendMessage $R0 16 0 0  ; WM_CLOSE
  NotLaunched2:


FunctionEnd

Function .onInstSuccess
  ; lancement

  IfSilent NoLaunch

  StrCmp $9 "exec" Good NoGood
  Good:
      Exec $INSTDIR\SuperCopier.exe
  NoGood:

  StrCmp $8 "README" Good2 NoGood2
  Good2:
    IntCmp $LANGUAGE ${LANG_FRENCH} RMFr
    ExecShell open $INSTDIR\README.txt
    GoTo NoGood2
    RMFr:
    ExecShell open $INSTDIR\README.txt
  NoGood2:

  NoLaunch:

FunctionEnd

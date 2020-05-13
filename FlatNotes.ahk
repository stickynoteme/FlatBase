;-------------------------------------------------
;Inialize FlateNotes AHK v1
;-------------------------------------------------
#SingleInstance Force
FileEncoding ,UTF-8
CoordMode, mouse, Screen
SetBatchLines, -1
;-------------------------------------------------
;Setup Tray Menu
;-------------------------------------------------
Menu, Tray, NoStandard
Menu, Tray, Add 
Menu, Tray, Add, Library
Menu, Tray, Add, About
Menu, Tray, Add, Options
Menu, Tray, Add, Exit
Menu, Tray, Default, Library
;-------------------------------------------------
;Set up script global variables
;-------------------------------------------------
global CheckForOldNote 
global FileList = ""
global FileSafeClipBoard
global FileSafeName
global LV
global MyNotesArray := {}
global OldNoteData
global QuickNoteBody
global QuickNoteName
global U_MBG
global U_MFC
global U_SBG
global U_SFC
global UseCapslock
global U_Capslock
global fake
global iniPath
global sendCtrlC

iniPath = %A_WorkingDir%\settings.ini
IniRead, U_NotePath, %iniPath%, General, MyNotePath,%A_WorkingDir%\MyNotes\

if (FileExist(U_NotePath)) {
	if (U_NotePath = "") {
	U_NotePath = %A_WorkingDir%\MyNotes\
	FileCreateDir, MyNotes
	}
	}else {
		msgbox Notes folder: %U_NotePath% could not be found. %A_WorkingDir%\MyNotes\ will be used instead.
		FileCreateDir, MyNotes
		IniWrite, %A_WorkingDir%\MyNotes\, %iniPath%, General, MyNotePath
		U_NotePath = %A_WorkingDir%\MyNotes\
}

global U_NotePath
;-------------------------------------------------
;Set Default hotkeys if blank
;-------------------------------------------------


;-------------------------------------------------
; Read ini file or set defualts
;-------------------------------------------------
IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
IniRead, U_Capslock, %iniPath%, General, UserSetKey , 1
IniRead, sendCtrlC, %iniPath%, General, sendCtrlC, 1
;-------------------------------------------------
;Acitvate User Hotkeys if any
;-------------------------------------------------
SetUserHotKeys()
;-------------------------------------------------
;Use Capslock if users has not changed the main window hotkey
;-------------------------------------------------
vk14::
{
if (U_Capslock = "0"){
	vk14::vk14
	return
}
BuildGUI1()
return
}
;-------------------------------------------------
;Include external ahk  
;-------------------------------------------------
#Include functions.ahk
#Include shortcuts.ahk
;-!- Return after fucntions so lables don't get exacuted
return
#Include lables.ahk






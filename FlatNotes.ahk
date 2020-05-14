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
global U_MSFC
global U_FBCA
global UseCapslock
global U_Capslock
global fake
global iniPath
global sendCtrlC
global SortBody
global SortName
global SortAdded
global NextSortAdded
global NextSortBody
global NextSortName
global rowSelectColor
global rowSelectTextColor
;Pre-set globals
global LibW
global ReR
global PreR
global FontFamily 
global FontSize


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
; Read and/or set Colors
;-------------------------------------------------
IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000 ;Everything else
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff ;Details background
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff ;Result and preview
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000 ; Details font
IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor , ffffff ;Main Sort Font
IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor , 777700 ;search box font
IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor , 0x444444 ;Row Select color
IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor , 0xffffff ;Row Select Text color

;-------------------------------------------------
; Read and/or set Sizing, Font, & Other
;-------------------------------------------------
IniRead, FontFamily, %iniPath%, General, FontFamily ,Verdana
IniRead, FontSize, %iniPath%, General, FontSize ,10
IniRead, PreR, %iniPath%, General, PreviewRows ,8
IniRead, ReR, %iniPath%, General, ResultRows ,8
IniRead, LibW, %iniPath%, General, WindowWidth ,530
IniRead, U_Capslock, %iniPath%, General, UseCapsLock , 1
IniRead, sendCtrlC, %iniPath%, General, sendCtrlC, 1
;-------------------------------------------------
;Write ini if not found
;-------------------------------------------------
IniRead, isFristRun, %iniPath%, General, isFristRun,1
if (isFristRun = "1") {
	IniWrite, Vendana,%iniPath%,General,FontFamily
	IniWrite, 10,%iniPath%,General,FontSize
	IniWrite, 8,%iniPath%,General,PreviewRows
	IniWrite, 8,%iniPath%,General,ResultRows
	IniWrite, 530,%iniPath%,General,WindowWidth
	IniWrite, 000000,%iniPath%,Colors,MainBackgroundColor
	IniWrite, ffffff,%iniPath%,Colors,SubBackgroundColor
	IniWrite, ffffff,%iniPath%,Colors,MainFontColor
	IniWrite, 000000,%iniPath%,Colors,SubFontColor
	IniWrite, ffffff,%iniPath%,Colors,MainSortFontColor
	IniWrite, 777700,%iniPath%,Colors,SearchBoxFontColor
	IniWrite, 0x444444,%iniPath%,Colors,RowSelectColor
	IniWrite, 0xffffff,%iniPath%,Colors,RowSelectTextColor
	IniWrite, 1,%iniPath%,General,UseCapsLock
	IniWrite, 1,%iniPath%,General,sendCtrlC
}
;-------------------------------------------------
;Set Globals that need values from the ini
;-------------------------------------------------
global SubW := LibW-10	
global libWAdjust := LibW+10
global ColAdjust := LibW-95
global NameColW := Round(ColAdjust*0.4)
global BodyColW := Round(ColAdjust*0.6)
global NameColAndBodyCOlW := NameColW+BodyColW
;-------------------------------------------------
;Acitvate User Hotkeys if any
;-------------------------------------------------
SetUserHotKeys()
goto Options
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
#Include Class_LV_Colors.ahk
;-!- Return after fucntions so lables don't get exacuted
return
#Include lables.ahk






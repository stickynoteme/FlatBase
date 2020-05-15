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
global themePath
global sendCtrlC
global SortBody
global SortName
global SortAdded
global NextSortAdded
global NextSortBody
global NextSortName
global rowSelectColor
global rowSelectTextColor
global QuickNoteWidth
;Pre-set globals
global LibW
global PreviewRows
global ResultRows
global QuickNoteRows
global FontFamily 
global FontSize
global ResultFontFamily
global ResultFontSize
global PreviewFontFamily
global PreviewFontSize
global SearchFontFamily
global SearchFontSize
global FontRendering

iniPath = %A_WorkingDir%\settings.ini
themePath = %A_WorkingDir%\Themes
IniRead, U_NotePath, %iniPath%, General, MyNotePath,%A_WorkingDir%\MyNotes\

if (FileExist(U_NotePath)) {
	if (U_NotePath = "") {
	U_NotePath = %A_WorkingDir%\MyNotes\
	FileCreateDir, MyNotes
	}
	if (U_NotePath ="\"){
	U_NotePath = %A_WorkingDir%\MyNotes\
	FileCreateDir, MyNotes
	}else {
		msgbox Notes folder: %U_NotePath% could not be found. %A_WorkingDir%\MyNotes\ will be used instead.
		FileCreateDir, MyNotes
		IniWrite, %A_WorkingDir%\MyNotes\, %iniPath%, General, MyNotePath
		U_NotePath = %A_WorkingDir%\MyNotes\
	}
}

global U_NotePath
;-------------------------------------------------
;Set Default hotkeys if blank
;-------------------------------------------------

;-------------------------------------------------
;Write default theme ini if not found
;-------------------------------------------------
IniRead, isFristRun, %iniPath%, General, isFristRun,1
if (isFristRun = "1") {
	pathToTheme = %A_WorkingDir%\Themes\Black.ini
	
	IniRead, U_MBG, %pathToTheme%, Colors, MainBackgroundColor
	IniRead, U_SBG, %pathToTheme%, Colors, SubBackgroundColor
	IniRead, U_MFC, %pathToTheme%, Colors, MainFontColor
	IniRead, U_SFC, %pathToTheme%, Colors, SubFontColor
	IniRead, U_MSFC, %pathToTheme%, Colors, MainSortFontColor
	IniRead, U_FBCA, %pathToTheme%, Colors, SearchBoxFontColor
	IniRead, rowSelectColor, %pathToTheme%, Colors, RowSelectColor
	IniRead, rowSelectTextColor, %pathToTheme%, Colors, RowSelectTextColor
	IniRead, themeNumber, %pathToTheme%, Theme, UserSetting
	
	IniWrite, %U_MBG%,%iniPath%,Colors,MainBackgroundColor
	IniWrite, %U_SBG%,%iniPath%,Colors,SubBackgroundColor
	IniWrite, %U_MFC%,%iniPath%,Colors,MainFontColor
	IniWrite, %U_SFC%,%iniPath%,Colors,SubFontColor
	IniWrite, %U_MSFC%,%iniPath%,Colors,MainSortFontColor
	IniWrite, %U_FBCA%,%iniPath%,Colors,SearchBoxFontColor
	IniWrite, %rowSelectColor%,%iniPath%,Colors,RowSelectColor
	IniWrite, %rowSelectTextColor%,%iniPath%,Colors,RowSelectTextColor
	IniWrite, %themeNumber%, %iniPath%, Theme, UserSetting
	IniWrite, 0, %iniPath%, General, isFristRun
}
;-------------------------------------------------
; Read and/or set Colors
;-------------------------------------------------
IniRead, U_Theme, %iniPath%, Theme, UserSetting , Black
IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000 ;Everything else
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff ;Details background
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff ;Result and preview
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000 ; Details font
IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor , 777700 ;Main Sort Font
IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor , ffffff ;search box font
IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor , 0x444444 ;Row Select color
IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor , 0xffffff ;Row Select Text color

;-------------------------------------------------
; Read and/or set Sizing, Font, & Other
;-------------------------------------------------
IniRead, QuickNoteWidth,%iniPath%, General,QuickNoteWidth,500
IniRead, FontRendering,%iniPath%, General,FontRendering,5
IniRead, FontFamily, %iniPath%, General, FontFamily ,Verdana
IniRead, FontSize, %iniPath%, General, FontSize ,10

IniRead, SearchFontFamily, %iniPath%, General, SearchFontFamily ,Verdana
IniRead, SearchFontSize, %iniPath%, General, SearchFontSize ,10 

IniRead, ResultFontFamily, %iniPath%, General, ResultFontFamily ,Verdana
IniRead, ResultFontSize, %iniPath%, General, ResultFontSize ,10

IniRead, PreviewFontFamily, %iniPath%, General, PreviewFontFamily ,Verdana
IniRead, PreviewFontSize, %iniPath%, General, PreviewFontSize ,10

IniRead, PreviewRows, %iniPath%, General, PreviewRows ,8
IniRead, ResultRows, %iniPath%, General, ResultRows ,8
IniRead, QuickNoteRows, %iniPath%, General, QuickNoteRows ,7
IniRead, LibW, %iniPath%, General, WindowWidth ,530
IniRead, U_Capslock, %iniPath%, General, UseCapsLock , 1
IniRead, sendCtrlC, %iniPath%, General, sendCtrlC, 1

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
;BuildGUI1()
;goto Options
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






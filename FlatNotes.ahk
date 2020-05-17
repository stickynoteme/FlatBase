;-------------------------------------------------
;Inialize FlateNotes AHK v1
;-------------------------------------------------
#SingleInstance Force
FileEncoding ,UTF-8
CoordMode, mouse, Screen
SetBatchLines, -1
DetectHiddenWindows, On

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
global fake2
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
global LB1
global LB2
global isfake
global PB_Name
global PB_Add
global PB_Mod
global NamePercent
global BodyPercent
global AddedPercent
global oNamePercent
global oBodyPercent
global oAddedPercent 
global ShowStatusBar
global StatusBarM
global StatusBarA
global Fake
global SaveMod
global TitelBar
global StatusBarCount
global StatusBar
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
global detailsPath
global HideScrollbars
global backupsToKeep
global g1Open
global g1ID
global isStarting
global TotalNotes
;Var with starting values
global istitle = yes


FileCreateDir, NoteDetails
detailsPath := A_WorkingDir "\NoteDetails\"
iniPath = %A_WorkingDir%\settings.ini
themePath = %A_WorkingDir%\Themes
IniRead, U_NotePath, %iniPath%, General, MyNotePath,%A_WorkingDir%\MyNotes\

if InStr(FileExist(U_NotePath), "D") {
	if (U_NotePath = "") {
	U_NotePath = %A_WorkingDir%\MyNotes\
	FileCreateDir, MyNotes
	}
	if (U_NotePath ="\"){
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
;Write default theme ini if not found
;-------------------------------------------------
IniRead, isFristRun, %iniPath%, General, isFristRun,1
if (isFristRun = "1") {
	IniWrite, 0, %iniPath%, General, isFristRun
}
;-------------------------------------------------
; Read from theme .ini 
;-------------------------------------------------
IniRead, StartingTheme, %iniPath%, Theme, Name, Black
StartingTheme = %A_WorkingDir%\Themes\%StartingTheme%.ini


IniRead, U_Theme, %StartingTheme%, Theme, UserSetting , Black
IniRead, U_MBG, %StartingTheme%, Colors, MainBackgroundColor , 000000 ;Everything else
IniRead, U_SBG, %StartingTheme%, Colors, SubBackgroundColor , ffffff ;Details background
IniRead, U_MFC, %StartingTheme%, Colors, MainFontColor , ffffff ;Result and preview
IniRead, U_SFC, %StartingTheme%, Colors, SubFontColor , 000000 ; Details font
IniRead, U_MSFC, %StartingTheme%, Colors, MainSortFontColor , 777700 ;Main Sort Font
IniRead, U_FBCA, %StartingTheme%, Colors, SearchBoxFontColor , ffffff ;search box font
IniRead, rowSelectColor, %StartingTheme%, Colors, RowSelectColor , 0x444444 ;Row Select color
IniRead, rowSelectTextColor, %StartingTheme%, Colors, RowSelectTextColor , 0xffffff ;Row Select Text color

;-------------------------------------------------
; Read and from settings.ini
;-------------------------------------------------
IniRead, QuickNoteWidth,%iniPath%, General,QuickNoteWidth,500
IniRead, ShowStatusBar,%iniPath%, General,ShowStatusBar,1
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

IniRead, oNamePercent,%iniPath%, General,NamePercent,30
IniRead, oBodyPercent,%iniPath%, General,BodyPercent,55
IniRead, oAddedPercent,%iniPath%, General,AddedPercent,15
NamePercent = 0.%oNamePercent%
BodyPercent = 0.%oBodyPercent%
AddedPercent = 0.%oAddedPercent%

IniRead, HideScrollbars,%iniPath%,General,HideScrollbars,1
IniRead, backupsToKeep,%iniPath%,General,backupsToKeep,3

;-------------------------------------------------
;Set Globals that need values from the ini
;-------------------------------------------------
global 	SubW := LibW
global libWColAdjust :=round(LibW*.97)
global libWAdjust := LibW
if (HideScrollbars = 1){
	libWAdjust := LibW+10
	SubW := LibW-10
	}
;global ColAdjust := LibW-95
global NameColW := Round(libWColAdjust*NamePercent)
global BodyColW := Round(libWColAdjust*BodyPercent)
global AddColW := Round(libWColAdjust*AddedPercent)
global NameColAndBodyCOlW := NameColW+BodyColW
;-------------------------------------------------
;Acitvate User Hotkeys if any & make INI for new files
;-------------------------------------------------
isStarting = 1
Progress, 0, Setting Hotkeys
SetUserHotKeys()
Progress, 5,  Adding new notes
MakeAnyMissingINI()
Progress, 10, Removing data for deleted notes
RemoveINIsOfMissingTXT()
Progress, 15, Backing up your notes
BackupNotes()
Progress, 20, Building note index
BuildGUI1()
Progress, 100, Done!
WinHide, FlatNotes - Library
Progress, Off
isStarting = 0

WinShow, ahk_id %g1ID%
;goto Options
;-------------------------------------------------
;Use Capslock if users has not changed the main window hotkey
;-------------------------------------------------
!w::
{
goto Options
}
vk14::
{
if (U_Capslock = "0"){
	vk14::vk14
	return
}
if (g1Open=1) {
	WinHide, FlatNotes - Library
	g1Open=0
	return
}
if (g1Open=0) {
	MouseGetPos, xPos, yPos	
	xPos /= 1.5
	yPos /= 1.5
	WinMove, ahk_id %g1ID%, , %xPos%, %yPos%
	WinShow, ahk_id %g1ID%
	WinRestore, ahk_id %g1ID%
	WinActivate, ahk_id %g1ID%
	g1Open=1
	ControlFocus,Edit1,FlatNotes - Library
	sendinput {left}{right}
	return
}
return
}
;-------------------------------------------------
;playground 
;-------------------------------------------------


;-------------------------------------------------
;Include external ahk  
;-------------------------------------------------
#Include functions.ahk
#Include shortcuts.ahk
#Include Class_LV_Colors.ahk
;-!- Return after fucntions so lables don't get exacuted
return
#Include lables.ahk






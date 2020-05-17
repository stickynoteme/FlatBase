Label1:
{
	if (U_Capslock = "1"){
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
	return
}
}
Label2:
{
	IniRead,sendCtrlC,%iniPath%,General,sendCtrlC, 1
	if (sendCtrlC="1")
		send {Ctrl Down}{c}{Ctrl up}
		clipboard := clipboard

BuildGUI2()

GuiControl,, QuickNoteName,%clipboard%
GuiControl,, FileSafeName,%FileSafeClipBoard%
GuiControl, +Redraw, FileSafeName
GuiControl, +Redraw, QuickNoteName
ControlFocus, Edit2, FlatNote - QuickNote 
if (OldNoteData !="")
{
	FilePath = %U_NotePath%%FileSafeClipBoard%.txt
	FileRead, MyFile, %FilePath%
	GuiControl,, QuickNoteBody,%MyNewFile%
	GuiControl, +Redraw, QuickNoteBody
}
return
}
Label3:
{
	if(istitle != "no") {
			send {Ctrl Down}{c}{Ctrl up}
			ztitle := clipboard
			istitle = no
			;only first line for title to prevent fail
			Loop, parse, clipboard, `n, `r
				{
					%A_Index%ztitle = %A_LoopField%
					if (A_Index = 2)
						break
				}
			;trim space and tab
			ztitle := Trim(1ztitle," 	")
			tooltip T: %ztitle%
			settimer, KillToolTip, -500
			return
	}
	else if(istitle = "no") {
			send {Ctrl Down}{c}{Ctrl up}
			zbody := clipboard 
			istitle = yes
			TmpFileSafeName := RegExReplace(ztitle, "\*|\?|\\|\||/|""|:|<|>" , Replacement := "_")
			FileReadLine, CheckExists, %U_NotePath%%TmpFileSafeName%.txt, 1
			if (CheckExists !="")
			{
				 msgbox Note Already Exists
				 return
			}
			SaveFile(ztitle,TmpFileSafeName,zbody,0)
			;MakeFileList(1)
			if WinActive("FlatNotes - Library")
				send {space}{backspace} ;update results
			tooltip B: %zbody%
			settimer, KillToolTip, -500
			return
	}
return
}
Label4:
{
	istitle = yes
	tooltip cancled
	settimer,KillToolTip,-1000
	return 
}
SaveButton:
{
	GuiControlGet,FileSafeName,,FileSafeName
	if (QuickNoteName == ""){
		MsgBox Note Name Can Not Be Empty
	return
	}
	Gui, 2:Submit
	SaveMod = 0
	IfExist, %U_NotePath%%FileSafeName%.txt
		SaveMod = 1
	SaveFile(QuickNoteName,FileSafeName,QuickNoteBody,SaveMod)
	;horrible fix to LV to update
	GuiControlGet,SearchTerm
	GuiControl,1: , SearchTerm, _
	GuiControl,1: , SearchTerm,
	if WinActive("FlatNotes - Library")
		send {space}{backspace} ;update results
	tooltip Saved
	settimer, KillToolTip, -500
	return
}

QuickSafeNameUpdate:
{
	GuiControlGet, QuickNoteName
	;Remove stray whitespace from front and back
	;QuickNoteName := Ltrim(QuickNoteName," ")
	;QuickNoteName := Rtrim(QuickNoteName," ")
	NewFileSafeName := RegExReplace(QuickNoteName, "\*|\?|\\|\||/|""|:|<|>" , Replacement := "_")
	GuiControl,, FileSafeName,%NewFileSafeName%
	return
}
Search:
{
	
	global SearchTerm
	GuiControlGet, SearchTerm
	GuiControl, -Redraw, LV
	LV_Delete()
	If (InStr(SearchTerm, "$$") != 0) {
		SearchTerm := StrReplace(SearchTerm, "$$" , "")
		For Each, Note In MyNotesArray
		{
		  If (SearchTerm != "")
		  {
			If (InStr(Note.1, SearchTerm) != 0){
			 LV_Add("", Note.1, Note.2,Note.3,Note.4)
			   }
			}
			Else
			  LV_Add("", Note.1,Note.2,Note.3,Note.4)
		}
	GuiControl, +Redraw, LV
	return
	}
	
	For Each, Note In MyNotesArray
	{
	   If (SearchTerm != "")
	   {
			If (InStr(Note.1, SearchTerm) != 0){
			 LV_Add("", Note.1, Note.2,Note.3,Note.4)
			}Else if (InStr(Note.2, SearchTerm) != 0)
		   {LV_Add("", Note.1, Note.2,Note.3,Note.4)
		   }Else if (InStr(Note.3, SearchTerm) != 0)
		   {LV_Add("", Note.1, Note.2,Note.3,Note.4)
		   }Else if (InStr(Note.4, SearchTerm) != 0)
		   {LV_Add("", Note.1, Note.2,Note.3,Note.4)
		   }
	   }
	   Else
		  LV_Add("", Note.1,Note.2,Note.3,Note.4)
	}
Items := LV_GetCount()
if (Items != 0) {
	LV_GetText(LastResultName, 1 , 1)
	LV_GetText(LastFileName, 1 , 4)
	LV_GetText(LastNoteAdded, 1 , 3)
	GuiControl,,TitleBar, %LastResultName%
	FileRead, LastResultBody,%U_NotePath%%LastFileName%
	LastNoteIni := StrReplace(LastFileName, ".txt",".ini") 
	iniRead,LastNoteModded,%detailsPath%%LastNoteIni%,INFO,Mod
	GuiControl,,PreviewBox, %LastResultBody%
	GuiControl,,StatusBarM,M: %LastNoteModded% 
	GuiControl,,StatusBarA,A: %LastNoteAdded%
	}else{
		GuiControl,,TitleBar, 
		GuiControl,,PreviewBox,
		GuiControl,,StatusBarM,M: 00\00\00 
		GuiControl,,StatusBarA,A: 00\00\00
	}
GuiControl,,StatusBarCount, %Items% of %TotalNotes%
GuiControl, +Redraw, LV
Return
}

KillToolTip:
{
   ToolTip
Return
}

UnDoom:
{
	Doom = 0
return
}
TitleBarClick:
{
	GuiControlGet, TitleBar
	tooltip %TitleBar%
	SetTimer, KillToolTip, -2000
	return
}

NoteListView:
{
Critical
 
; make arrow down from search feel right by avoiding the header.
if (A_GuiEvent == "F" && firstDown == "1" && A_EventInfo == "0"){
	send {down}{up}
	firstDown = 0
	Doom = 1
	SetTimer, UnDoom, -50
}
TotalItems := LV_GetCount()
if (A_EventInfo = TotalItems && Doom = 1 && A_GuiEvent = "Normal"){
	send {down}
}
;copy title on double click
if (A_GuiEvent = "DoubleClick")
{
    LV_GetText(RowText, A_EventInfo)  ; Get the text from the row's first field.
    clipboard = %RowText%
    ToolTip Text: "%RowText%" Copied to clipboard
    SetTimer, KillToolTip, -500
    WinHide, FlatNotes - Library
	g1Open=0
}
if (A_GuiEvent = "RightClick")
{
    LV_GetText(RowText, A_EventInfo)
    TmpFileSafeName := RegExReplace(RowText, "\*|\?|\\|\||/|""|:|<|>" , Replacement := "_")
    FilePath = %U_NotePath%%TmpFileSafeName%.txt
	FileRead, MyFile, %FilePath%
    clipboard = %NoteBody%
    ToolTip Text: "%RowText%" Copied to clipboard
    SetTimer, KillToolTip, -500
    WinHide, FlatNotes - Library
	g1Open=0
}
if (A_GuiEvent == "E") 
	LV_GetText(OldRowText, A_EventInfo,1)
if (A_GuiEvent == "e")
{
	LV_GetText(RowText, A_EventInfo,1)
	TmpFileSafeName := RegExReplace(RowText, "\*|\?|\\|\||/|""|:|<|>" , Replacement := "_")
	TmpOldFileSafeName := RegExReplace(OldRowText, "\*|\?|\\|\||/|""|:|<|>" , Replacement := "_")
	
	
	FilePath = %U_NotePath%%TmpFileSafeName%.txt
	OldFilePath = %U_NotePath%%TmpOldFileSafeName%.txt
	if FileExist(FilePath)
		{
			 msgbox Note With This Name Already Exists
			 LV_Modify(A_EventInfo, ,OldRowText)
			 return
		}
	FileRead, MyOldFile, %OldFilePath%
	FileRecycle,  %OldFilePath%
	FileRecycle,  %detailsPath%%TmpOldFileSafeName%.ini
	SaveFile(RowText,TmpFileSafeName,MyOldFile,0)
	MakeFileList(1)
	ReFreshLV()
	iniRead, NewAdd,%detailsPath%%TmpFileSafeName%.ini,INFO,Add
	iniRead, NewMod,%detailsPath%%TmpFileSafeName%.ini,INFO,Mod
	GuiControl,, TitleBar, %RowText%
	GuiControl,, StatusbarM,M: %NewMod%
	GuiControl,, StatusbarA,A: %NewAdd%
}
;update the preview
if (A_GuiEvent = "I" && InStr(ErrorLevel, "S", true))
{
	global LVSelectedROW = A_EventInfo
    LV_GetText(RowText, A_EventInfo,4)  ; Get the text from the row's first field.
    FileRead, NoteFile, %U_NotePath%%RowText%
	TMPini := StrReplace(RowText, ".txt", ".ini")
	TMPName := StrReplace(RowText, ".txt", "")
	iniRead, NoteAdd,%detailsPath%%TMPini%,INFO,Add
	iniRead, NoteMod,%detailsPath%%TMPini%,INFO,Mod
	GuiControl,, PreviewBox, %NoteFile%
	GuiControl,, TitleBar, %TMPName%
	GuiControl,, StatusbarM,M: %NoteMod%
	GuiControl,, StatusbarA,A: %NoteAdd%
}
return
}

About:
{
Gui, 4:add,text,,FlatNotes Version 2.0.0 May 2020
Gui, 4:Add,Link,,<a href="https://github.com/chaosdrop/FlatNotes">GitHub Page</a>
Gui, 4:add,button,g4GuiEscape,Close
Gui, 4:Show
return
}

Library:
{
    WinGetPos,,, Width, Height, ahk_id %g1ID%
	WinMove, ahk_id %g1ID%,, (A_ScreenWidth/2)-(Width/2), (A_ScreenHeight/2)-(Height/2)
	g1Open=1
	WinShow, ahk_id %g1ID%
	WinRestore, ahk_id %g1ID%
	return
}
CtrlCToggle:
{
	GuiControlGet, SetCtrlC
	if (SetCtrlC = 1)
		IniWrite, 1, %iniPath%, General, sendCtrlC
	if (SetCtrlC = 0)
		IniWrite, 0, %iniPath%, General, sendCtrlC
	return
}
UseCapslockToggle:
{
	GuiControlGet, UseCapslock
	
	if (UseCapslock = 1)
		GuiControl, Disable, msctls_hotkey321
	if (UseCapslock = 0)
		GuiControl, Enable, msctls_hotkey321
	if (A_GuiEvent == "Normal"){
		IniWrite,%UseCapslock%, %iniPath%, General, UserSetKey
		return
	}
return
}

ColorPicked:
{
	if (A_GuiEvent == "Normal"){	
		GuiControlGet, ColorPicked,,ColorChoice
		pathToTheme = %A_WorkingDir%\Themes\%ColorPicked%.ini
		
		IniRead, U_MBG, %pathToTheme%, Colors, MainBackgroundColor
		IniRead, U_SBG, %pathToTheme%, Colors, SubBackgroundColor
		IniRead, U_MFC, %pathToTheme%, Colors, MainFontColor
		IniRead, U_SFC, %pathToTheme%, Colors, SubFontColor
		IniRead, U_MSFC, %pathToTheme%, Colors, MainSortFontColor
		IniRead, U_FBCA, %pathToTheme%, Colors, SearchBoxFontColor
		IniRead, rowSelectColor, %pathToTheme%, Colors, RowSelectColor
		IniRead, rowSelectTextColor, %pathToTheme%, Colors, RowSelectTextColor
		IniRead, themeNumber, %pathToTheme%, Theme, UserSetting
		
		
		;save theme number
		IniWrite, %themeNumber%, %iniPath%, Theme, UserSetting
		
		;save theme name
		IniWrite, %ColorPicked%, %iniPath%, Theme, Name
		
	}
	gosub DummyGUI1
}

SortName:
	{
		if (NextSortName ="1") {
			LV_ModifyCol(1, "SortDesc")
			NextSortName = 0
			NextSortBody = 0
			NextSortAdded = 0
		}else {
			LV_ModifyCol(1, "Sort")
			NextSortName = 1
			NextSortBody = 0
			NextSortAdded = 0
			Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_MSFC%, %ResultFontFamily%, %U_SFC%
			GuiControl, Font, SortName
			Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_SFC%, %ResultFontFamily%, %U_SFC%
			GuiControl, Font, SortBody
			GuiControl, Font, SortAdded
			
		}
		return
	}
SortBody:
{
		if (NextSortBody ="1") {
			LV_ModifyCol(2, "SortDesc")
			NextSortBody = 0
			NextSortName = 0
			NextSortAdded = 0
		}else {
			LV_ModifyCol(2, "Sort")
			NextSortBody = 1
			NextSortName = 0
			NextSortAdded = 0
			Gui, Font, %FontSize% c%U_MSFC%, %FontFamily%
			GuiControl, Font, SortBody
			Gui, Font, %FontSize% c%U_SFC%, %FontFamily%
			GuiControl, Font, SortName
			GuiControl, Font, SortAdded
		}
		return
	}
SortAdded:
{
		if (NextSortAdded ="1") {
			LV_ModifyCol(3, "SortDesc")
			NextSortAdded = 0
			NextSortName = 0
			NextSortBody = 0
		}else {
			LV_ModifyCol(3, "Sort")
			NextSortAdded = 1
			NextSortName = 0
			NextSortBody = 0
			Gui, Font, %FontSize% c%U_MSFC%, %FontFamily%
			GuiControl, Font, SortAdded
			Gui, Font, %FontSize% c%U_SFC%, %FontFamily%
			GuiControl, Font, SortBody
			GuiControl, Font, SortName
		}
		return
	}
FolderSelect:
{
		WinSet, AlwaysOnTop, Off, FlatNotes - Options
		FileSelectFolder, NewNotesFolder, , 123
		if NewNotesFolder =
			GuiControl,,NotesStorageFolder,%U_NotePath%
		else
			GuiControl,,NotesStorageFolder,%NewNotesFolder%\
		IniWrite, %NewNotesFolder%\, %iniPath%, General, MyNotePath
		WinSet, AlwaysOnTop, On, FlatNotes - Options
		return
	}
Options:
{

Fontlist := "fontlist.cfg"
FileRead, FontFile, % Fontlist
FontOptionsArray := []
loop, parse, FontFile, `n
	FontOptionsArray.push(A_LoopField)
For k, fonts in FontOptionsArray
	FontDropDownOptions .= fonts "|"


		Gui, 3:New,,FlatNotes - Options
		Gui, 3:Add, Tab3,, General|Hotkeys|Appearance|Window Options
		Gui, 3:Tab, General
		Gui, 3:Add,Text,section, Notes storage folder:
		Gui, 3:Add,Edit, disabled r1 w300 vNotesStorageFolder, %U_NotePath%
		Gui, 3:Add,Button, gFolderSelect, Select a folder.
		
		Gui, 3:Add,Text,xs,How many daily backups to keep: (Default: 3)
		Gui, 3:Add,Edit, yp-5 x+5 w25
		Gui, 3:Add,UpDown,vbackupsToKeepSelect gSet_backupsToKeep range0-99, %backupsToKeep%
		Gui, 3:Add,CheckBox, xs vShowStatusBarSelect gSetShowStatusBar, Show Library Window Statusbar?
		GuiControl,,ShowStatusBarSelect,%ShowStatusBar%

		;Hotkeys Tab
		Gui, 3:Tab, Hotkeys
		Gui, 3:Add,CheckBox, vSetCtrlC gCtrlCToggle, Send Ctrl+C when using the quick note hotkey.
		Gui, 3:Add, CheckBox, vUseCapslock gUseCapslockToggle, Use Capslock for Library?
		GuiControl,,UseCapslock,%U_Capslock%
		GuiControl,,SetCtrlC,%sendCtrlC%
		Gui, 3:Add,text, h1 Disabled 			
 		
		HotkeyNames := ["Show Library Window","Quick New Note","Rapid Save","Cancel Rapid Save"]
		Loop,% 4 {
			HotkeyNameTmp := HotkeyNames[A_Index]
			Gui, 3:Add, Text, , Hotkey: %HotkeyNameTmp%
			IniRead, savedHK%A_Index%, settings.ini, Hotkeys, %A_Index%, %A_Space%
   
			StringReplace, noMods, savedHK%A_Index%, ~                  
			StringReplace, noMods, noMods, #,,UseErrorLevel              
			Gui, 3:Add, Hotkey, section vHK%A_Index% gLabel, %noMods%           
			Gui, 3:Add, CheckBox, x+5  vCB%A_Index% Checked%ErrorLevel%, Win
			Gui, 3:Add,text, h0 xs0 Disabled
		}                                                        
		if (U_Capslock = 1)
			GuiControl, Disable, msctls_hotkey321

		;Appearance Tab
		Gui, 3:Tab, Appearance
		Gui, 3:Add,Text,,Font Rendering: (5 = ClearType)
		Gui, Add, Edit 
		Gui, 3:Add,UpDown, vFontRenderingSelect gSetFontRendering Range0-5, %FontRendering%
		
		Gui, 3:Add, CheckBox, vHideScrollbarsSelect gSetHideScrollbars, Hide Scroolbars where possible.
		GuiControl,,HideScrollbarsSelect,%HideScrollbars%
		
		
		
		Gui, 3:Add,Text,,Theme Selection:
		Loop, Files, %themePath%\*.ini
		{
			themeFileList .= A_LoopFileName "|"
			IniWrite, %A_index%,%themePath%\%A_LoopFileName%,Theme,UserSetting
			themeList := StrReplace(themeFileList, ".ini" , "")
		}
		Gui, 3:Add,DropDownList, Choose%U_Theme% vColorChoice gColorPicked, %themeList%
		
		CurrentFont = 1
		C_PreventFont = 1
		C_ResultFont = 1
		C_SearchFont = 1
		for k, v in FontOptionsArray
		{ 
			if (v = FontFamily) 
				CurrentFont := k
		} 
		for k, v in FontOptionsArray
		{ 
			if (v = PreviewFontFamily) 
				C_PreventFont := k
		} 
		for k, v in FontOptionsArray
		{ 
			if (v = ResultFontFamily) 
				C_ResultFont := k
		} 
		for k, v in FontOptionsArray
		{ 
			if (v = SearchFontFamily) 
				C_SearchFont := k
		} 
		Gui, 3:Add,text,section, Quick Note Interface font settings:
		Gui, 3:add,DropDownList, Choose%CurrentFont% w100 vFontFamilySelect gSetFontFamily, %FontDropDownOptions%
		CurrentFontSize := FontSize*0.5
		Gui, 3:add,DropDownList, x+10 Choose%CurrentFontSize% vFontSizeSelect gSetFontSize, 2|4|6|8|10|12|14|16|18|20|22|24|26|28|30|32|34|36|38|40|42|44|46|48|50|52|54|56|58|60|62|64|66|68|70|72|74|76|78|80|82|84|86|88|90|92|94|96|98|100
		Gui, 3:Add,text,xs section, Search Box font settings:
		Gui, 3:add,DropDownList, Choose%C_SearchFont% w100 vSearchFontFamilySelect gSetSearchFontFamily,%FontDropDownOptions%
		CurrenSearchFontSize := SearchFontSize*0.5
		Gui, 3:add,DropDownList, x+10 Choose%CurrenSearchFontSize% vSearchFontSizeSelect gSetSearchFontSize, 2|4|6|8|10|12|14|16|18|20|22|24|26|28|30|32|34|36|38|40|42|44|46|48|50|52|54|56|58|60|62|64|66|68|70|72|74|76|78|80|82|84|86|88|90|92|94|96|98|100
		Gui, 3:Add,text,xs section, Result font settings:
		Gui, 3:add,DropDownList, Choose%C_ResultFont% w100 vResultFontFamilySelect gSetResultFontFamily, %FontDropDownOptions%
		CurrenResulttFontSize := ResultFontSize*0.5
		Gui, 3:add,DropDownList, x+10 Choose%CurrenResulttFontSize% vResultFontSizeSelect gSetResultFontSize, 2|4|6|8|10|12|14|16|18|20|22|24|26|28|30|32|34|36|38|40|42|44|46|48|50|52|54|56|58|60|62|64|66|68|70|72|74|76|78|80|82|84|86|88|90|92|94|96|98|100
		Gui, 3:Add,text,xs section, Note font settings:
		Gui, 3:add,DropDownList, Choose%C_PreventFont% w100 vPreviewFontFamilySelect gSetPreviewFontFamily, %FontDropDownOptions%
		CurrentPreviewFontSize := PreviewFontSize*0.5
		Gui, 3:add,DropDownList, x+10 Choose%CurrentPreviewFontSize% vPreviewFontSizeSelect gSetPreviewFontSize, 2|4|6|8|10|12|14|16|18|20|22|24|26|28|30|32|34|36|38|40|42|44|46|48|50|52|54|56|58|60|62|64|66|68|70|72|74|76|78|80|82|84|86|88|90|92|94|96|98|100
		
		global NamePercent = 0.5
global BodyPercent = 0.5
global AddedPercent 
		
		
		Gui, 3:Add,Text,xs,Column Width Percentage Name | Body | Added 
		
		Gui, Add, Edit, w50
		Gui, 3:Add,UpDown, vNamePercentSelect gSetNamePercent Range0-100, %oNamePercent%
		Gui, Add, Edit, w50 x+5
		Gui, 3:Add,UpDown,  vBodyPercentSelect gSetBodyPercent Range0-100, %oBodyPercent%
		Gui, Add, Edit, w50 x+5
		Gui, 3:Add,UpDown,  vAddedPercentSelect gSetAddedPercent Range0-100, %oAddedPercent%
		
		;Window Options Tab
		Gui, 3:Tab, Window Options
		Gui, 3:Add,Text,section,Main Window Width: (Default: 530)
		Gui, 3:Add,Edit   
		Gui, 3:Add,UpDown,vMainWSelect gSetMainW range50-3000, %LibW%
		
		Gui, 3:Add,Text,xs,Result Rows: (Default: 8)
		Gui, 3:Add,Edit   
		Gui, 3:Add,UpDown,vResultRowsSelect gSetResultRows range1-99, %ResultRows%
		
		Gui, 3:Add,Text,xs,Note Preview/Edit Rows: (Default: 8)
		Gui, 3:Add,Edit   
		Gui, 3:Add,UpDown,vPreviewRowsSelect gSetPreviewRows range1-99, %PreviewRows%
		
		Gui, 3:Add,Text,xs,Quick Note Window Width: (Default: 500)
		Gui, 3:Add,Edit   
		Gui, 3:Add,UpDown,vQuickWSelect gSetQuickW range50-3000, %QuickNoteWidth%
		
		Gui, 3:Add,Text,xs,Quick Note Rows: (Default: 7)
		Gui, 3:Add,Edit   
		Gui, 3:Add,UpDown,vQuickNoteRowsSelect gSetQuickNoteRows range1-99, %QuickNoteRows%
		
		
		Gui, 3:Tab 
		Gui, 3:Add, Button, Default gSaveAndReload, Save and Reload
		Gui, 3:SHOW 
		WinSet, AlwaysOnTop, On, FlatNotes - Options
		return
	}
  
SaveAndReload:
{ 
	GuiControlGet, U_QuickNoteWidth,,QuickWSelect	
	IniWrite, %U_QuickNoteWidth%,%iniPath%,General, QuickNoteWidth
	GuiControlGet, U_MainNoteWidth,,MainWSelect	
	IniWrite, %U_MainNoteWidth%,%iniPath%,General, WindowWidth	
	GuiControlGet, U_FontRendering,,FontRenderingSelect	
	IniWrite, %U_FontRendering%,%iniPath%,General, FontRendering
	GuiControlGet, U_SearchFontFamily,,SearchFontFamilySelect
	IniWrite, %U_SearchFontFamily%,%iniPath%,General, SearchFontFamily
	GuiControlGet, U_SearchSize,,SearchFontSizeSelect	
	IniWrite, %U_SearchSize%,%iniPath%,General, SearchFontSize
	GuiControlGet, U_ResultFontFamily,,ResultFontFamilySelect
	IniWrite, %U_ResultFontFamily%,%iniPath%,General, ResultFontFamily	
	GuiControlGet, U_ResultSize,,ResultFontSizeSelect	
	IniWrite, %U_ResultSize%,%iniPath%,General, ResultFontSize
	GuiControlGet, U_PreviewFontFamily,,PreviewFontFamilySelect
	IniWrite, %U_PreviewFontFamily%,%iniPath%,General, PreviewFontFamily	
	GuiControlGet, U_PreviewSize,,PreviewFontSizeSelect	
	IniWrite, %U_PreviewSize%,%iniPath%,General, PreviewFontSize
	GuiControlGet, U_FontFamily,,FontFamilySelect
	IniWrite, %U_FontFamily%,%iniPath%,General, FontFamily	
	GuiControlGet, U_FontSize,,FontSizeSelect	
	IniWrite, %U_FontSize%,%iniPath%,General, FontSize
	GuiControlGet, U_PreviewRows,,PreviewRowsSelect	
	IniWrite, %U_PreviewRows%,%iniPath%,General, PreviewRows	
	GuiControlGet, U_ResultRows,,ResultRowsSelect	
	IniWrite, %U_ResultRows%,%iniPath%,General, ResultRows	
	GuiControlGet, U_QuickNoteRows,,QuickNoteRowsSelect	
	IniWrite, %U_QuickNoteRows%,%iniPath%,General, QuickNoteRows
	GuiControlGet, U_QuickNoteWidth,,QuickWSelect	
	IniWrite, %U_QuickNoteWidth%,%iniPath%,General, QuickNoteWidth
	GuiControlGet, U_MainNoteWidth,,MainWSelect	
	IniWrite, %U_MainNoteWidth%,%iniPath%,General, WindowWidth	
	GuiControlGet, U_FontRendering,,FontRenderingSelect	
	IniWrite, %U_FontRendering%,%iniPath%,General, FontRendering
	GuiControlGet,HideScrollbarsSelect
	IniWrite,%HideScrollbarsSelect%, %iniPath%, General, HideScrollbars
	GuiControlGet,ShowStatusBarSelect
	IniWrite,%ShowStatusBarSelect%, %iniPath%, General, ShowStatusBar
	
	GuiControlGet, NamePercentSelect	
	GuiControlGet, BodyPercentSelect	
	GuiControlGet, AddedPercentSelect	

	is100 := NamePercentSelect+BodyPercentSelect+AddedPercentSelect
	WinSet, AlwaysOnTop, Off, FlatNotes - Options
	if (is100 >= 101){
		msgbox Column width exceeds 100 please fix.
		return
	}
	IniWrite, %NamePercentSelect%,%iniPath%,General, NamePercent		
	IniWrite, %BodyPercentSelect%,%iniPath%,General, BodyPercent		
	IniWrite, %AddedPercentSelect%,%iniPath%,General, AddedPercent		
reload
}
Set_backupsToKeep:
{
	GuiControlGet,U_backupsToKeep,, backupsToKeepSelect	
	IniWrite, %U_backupsToKeep%,%iniPath%,General, backupsToKeep
	IniRead, backupsToKeep, %iniPath%, General, backupsToKeep
}
SetHideScrollbars:
{
	GuiControlGet,HideScrollbarsSelect
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%HideScrollbarsSelect%, %iniPath%, General, HideScrollbars
		IniRead,HideScrollbars,%iniPath%,General,HideScrollbars
		
	}
return
}
SetShowStatusBar:
{
	GuiControlGet,ShowStatusBarSelect
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%ShowStatusBarSelect%, %iniPath%, General, ShowStatusBar
		IniRead,ShowStatusBar,%iniPath%,General,ShowStatusBar
		
	}
return
}
SetPreviewRows:
{
	GuiControlGet, U_PreviewRows,,PreviewRowsSelect	
	IniWrite, %U_PreviewRows%,%iniPath%,General, PreviewRows	
	IniRead, PreviewRows, %iniPath%, General, PreviewRows
	gosub DummyGUI1
	return
}
SetResultRows:
{
	GuiControlGet, U_ResultRows,,ResultRowsSelect	
	IniWrite, %U_ResultRows%,%iniPath%,General, ResultRows		
	IniRead, ResultRows, %iniPath%, General, ResultRows
	gosub DummyGUI1
	return 
}
SetQuickNoteRows:
{
	GuiControlGet, U_QuickNoteRows,,QuickNoteRowsSelect	
	IniWrite, %U_QuickNoteRows%,%iniPath%,General, QuickNoteRows	
	IniRead, QuickNoteRows, %iniPath%, General, QuickNoteRows
	Gui, 2:Destroy
	Gui, 5:Destroy
	isfake = 1
	BuildGUI2()
	isfake = 0
	WinMove,FlatNote - QuickNote, x25 y%fakeY%
	if WinExist("FlatNote - QuickNote")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	return
}
SetQuickW:
{ 
	GuiControlGet, U_QuickNoteWidth,,QuickWSelect	
	IniWrite, %U_QuickNoteWidth%,%iniPath%,General, QuickNoteWidth	
	IniRead, QuickNoteWidth,%iniPath%, General,QuickNoteWidth
	Gui, 2:Destroy
	Gui, 5:Destroy
	isfake = 1
	BuildGUI2()
	isfake = 0
	if WinExist("FlatNote - QuickNote")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	return
}
SetMainW:
{
	GuiControlGet, U_MainNoteWidth,,MainWSelect	
	IniWrite, %U_MainNoteWidth%,%iniPath%,General, WindowWidth	
	IniRead, LibW, %iniPath%, General, WindowWidth ,530
	SubW := LibW-10	
	libWAdjust := LibW+10
	ColAdjust := LibW-95
	NameColW := Round(ColAdjust*0.4)
	BodyColW := Round(ColAdjust*0.6)
	NameColAndBodyCOlW := NameColW+BodyColW
	gosub DummyGUI1
	return 
}
SetFontRendering:
{
	GuiControlGet, U_FontRendering,,FontRenderingSelect	
	IniWrite, %U_FontRendering%,%iniPath%,General, FontRendering		
	IniRead, FontRendering,%iniPath%, General,FontRendering
	gosub DummyGUI1
} 
SetSearchFontFamily:
{
	GuiControlGet, U_SearchFontFamily,,SearchFontFamilySelect
	IniWrite, %U_SearchFontFamily%,%iniPath%,General, SearchFontFamily	
	IniRead, SearchFontFamily, %iniPath%, General, SearchFontFamily
	gosub DummyGUI1
	return 
}
SetSearchFontSize:
{
	GuiControlGet, U_SearchSize,,SearchFontSizeSelect	
	IniWrite, %U_SearchSize%,%iniPath%,General, SearchFontSize
	IniRead, SearchFontSize, %iniPath%, General, SearchFontSize
	gosub DummyGUI1
	return 
}
SetResultFontFamily:
{
	GuiControlGet, U_ResultFontFamily,,ResultFontFamilySelect
	IniWrite, %U_ResultFontFamily%,%iniPath%,General, ResultFontFamily	
	IniRead, ResultFontFamily, %iniPath%, General, ResultFontFamily
	gosub DummyGUI1
	return 
}
SetResultFontSize:
{
	GuiControlGet, U_ResultSize,,ResultFontSizeSelect	
	IniWrite, %U_ResultSize%,%iniPath%,General, ResultFontSize
	IniRead, ResultFontSize, %iniPath%, General, ResultFontSize
	gosub DummyGUI1
	return 
}
SetPreviewFontFamily:
{
	GuiControlGet, U_PreviewFontFamily,,PreviewFontFamilySelect
	IniWrite, %U_PreviewFontFamily%,%iniPath%,General, PreviewFontFamily	
	IniRead, PreviewFontFamily, %iniPath%, General, PreviewFontFamily
	gosub DummyGUI1
	return
}
SetPreviewFontSize:
{
	GuiControlGet, U_PreviewSize,,PreviewFontSizeSelect	
	IniWrite, %U_PreviewSize%,%iniPath%,General, PreviewFontSize
	IniRead, PreviewFontSize, %iniPath%, General, PreviewFontSize
	gosub DummyGUI1
	return
}
SetFontFamily:
{ 
	GuiControlGet, U_FontFamily,,FontFamilySelect
	IniWrite, %U_FontFamily%,%iniPath%,General, FontFamily	
	IniRead, FontFamily, %iniPath%, General, FontFamily ,Verdana
	Gui, 2:Destroy
	Gui, 5:Destroy
	isfake = 1
	BuildGUI2()
	isfake = 0
	WinMove,FlatNote - QuickNote, x25 y%fakeY%
	if WinExist("FlatNote - QuickNote")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	GuiControl,,QuickNoteName, Sample Text
	GuiControl,,QuickNoteBody, Sample Text
	return
}
SetFontSize:
{
	GuiControlGet, U_FontSize,,FontSizeSelect	
	IniWrite, %U_FontSize%,%iniPath%,General, FontSize
	IniRead, FontSize, %iniPath%, General, FontSize
	isfake = 1
	BuildGUI2()
	isfake = 0
	WinMove,FlatNote - QuickNote, x25 y%fakeY%
	if WinExist("FlatNote - QuickNote")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	GuiControl,,QuickNoteName, Sample Text
	GuiControl,,QuickNoteBody, Sample Text
	return
}
SetNamePercent:
{
	GuiControlGet, NamePercentSelect	
	IniWrite, %NamePercentSelect%,%iniPath%,General, NamePercent		
	IniRead, NamePercent,%iniPath%, General,NamePercent
	gosub DummyGUI1
	return
}
SetBodyPercent:
{
	GuiControlGet, BodyPercentSelect	
	IniWrite, %BodyPercentSelect%,%iniPath%,General, BodyPercent		
	IniRead, BodyPercent,%iniPath%, General,BodyPercent
	gosub DummyGUI1
	return
}
SetAddedPercent:
{
	GuiControlGet, AddedPercentSelect	
	IniWrite, %AddedPercentSelect%,%iniPath%,General, AddedPercent		
	IniRead, AddedPercent,%iniPath%, General,AddedPercent
	gosub DummyGUI1
	return
}

Label:
{
	If %A_GuiControl% in +,^,!,+^,+!,^!,+^!    ;If the hotkey contains only modifiers, return to wait for a key.
		return
	num := SubStr(A_GuiControl,3)              ;Get the index number of the hotkey control.
	If (HK%num% != "") {                       ;If the hotkey is not blank...
		Gui, Submit, NoHide
		If CB%num%                                ;  If the 'Win' box is checked, then add its modifier (#).
			HK%num% := "#" HK%num%
		If !RegExMatch(HK%num%,"[#!\^\+]")        ;  If the new hotkey has no modifiers, add the (~) modifier.
			HK%num% := "~" HK%num%                   ;    This prevents any key from being blocked.
		Loop,% #ctrls
			If (HK%num% = savedHK%A_Index%) {        ;  Check for duplicate hotkey...
				dup := A_Index
				Loop,6 {
					GuiControl,% "Disable" b:=!b, HK%dup%  ;    Flash the original hotkey to alert the user.
					Sleep,200
				}
				GuiControl,,HK%num%,% HK%num% :=""      ;    Delete the hotkey and clear the control.
				break
			}
	}
	If (savedHK%num% || HK%num%)
		setHK(num, savedHK%num%, HK%num%)
	return
}
4GuiEscape:
{
	Gui, 4:Destroy
	return
}
3GuiEscape:
{
	Gui, 3:Destroy
	reload
	return
}
2GuiEscape:
{
	Gui, 2:Destroy 
	return
}
GuiEscape:
{
	WinHide, ahk_id %g1ID%
	g1Open=0
	return
}
GuiClose:
{
	WinHide, ahk_id %g1ID%
	g1Open=0
	return
}
Exit:
{
	ExitApp
}
CheckBackupLater:
{
 BackupNotes()
}
DummyGUI1:
{
	Gui, 5:Destroy
	Gui, 2:Destroy
	Gui, 5:New,, FlatNotes - Sample
	Gui, 5:Margin , 0, 0 
	Gui, 5:Font, s%SearchFontSize% Q%FontRendering%, %SearchFontFamily%, %U_MFC%
	Gui, 5:Color,%U_SBG%, %U_MBG%
	Gui, 5:Add,Edit, c%U_FBCA% w%LibW% y%FontSize% x6 y8 -E0x200, Sample Search Text
	Gui, 5:Add, ListBox, +0x100 h8 w%LibW% x0 y0 -E0x200 Disabled 
	Gui, 5:Add, ListBox, +0x100 h15 w%LibW% x0 ys0 -E0x200 Disabled
	Gui, 5:Font, s%ResultFontSize% Q%FontRendering%, %ResultFontFamily%, %U_SFC%	
	Gui, 5:Add, text, c%U_SFC% w%NameColW% center , Name
	Gui, 5:Add, text, c%U_SFC% xp+%NameColW% yp+1 w%BodyColW% center , Body
	Gui, 5:Add, text, yp+1 xp+%BodyColW% w75 center c%U_MSFC% , Added
	Gui, 5:Add, ListView, -E0x200 -hdr LV0x10000 -ReadOnly grid r%ResultRows% w%libWAdjust% x0 C%U_MFC% vLVfake hwndHLV2  -Multi, Title|Body|Created|FileName
	

	Gui, 5:Add,text, center xs -E0x200  x0 r1 C%U_SFC% w%SubW% gTitleBarClick,
	
	
	
	;Allow User set prevent/edit font
	Gui, 5:Font, s%PreviewFontSize% Q%FontRendering%, %PreviewFontFamily%, %U_SFC%
	Gui, 5:Add,Edit, -E0x200 r%PreviewRows% w%LibW% yp+18 x0 C%U_MFC% ,
	
		;statusbar
	if (ShowStatusBar=1) {
		Gui, 5:Font, s8
		StatusWidth := SubW-185
		Gui, 5:add,text, xs center w85, 3 of 100
		Gui, 5:add,text, x+5 center  w%StatusWidth%,M: 00/00/00
		Gui, 5:add,text, x+5 right  w75,A: 00/00/00
		Gui, 5:Font, s2
		Gui, 5:add,text, xs
	}
	
	
	LV_Add("", "Name", "Body", "20/20/20","Sample")
	LV_Add("", "Name", "Body", "20/20/20","Sample")
	LV_Add("", "Name", "Body", "20/20/20","Sample")
	LV_ModifyCol(1, NameColW) ; 145
	LV_ModifyCol(1, "Logical")
	LV_ModifyCol(2, BodyColW) ; 275
	LV_ModifyCol(2, "Logical")
	LV_ModifyCol(3, AddColW)
	LV_ModifyCol(3, "Logical")
	LV_ModifyCol(3, "SortDesc")
	LV_ModifyCol(3, "Center")
	LV_ModifyCol(4, 0)
	CLV2 := New LV_Colors(HLV2)
	CLV2.SelectionColors(rowSelectColor,rowSelectTextColor)
	fakeY := round((A_ScreenHeight/3))
	
	
	Gui, 5:SHOW, w%SubW% x25 y%fakeY%
	if WinActive("FlatNotes - Sample")
		sendinput Sample
	WinActivate,FlatNotes - Options
	return
}









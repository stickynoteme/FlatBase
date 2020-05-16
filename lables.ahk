Label1:
{
	if (U_Capslock = "1"){
		return
}
	BuildGUI1(1,1)
	return
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
			settimer, KillToolTip, 500
			return
	}
	else if(istitle = "no") {
			send {Ctrl Down}{c}{Ctrl up}
			zbody := clipboard 
			istitle = yes
			TmpFileSafeName := RegExReplace(ztitle, "\*|\?|\||/|""|:|<|>" , Replacement := "_")
			FileReadLine, CheckExists, %U_NotePath%%TmpFileSafeName%.txt, 1
			if (CheckExists !="")
			{
				 msgbox Note Already Exists
				 return
			}
			SaveFile(ztitle,TmpFileSafeName,zbody)
			MakeFileList(1)
			if WinActive("FlatNotes - Library")
				send {space}{backspace} ;update results
			tooltip B: %zbody%
			settimer, KillToolTip, 500
			return
	}
return
}
Label4:
{
	istitle = yes
	tooltip cancled
	settimer,KillToolTip,1000
	return 
}
SaveButton:
{
	GuiControlGet, QuickNoteName
	GuiControlGet, FileSafeName
	if (QuickNoteName == ""){
		MsgBox Note Name Can Not Be Empty
	return
	}

GuiControlGet, FileSafeName
GuiControlGet, QuickNoteBody
SaveFile(QuickNoteName,FileSafeName,QuickNoteBody)
Gui, 2:Destroy
MakeFileList(1)
ReFreshLV()
if WinActive("FlatNotes - Library")
	send {space}{backspace} ;update results
return
}

QuickSafeNameUpdate:
{
	GuiControlGet, QuickNoteName
	;Remove stray whitespace from front and back
	;QuickNoteName := Ltrim(QuickNoteName," ")
	;QuickNoteName := Rtrim(QuickNoteName," ")
	NewFileSafeName := RegExReplace(QuickNoteName, "\*|\?|\||/|""|:|<|>" , Replacement := "_")
	GuiControl,, FileSafeName,%NewFileSafeName%
	return
}
Search:
{
	global SearchTerm
	GuiControlGet, SearchTerm
	GuiControl, -Redraw, LV
	LV_Delete()
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
NoteDetailPreviewBoxClick:
{
	GuiControlGet, NoteDetailPreviewBox
	tooltip %NoteDetailPreviewBox%
	SetTimer, KillToolTip, 2000
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
	SetTimer, UnDoom, 50
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
    SetTimer, KillToolTip, 500
    Gui, 1:Destroy
}
if (A_GuiEvent = "RightClick")
{
    LV_GetText(RowText, A_EventInfo)
    TmpFileSafeName := RegExReplace(RowText, "\*|\?|\||/|""|:|<|>" , Replacement := "_")
    FilePath = %U_NotePath%%TmpFileSafeName%.txt
	FileRead, MyFile, %FilePath%
    clipboard = %NoteBody%
    ToolTip Text: "%RowText%" Copied to clipboard
    SetTimer, KillToolTip, 500
    Gui, 1:Destroy
}
if (A_GuiEvent == "E") 
	LV_GetText(OldRowText, A_EventInfo,1)
if (A_GuiEvent == "e")
{
	LV_GetText(RowText, A_EventInfo,1)
	TmpFileSafeName := RegExReplace(RowText, "\*|\?|\||/|""|:|<|>" , Replacement := "_")
	TmpOldFileSafeName := RegExReplace(OldRowText, "\*|\?|\||/|""|:|<|>" , Replacement := "_")
	
	
	FilePath = %U_NotePath%%TmpFileSafeName%.txt
	OldFilePath = %U_NotePath%%TmpOldFileSafeName%.txt
	FileRead, MyFile, %OldFilePath%
	FileRecycle,  %OldFilePath%
	FileRecycle,  %detailsPath%%TmpOldFileSafeName%.ini

	SaveFile(RowText,TmpFileSafeName,MyOldFile)
	MakeFileList(1)
	ReFreshLV()
	iniRead, NewAdd,%detailsPath%%TmpFileSafeName%.ini,INFO,Add
	iniRead, NewMod,%detailsPath%%TmpFileSafeName%.ini,INFO,Mod
	GuiControl,, NoteDetailPreviewBox, %RowText% | %NewAdd% | %NewMod%
}
;update the preview
if (A_GuiEvent = "I" && InStr(ErrorLevel, "S", true))
{
	global LVSelectedROW = A_EventInfo
    LV_GetText(RowText, A_EventInfo,4)  ; Get the text from the row's first field.
    FileRead, NoteFile, %U_NotePath%%RowText%
    GuiControl,, PreviewBox, %NoteFile%
	TMPini := StrReplace(RowText, ".txt", ".ini")
	TMPName := StrReplace(RowText, ".txt", "")

	iniRead, NoteAdd,%detailsPath%%TMPini%,INFO,Add
	iniRead, NoteMod,%detailsPath%%TMPini%,INFO,Mod
	GuiControl,, NoteDetailPreviewBox, %TMPName% | %NoteAdd% | %NoteMod%
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
	Gui, 1:Destroy
	BuildGUI1(0,0)
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
		
		IniWrite, %U_MBG%,%iniPath%,Colors,MainBackgroundColor
		IniWrite, %U_SBG%,%iniPath%,Colors,SubBackgroundColor
		IniWrite, %U_MFC%,%iniPath%,Colors,MainFontColor
		IniWrite, %U_SFC%,%iniPath%,Colors,SubFontColor
		IniWrite, %U_MSFC%,%iniPath%,Colors,MainSortFontColor
		IniWrite, %U_FBCA%,%iniPath%,Colors,SearchBoxFontColor
		IniWrite, %rowSelectColor%,%iniPath%,Colors,RowSelectColor
		IniWrite, %rowSelectTextColor%,%iniPath%,Colors,RowSelectTextColor
		IniWrite, %themeNumber%, %iniPath%, Theme, UserSetting
		
	}
	Gui, 1:Destroy
	BuildGUI1(0,0)
	if WinExist("FlatNotes - Options")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	return
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
			Gui, Font, %FontSize% c%U_MSFC%, %FontFamily%
			GuiControl, Font, SortName
			Gui, Font, %FontSize% c%U_SFC%, %FontFamily%
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
		Gui, 3:New,,FlatNotes - Options
		Gui, 3:Add, Tab3,, General|Hotkeys|Appearance
		Gui, 3:Tab, General
		Gui, 3:Add,Text,section, Notes storage folder:
		Gui, 3:Add,Edit, disabled r1 w300 vNotesStorageFolder, %U_NotePath%
		Gui, 3:Add,Button, gFolderSelect, Select a folder.
		
		Gui, 3:Add,Text,xs,Main Window Width: (Default: 530)
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
			;Sets Hotkeys, this is done else where now and editing settings relodas the script
			;If savedHK%A_Index%                                       
				;Hotkey,% savedHK%A_Index%, Label%A_Index%                 
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
		
		;Gui, 3:Add, CheckBox, vUseCapslock ;gUseCapslockToggle, Use Capslock for Library?
		;GuiControl,,UseCapslock,%U_Capslock%
		
		
		Gui, 3:Add,Text,,Theme Selection:
		Loop, Files, %themePath%\*.ini
		{
			themeFileList .= A_LoopFileName "|"
			IniWrite, %A_index%,%themePath%\%A_LoopFileName%,Theme,UserSetting
			themeList := StrReplace(themeFileList, ".ini" , "")
		}
		Gui, 3:Add,DropDownList, Choose%U_Theme% vColorChoice gColorPicked, %themeList%
		
		FontOptionsArray := ["Bahnschrift","Fixedsys","Modern","MS Sans Serif","MS Serif","Neue Haas Grotesk Text Pro","Roman","Script","Small Fonts","System","Terminal","Arial","Arial Black","Arial Nova","Calibri","Calibri Light","Cambria","Candara","Comic Sans MS","Consolas","Constantia","Corbel","Courier","Courier New","Franklin Gothic Medium","Gabriola","Georgia","Georgia Pro","Gill Sans Nova","Impact","Lucida Console","Lucida Sans","Lucida Sans Unicode","Microsoft Sans Serif","Palatino Linotype","Rockwell Nova","Segoe Print","Segoe Script","Segoe UI","Sitka Display","Sitka Text","Tahoma","Times New Roman","Trebuchet MS","Verdana","Verdana Pro"]
		
		
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
		Gui, 3:add,DropDownList, Choose%CurrentFont% w100 vFontFamilySelect gSetFontFamily, Bahnschrift|Fixedsys|Modern|MS Sans Serif|MS Serif|Neue Haas Grotesk Text Pro|Roman|Script|Small Fonts|System|Terminal|Arial|Arial Black|Arial Nova|Calibri|Calibri Light|Cambria|Candara|Comic Sans MS|Consolas|Constantia|Corbel|Courier|Courier New|Franklin Gothic Medium|Gabriola|Georgia|Georgia Pro|Gill Sans Nova|Impact|Lucida Console|Lucida Sans|Lucida Sans Unicode|Microsoft Sans Serif|Palatino Linotype|Rockwell Nova|Segoe Print|Segoe Script|Segoe UI|Sitka Display|Sitka Text|Tahoma|Times New Roman|Trebuchet MS|Verdana|Verdana Pro 
		CurrentFontSize := FontSize*0.5
		Gui, 3:add,DropDownList, x+10 Choose%CurrentFontSize% vFontSizeSelect gSetFontSize, 2|4|6|8|10|12|14|16|18|20|22|24|26|28|30|32|34|36|38|40|42|44|46|48|50|52|54|56|58|60|62|64|66|68|70|72|74|76|78|80|82|84|86|88|90|92|94|96|98|100
		Gui, 3:Add,text,xs section, Search Box font settings:
		Gui, 3:add,DropDownList, Choose%C_SearchFont% w100 vSearchFontFamilySelect gSetSearchFontFamily, Bahnschrift|Fixedsys|Modern|MS Sans Serif|MS Serif|Neue Haas Grotesk Text Pro|Roman|Script|Small Fonts|System|Terminal|Arial|Arial Black|Arial Nova|Calibri|Calibri Light|Cambria|Candara|Comic Sans MS|Consolas|Constantia|Corbel|Courier|Courier New|Franklin Gothic Medium|Gabriola|Georgia|Georgia Pro|Gill Sans Nova|Impact|Lucida Console|Lucida Sans|Lucida Sans Unicode|Microsoft Sans Serif|Palatino Linotype|Rockwell Nova|Segoe Print|Segoe Script|Segoe UI|Sitka Display|Sitka Text|Tahoma|Times New Roman|Trebuchet MS|Verdana|Verdana Pro 
		CurrenSearchFontSize := ResultFontSize*0.5
		Gui, 3:add,DropDownList, x+10 Choose%CurrenSearchFontSize% vSearchFontSizeSelect gSetSearchFontSize, 2|4|6|8|10|12|14|16|18|20|22|24|26|28|30|32|34|36|38|40|42|44|46|48|50|52|54|56|58|60|62|64|66|68|70|72|74|76|78|80|82|84|86|88|90|92|94|96|98|100
		Gui, 3:Add,text,xs section, Result font settings:
		Gui, 3:add,DropDownList, Choose%C_ResultFont% w100 vResultFontFamilySelect gSetResultFontFamily, Bahnschrift|Fixedsys|Modern|MS Sans Serif|MS Serif|Neue Haas Grotesk Text Pro|Roman|Script|Small Fonts|System|Terminal|Arial|Arial Black|Arial Nova|Calibri|Calibri Light|Cambria|Candara|Comic Sans MS|Consolas|Constantia|Corbel|Courier|Courier New|Franklin Gothic Medium|Gabriola|Georgia|Georgia Pro|Gill Sans Nova|Impact|Lucida Console|Lucida Sans|Lucida Sans Unicode|Microsoft Sans Serif|Palatino Linotype|Rockwell Nova|Segoe Print|Segoe Script|Segoe UI|Sitka Display|Sitka Text|Tahoma|Times New Roman|Trebuchet MS|Verdana|Verdana Pro 
		CurrenResulttFontSize := ResultFontSize*0.5
		Gui, 3:add,DropDownList, x+10 Choose%CurrenResulttFontSize% vResultFontSizeSelect gSetResultFontSize, 2|4|6|8|10|12|14|16|18|20|22|24|26|28|30|32|34|36|38|40|42|44|46|48|50|52|54|56|58|60|62|64|66|68|70|72|74|76|78|80|82|84|86|88|90|92|94|96|98|100
		Gui, 3:Add,text,xs section, Note font settings:
		Gui, 3:add,DropDownList, Choose%C_PreventFont% w100 vPreviewFontFamilySelect gSetPreviewFontFamily, Bahnschrift|Fixedsys|Modern|MS Sans Serif|MS Serif|Neue Haas Grotesk Text Pro|Roman|Script|Small Fonts|System|Terminal|Arial|Arial Black|Arial Nova|Calibri|Calibri Light|Cambria|Candara|Comic Sans MS|Consolas|Constantia|Corbel|Courier|Courier New|Franklin Gothic Medium|Gabriola|Georgia|Georgia Pro|Gill Sans Nova|Impact|Lucida Console|Lucida Sans|Lucida Sans Unicode|Microsoft Sans Serif|Palatino Linotype|Rockwell Nova|Segoe Print|Segoe Script|Segoe UI|Sitka Display|Sitka Text|Tahoma|Times New Roman|Trebuchet MS|Verdana|Verdana Pro 
		CurrentPreviewFontSize := PreviewFontSize*0.5
		Gui, 3:add,DropDownList, x+10 Choose%CurrentPreviewFontSize% vPreviewFontSizeSelect gSetPreviewFontSize, 2|4|6|8|10|12|14|16|18|20|22|24|26|28|30|32|34|36|38|40|42|44|46|48|50|52|54|56|58|60|62|64|66|68|70|72|74|76|78|80|82|84|86|88|90|92|94|96|98|100
		
		Gui, 3:Tab 
		;Gui, 3:Add,Text,x0 w%Gui3W% +Center,Settings are saved automatically.
		;Gui, 3:Add,Text,x0 w%Gui3W% +Center,Press Esc to exit and reload.
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
	reload
}
SetHideScrollbars:
{
	GuiControlGet,HideScrollbarsSelect
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%HideScrollbarsSelect%, %iniPath%, General, HideScrollbars
		
	}
return
}
SetPreviewRows:
{
	GuiControlGet, U_PreviewRows,,PreviewRowsSelect	
	IniWrite, %U_PreviewRows%,%iniPath%,General, PreviewRows	
	IniRead, PreviewRows, %iniPath%, General, PreviewRows
	Gui, 1:Destroy
	Gui, 2:Destroy	
	BuildGUI1(0,0)
	if WinExist("FlatNotes - Options")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	return 
}
SetResultRows:
{
	GuiControlGet, U_ResultRows,,ResultRowsSelect	
	IniWrite, %U_ResultRows%,%iniPath%,General, ResultRows		
	IniRead, ResultRows, %iniPath%, General, ResultRows
	Gui, 1:Destroy
	Gui, 2:Destroy	
	BuildGUI1(0,0)
	if WinExist("FlatNotes - Options")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	return 
}
SetQuickNoteRows:
{
	GuiControlGet, U_QuickNoteRows,,QuickNoteRowsSelect	
	IniWrite, %U_QuickNoteRows%,%iniPath%,General, QuickNoteRows	
	IniRead, QuickNoteRows, %iniPath%, General, QuickNoteRows
	Gui, 1:Destroy 
	Gui, 2:Destroy
	BuildGUI2()
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
	Gui, 1:Destroy
	Gui, 2:Destroy
	BuildGUI2()
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
	Gui, 1:Destroy
	Gui, 2:Destroy	
	BuildGUI1(0,0)
	if WinExist("FlatNotes - Options")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	return 
}
SetFontRendering:
{
	GuiControlGet, U_FontRendering,,FontRenderingSelect	
	IniWrite, %U_FontRendering%,%iniPath%,General, FontRendering		
	IniRead, FontRendering,%iniPath%, General,FontRendering
	Gui, 1:Destroy
	Gui, 2:Destroy
	BuildGUI1(0,0)
	if WinExist("FlatNotes - Options")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	return 
} 
SetSearchFontFamily:
{
	GuiControlGet, U_SearchFontFamily,,SearchFontFamilySelect
	IniWrite, %U_SearchFontFamily%,%iniPath%,General, SearchFontFamily	
	IniRead, SearchFontFamily, %iniPath%, General, SearchFontFamily
	Gui, 1:Destroy
	Gui, 2:Destroy
	BuildGUI1(0,0)
	if WinExist("FlatNotes - Options")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	GuiControl,,SearchTerm, Sample Text
	return 
}
SetSearchFontSize:
{
	GuiControlGet, U_SearchSize,,SearchFontSizeSelect	
	IniWrite, %U_SearchSize%,%iniPath%,General, SearchFontSize
	IniRead, SearchFontSize, %iniPath%, General, SearchFontSize
	Gui, 1:Destroy
	Gui, 2:Destroy
	BuildGUI1(0,0)
	if WinExist("FlatNotes - Options")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	GuiControl,,SearchTerm, Sample Text
	return 
}
SetResultFontFamily:
{
	GuiControlGet, U_ResultFontFamily,,ResultFontFamilySelect
	IniWrite, %U_ResultFontFamily%,%iniPath%,General, ResultFontFamily	
	IniRead, ResultFontFamily, %iniPath%, General, ResultFontFamily
	Gui, 1:Destroy
	Gui, 2:Destroy
	BuildGUI1(0,0)
	if WinExist("FlatNotes - Options")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	return 
}
SetResultFontSize:
{
	GuiControlGet, U_ResultSize,,ResultFontSizeSelect	
	IniWrite, %U_ResultSize%,%iniPath%,General, ResultFontSize
	IniRead, ResultFontSize, %iniPath%, General, ResultFontSize
	Gui, 1:Destroy
	Gui, 2:Destroy
	BuildGUI1(0,0)
	if WinExist("FlatNotes - Options")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	return 
}
SetPreviewFontFamily:
{
	GuiControlGet, U_PreviewFontFamily,,PreviewFontFamilySelect
	IniWrite, %U_PreviewFontFamily%,%iniPath%,General, PreviewFontFamily	
	IniRead, PreviewFontFamily, %iniPath%, General, PreviewFontFamily
	Gui, 1:Destroy
	Gui, 2:Destroy
	BuildGUI1(0,0)
	if WinExist("FlatNotes - Options")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	GuiControl,,PreviewBox, Sample Text 	
	return
}
SetPreviewFontSize:
{
	GuiControlGet, U_PreviewSize,,PreviewFontSizeSelect	
	IniWrite, %U_PreviewSize%,%iniPath%,General, PreviewFontSize
	IniRead, PreviewFontSize, %iniPath%, General, PreviewFontSize
	Gui, 1:Destroy
	Gui, 2:Destroy
	BuildGUI1(0,0)
	if WinExist("FlatNotes - Options")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	GuiControl,,PreviewBox, Sample Text 	
	return
}
SetFontFamily:
{ 
	GuiControlGet, U_FontFamily,,FontFamilySelect
	IniWrite, %U_FontFamily%,%iniPath%,General, FontFamily	
	IniRead, FontFamily, %iniPath%, General, FontFamily ,Verdana
	Gui, 1:Destroy
	Gui, 2:Destroy
	BuildGUI2()
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
	Gui, 1:Destroy
	Gui, 2:Destroy	
	BuildGUI2()
	if WinExist("FlatNote - QuickNote")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	GuiControl,,QuickNoteName, Sample Text
	GuiControl,,QuickNoteBody, Sample Text
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
	Gui, Destroy
	return
}
Exit:
{
	ExitApp
}













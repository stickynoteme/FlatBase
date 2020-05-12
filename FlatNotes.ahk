/*Todo list
#LV Context menu +multi select
##Copy All Titles, Copy All Bodies, Delete All Selected 
*/
;------------------------------------------------------------------------------
;-----------------------Inialize FlateNotes AHK v1
;------------------------------------------------------------------------------
#SingleInstance Force
FileEncoding ,UTF-8
CoordMode, mouse, Screen
SetBatchLines, -1
;TraySetIcon("FlatNotes.ico")
Menu, Tray, NoStandard
Menu, Tray, Add 
Menu, Tray, Add, Library
Menu, Tray, Add, About
Menu, Tray, Add, Options
Menu, Tray, Add, Exit
Menu, Tray, Default, Library
;Set script Vars
global MyNotesArray := {}
global FileList = ""
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
IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000

#Include functions.ahk

;Add GUI for users to set settings with Alt+C
#Include user_settings.ahk

;Setup the main GUI on Win+m [manage]
vk14::
!^6::
{
if WinExist("FlatNotes - Library")
{
	Gui, 1:destroy
	return
}
firstDown = 1
MouseGetPos, xPos, yPos	
xPos /= 1.5
yPos /= 1.5
Gui, 1:New,, FlatNotes - Library
Gui, 1:Margin , 0, 0
Gui, 1:Font, s10, Verdana, white
Gui, 1:Color,%U_SBG%, %U_MBG%
Gui, 1:Add,Edit, Cffffff w530 x-3 y0 vSearchTerm gSearch
Gui, 1:Add, ListView, LV0x10000 -ReadOnly grid r8 w530 x-3 C%U_MFC% vLV gNoteListView +altsubmit -Multi, Title|Body|Created|FileName
Gui, 1:Add,Edit, r0 h0  vFake,
GuiControl, Hide, Fake
Gui, 1:Add,Text, r1 w530 Center C%U_SFC% vNoteDetailPreviewBox gNoteDetailPreviewBoxClick,
Gui, 1:Add,Edit,  r7 w530 x-3 yp+18 C%U_MFC% vPreviewBox,

MakeFileList()

Gui, 1:SHOW, w510 h338 x%xPos% y%yPos%
isFristRun = 0
return

;capture a new note with Win+N
#n::
AutoTrim On
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
MyNewFile := SubStr(MyFile, InStr(MyFile, "`n") + 1)
GuiControl,, QuickNoteBody,%MyNewFile%
GuiControl, +Redraw, QuickNoteBody
}
return


SaveButton:
GuiControlGet, QuickNoteName
if (QuickNoteName == ""){
	MsgBox Note Name Can Not Be Empty
	return
}
GuiControlGet, FileSafeName
GuiControlGet, QuickNoteBody
FormatTime, CurrentTimeStamp, %A_Now%, yy/MM/dd

SaveFileName = %U_NotePath%%FileSafeName%.txt
FileReadLine, OldDetails, %SaveFileName%, 1
if (OldDetails !="")
{
 RegExMatch(OldDetails, "\d\d/\d\d/\d\d" , CreatedDate)
 }
if (CreatedDate =="")
{
CreatedDate = %CurrentTimeStamp%
}
FileRecycle, %SaveFileName%
FileLineOne = %QuickNoteName% || C:%CreatedDate% || M:%CurrentTimeStamp%`n
FileAppend , %FileLineOne%%QuickNoteBody%, %SaveFileName%, UTF-8
Gui, 2:Destroy
MakeFileList()
if WinActive("FlatNotes - Library")
	send {space}{backspace} ;update results
return

QuickSafeNameUpdate:
GuiControlGet, QuickNoteName
NewFileSafeName := RegExReplace(QuickNoteName, "\*|\?|\||/|""|:|<|>" , Replacement := "_")
GuiControl,, FileSafeName,%NewFileSafeName%
return

Search:
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
   ToolTip
Return

UnDoom:
	Doom = 0
return

NoteDetailPreviewBoxClick:
{
	GuiControlGet, NoteDetailPreviewBox
	tooltip %NoteDetailPreviewBox%
	SetTimer, KillToolTip, 2000
	return
}


NoteListView:
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
	NoteBody := SubStr(MyFile, InStr(MyFile, "`n") + 1)
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
FileReadLine, OldDetails, %OldFilePath%, 1
RegExMatch(OldDetails, "\d\d/\d\d/\d\d" , CreatedDate)
FileRead, MyFile, %OldFilePath%
MyOldFile := SubStr(MyFile, InStr(MyFile, "`n") + 1)
FileRecycle,  %OldFilePath%
FormatTime, CurrentTimeStamp, %A_Now%, yy/MM/dd
FileRebuildLineOne = %RowText% || C:%CreatedDate% || M:%CurrentTimeStamp%
FileAppend , %FileRebuildLineOne%`n%MyOldFile%, %FilePath%, UTF-8
MakeFileListNoRefresh()
ReFreshLV()
GuiControl,, NoteDetailPreviewBox, %FileRebuildLineOne%
}
;update the preview
if (A_GuiEvent = "I" && InStr(ErrorLevel, "S", true))
{
	global LVSelectedROW = A_EventInfo
    LV_GetText(RowText, A_EventInfo,4)  ; Get the text from the row's first field.
    FileRead, NoteFile, %U_NotePath%%RowText%
    FileReadLine,NoteDetails, %U_NotePath%%RowText%, 1
	NoteBody := SubStr(NoteFile, InStr(NoteFile, "`n") + 1)
    GuiControl,, PreviewBox, %NoteBody%
    GuiControl,, NoteDetailPreviewBox, %NoteDetails%
}
return
3GuiEscape: 
Gui, 3:Destroy 
return
2GuiEscape: 
Gui, 2:Destroy 
return
GuiEscape: 
Gui, Destroy
return

About:
{
MsgBox FlatNotes Version 1.0.0 May 2020
return
}

Library:
{
if WinExist("FlatNotes - Library")
{
	Gui, 1:destroy
	return
}
firstDown = 1
Gui, 1:New,, FlatNotes - Library
Gui, 1:Margin , 0, 0
Gui, 1:Font, s10, Verdana, white
Gui, 1:Color,%U_SBG%, %U_MBG%
Gui, 1:Add,Edit, Cffffff w530 x-3 y0 vSearchTerm gSearch
Gui, 1:Add, ListView, LV0x10000 -ReadOnly grid r8 w530 x-3 C%U_MFC% vLV gNoteListView +altsubmit -Multi, Title|Body|Created|FileName
Gui, 1:Add,Edit, r0 h0  vFake,
GuiControl, Hide, Fake
Gui, 1:Add,Text, r1 w530 Center C%U_SFC% vNoteDetailPreviewBox gNoteDetailPreviewBoxClick,
Gui, 1:Add,Edit,  r7 w530 x-3 yp+18 C%U_MFC% vPreviewBox,

MakeFileList()

Gui, 1:SHOW, w510 h338
isFristRun = 0
return
}
;------------------------------------------
;Main window shortcut keys below this point
;------------------------------------------
#IfWinActive, FlatNotes - Library
{
^l::
!l::
{
ControlFocus, SysListView321, FlatNotes - Library
return
}
^s::
^f::
!s::
!f::
{
ControlFocus, Edit1, FlatNotes - Library
return
}
^e::
^p::
!e::
!p::
{
ControlFocus, Edit3, FlatNotes - Library
return
}
Down::
ControlGetFocus, OutputVar, FlatNotes - Library
		{
		 If (OutputVar == "Edit1"){
			ControlFocus, SysListView321, FlatNotes - Library
			return
		}else
			Down::Down
}
^Enter::
{

ControlGetFocus, OutputVar, FlatNotes - Library
		if(OutputVar == "SysListView321"){
			global LVSelectedROW
			LV_GetText(RowText, LVSelectedROW)
			TmpFileSafeName := RegExReplace(RowText, "\*|\?|\||/|""|:|<|>" , Replacement := "_")
			FilePath = %U_NotePath%%TmpFileSafeName%.txt
			FileRead, MyFile, %FilePath%
			NoteBody := SubStr(MyFile, InStr(MyFile, "`n") + 1)
			clipboard = %NoteBody%
			ToolTip Text: "%RowText%" Copied to clipboard
			SetTimer, KillToolTip, 500
			Gui, 1:Destroy
			return
			}else
			^Enter::^Enter
}

^+Enter::
{

ControlGetFocus, OutputVar, FlatNotes - Library
		if(OutputVar == "SysListView321"){
			global LVSelectedROW
			LV_GetText(RowText, LVSelectedROW)
			TmpFileSafeName := RegExReplace(RowText, "\*|\?|\||/|""|:|<|>" , Replacement := "_")
			FilePath = %U_NotePath%%TmpFileSafeName%.txt
			FileReadLine, MyFile, %FilePath%,2
			clipboard = %MyFile%
			ToolTip Text: "%RowText%" Copied to clipboard
			SetTimer, KillToolTip, 500
			Gui, 1:Destroy
			return
			}else
			^+Enter::^+Enter
}

Enter::
{

ControlGetFocus, OutputVar, FlatNotes - Library
		 If (OutputVar == "Edit1"){
			GuiControlGet, SearchTerm
			FileSafeSearchTerm := RegExReplace(SearchTerm, "\*|\?|\||/|""|:|<|>" , Replacement := "_")
			CheckForOldNote = %U_NotePath%%FileSafeSearchTerm%.txt
			FileRead, MyFile, %CheckForOldNote%
			
			BuildGUI2()
			GuiControl,, QuickNoteName,%SearchTerm%
			GuiControl,, FileSafeName,%FileSafeSearchTerm%
			GuiControl, +Redraw, FileSafeName
			GuiControl, +Redraw, QuickNoteName
			ControlFocus, Edit2, FlatNote - QuickNote 
			
			if (MyFile !="")
			{
			MyNewFile := SubStr(MyFile, InStr(MyFile, "`n") + 1)
			GuiControl,, QuickNoteBody,%MyNewFile%
			GuiControl, +Redraw, QuickNoteBody
			}
			return
			}
		if(OutputVar == "SysListView321"){
			global LVSelectedROW
			LV_GetText(RowText, LVSelectedROW)
			clipboard = %RowText%
			ToolTip Text: "%RowText%" Copied to clipboard
			SetTimer, KillToolTip, 500
			Gui, 1:Destroy
			return
			}
		if(OutputVar == "Edit3"){
			global LVSelectedROW
			LV_GetText(RowText, LVSelectedROW,1)
			FileSafeName := RegExReplace(RowText, "\*|\?|\||/|""|:|<|>" , Replacement := "_")
			GuiControlGet, NoteDetailPreviewBox
			GuiControlGet, PreviewBox
			LVBodyUpdate := StrSplit(PreviewBox , "`n")  
			ReCombine =%NoteDetailPreviewBox%`n%PreviewBox%
			SaveFile(RowText,FileSafeName,ReCombine)
			ToolTip Saved 
			LV_Modify(LVSelectedROW , ,RowText, LVBodyUpdate[1])
			SetTimer, KillToolTip, 500
			return
		}else
			Enter::Enter
}

esc::
ControlGetFocus, OutputVar, FlatNotes - Library
{
		If (OutputVar == "Edit2"){
			esc::+enter
			return
			}
		If (OutputVar == "Edit3"){
			Gui,1:destroy 
			return
			}
		If (OutputVar == "Edit1"){
			Gui,1:destroy 
			return
			}
		If (OutputVar == "SysListView321"){
			Gui,1:destroy 
			return
			}
}

del::
ControlGetFocus, OutputVar, FlatNotes - Library
{
		 If (OutputVar == "SysListView321"){
		 global LVSelectedROW
		 SaveRowNumber = %LVSelectedROW%
		 LV_GetText(RowText, LVSelectedROW)
		 FileSafeName := RegExReplace(RowText, "\*|\?|\||/|""|:|<|>" , Replacement := "_")
		 MsgBox , 4, Delete?, Delete: %FileSafeName%.txt
		 IfMsgBox, No
			Return 
		 IfMsgBox, Yes
			FileRecycle %U_NotePath%%FileSafeName%.txt
			MakeFileListNoRefresh()
			LV_Delete(LVSelectedROW)
			RowsCount := LV_GetCount()
			if (RowsCount > SaveRowNumber) {
				NextUp = %SaveRowNumber%
				LV_GetText(NextUpName, NextUp , 1)
			}else
				NextUp = %RowsCount%
				LV_GetText(NextUpName, NextUp , 1)
				
				
			FileSafeName := RegExReplace(NextUpName, "\*|\?|\||/|""|:|<|>" , Replacement := "_")
			FileReadLine,NextUpDetails,%U_NotePath%%FileSafeName%.txt,1
			FileRead,NextUpBody,%U_NotePath%%FileSafeName%.txt
			NextUpBody := SubStr(NextUpBody, InStr(NextUpBody, "`n") + 1)
			GuiControl,, PreviewBox,%NextUpBody%
			GuiControl,, NoteDetailPreviewBox, %NextUpDetails%
		 }else
			del::del
}
Options:
{
IniRead, U_Theme, %iniPath%, Theme, UserSetting , Aqua-Dark
IniRead, U_NotePath, %iniPath%, General, MyNotePath , %U_NotePath%

Gui, 3:New,,FlatNotes - Options
Gui, 3:Add,Text,,Theme Selection:
Gui, 3:Add,DropDownList, Choose%U_Theme% vColorChoice gColorPicked, Aqua-Dark|Black|Blue-Dark|Blue-Light|Brown-Dark|Green-Dark|Green-Light|Orange-Light|Pink-Light|Violet-Dark|Violet-Light|White|Yellow-Dark|Yellow-Light
Gui, 3:Add,Text,, Notes storage folder:
Gui, 3:Add,Edit, disabled r1 w175 vNotesStorageFolder gFolderEdit, %U_NotePath%
Gui, 3:Add,Button, gFolderSelect, Select a folder.
Gui, 3:Add,Text,,Settings are saved automatically.
Gui, 3:Add,Text,,Press Esc to exit.
Gui, 3:SHOW
WinSet, AlwaysOnTop, On, FlatNotes - Options
Return
}
return
}
FolderEdit:
{
if (A_GuiEvent = "Normal")
	{
	tooltip %A_GuiEvent%
	}
return
}
FolderSelect:
{
WinSet, AlwaysOnTop, Off, FlatNotes - Options
FileSelectFolder, NewNotesFolder, , 123
if NewNotesFolder =
    MsgBox, You didn't select a folder.
else
    GuiControl,,NotesStorageFolder,%NewNotesFolder%\
	IniWrite, %NewNotesFolder%\, %iniPath%, General, MyNotePath
	WinSet, AlwaysOnTop, On, FlatNotes - Options
	return
return
}
Exit:
{
ExitApp
return
}

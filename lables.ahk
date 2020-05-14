Label1:
{
	if (U_Capslock = "1"){
		return
}
	BuildGUI1()
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
MyNewFile := SubStr(MyFile, InStr(MyFile, "`n") + 1)
GuiControl,, QuickNoteBody,%MyNewFile%
GuiControl, +Redraw, QuickNoteBody
}
return
}
SaveButton:
{
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
}

QuickSafeNameUpdate:
{
GuiControlGet, QuickNoteName
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
}

About:
{
MsgBox FlatNotes Version 1.1.0 May 2020
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
		if (A_GuiEvent = "Normal" && ColorPicked = "Black" ) 
		{
			IniWrite, 000000,%iniPath%,Colors,MainBackgroundColor
			IniWrite, ffffff,%iniPath%,Colors,SubBackgroundColor
			IniWrite, ffffff,%iniPath%,Colors,MainFontColor
			IniWrite, 000000,%iniPath%,Colors,SubFontColor
			IniWrite, ffffff,%iniPath%,Colors,MainSortFontColor
			IniWrite, 777700,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0x444444,%iniPath%,Colors,RowSelectColor
			IniWrite, 0xffffff,%iniPath%,Colors,RowSelectTextColor
			
			IniWrite, 2, %iniPath%, Theme, UserSetting
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "White" ) 
		{
			IniWrite, ffffff,%iniPath%,Colors,MainBackgroundColor
			IniWrite, 000000,%iniPath%,Colors,SubBackgroundColor
			IniWrite, 000000,%iniPath%,Colors,MainFontColor
			IniWrite, ffffff,%iniPath%,Colors,SubFontColor
			IniWrite, 000000,%iniPath%,Colors,MainSortFontColor
			IniWrite, bbbb00,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0xdddddd,%iniPath%,Colors,RowSelectColor
			IniWrite, 0x000000,%iniPath%,Colors,RowSelectTextColor
			
			IniWrite, 16, %iniPath%, Theme, UserSetting
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "Chalkboard" ) 
		{		
			IniWrite, 003300,%iniPath%,Colors,MainBackgroundColor
			IniWrite, 001100,%iniPath%,Colors,SubBackgroundColor
			IniWrite, ffffff,%iniPath%,Colors,MainFontColor
			IniWrite, aaaaff,%iniPath%,Colors,SubFontColor
			IniWrite, ffff00,%iniPath%,Colors,MainSortFontColor
			IniWrite, ffff00,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0x007700,%iniPath%,Colors,RowSelectColor
			IniWrite, 0xaaffaa,%iniPath%,Colors,RowSelectTextColor
			
			IniWrite, 4, %iniPath%, Theme, UserSetting
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "Rose" ) 
		{	
			IniWrite, 10, %iniPath%, Theme, UserSetting	
			IniWrite, dd9999,%iniPath%,Colors,MainBackgroundColor
			IniWrite, FFFFFF,%iniPath%,Colors,SubBackgroundColor
			IniWrite, 000000,%iniPath%,Colors,MainFontColor
			IniWrite, 000000,%iniPath%,Colors,SubFontColor
			IniWrite, dd9999,%iniPath%,Colors,MainSortFontColor
			IniWrite, 000000,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0xffaaaa,%iniPath%,Colors,RowSelectColor
			IniWrite, 0x000000,%iniPath%,Colors,RowSelectTextColor
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "Sugar Cookie" ) 
		{
			IniWrite, 14, %iniPath%, Theme, UserSetting		
			IniWrite, ffddff,%iniPath%,Colors,MainBackgroundColor
			IniWrite, FFFFFF,%iniPath%,Colors,SubBackgroundColor
			IniWrite, 000000,%iniPath%,Colors,MainFontColor
			IniWrite, 000000,%iniPath%,Colors,SubFontColor
			IniWrite, dd99dd,%iniPath%,Colors,MainSortFontColor
			IniWrite, 000000,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0xfff0ff,%iniPath%,Colors,RowSelectColor
			IniWrite, 0x000000,%iniPath%,Colors,RowSelectTextColor
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
			
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "Pink" )
		{
			IniWrite, 9, %iniPath%, Theme, UserSetting		
			IniWrite, dd99dd,%iniPath%,Colors,MainBackgroundColor
			IniWrite, FFFFFF,%iniPath%,Colors,SubBackgroundColor
			IniWrite, 000000,%iniPath%,Colors,MainFontColor
			IniWrite, 000000,%iniPath%,Colors,SubFontColor
			IniWrite, dd99dd,%iniPath%,Colors,MainSortFontColor
			IniWrite, 00000r0,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0xffddff,%iniPath%,Colors,RowSelectColor
			IniWrite, 0x000000,%iniPath%,Colors,RowSelectTextColor
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
			
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "Sensual" ) 
		{
			IniWrite, 12, %iniPath%, Theme, UserSetting		
			IniWrite, 000000,%iniPath%,Colors,MainBackgroundColor
			IniWrite, eeccee,%iniPath%,Colors,SubBackgroundColor
			IniWrite, ffffff,%iniPath%,Colors,MainFontColor
			IniWrite, 000000,%iniPath%,Colors,SubFontColor
			IniWrite, ffffff,%iniPath%,Colors,MainSortFontColor
			IniWrite, ffffff,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0xffddff,%iniPath%,Colors,RowSelectColor
			IniWrite, 0x000000,%iniPath%,Colors,RowSelectTextColor
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "Chocolate" ) 
		{
			IniWrite, 5, %iniPath%, Theme, UserSetting		
			IniWrite, 0x331100,%iniPath%,Colors,MainBackgroundColor
			IniWrite, 0x885533,%iniPath%,Colors,SubBackgroundColor
			IniWrite, 0xffffff,%iniPath%,Colors,MainFontColor
			IniWrite, 0xffffff,%iniPath%,Colors,SubFontColor
			IniWrite, 0xaa8855,%iniPath%,Colors,MainSortFontColor
			IniWrite, 0xffddaa,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0xaa8866,%iniPath%,Colors,RowSelectColor
			IniWrite, 0x331100,%iniPath%,Colors,RowSelectTextColor
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}		
		if (A_GuiEvent = "Normal" && ColorPicked = "Velvet" )
		{
			IniWrite, 15, %iniPath%, Theme, UserSetting		
			IniWrite, 0x330033,%iniPath%,Colors,MainBackgroundColor
			IniWrite, 0x000000,%iniPath%,Colors,SubBackgroundColor
			IniWrite, 0xffffff,%iniPath%,Colors,MainFontColor
			IniWrite, 0xeeeeff,%iniPath%,Colors,SubFontColor
			IniWrite, 0xdd99dd,%iniPath%,Colors,MainSortFontColor
			IniWrite, 0xffffff,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0x000000,%iniPath%,Colors,RowSelectColor
			IniWrite, 0xffffff,%iniPath%,Colors,RowSelectTextColor
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "Lavender" ) 
		{
			IniWrite, 6, %iniPath%, Theme, UserSetting		
			IniWrite, 0x9999dd,%iniPath%,Colors,MainBackgroundColor
			IniWrite, 0xFFFFFF,%iniPath%,Colors,SubBackgroundColor
			IniWrite, 0x000000,%iniPath%,Colors,MainFontColor
			IniWrite, 0x000000,%iniPath%,Colors,SubFontColor
			IniWrite, 0x9999dd,%iniPath%,Colors,MainSortFontColor
			IniWrite, 0xffffff,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0xaaaaff,%iniPath%,Colors,RowSelectColor
			IniWrite, 0x000000,%iniPath%,Colors,RowSelectTextColor
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "Seafoam" ) 
		{
			IniWrite, 11, %iniPath%, Theme, UserSetting		
			IniWrite, 0x99dddd,%iniPath%,Colors,MainBackgroundColor
			IniWrite, 0xFFFFFF,%iniPath%,Colors,SubBackgroundColor
			IniWrite, 0x000000,%iniPath%,Colors,MainFontColor
			IniWrite, 0x000000,%iniPath%,Colors,SubFontColor
			IniWrite, 0x99dddd,%iniPath%,Colors,MainSortFontColor
			IniWrite, 0x000000,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0xddf0f0,%iniPath%,Colors,RowSelectColor
			IniWrite, 0x000000,%iniPath%,Colors,RowSelectTextColor
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "Sky" ) 
		{
			IniWrite, 13, %iniPath%, Theme, UserSetting		
			IniWrite, 0x999dd,%iniPath%,Colors,MainBackgroundColor
			IniWrite, 0xFFFFFF,%iniPath%,Colors,SubBackgroundColor
			IniWrite, 0x000000,%iniPath%,Colors,MainFontColor
			IniWrite, 0x000000,%iniPath%,Colors,SubFontColor
			IniWrite, 0x9999dd,%iniPath%,Colors,MainSortFontColor
			IniWrite, 0x000000,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0xeeeeff,%iniPath%,Colors,RowSelectColor
			IniWrite, 0x000000,%iniPath%,Colors,RowSelectTextColor
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "Notepaper" ) 
		{
			IniWrite, 7, %iniPath%, Theme, UserSetting		
			IniWrite, 0xdddd99,%iniPath%,Colors,MainBackgroundColor
			IniWrite, 0xFFFFFF,%iniPath%,Colors,SubBackgroundColor
			IniWrite, 0x000000,%iniPath%,Colors,MainFontColor
			IniWrite, 0x000000,%iniPath%,Colors,SubFontColor
			IniWrite, 0xdddd99,%iniPath%,Colors,MainSortFontColor
			IniWrite, 0x000000,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0xffff99,%iniPath%,Colors,RowSelectColor
			IniWrite, 0x000000,%iniPath%,Colors,RowSelectTextColor
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "Orange Cream" ) 
		{
			IniWrite, 8, %iniPath%, Theme, UserSetting		
			IniWrite, 0xdd9933,%iniPath%,Colors,MainBackgroundColor
			IniWrite, 0xFFFFFF,%iniPath%,Colors,SubBackgroundColor
			IniWrite, 0x000000,%iniPath%,Colors,MainFontColor
			IniWrite, 0x000000,%iniPath%,Colors,SubFontColor
			IniWrite, 0xdd9933,%iniPath%,Colors,MainSortFontColor
			IniWrite, 0x000000,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0xffaa55,%iniPath%,Colors,RowSelectColor
			IniWrite, 0x000000,%iniPath%,Colors,RowSelectTextColor
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "Aqua" ) 
		{
			IniWrite, 1, %iniPath%, Theme, UserSetting		
			IniWrite, 0x005867,%iniPath%,Colors,MainBackgroundColor
			IniWrite, 0x0088aa,%iniPath%,Colors,SubBackgroundColor
			IniWrite, 0xffffff,%iniPath%,Colors,MainFontColor
			IniWrite, 0xffffff,%iniPath%,Colors,SubFontColor
			IniWrite, 0x99aaee,%iniPath%,Colors,MainSortFontColor
			IniWrite, 0xffffff,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0x00aacc,%iniPath%,Colors,RowSelectColor
			IniWrite, 0x000000,%iniPath%,Colors,RowSelectTextColor
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}
		if (A_GuiEvent = "Normal" && ColorPicked = "Brown Mustard" ) 
		{
			IniWrite, 3, %iniPath%, Theme, UserSetting		
			IniWrite, 0xaa7700,%iniPath%,Colors,MainBackgroundColor
			IniWrite, 0xFFFFFF,%iniPath%,Colors,SubBackgroundColor
			IniWrite, 0x000000,%iniPath%,Colors,MainFontColor
			IniWrite, 0x000000,%iniPath%,Colors,SubFontColor
			IniWrite, 0xaa7700,%iniPath%,Colors,MainSortFontColor
			IniWrite, 0x000000,%iniPath%,Colors,SearchBoxFontColor
			IniWrite, 0xcc9900,%iniPath%,Colors,RowSelectColor
			IniWrite, 0x000000,%iniPath%,Colors,RowSelectTextColor
			
			
			IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor
			IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor
			IniRead, U_MFC, %iniPath%, Colors, MainFontColor
			IniRead, U_SFC, %iniPath%, Colors, SubFontColor
			IniRead, U_MSFC, %iniPath%, Colors, MainSortFontColor
			IniRead, U_FBCA, %iniPath%, Colors, SearchBoxFontColor
			IniRead, rowSelectColor, %iniPath%, Colors, RowSelectColor
			IniRead, rowSelectTextColor, %iniPath%, Colors, RowSelectTextColor
		}
		
		Gui, 1:Destroy
		goto vk14
		if WinExist("FlatNotes - Options")
			WinActivate ; use the window found above
		else
			WinActivate, FlatNotes
	}
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
			MsgBox, You didn't select a folder.
		else
			GuiControl,,NotesStorageFolder,%NewNotesFolder%\
		IniWrite, %NewNotesFolder%\, %iniPath%, General, MyNotePath
		WinSet, AlwaysOnTop, On, FlatNotes - Options
		return
	}
	
	Options:
	{
		IniRead, U_Theme, %iniPath%, Theme, UserSetting , Aqua-Dark
		IniRead, U_NotePath, %iniPath%, General, MyNotePath , %U_NotePath%
		IniRead, U_UserSetKey, %iniPath%, General, UserSetKey , 1
		IniRead, sendCtrlC, %iniPath%, General, sendCtrlC, 1
		
		
		Gui3W = 200
		Gui, 3:New,,FlatNotes - Options
		Gui, 3:Add,CheckBox, vSetCtrlC gCtrlCToggle, Send Ctrl+C when using the quick note hotkey.
		Gui, 3:Add,Text,,Theme Selection:
		Gui, 3:Add,DropDownList, Choose%U_Theme% vColorChoice gColorPicked, Aqua|Black|Brown Mustard|Chalkboard|Chocolate|Lavender|Notepaper|Orange Cream|Pink|Rose|Seafoam|Sensual|Sky|Sugar Cookie|Velvet|White
		Gui, 3:Add,Text,, Notes storage folder:
		Gui, 3:Add,Edit, disabled r1 w%Gui3W% vNotesStorageFolder, %U_NotePath%
		Gui, 3:Add,Button, gFolderSelect, Select a folder.
		Gui, 3:Add, CheckBox, vUseCapslock gUseCapslockToggle, Use Capslock for Library?
		GuiControl,,UseCapslock,%U_UserSetKey%
		GuiControl,,SetCtrlC,%sendCtrlC%
		
		HotkeyNames := ["Show Library Window","Quick New Note"]
		Loop,% 2 {
			HotkeyNameTmp := HotkeyNames[A_Index]
			Gui, 3:Add, Text, xm, Hotkey %HotkeyNameTmp%:
			IniRead, savedHK%A_Index%, settings.ini, Hotkeys, %A_Index%, %A_Space%
			If savedHK%A_Index%                                       
				Hotkey,% savedHK%A_Index%, Label%A_Index%                 
			StringReplace, noMods, savedHK%A_Index%, ~                  
			StringReplace, noMods, noMods, #,,UseErrorLevel              
			Gui, 3:Add, Hotkey, x+5 vHK%A_Index% gLabel, %noMods%           
			Gui, 3:Add, CheckBox, x+5 vCB%A_Index% Checked%ErrorLevel%, Win  
		}                                                               
		if (U_UserSetKey = 1)
			GuiControl, Disable, msctls_hotkey321
		Gui, 3:Add,Text,x0 w%Gui3W% +Center,Settings are saved automatically.
		Gui, 3:Add,Text,x0 w%Gui3W% +Center,Press Esc to exit and reload.
		Gui, 3:SHOW
		WinSet, AlwaysOnTop, On, FlatNotes - Options
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
	
	
	
	
	
	
	
	
	
	
	
	

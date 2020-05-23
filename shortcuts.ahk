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
		sendinput {tab}
		return
		}else
			Down::Down
	return
}
Enter::
{

ControlGetFocus, OutputVar, FlatNotes - Library
		if(OutputVar == "SysListView321"){
			global LVSelectedROW
			LV_GetText(RowText, LVSelectedROW,2)
			if (RowText="Title")
				return
			TmpFileSafeName := NameEncode(RowText)
			FilePath = %U_NotePath%%TmpFileSafeName%.txt
			FileRead, MyFile, %FilePath%
			NoteBody := SubStr(MyFile, InStr(MyFile, "`n") + 1)
			clipboard = %NoteBody%
			ToolTip Text: "%RowText%" Copied to clipboard
			SetTimer, KillToolTip, -500
			WinHide, FlatNotes - Library
			g1Open=0
			return
			}else
			Enter::Enter
}

^+Enter::
{

ControlGetFocus, OutputVar, FlatNotes - Library
		if(OutputVar == "SysListView321"){
			global LVSelectedROW
			LV_GetText(RowText, LVSelectedROW,2)
			TmpFileSafeName := NameEncode(RowText)
			FilePath = %U_NotePath%%TmpFileSafeName%.txt
			FileReadLine, MyFile, %FilePath%,2
			clipboard = %MyFile%
			ToolTip Text: "%RowText%" Copied to clipboard
			SetTimer, KillToolTip, -500
			gosub GuiEscape
			return
			}else
			^+Enter::^+Enter
}

^Enter::
{
ControlGetFocus, OutputVar, FlatNotes - Library
		 If (OutputVar == "Edit1"){
			GuiControlGet, SearchTerm
			;Remove stray whitespace from front and back
			;SearchTerm := Ltrim(SearchTerm," ")
			;SearchTerm := Rtrim(SearchTerm," ")
			FileSafeSearchTerm := NameEncode(SearchTerm)
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
			LV_GetText(RowText, LVSelectedROW,2)
			clipboard = %RowText%
			ToolTip Text: "%RowText%" Copied to clipboard
			SetTimer, KillToolTip, -500
			gosub GuiEscape
			return
			}
		if(OutputVar == "Edit3"){
			global LVSelectedROW
			if (LVSelectedROW="")
				LVSelectedROW=1
			LV_GetText(RowText, LVSelectedROW,2)
			FileSafeName := NameEncode(RowText)
			GuiControlGet, PreviewBox
			SaveFile(RowText,FileSafeName,PreviewBox,1)
			iniRead,OldAdd,%detailsPath%%FileSafeName%.ini,INFO,Add
			FileReadLine, NewBodyText, %U_NotePath%%FileSafeName%.txt,1
			LV_Modify(LVSelectedROW,,, RowText, NewBodyText)
			ToolTip Saved 
			SetTimer, KillToolTip, -500
			unsaveddataEdit3 = 0
			return
		}else
			^Enter::^Enter
}
del::
ControlGetFocus, OutputVar, FlatNotes - Library
{
		 If (OutputVar == "SysListView321"){
		 global LVSelectedROW
		 SaveRowNumber = %LVSelectedROW%
		 LV_GetText(FileName, LVSelectedROW,8)
		 iniFileName = RegExReplace(FileName, "\.txt(?:^|$|\r\n|\r|\n)", Replacement := ".ini")
		 MsgBox , 52, Delete - Note , Delete: %FileName%.txt
		 IfMsgBox, No
			Return 
		 IfMsgBox, Yes
			FileRecycle %U_NotePath%%FileName%
			FileRecycle %detailsPath%%iniFileName%

			for Each, Note in MyNotesArray{
					If (Note.8 = FileName){
						MyNotesArray.RemoveAt(Each)
					}
				}
			LV_Delete(LVSelectedROW)
			RowsCount := LV_GetCount()
			if (RowsCount > SaveRowNumber) {
				NextUp = %SaveRowNumber%
				LV_GetText(NextUpName, NextUp , 2)
			}else
				NextUp = %RowsCount%
				LV_GetText(NextUpName, NextUp , 2)
				
				
			FileSafeName := NameEncode(NextUpName)
			iniRead,NextUpAddedDate,%detailsPath%%FileSafeName%,Add
			iniRead,NextUpModdedDate,%detailsPath%%FileSafeName%,Mod

			FileRead,NextUpBody,%U_NotePath%%FileSafeName%.txt
	
			GuiControl,, PreviewBox,%NextUpBody%
			GuiControl,, TitleBar, %NextUpName%
			GuiControl,, StatusbarM,M: %NextUpModdedDate%
			GuiControl,, StatusbarA,A: %NextUpAddedDate%
		 }else
			del::del
}
MButton::
{
	ControlGetFocus, OutputVar, FlatNotes - Library
	{
		MouseGetPos, mxPos, myPos
		MouseClick, left, %mxPos%, %myPos%
		LV_GetText(StickyNoteName,LastRowSelected,2)
		LV_GetText(StickyNoteFile,LastRowSelected,8)
		Build_Stickynote_GUI(StickyNoteName,StickyNoteFile)
	}
	return
}
}
#IfWinActive

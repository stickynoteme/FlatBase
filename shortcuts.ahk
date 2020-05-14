
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
		 MsgBox , 52, Delete - Note , Delete: %FileSafeName%.txt
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
}
#IfWinActive

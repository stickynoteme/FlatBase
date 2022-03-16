;---------------------
;Other shortcut keys
;---------------------
#IfWinActive, FlatNotes - Note From Template
{
!enter::
	gosub ntInsertB
	return
+enter::
	gosub ntInsert
	return
}
;------------------------------------------
;Main window shortcut keys below this point
;------------------------------------------
#IfWinActive, FlatNotes - Library
{
Down::
ControlGetFocus, OutputVar, FlatNotes - Library
{
	 If (OutputVar == "Edit1"){
		sendinput {tab}{tab}
		return
		}else
			Down::Down
	return
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

del::
ControlGetFocus, OutputVar, FlatNotes - Library
{
		 If (OutputVar == "SysListView321"){
		 global LVSelectedROW
		 SaveRowNumber = %LVSelectedROW%
		 LV_GetText(FileName, LVSelectedROW,8)
		 iniFileName := RegExReplace(FileName, "\.txt(?:^|$|\r\n|\r|\n)", Replacement := ".ini")
		 MsgBox , 0x40024, Delete - Note , Delete: %FileName%
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

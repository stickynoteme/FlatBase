; --------------------—
; Handle Window specific things.
; ---------------------
;handle window resize
treeGuiSize:
  If A_EventInfo = 1  ; If minimized.
    Return

 TreeLibW := A_GuiWidth
 TreeLibH := A_GuiHeight

global TreeCol1W := 125 + ScrollbarW
global TreeCol1WSBH := TreeCol1W - ScrollbarW
global TreeCol1X := 0
global TreeCol1H := TreeLibH
global TreeCol2W := TreeLibW - TreeCol1W - TreeBorder + ScrollbarW + ScrollbarW
global TreeCol2X := TreeCol1W + TreeBorder - ScrollbarW
global TreeNameH = 20
global TreePreviewH := TreeLibH - TreeNameH - TreeBorder
global TreePreviewY := TreeNameH + TreeBorder + TreeBorder + TreeBorder + TreeBorder

  GuiControl Move, TVNoteTree, h%TreeCol1H% w%TreeCol1W%
  GuiControl Move, TVBGLB1, w%TreeCol2W%
  GuiControl Move, TVNoteName, h%TreeNameH% w%TreeCol2W%
  GuiControl Move, TVNotePreview, h%TreePreviewH% w%TreeCol2W%
Return


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
#IfWinActive, FlatNote - QuickNote
{
!enter::	
	ControlClick,Button1,FlatNote - QuickNote
	return
+enter::
	ControlClick,Button1,FlatNote - QuickNote
	return
}
#IfWinActive, FlatNote - Tree
{
!enter::	
	ControlClick,Button1,FlatNote - Tree
	tooltip, saved
	settimer, KillToolTip, -500
	return
+enter::
	ControlClick,Button1,FlatNote - Tree
	tooltip, saved
	settimer, KillToolTip, -500
	return
}
;------------------------------------------
;Main window shortcut keys below this point
;------------------------------------------
#IfWinActive, FlatNotes - Library

{

^b::
{
	LV@sel_col = 3
	ColEditName :=  ColList[LV@sel_col]
	gosub build_SKColEdit
	return
}

^t::
{
	LV@sel_col = 10
	ColEditName :=  ColList[LV@sel_col]
	gosub build_SKColEdit
	return
}

^k::
{
	LV@sel_col = 11
	ColEditName :=  ColList[LV@sel_col]
	gosub build_SKColEdit
	return
}

^p::
{
	LV@sel_col = 12
	ColEditName :=  ColList[LV@sel_col]
	gosub build_SKColEdit
	return
}

^n::
{
	LV@sel_col = 3
	ColEditName :=  ColList[LV@sel_col]
	LV_GetText(TitleOldFile, LVSelectedROW,8)
	gosub build_SKNameEdit
	return
}

Down::
ControlGetFocus, OutputVar, FlatNotes - Library
{
	 If (OutputVar == "Edit1"){
		;sendinput {tab}{tab}{tab}
		ControlFocus,SysListView321,FlatNotes - Library
		return
		}else
			Down::Down
	return
}
Enter::
{
ControlGetFocus, OutputVar, FlatNotes - Library
		if(OutputVar == "SysListView321"){
		LV_GetText(FileTmp, LVSelectedROW, 8)
		fileread,clipboard,%U_NotePath%%FileTmp%
		Tooltip % "Body Copied"
		SetTimer, KillToolTip, -1000
		gosub GuiEscape
		return
		}else
			Enter::Enter
}

^Enter::
{
ControlGetFocus, OutputVar, FlatNotes - Library
	if(OutputVar == "SysListView321"){
		LV_GetText(FileTmp, LVSelectedROW, 8)
		FileTmp := RegExReplace(FileTmp, "\.txt(?:^|$|\r\n|\r|\n)", Replacement := ".clipboard")
		
		if (FileExist(clipPath FileTmp)){
			FileRead, clipboard, *c %clipPath%%FileTmp%
			Tooltip % "Packaged Clipboard Copied"
			SetTimer, KillToolTip, -1000
			gosub GuiEscape
		}
		return
	}else
		^Enter::^Enter
}

+Enter::
{
ControlGetFocus, OutputVar, FlatNotes - Library
	If (OutputVar == "Edit1"){
		gosub NewAndSaveHK
	}else if(OutputVar == "SysListView321"){
			LV_GetText(NameTmp, LVSelectedROW,2)
			clipboard := NameTmp
			Tooltip % "Name Copied"
			SetTimer, KillToolTip, -500
			gosub GuiEscape
			return
		}else
		+Enter::+Enter
}

del::
ControlGetFocus, OutputVar, FlatNotes - Library
{
		 If (OutputVar == "SysListView321"){
		 global LVSelectedROW
		 SelectedRows := trim(SelectedRows)
		 SelectedRowsArray := StrSplit(SelectedRows," "," ")
		 SelectedRowsArrayLength := SelectedRowsArray.Count() - 1
		 SaveRowNumber = %LVSelectedROW%
		 
		 LV_GetText(FileName, LVSelectedROW,8)

		 MsgBox , 0x40024, Delete - Note , Delete: %FileName% and %SelectedRowsArrayLength% others?
		 IfMsgBox, No
			Return 
		 IfMsgBox, Yes
			TVReDraw = 1
			
			SelectedRowsArray:=ObjectSort(SelectedRowsArray,,,true)
			;v = row numbers
			for k, v in SelectedRowsArray{
				;error checking to see each row before it's deleted.
				;msgbox % v
				LV_GetText(FileName, v,2)
				LV_GetText(RawName, v,2)
				FileName := NameEncode(FileName)
				
				
				if (FileName == "") {
					msgbox, Error no name, can't delete.
				}else {	
								
				FileRecycle %U_NotePath%%FileName%.txt
				FileRecycle %U_NotePath%%FileName%.ini
				FileRecycle %U_NotePath%%FileName%.clipboard
				FileRecycle %U_NotePath%%FileName%.lnk
				
							; remove from MyNoteArray
				for Each, Note in MyNotesArray{
					If (Note.2 == RawName){
						tooltip, %FileName% has been deleted
						MyNotesArray.RemoveAt(Each)
					}
				}
				; remove from ListView
				LV_Delete(v)
				}
			}
			
			;Display a new LV if any.
			
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
}
#IfWinActive

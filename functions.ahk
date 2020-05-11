BuildGUI2(){
global FileSafeClipBoard
global CheckForOldNote 
global OldNoteData
global QuickNoteName
global QuickNoteBody
global FileSafeName
global U_SFC
global U_MFC
global U_MBG
global U_SBG
FileSafeClipBoard := RegExReplace(clipboard, "\*|\?|\||/|""|:|<|>"yyyy , Replacement := "_")
CheckForOldNote = %A_WorkingDir%\MyNotes\%FileSafeClipBoard%.txt
FileRead, OldNoteData, %CheckForOldNote%
MouseGetPos, xPos, yPos
xPos /= 1.5
yPos /= 1.15
Gui, 2:New,, FlatNote - QuickNote
Gui, 2:Margin , 0, 0
Gui, 2:Font, s10, Verdana, white
Gui, 2:Color,%U_SBG%, %U_MBG%
Gui, 2:Add,Edit, C%U_MFC% w250 vQuickNoteName gQuickSafeNameUpdate
Gui, 2:Add,Edit, -WantReturn C%U_MFC% r7 w500 vQuickNoteBody
Gui, 2:Add,Text, C%U_SFC% x255 y3 w245 vFileSafeName,
Gui, 2:Add, Button,x-1000 default gSaveButton y-1000, &Save
Gui, 2:SHOW, w500 h145 x%xPos% y%yPos%
}

MakeFileList(){
FileList := ""
MyNotesArray := {}
Loop, Files, %A_WorkingDir%\MyNotes\*.txt
    FileList .= A_LoopFileName "`n"
;trim off the extra starting newline
	FileList := RTrim(Filelist, "`n")
Loop Parse, FileList, `n
	{
		NoteField := ""
		OldNoteField = NoteField
		FileReadLine, NoteDetails, %A_WorkingDir%\MyNotes\%A_LoopField%, 1
		FileReadLine, NoteField, %A_WorkingDir%\MyNotes\%A_LoopField%, 2

		DetailsSplitArray := StrSplit(NoteDetails ,"||")
		NameField := DetailsSplitArray[1]
		NameField := RTrim(NameField, " ")
		AddedField := DetailsSplitArray[2]
		AddedField := LTrim(AddedField, " C:")
		AddedField := RTrim(AddedField, " ")
		ModifiedField := DetailsSplitArray[2]
		ModifiedField := LTrim(ModifiedField, " M:")


		LV_Add("", NameField, NoteField, AddedField,A_LoopField)
		if (isFristRun != 0){
			MyNotesArray.Push({1:NameField,2:NoteField,3:AddedField,4:A_LoopField})
			}
	} ; File loop end
LV_ModifyCol(1, "145 Logical")
LV_ModifyCol(2, "275")
LV_ModifyCol(3, "75")
LV_ModifyCol(4, "0")
}

MakeFileListNoRefresh(){
FileList := ""
MyNotesArray := {}
Loop, Files, %A_WorkingDir%\MyNotes\*.txt
    FileList .= A_LoopFileName "`n"
;trim off the extra starting newline
	FileList := RTrim(Filelist, "`n")
Loop Parse, FileList, `n
	{
		NoteField := ""
		FileReadLine, NoteDetails, %A_WorkingDir%\MyNotes\%A_LoopField%, 1
		FileReadLine, NoteField, %A_WorkingDir%\MyNotes\%A_LoopField%, 2
		DetailsSplitArray := StrSplit(NoteDetails ,"||")
		NameField := DetailsSplitArray[1]
		NameField := RTrim(NameField, " ")
		AddedField := DetailsSplitArray[2]
		AddedField := LTrim(AddedField, " C:")
		AddedField := RTrim(AddedField, " ")
		ModifiedField := DetailsSplitArray[2]
		ModifiedField := LTrim(ModifiedField, " M:")
		if (isFristRun != 0){
			MyNotesArray.Push({1:NameField,2:NoteField,3:AddedField,4:A_LoopField})
			}
	} ; File loop end
LV_ModifyCol(1, "145 Logical")
LV_ModifyCol(2, "275")
LV_ModifyCol(3, "75")
LV_ModifyCol(4, "0")
}

ReFreshLV(){
global SearchTerm
GuiControlGet, SearchTerm
GuiControl, -Redraw, LV
LV_Delete()
For Each, Note In MyNotesArray
{
		If (InStr(Note.1, SearchTerm) != 0){
         LV_Add("", Note.1, Note.2,Note.3,Note.4)
        }Else if (InStr(Note.2, SearchTerm) != 0)
	   {LV_Add("", Note.1, Note.2,Note.3,Note.4)
	   }Else if (InStr(Note.3, SearchTerm) != 0)
	   {LV_Add("", Note.1, Note.2,Note.3,Note.4)
	   }Else if (InStr(Note.4, SearchTerm) != 0)
	   {LV_Add("", Note.1, Note.2,Note.3,Note.4)
	   }Else
	   
      LV_Add("", Note.1,Note.2,Note.3,Note.4)
	  GuiControl, +Redraw, LV
}
}

SaveFile(QuickNoteName,FileSafeName,QuickNoteBody){
FormatTime, CurrentTimeStamp, %A_Now%, yy/MM/dd

SaveFileName = %A_WorkingDir%\MyNotes\%FileSafeName%.txt
FileReadLine, OldDetails, %SaveFileName%, 1
 RegExMatch(OldDetails, "\d\d/\d\d/\d\d" , CreatedDate)
 QuickNoteBody := SubStr(QuickNoteBody, InStr(QuickNoteBody, "`n") + 1)
if (CreatedDate =="")
{
CreatedDate = %CurrentTimeStamp%
}
FileRecycle, %SaveFileName%
FileLineOne = %QuickNoteName% || C:%CreatedDate% || M:%CurrentTimeStamp%`n
FileAppend , %FileLineOne%%QuickNoteBody%, %SaveFileName%, UTF-8
}
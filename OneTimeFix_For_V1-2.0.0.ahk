#SingleInstance Force
FileEncoding ,UTF-8
CoordMode, mouse, Screen
SetBatchLines, -1

detailsPath := A_WorkingDir "\NoteDetails\"
iniPath = %A_WorkingDir%\settings.ini
FileCreateDir, NoteDetails
FileCreateDir, MyNotes

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

MsgBox, 4, , Fix for V1 or V2.0.0 Notes. MAKE A BACKUP FIRST!!
IfMsgBox Yes
    gosub Fixit
else IfMsgBox No
    return


Fixit:
FileList := ""
		MyNotesArray := {}
		Loop, Files, %U_NotePath%*.txt
		FileList .= A_LoopFileName "`n"
		FileList := RTrim(Filelist, "`n")
		Loop Parse, FileList, `n
		{
		NoteField := ""
		OldNoteField = NoteField

		FileReadLine, NoteField, %U_NotePath%%A_LoopField%, 1
		NoteIniName := StrReplace(A_LoopField, ".txt", ".ini")
		NoteBackupName := NoteBackupName := StrReplace(A_LoopField, ".txt", "")
		NoteIni = %detailsPath%%NoteIniName%
		;Only do these fo fix old notes
		FormatTime, DateBackup, %A_Now%, yy/MM/dd
		IniWrite,%NoteBackupName%,%NoteIni%, INFO, Name
		IniWrite,%DateBackup%,%NoteIni%, INFO, Add
		FileRead, FixNote, %U_NotePath%%A_LoopField%
		FixNoteBody := SubStr(FixNote, InStr(FixNote, "`n") + 1)
		FileRecycle, %U_NotePath%%A_LoopField%
		FileAppend , %FixNoteBody%, %U_NotePath%%A_LoopField%, UTF-8
		IniWrite,%DateBackup%,%NoteIni%, INFO, Mod
	}
msgbox Done!
ExitApp
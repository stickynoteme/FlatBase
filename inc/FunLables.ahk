GetCurrentNoteData(Fun_SafeName)
{
	C_SafeName := Fun_SafeName

	;Collect Current Data
	if (GetFile != false)
		FileRead, C_File, %U_NotePath%%C_SafeName%.txt
	if (GetFile == false)
		C_File = false
	iniRead,C_Name,%detailsPath%%C_SafeName%.ini,INFO,Name,
	C_Name := strreplace(C_Name,"$#$")
	iniRead,C_Star,%detailsPath%%C_SafeName%.ini,INFO,Star,
	iniRead,C_Add,%detailsPath%%C_SafeName%.ini,INFO,Add,
	iniRead,C_Mod,%detailsPath%%C_SafeName%.ini,INFO,Mod,
	C_Star := ConvertStar(C_Star)
	iniRead,C_Tags,%detailsPath%%C_SafeName%.ini,INFO,Tags,
	iniRead,C_Cat,%detailsPath%%C_SafeName%.ini,INFO,Cat,
	iniRead,C_Parent,%detailsPath%%C_SafeName%.ini,INFO,Parent,
	iniRead,C_Image,%detailsPath%%C_SafeName%.ini,INFO,Image,
	iniRead,C_Bookmark,%detailsPath%%C_SafeName%.ini,INFO,Bookmark,
	iniRead,C_Checked,%detailsPath%%C_SafeName%.ini,INFO,Checked,
	iniRead,C_Marked,%detailsPath%%C_SafeName%.ini,INFO,Marked,
	iniRead,C_Clip,%detailsPath%%C_SafeName%.ini,INFO,Clip,
	iniRead,C_Extra,%detailsPath%%C_SafeName%.ini,INFO,Extra,
	iniRead,C_RunType,%detailsPath%%C_SafeName%.ini,INFO,RunType,
	GetFile = true ;reset so it doesn't cause any strange issues and we can use it where ever we need it.
return
}

Import:
C_Loop = 0
Loop
{
    FileReadLine, line,%A_WorkingDir%\Import.txt, %A_Index%
    if ErrorLevel
        break
	C_Loop++
	if (C_Loop == 1)
		ImportFileName := line
	if (C_Loop == 2){
		C_Loop = 0
		ImportFileBody := line
		tempSafeName := NameEncode(ImportFileName)
		SaveFile(ImportFileName,tempSafeName,ImportFileBody,0,"","","")
	}
}
MsgBox, The end of the file has been reached or there was a problem.
return


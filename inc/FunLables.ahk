GetCurrentNoteData(Fun_SafeName)
{
	C_SafeName := Fun_SafeName

	;Collect Current Data
	if (GetFile != false)
		FileRead, C_File, %U_NotePath%%C_SafeName%.txt
	if (GetFile == false)
		C_File = false
	iniRead,C_Name,%detailsPath%%C_SafeName%.ini,INFO,Name,
	iniRead,C_Star,%detailsPath%%C_SafeName%.ini,INFO,Star,
	iniRead,C_Add,%detailsPath%%C_SafeName%.ini,INFO,Add,
	iniRead,C_Mod,%detailsPath%%C_SafeName%.ini,INFO,Mod,
	C_Star := ConvertStar(C_Star)
	iniRead,C_Tags,%detailsPath%%C_SafeName%.ini,INFO,Tags,
	iniRead,C_Cat,%detailsPath%%C_SafeName%.ini,INFO,Cat,
	iniRead,C_Parent,%detailsPath%%C_SafeName%.ini,INFO,Parent,
	GetFile = true ;reset so it doesn't cause any strange issues and we can use it where ever we need it.
return
}
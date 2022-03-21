GetCurrentNoteData(Fun_SafeName)
{
	C_SafeName := Fun_SafeName
	CurrentCol := ["C_Star","C_Name","C_Body","C_Add","C_Mod","C_RawAdd","C_RawMod","C_FileName","C_RawStar","C_Tags","C_Cat","C_Parent","C_Marked","C_Extra"]

	;Collect Current Data
	if (GetBody != false)
		FileRead, C_File, %U_NotePath%%C_SafeName%.txt
	iniRead,C_Name,%detailsPath%%C_SafeName%.ini,INFO,Name,
	iniRead,C_Star,%detailsPath%%C_SafeName%.ini,INFO,Star,
	iniRead,C_Add,%detailsPath%%C_SafeName%.ini,INFO,Add,
	iniRead,C_Mod,%detailsPath%%C_SafeName%.ini,INFO,Mod,
	C_Star := ConvertStar(C_Star)
	iniRead,C_Tags,%detailsPath%%C_SafeName%.ini,INFO,Tags,
	iniRead,C_Cat,%detailsPath%%C_SafeName%.ini,INFO,Cat,
	iniRead,C_Parent,%detailsPath%%C_SafeName%.ini,INFO,Parent,
	GetBody = true ;reset so it doesn't cause any strange issues and we can use it where ever we need it.
return
}
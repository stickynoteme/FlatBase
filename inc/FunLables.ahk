GetCurrentNoteData:
	;Collect Current Data
	FileRead, C_File, %U_NotePath%%C_SafeName%.txt
	iniRead,C_Name,%detailsPath%%C_SafeName%.ini,INFO,Name,
	iniRead,C_Star,%detailsPath%%C_SafeName%.ini,INFO,Star,
	iniRead,C_Add,%detailsPath%%C_SafeName%.ini,INFO,Add,
	iniRead,C_Mod,%detailsPath%%C_SafeName%.ini,INFO,Mod,
	C_Star := ConvertStar(C_Star)
	iniRead,C_Tags,%detailsPath%%C_SafeName%.ini,INFO,Tags,
	iniRead,C_Cat,%detailsPath%%C_SafeName%.ini,INFO,Cat,
	iniRead,C_Parent,%detailsPath%%C_SafeName%.ini,INFO,Parent,
return
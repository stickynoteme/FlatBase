SetUserHotKeys() {
	IniRead, savedHK1, %iniPath%, Hotkeys, 1, #o
	IniRead, savedHK2, %iniPath%, Hotkeys, 2, #n
	IniRead, savedHK1, %iniPath%, Hotkeys, 1, #z
	IniRead, savedHK2, %iniPath%, Hotkeys, 2, #+z
	if (savedHK1="")
		savedHK1=#o
		IniWrite,#o,%iniPath%,Hotkeys, 2
	if (savedHK2="")
		savedHK2=#n
		IniWrite,#n,%iniPath%,Hotkeys, 2
	if (savedHK3="")
		savedHK3=#z
		IniWrite,#z,%iniPath%,Hotkeys, 3
	if (savedHK4="")
		savedHK4=#+z
		IniWrite,#+z,%iniPath%,Hotkeys, 4
	Hotkey,%savedHK1%, Label1
	Hotkey,%savedHK2%, Label2
	Hotkey,%savedHK3%, Label3
	Hotkey,%savedHK4%, Label4
return
}

setHK(num,INI,GUI) {
	 If INI
	  Hotkey, %INI%, Label%num%, Off
	 If GUI
	  Hotkey, %GUI%, Label%num%, On
	 IniWrite,% GUI ? GUI:null, settings.ini, Hotkeys, %num%
	 savedHK%num%  := HK%num%
	 TrayTip, Label%num%,% !INI ? GUI " ON":!GUI ? INI " OFF":GUI " ON`n" INI " OFF"
	 return
}

BuildGUI1(){
	
	if WinExist("FlatNotes - Library") {
		Gui, 1:destroy
		return
	}
	firstDown = 1
	Gui, 1:New,, FlatNotes - Library
	Gui, 1:Margin , 0, 0 
	Gui, 1:Font, s%SearchFontSize% Q%FontRendering%, %SearchFontFamily%, %U_MFC%
	Gui, 1:Color,%U_SBG%, %U_MBG%
	Gui, 1:Add,Edit, c%U_FBCA% w%LibW% y%FontSize% x6 y8 vSearchTerm gSearch -E0x200
	;ListBox used as background color for search area padding

	Gui, 1:Add, ListBox, vLB1 +0x100 h8 w%LibW% x0 y0 -E0x200 Disabled 
	Gui, 1:Add, ListBox, vlB2 +0x100 h15 w%LibW% x0 ys0 -E0x200 Disabled
	Gui, 1:Font, s%ResultFontSize% Q%FontRendering%, %ResultFontFamily%, %U_SFC%
	Gui, 1:Add, text, x-3 c%U_SFC% w%StarColW% center gSortStar vSortStar, *
	Gui, 1:Add, text, c%U_SFC% xp+%StarColW% w%NameColW% center gSortName vSortName, Name
	Gui, 1:Add, text, c%U_SFC% xp+%NameColW% yp+1 w%BodyColW% center gSortBody vSortBody, Body
	Gui, 1:Add, text, yp+1 xp+%BodyColW% w%AddColW% center c%U_SFC% gSortAdded vSortAdded, Added
	Gui, 1:Add, text, yp+1 xp+%AddColW% w%ModColW% center c%U_SFC% gSortModded vSortModded, Modified
	Gui, 1:Add, ListView, -E0x200 -hdr NoSort NoSortHdr LV0x10000 grid r%ResultRows% w%libWAdjust% x-3 C%U_MFC% vLV hwndHLV gNoteListView +altsubmit -Multi Report, Star|Title|Body|Added|Modified|RawAdded|RawModded|FileName|RawStar

	Gui, 1:add, Edit, vFake h0 x-1000 y-1000
	Gui, 1:Add,text, center xs -E0x200  x0 r1 vTitleBar C%U_SFC% w%SubW% gTitleBarClick,

	
	;Allow User set prevent/edit font
	Gui, 1:Font, s%PreviewFontSize% Q%FontRendering%, %PreviewFontFamily%, %U_SFC%
	Gui, 1:Add,Edit, -E0x200 r%PreviewRows% w%LibW% yp+18 x0 C%U_MFC% vPreviewBox,
	
	MakeFileList(1)
	CLV := New LV_Colors(HLV)
	CLV.SelectionColors(rowSelectColor,rowSelectTextColor)
	
	;statusbar
	if (ShowStatusBar=1) {
		Gui, 1:Font, s8 Q%FontRendering%
		StatusWidth := SubW-185
		Gui, 1:add,text, xs center vStatusBarCount w85 C%U_SFC%, %TotalNotes% of %TotalNotes%
		Gui, 1:add,text, x+5 center vStatusBarM w%StatusWidth% C%U_SFC%,M: 00/00/00
		Gui, 1:add,text, x+5 right vStatusBarA w75 C%U_SFC%,A: 00/00/00
		Gui, 1:Font, s2
		Gui, 1:add,text, xs
	}

	Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_MSFC%, %ResultFontFamily%, %U_SFC%
	if (DeafultSort=1)
		GuiControl, Font, SortName
	if (DeafultSort=2)
		GuiControl, Font, SortBody
	if (DeafultSort=6)
		GuiControl, Font, SortAdded
	if (DeafultSort=7)
		GuiControl, Font, SortModded
	
	
	;These are needed to get the clicked COL
	WM_LBUTTONDOWN = 0x0201
	OnMessage( WM_LBUTTONDOWN, "HandleMessage" )

	WM_RBUTTONDOWN = 0x0204
	OnMessage( WM_RBUTTONDOWN, "HandleMessage" )

	
	Gui, 1:SHOW, Hide w%SubW%
	WinGet, g1ID,, FlatNotes - Library
	g1Open=0
	gosub search
	return
}

BuildGUI2(){
	QuickSubWidth := round(QuickNoteWidth*0.5)
	FileSafeClipBoard := RegExReplace(clipboard, "\*|\?|\\|\||/|""|:|<|>"yyyy , Replacement := "_")
	CheckForOldNote = %U_NotePath%%FileSafeClipBoard%.txt
	FileRead, OldNoteData, %CheckForOldNote%
	MouseGetPos, xPos, yPos
	xPos /= 1.5
	yPos /= 1.15
	if (isfake = 1){
		xPos = x50
		fakeY := round((A_ScreenHeight/3))
		yPos := y%fakeY%
	}else{
		xPos = x%xPos%
		yPos = y%yPos%
	}
	Gui, 2:New,, FlatNote - QuickNote
	Gui, 2:Margin , 0, 0 
	Gui, 2:Font, s%FontSize% Q%FontRendering%, %FontFamily%, %U_SFC%	
	Gui, 2:Color,%U_SBG%, %U_MBG%
	Gui, 2:Add,Edit, C%U_MFC% w%QuickSubWidth% vQuickNoteName gQuickSafeNameUpdate -E0x200
	Gui, 2:Add,Edit, -WantReturn C%U_MFC% r%QuickNoteRows% w%QuickNoteWidth% y+1 vQuickNoteBody -E0x200
	Gui, 2:Add,Text, C%U_SFC% x%QuickSubWidth% y3 w%QuickSubWidth% vFileSafeName,
	Gui, 2:Add, Button,x-1000 default gSaveButton y-1000, &Save
	Gui, 2:SHOW, w%QuickNoteWidth% %xPos% %yPos% 
	return  
}

MakeFileList(ReFreshMyNoteArray){
	FileList := ""
	MyNotesArray := {}
	Loop, Files, %U_NotePath%*.txt
		FileList .= A_LoopFileName "`n"
;trim off the extra starting newline
	FileList := RTrim(Filelist, "`n")
	if (isStarting = 1)
		Progress, 25, Building the search index
	Loop Parse, FileList, `n
	{
		NoteField := ""
		OldNoteField = NoteField

		FileReadLine, NoteField, %U_NotePath%%A_LoopField%, 1
		NoteIniName := StrReplace(A_LoopField, ".txt", ".ini")
		NoteBackupName := NoteBackupName := StrReplace(A_LoopField, ".txt", "")
		NoteIni = %detailsPath%%NoteIniName%
		IniRead, StarField, %NoteIni%, INFO, Star,S
		IniRead, NameField, %NoteIni%, INFO, Name
		IniRead, AddedField, %NoteIni%, INFO, Add
		IniRead, ModdedField, %NoteIni%, INFO, Mod
		FormatTime, UserTimeFormatA, %AddedField%, %UserTimeFormat%
		FormatTime, UserTimeFormatM, %ModdedField%,%UserTimeFormat%

		if (StarField=0)
			StarFieldArray:= A_sapce
		if (StarField=1)
			StarFieldArray:=Star1
		if (StarField=2)
			StarFieldArray:=Star2
		if (StarField=3)
			StarFieldArray:=Star3
		if (StarField=4)
			StarFieldArray:=Star4

		if (ReFreshMyNoteArray = 1){
			LV_Add("",StarFieldArray ,NameField, NoteField, UserTimeFormatA,UserTimeFormatM,AddedField,ModdedField,A_LoopField,StarField)
			}
		MyNotesArray.Push({1:StarFieldArray,2:NameField,3:NoteField,4:UserTimeFormatA,5:UserTimeFormatM,6:AddedField,7:ModdedField,8:A_LoopField,9:StarField})
	} ; File loop end
	LV_ModifyCol(1, StarColW) 
	LV_ModifyCol(1, "Center")
	LV_ModifyCol(2, NameColW)
	LV_ModifyCol(2, "Logical")
	LV_ModifyCol(3, BodyColW) ; 275
	LV_ModifyCol(3, "Logical")
	LV_ModifyCol(4, AddColW)
	LV_ModifyCol(4, "Center")
	LV_ModifyCol(5, ModColW)
	LV_ModifyCol(5, "Center")
	LV_ModifyCol(6, 0)
	LV_ModifyCol(6, "Logical")
	LV_ModifyCol(7, 0)
	LV_ModifyCol(7, "Logical")
	LV_ModifyCol(8, 0)
	LV_ModifyCol(9, 0)
	
	if (DeafultSort = 1)
			LV_ModifyCol(2, "Sort")
	if (DeafultSort = 10)
			LV_ModifyCol(2, "SortDesc")
	if (DeafultSort = 2)
			LV_ModifyCol(3, "Sort")
	if (DeafultSort = 20)
			LV_ModifyCol(3, "SortDesc")
	if (DeafultSort = 3)
			LV_ModifyCol(6, "Sort")
	if (DeafultSort = 30)
			LV_ModifyCol(6, "SortDesc")
	if (DeafultSort = 4)
			LV_ModifyCol(7, "Sort")
	if (DeafultSort = 40)
			LV_ModifyCol(7, "SortDesc")
	TotalNotes := MyNotesArray.MaxIndex()
	return
}

ReFreshLV(){
GuiControl, 1:-Redraw, LV
LV_Delete()
For Each, Note In MyNotesArray
{
	LV_Add("", Note.1, Note.2,Note.3,Note.4,Note.5,Note.6,Note.7,Note.8,Note.9)
}
gosub SortNow
TotalNotes := MyNotesArray.MaxIndex() 
GuiControl, 1:+Redraw, LV
return
}

SaveFile(QuickNoteName,FileSafeName,QuickNoteBody,Modified) {
	FileNameTxt =%FileSafeName%.txt
	SaveFileName = %U_NotePath%%FileSafeName%.txt
	
	iniRead,CreatedDate,%detailsPath%%FileSafeName%.ini,INFO,Add,%A_Now%
	iniRead,NoteStar,%detailsPath%%FileSafeName%.ini,INFO,Star,
	FileRecycle, %SaveFileName%
	FormatTime, UserTimeFormatA, %CreatedDate%, %UserTimeFormat%
	FormatTime, UserTimeFormatM, %A_Now%, %UserTimeFormat%
	
	IniRead, StarField, %NoteIni%, INFO, Star,S

		if (StarField=0)
			StarFieldArray:= A_sapce
		if (StarField=1)
			StarFieldArray:=Star1
		if (StarField=2)
			StarFieldArray:=Star2
		if (StarField=3)
			StarFieldArray:=Star3
		if (StarField=4)
			StarFieldArray:=Star4
	
	if (Modified=0){
		MyNotesArray.Push({1:StarFieldArray, 2:QuickNoteName,3:QuickNoteBody,4:UserTimeFormatA,5:UserTimeFormatM,6:CreatedDate,7:A_Now,8:FileNameTxt,9:NoteStar})
		GuiControl, 1:+Redraw, LV
	}
	if (Modified=1){
		for Each, Note in MyNotesArray{
			If (Note.1 = QuickNoteName){
				MyNotesArray.RemoveAt(Each)
			}
		}
		MyNotesArray.Push({1:StarFieldArray,2:QuickNoteName,3:QuickNoteBody,4:UserTimeFormatA,4:UserTimeFormatM,6:CreatedDate,7:A_Now,8:FileNameTxt,9:NoteStar})
		GuiControl, 1:+Redraw, LV
	}

	iniWrite,%CreatedDate%,%detailsPath%%FileSafeName%.ini,INFO,Add
	iniWrite,%QuickNoteName%,%detailsPath%%FileSafeName%.ini,INFO,Name
	iniWrite,%A_Now%,%detailsPath%%FileSafeName%.ini,INFO,Mod
	iniWrite,%NoteStar%,%detailsPath%%FileSafeName%.ini,INFO,Star
	FileAppend , %QuickNoteBody%, %SaveFileName%, UTF-8
return
}
MakeAnyMissingINI(){
	FileList := ""
	MyNotesArray := {}
	Loop, Files, %U_NotePath%*.txt
		FileList .= A_LoopFileName "`n"
	FileList := RTrim(Filelist, "`n")
	Loop Parse, FileList, `n
	{
		NoteIniName := ""
		NoteIniName := StrReplace(A_LoopField, ".txt", ".ini")
		IfNotExist, %detailsPath%%NoteIniName%
				NoteName := StrReplace(A_LoopField, ".txt", "")
				FormatTime, CurrentTimeStamp, %A_Now%, yy/MM/dd
				iniWrite,%NoteName%,%detailsPath%%NoteName%.ini,INFO,Name
				iniWrite,%CurrentTimeStamp%,%detailsPath%%NoteName%.ini,INFO,Mod
				iniWrite,%CurrentTimeStamp%,%detailsPath%%NoteName%.ini,INFO,Add
	} 
return
}
RemoveINIsOfMissingTXT(){
	FileList := ""
	MyNotesArray := {}
	Loop, Files, %detailsPath%*.ini
		FileList .= A_LoopFileName "`n"
	FileList := RTrim(Filelist, "`n")
	Loop Parse, FileList, `n
	{
		NoteName := ""
		NoteName := StrReplace(A_LoopField, ".ini", ".txt")
		IfNotExist, %U_NotePath%%NoteName%
			FileRecycle %detailsPath%%A_LoopField%
	} 
return
}
BackupNotes(){
	FormatTime, CurrentTimeStamp, %A_Now%, yy-MM-dd
	7z_exe:="7za.exe"
	z = 0
	BackupFileList := ""  ; Initialize to be blank.
	Loop, %A_WorkingDir%\Backups\*.*
		BackupFileList .= A_LoopFileName "`n"
	Sort, BackupFileList
	TimeToBackup := CurrentTimeStamp ".7z"
	Loop, parse, BackupFileList, `n
	{
		if (A_LoopField = TimeToBackup)
			SetTimer, CheckBackupLater, 18000000
			return
	}
	Sort, BackupFileList, R  
	Loop, parse, BackupFileList, `n
	{
		if (A_LoopField = "")
			continue
		z +=1
		if (z>=backupsToKeep)
		 FileRecycle %A_WorkingDir%\Backups\%A_LoopField%
	}
	FormatTime, CurrentTimeStamp, %A_Now%, yy-MM-dd
	Run, %7z_exe% a -t7z "%A_WorkingDir%\Backups\%CurrentTimeStamp%.7z" "%detailsPath%" "%U_NotePath%",,Hide UseErrorLevel
return
}
SetUserHotKeys() {
	Hotkey,%savedHK1%, Label1
	Hotkey,%savedHK2%, Label2
	Hotkey,%savedHK3%, Label3
	Hotkey,%savedHK4%, Label4
	Hotkey,%savedHK5%, Label5
	
	if (CtrlEnter = 0)
		Hotkey,Enter, NewAndSaveHK
	if (CtrlEnter = 1)
		Hotkey,^Enter, NewAndSaveHK2
		
;-------------------------------------------------
; Shortcuts
;-------------------------------------------------
	Hotkey,%savedSK1%, LabelS1
	Hotkey,%savedSK2%, LabelS2
	Hotkey,%savedSK3%, LabelS3

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
setSK(num,INI,GUI) {
	 If INI
	  Hotkey, %INI%, LabelS%num%, Off
	 If GUI
	  Hotkey, %GUI%, LabelS%num%, On
	 IniWrite,% GUI ? GUI:null, settings.ini, Shortcuts, %num%
	 savedHK%num%  := SK%num%
	 TrayTip, LabelS%num%,% !INI ? GUI " ON":!GUI ? INI " OFF":GUI " ON`n" INI " OFF"
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

	searchX = 6
	if (ShowStarHelper = 1) {
		searchX = 27
	}
	
	Gui, 1:Add,Edit, c%U_FBCA% w%LibW% y%FontSize% x%searchX% y8 vSearchTerm gSearch -E0x200 HwndHSterm
	Gui, 1:Add, ListBox, vLB1 +0x100 h8 w%LibW% x0 y0 -E0x200 Disabled 
	Gui, 1:Add, ListBox, vlB2 +0x100 h15 w%LibW% x0 ys0 -E0x200 Disabled
	;ListBox used as background color for search area padding
	Gui, 1:Font, s%ResultFontSize% Q%FontRendering%, %ResultFontFamily%, %U_SFC%
	Gui, 1:Add, text, x-3 c%U_SFC% w%StarColW% center gSortStar vSortStar, %Star1%
	Gui, 1:Add, text, c%U_SFC% xp+%StarColW% w%NameColW% center gSortName vSortName, Name
	Gui, 1:Add, text, c%U_SFC% xp+%NameColW% yp+1 w%BodyColW% center gSortBody vSortBody, Body
	Gui, 1:Add, text, yp+1 xp+%BodyColW% w%AddColW% center c%U_SFC% gSortAdded vSortAdded, Added
	Gui, 1:Add, text, yp+1 xp+%AddColW% w%ModColW% center c%U_SFC% gSortModded vSortModded, Modified
	
	Gui, 1:Add, ListView, -E0x200 -hdr NoSort NoSortHdr LV0x10000 grid r%ResultRows% w%libWAdjust% x-3 C%U_MFC% vLV hwndHLV gNoteListView +altsubmit -Multi Report, Star|Title|Body|Added|Modified|RawAdded|RawModded|FileName|RawStar

	;Allow User set prevent/edit font
	Gui, 1:Font, s%PreviewFontSize% Q%FontRendering%, %PreviewFontFamily%, %U_SFC%
	;Gui, 1:Add,edit, readonly h6 -E0x200
	title_h := PreviewFontSize*1.7
	Gui, 1:Add,edit, readonly center xs -E0x200  x0 vTitleBar C%U_SFC% w%LibW% h%title_h%,

	
	Gui, 1:Add,Edit, section hwndHPB -E0x200 r%PreviewRows% w%LibW% x0 C%U_MFC% gPreviewBox vPreviewBox,
	
	MakeFileList(1)
	CLV := New LV_Colors(HLV)
	CLV.SelectionColors(rowSelectColor,rowSelectTextColor)
	
	
	
	;statusbar
	if (ShowStatusBar=1) {
		Gui, 1:Font, s8 Q%FontRendering%
		StatusWidth := LibW//3
		Gui, 1:add,text, xs left vStatusBarCount w%StatusWidth% C%U_SFC%, %TotalNotes% of %TotalNotes%
		Gui, 1:add,text, x+0 center vStatusBarM w%StatusWidth% C%U_SFC%,M: 00/00/00
		Gui, 1:add,text, x+0 right vStatusBarA w%StatusWidth% C%U_SFC%,A: 00/00/00
		Gui, 1:Font, s2
		Gui, 1:add,text, xs
	}

	Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_MSFC%, %ResultFontFamily%, %U_SFC%
	if (DeafultSort=1)
		GuiControl, Font, SortStar
	if (DeafultSort=2)
		GuiControl, Font, SortName
	if (DeafultSort=3)
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

	Gui, 1:Add,Edit, w35 y-2000 x-2000 vSearchFilter HwndHSF,
	if (ShowStarHelper = 1) {
			Gui, 1:Font, s8 Q%FontRendering%, Segoe UI Emoji
, %U_MFC%

			Gui, 1:add, text, center backgroundTrans w15 h15 x2 y8 -E0x200 c%U_FBCA% gStarFilterBox, %star1%
		}
	

	if (HideScrollbars = 1) {
		LVM_ShowScrollBar(HPB,1,False)
		GuiControl,+Vscroll,%HPB%
	}
	Gui, 1:SHOW, Hide w%LibW%
	WinGet, g1ID,, FlatNotes - Library
	g1Open=0
	gosub search
	return
}
BuildGUI2(){
	QuickStarListRows := QuickNoteRows+2
	QuickSubWidth := QuickNoteWidth-232
	QuickNoteEditW := QuickNoteWidth-42
	if (OOKStars > 0){
		QNOKX := QuickNoteWidth-37
		QuickSubWidth := QuickNoteWidth-267
		QuickNoteEditW := QuickNoteWidth-80
	}
	QuickNoteXOffset := 40
	if (UniqueStarList2>0)
		QuickNoteXOffset := 80
	FileSafeClipBoard := NameEncode(clipboard)
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
	Gui, 2:Margin , 2, 2 
	Gui, 2:Font, s%FontSize% Q%FontRendering%, %FontFamily%, %U_SFC%	
	Gui, 2:Color,%U_SBG%, %U_MBG%
	Gui, 2:Add,Edit, section C%U_MFC% w%QuickSubWidth% y+2 x%QuickNoteXOffset% vQuickNoteName gQuickSafeNameUpdate -E0x200
	Gui, 2:Add,Edit, x+2 w35    C%U_MFC% -E0x200 center vQuickStar,%OldStarData%
	Gui, 2:Add,text, x+2 w35 r1 C%U_SFC% -E0x200 center gAddStar1, %Star1%
	Gui, 2:Add,text, x+2 w35 r1 C%U_SFC% -E0x200 center gAddStar2, %Star2%
	Gui, 2:Add,text, x+2 w35 r1 C%U_SFC% -E0x200 center gAddStar3, %Star3% 
	Gui, 2:Add,text, x+2 w35 r1 C%U_SFC% -E0x200 center gAddStar4, %Star4%
	

	Gui, 2:Add,Edit, disabled hidden x+1 r1 w0
	

	Gui, 2:Add,Edit, xs section y+2 x%QuickNoteXOffset% -E0x200 -WantReturn C%U_MFC% r%QuickNoteRows% w%QuickNoteEditW% vQuickNoteBody hwndHQNB
	

	Gui, 2:Add,listbox, center x2 y4 w35 hwndHQNUSL1 C%U_MFC% r%QuickStarListRows% -Vscroll -E0x200 gAddStarU vSelect_UStar,%UniqueStarList%
	if (UniqueStarList2>0)
		Gui, 2:Add,listbox, center x2 y4 w35 hwndHQNUSL2 C%U_MFC% r%QuickStarListRows% -Vscroll -E0x200 gAddStarU2 vSelect_UStar2 ,%UniqueStarList2%
	if (OOKStars > 0)
		Gui, 2:Add,listbox, center x%QNOKX% y4 w35 hwndHQNUSL3 C%U_MFC% r%QuickStarListRows% -Vscroll -E0x200 gAddStarU3 vSelect_UStar3 ,%OOKStars%
	
	
	if (HideScrollbars = 1) {
		LVM_ShowScrollBar(HQNB,1,False)
		LVM_ShowScrollBar(HQNUSL1,1,False)
		LVM_ShowScrollBar(HQNUSL2,1,False)
		GuiControl,+Vscroll,%HQNB%
		GuiControl,+Vscroll,%HQNUSL1%
		GuiControl,+Vscroll,%HQNUSL2%
	}
	TemplateFiles = 1
	if (TemplateFiles > 0)
		gui, 2:Add, text, xs section center c%U_SFC% x%QuickNoteXOffset% w%QuickNoteEditW%  gNoteTemplateSelectUI, [ Template ] 
	Gui, 2:Add, Button,x-1000 default gSaveButton y-1000, &Save
	Gui, 2:Add,Text,x-1000 y-1000 vFileSafeName hwndHQNFSN,	
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
		
		if (SearchWholeNote = 0)
			FileReadLine, NoteField, %U_NotePath%%A_LoopField%, 1
		if (SearchWholeNote = 1)
			FileRead, NoteField, %U_NotePath%%A_LoopField%

		NoteIniName := RegExReplace(A_LoopField, "\.txt(?:^|$|\r\n|\r|\n)", Replacement := ".ini")
		NoteBackupName := NoteBackupName := := RegExReplace(A_LoopField, "\.txt(?:^|$|\r\n|\r|\n)")
		NoteIni = %detailsPath%%NoteIniName%
		IniRead, StarField, %NoteIni%, INFO, Star,S
		IniRead, NameField, %NoteIni%, INFO, Name
		IniRead, AddedField, %NoteIni%, INFO, Add
		IniRead, ModdedField, %NoteIni%, INFO, Mod
		FormatTime, UserTimeFormatA, %AddedField%, %UserTimeFormat%
		FormatTime, UserTimeFormatM, %ModdedField%,%UserTimeFormat%

		if (StarField=10001)
			StarFieldArray:=Star1
		if (StarField=10002)
			StarFieldArray:=Star2
		if (StarField=10003)
			StarFieldArray:=Star3
		if (StarField=10004)
			StarFieldArray:=Star4
		if (StarField != A_space and StarField !=10001 and StarField !=10002 and StarField !=10003 and StarField !=10004)
			StarFieldArray:=StarField
		if (StarField=10000)
			StarFieldArray:= A_sapce
		
		if (ReFreshMyNoteArray = 1){
			LV_Add("",StarFieldArray ,NameField, NoteField, UserTimeFormatA,UserTimeFormatM,AddedField,ModdedField,A_LoopField,StarField)
			}
		
		UsedStars .= StarFieldArray "|"
		MyNotesArray.Push({1:StarFieldArray,2:NameField,3:NoteField,4:UserTimeFormatA,5:UserTimeFormatM,6:AddedField,7:ModdedField,8:A_LoopField,9:StarField})
	} ; File loop end
	UsedStars := RemoveDups(UsedStars,"|")
	UsedStars := StrReplace(UsedStars,"||","|")
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
	FileNameTxt := FileSafeName ".txt"
	SaveFileName = %U_NotePath%%FileSafeName%.txt
	if (SaveFileName =".txt") {
		msgbox Name error #01
		return
		}
	if (SaveFileName =".txt.txt") {
		msgbox Name error #02
		return
		}
	iniRead,CreatedDate,%detailsPath%%FileSafeName%.ini,INFO,Add,%A_Now%
	iniRead,NoteStar,%detailsPath%%FileSafeName%.ini,INFO,Star,10000
	FileRecycle, %SaveFileName%
	FormatTime, UserTimeFormatA, %CreatedDate%, %UserTimeFormat%
	FormatTime, UserTimeFormatM, %A_Now%, %UserTimeFormat%
	
		if (NoteStar=10001)
			StarFieldArray:=Star1
		if (NoteStar=10002)
			StarFieldArray:=Star2
		if (NoteStar=10003)
			StarFieldArray:=Star3
		if (NoteStar=10004) 
			StarFieldArray:=Star4
		if (NoteStar !=10001 and NoteStar !=10002 and NoteStar !=10003 and NoteStar !=10004 and NoteStar !=A_Space)
			StarFieldArray:=NoteStar
		if (NoteStar=10000)
			StarFieldArray:= A_sapce
			
	if (Modified=1){
		for Each, Note in MyNotesArray{
			If (Note.2 = QuickNoteName){
				MyNotesArray.RemoveAt(Each)
			}
		}
	}	
	MyNotesArray.Push({1:StarFieldArray, 2:QuickNoteName,3:QuickNoteBody,4:UserTimeFormatA,5:UserTimeFormatM,6:CreatedDate,7:A_Now,8:FileNameTxt,9:NoteStar})
	

	iniWrite,%CreatedDate%,%detailsPath%%FileSafeName%.ini,INFO,Add
	iniWrite,%QuickNoteName%,%detailsPath%%FileSafeName%.ini,INFO,Name
	iniWrite,%A_Now%,%detailsPath%%FileSafeName%.ini,INFO,Mod
	iniWrite,%NoteStar%,%detailsPath%%FileSafeName%.ini,INFO,Star
	FileAppend , %QuickNoteBody%, %SaveFileName%, UTF-8
;ReFreshLV()
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
		DecodedNoteName := ""
		NoteIniName := RegExReplace(A_LoopField, "\.txt(?:^|$|\r\n|\r|\n)", Replacement := ".ini")
		IfNotExist, %detailsPath%%NoteIniName% 
		{
				DecodedNoteName := RegExReplace(A_LoopField, "\.txt(?:^|$|\r\n|\r|\n)")
				DecodedNoteName := NameDecode(DecodedNoteName)
				NoteName := RegExReplace(A_LoopField, "\.txt(?:^|$|\r\n|\r|\n)")
				
				iniWrite,%DecodedNoteName%,%detailsPath%%NoteName%.ini,INFO,Name
				iniWrite,%A_Now%,%detailsPath%%NoteName%.ini,INFO,Mod
				iniWrite,%A_Now%,%detailsPath%%NoteName%.ini,INFO,Add
				iniWrite,10000,%detailsPath%%NoteName%.ini,INFO,Star
	}   } 
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
		NoteName := RegExReplace(A_LoopField, "\.ini(?:^|$|\r\n|\r|\n)", Replacement := ".txt")
		IfNotExist, %U_NotePath%%NoteName%
			FileRecycle %detailsPath%%A_LoopField%
	} 
return
}
BackupNotes(){
	settimer, CheckBackupLaterTimer, 7200000
	if (A_Now - LastBackupTime < 86400) ;1day in seconds
		return	
	FormatTime, CurrentTimeStamp, %A_Now%, yy-MM-dd@tHH
	7z_exe:="sys\7za.exe"
	z = 0
	BackupFileList := ""  ; Initialize to be blank.
	Loop, %A_WorkingDir%\Backups\*.*
		BackupFileList .= A_LoopFileName "`n"
	Sort, BackupFileList
	Sort, BackupFileList, R  
	Loop, parse, BackupFileList, `n
	{
		if (A_LoopField = "")
			continue
		z +=1
		if (z>=backupsToKeep)
		 FileRecycle %A_WorkingDir%\Backups\%A_LoopField%
	}
	LastBackupTime := A_Now
	iniwrite,%LastBackupTime%,%iniPath%,General,LastBackupTime
	Run, %7z_exe% a -t7z "%A_WorkingDir%\Backups\%CurrentTimeStamp%.7z" "%detailsPath%" "%U_NotePath%",,Hide UseErrorLevel
return
}

LV_Set_Column_Order( _Num_Of_Columns, _New_Column_Order, _lvID="1", Delim="," )
{
    local colOrder, pos
    VarSetCapacity( colOrder, _Num_Of_Columns * 4, 0 )
    
    Loop, Parse, _New_Column_Order, %Delim%
    {
        pos := A_Index - 1
        NumPut( A_LoopField - 1, colOrder, pos * 4, "UInt" )
    }
    
    SendMessage, LVM_FIRST + LVM_SETCOLUMNORDERARRAY
               , _Num_Of_Columns, &colOrder, SysListView32%_lvId%, A   ; LVM_SETCOLUMNORDERARRAY
    
    SendMessage, LVM_FIRST + LVM_REDRAWITEMS        
               , 0, _Num_Of_Columns - 1, SysListView32%_lvId%, A   ; LVM_REDRAWITEMS
    
    VarSetCapacity( colOrder, 0 ) ; Clean up.
}


LV_Get_Column_Order( _Num_Of_Columns, _lvID="1", Delim="," )
{
    local colOrder, pos
    Output := ""
    VarSetCapacity( colOrder, _Num_Of_Columns * 4, 0 )
    
    SendMessage, LVM_FIRST + LVM_GETCOLUMNORDERARRAY
               , _Num_Of_Columns, &colOrder, SysListView32%_lvID%, A   ; LVM_GETCOLUMNORDERARRAY

    Loop, % _Num_Of_Columns
    {
        pos := A_Index - 1
        Col := NumGet( colOrder, pos * 4, "UInt"  ) + 1 ; Array is zero-based so we add one.
        Output .= Col . Delim
    }
    StringTrimRight, Output, Output, 1 ; Trim trailing delimiter.
    VarSetCapacity( colOrder, 0 ) ; Clean up.
    Return, Output
}

NameEncode(Name){
; RegExReplace(RowText, "\*|\?|\\|\||/|""|:|<|>"
Name := strreplace(Name,"\","$1bslash%")
Name := strreplace(Name,"?","$2qm%")
Name := strreplace(Name,"*","$3as%")
Name := strreplace(Name,"|","$4pi%")
Name := strreplace(Name,"""","$5dq%")
Name := strreplace(Name,":","$6col%")
Name := strreplace(Name,"<","$7less%")
Name := strreplace(Name,">","$8great%")
Name := strreplace(Name,"/","$9fslash%")
return Name
}
NameEncodeSticky(Name){
; RegExReplace(RowText, "\*|\?|\\|\||/|""|:|<|>"
Name := strreplace(Name,"\","%1")
Name := strreplace(Name,"?","_qm_")
Name := strreplace(Name,"*","_a_")
Name := strreplace(Name,"|","_pi_")
Name := strreplace(Name,"""","_q_")
Name := strreplace(Name,":","_d_")
Name := strreplace(Name,"<","_g_")
Name := strreplace(Name,">","_l_")
Name := strreplace(Name,"/","_fs_")
Name := strreplace(Name,".","_p_")
Name := strreplace(Name,"1","one")
Name := strreplace(Name,"2","two")
Name := strreplace(Name,"3","three")
Name := strreplace(Name,"4","four")
Name := strreplace(Name,"5","five")
Name := strreplace(Name,"6","six")
Name := strreplace(Name,"7","seven")
Name := strreplace(Name,"8","eight")
Name := strreplace(Name,"9","nine")
Name := strreplace(Name,"0","zero")
Name := strreplace(Name," ","_")
return Name
}
NameDecode(Name){
Name := strreplace(Name,"$1bslash%","\")
Name := strreplace(Name,"$2qm%","?")
Name := strreplace(Name,"$3as%","*")
Name := strreplace(Name,"$4pi%","|")
Name := strreplace(Name,"$5dq%","""")
Name := strreplace(Name,"$6col%",":")
Name := strreplace(Name,"$7less%","<")
Name := strreplace(Name,"$8great%",">")
Name := strreplace(Name,"$9fslash%","/"	)
return Name
}
RemoveDups( List="", delimiter="`n" ) {
Loop, Parse, List, %delimiter%
	List := (A_Index=1 ? A_LoopField : List . (InStr(delimiter List delimiter
	, delimiter A_LoopField delimiter) ? "" : delimiter A_LoopField ) )
return list
}

LVM_ShowScrollBar(hLV,wBar,p_Show=True)
    {
    Static Dummy6622

          ;-- Scroll bar flags
          ,SB_HORZ:=0
            ;-- Shows or hides a window's standard horizontal scroll bars.

          ,SB_VERT:=1
            ;-- Shows or hides a window's standard vertical scroll bar.

          ,SB_CTL:=2
            ;-- Shows or hides a scroll bar control. The hLV parameter must be
            ;   the handle to the scroll bar control.

          ,SB_BOTH:=3
            ;-- Shows or hides a window's standard horizontal and vertical
            ;   scroll bars.

    RC:=DllCall("ShowScrollBar"
        ,(A_PtrSize=8) ? "Ptr":"UInt",hLV               ;-- hWnd
        ,"UInt",wBar                                    ;-- wbar
        ,"UInt",p_Show)                                 ;-- bShow

    Return RC ? True:False
    }
OnMsgBox() {
	MouseGetPos, xPos, yPos
	xPos /= 1.5
	yPos /= 1.15
	DetectHiddenWindows, On
    Process, Exist
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
        WinMove %xPos%, %yPos%
    }
}
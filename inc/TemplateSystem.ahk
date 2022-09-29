BuildTemplateInsertUI:
	Gui, nt:New,, FlatNotes - Note From Template

	if (WindowW < 175)
		WindowW = 175

	Gui, nt:Margin, 3,3
	Gui, nt:Font, s10, Courier New,
	Gui, nt:Color,%U_SBG%, %U_MBG%

	Gui, nt:add, text, c%U_SFC% center w%WindowW% -E0x200 gntInsert, [ Insert At Top ]
	global TemplateType
	RadioX := round(WindowW *0.33)
	
	Gui, nt:Add, DDL, section vTemplateType w100 r2, Horizontal|Vertical 
	Gui, nt:Add, CheckBox, ys+2 xp+115 vExtraInput, Extra Input

	Gui, nt:add, text, c%U_SFC% section xs center h0 w0 hidden
	for k, v in TemplateArr {
		wTMP%k%:= ListBoxWarr[A_Index]
		wwTMP := wTMP%k%
		if (wwTMP = ""){
			msgbox Width Row is missing a value.`n`nTry opening this template in the editor by right clicking it and using [Auto Width].
			return
		}
		if (ExtraInput)
			Gui, nt:add, edit, % " -E0x200 c" U_MFC " x+3 ys0 w" wwTMP " vNTeB" k " r1", 
		Gui, nt:add, listbox, % "Multi -E0x200 c" U_MFC " w" wwTMP " vNTLB" k " r10 ys0" , %v%
	}
	Gui, nt:add, text, c%U_SFC% center y+3 x3 section w%WindowW% -E0x200 gntInsertB, [ Insert At Bottom ]
	Gui, nt:show, x%xPos% y%yPos%
return

LibTemplateAdd:
	LibWindow = 1
	gosub NoteTemplateSelectUI
return

NoteTemplateSelectUI:
	MouseGetPos, xPos, yPos
	xPos /= 1.15
	yPos /= 1.15
	TemplateFileList := ""
	Loop, Files, %templatePath%*.txt 
		TemplateFileList .= A_LoopFileName "|"
	gui, ts:new, +hwndHTSGUI ,Template Select - FlatNotes
	Gui, ts:Margin, 3,3
	Gui, ts:Font, s10, Courier New,
	Gui, ts:Color,%U_SBG%, %U_MBG%
	TemplateLBW := 227+VSBW
	Gui, ts:Add, ListView, hwndHTSLB r10 x+-6 w%TemplateLBW% gNoteTemplateUI vSelected_NoteTemplate -E0x200 -hdr NoSort NoSortHdr LV0x10000 grid C%U_MFC% +altsubmit -Multi Report, Name
	if (HideScrollbars = 1) {
		LVM_ShowScrollBar(HTSLB,1,False)
		GuiControl,+Vscroll,%HTSLB%
	}
	TemplateFileList := Trim(TemplateFileList,"|")
	TemplateFileListLVArr := strsplit(TemplateFileList, "|","|")
	for k,v in TemplateFileListLVArr
		LV_Add("",v)
	LV_ModifyCol(1, 227)
	LV_ModifyCol(1, "Logical")
	LV_ModifyCol(1, "Sort")
	
	Gui, ts:add, edit, c%U_MFC% center hwndHTRowsOver r1 -E0x200 x197 w25 vTRowsOver gTRowsOver, %NewTemplateRows%
	Gui, ts:add, text, c%U_SFC% center x0 w148 yp+5 gNoteTemplateMaker,  [ Make New ]
	
	CLV := New LV_Colors(HTSLB)
	CLV.SelectionColors(rowSelectColor,rowSelectTextColor)
	Gui, ts:show, x%xPos% y%yPos% w225
	Gui, ts:add, button, default x-1000 h0 gNoteTemplateEnterButton, OK
	Gui +LastFound 
	WinSet, AlwaysOnTop , Toggle
return

TRowsOver:
	GuiControlGet,TRowsOver
	if (TRowsOver>30)
		TRowsOver = 30
	IniWrite, %TRowsOver%,%iniPath%, General, NewTemplateRows
	Iniread, NewTemplateRows,%iniPath%, General, NewTemplateRows
return

NoteTemplateUI:
	if (A_GuiEvent = "I" && InStr(ErrorLevel, "S", true))
	{
		TemplateLVSelectedROW := A_EventInfo
	}
	LV_GetText(Selected_NoteTemplate,A_EventInfo)
	;z := "#" A_GuiEvent ":" errorlevel ":" A_EventInfo ":" LV@sel_col ":" ;Selected_NoteTemplate
	;tooltip % z
	;settimer,KillToolTip,-1000
	;return

	if A_GuiEvent in RightClick
	{
		if WinExist("Template Maker - FlatNotes"){
		msgbox Sorry only one template can be open at a time.
		gui,ts:destroy
		return
		}
		FileRead,TemplateToEdit,%templatePath%%Selected_NoteTemplate%
		TemplateEditName := RegExReplace(Selected_NoteTemplate, "\.txt(?:^|$|\r\n|\r|\n)")
		TTEArr := StrSplit(TemplateToEdit,"`n","`n")
		Gui, ntm:new,hwndHNTM ,Template Maker - FlatNotes
		Gui, ntm:Margin, 3,3
		Gui, ntm:Font, s10, Courier New,
		Gui, ntm:Color,%U_SBG%, %U_MBG%
		Gui, ntm:add, text, c%U_SFC% section y+3 w50, Name:
		Gui, ntm:add, Edit, center c%U_MFC% x+3 w300 r1 -E0x200 vTemplateFileName,%TemplateEditName%
		Gui, ntm:add, text, c%U_SFC% x+3 w50, .txt
		Gui, ntm:add, text, section xs center h0 w0 hidden
		Gui, ntm:add, text, c%U_SFC% center w400, Width of each list: (50|70|100)
		Gui, ntm:add, text, c%U_SFC% center w200 gAutoWidth, [ Auto Width ]
		Gui, ntm:add, text, c%U_SFC% center w200 x+3 gntSAVE, [ Save ]
		TTEArrW := TTEArr[1]
		Gui, ntm:add, Edit, center c%U_MFC% section xs w400 r1 -E0x200 vListBoxWidthRow,%TTEArrW%
		TTEArr.RemoveAt(1)
		
		Gui, ntm:add, text, c%U_SFC%section xs center w400, List below here: (Red|Blue|Green) 
		for, k,v  in TTEArr {
			RowDetails := TTEArr[A_Index]
			Gui, ntm:add, text, c%U_SFC% section xs w30, %a_index%:
			;370 
			Gui, ntm:add, Edit, c%U_MFC% x+3 w350 r1 -E0x200  vTMLB%a_index%,%RowDetails%
			Gui, ntm:add, text, center c%U_SFC% x+5 w12 gTMup%a_index%,%TemplateAboveSymbol%
			Gui, ntm:add, text, center c%U_SFC% x+5 w12 gTMdown%a_index%,%TemplateBelowSymbol%
		}
		BlankRows := TTEArr.MaxIndex()
		GuiControlGet,TRowsOver,, %HTRowsOver%
		CheckRows := TRowsOver - BlankRows
		if (CheckRows>0)
			Loop %CheckRows% {
				BlankRows++
				Gui, ntm:add, text, c%U_SFC% section xs w30, %BlankRows%:
				Gui, ntm:add, Edit, c%U_MFC% x+3 w350 r1 -E0x200  vTMLB%BlankRows%,
				Gui, ntm:add, text, center c%U_SFC% x+5 w12 gTMup%BlankRows%,%TemplateAboveSymbol%
				Gui, ntm:add, text, center c%U_SFC% x+5 w12 gTMdown%BlankRows%,%TemplateBelowSymbol%
			}
		Gui, ntm:show
		return
	}
	if (A_GuiEvent = "K" and A_EventInfo = "32")
		{
		LV_GetText(Selected_NoteTemplate,TemplateLVSelectedROW)
		;msgbox % Selected_NoteTemplate "  &  " TemplateLVSelectedROW
		if (Selected_NoteTemplate = "")
			return
		Gui, nt:destroy
		Gui, ts:submit
		Gui, ts:destroy
		MouseGetPos, xPos, yPos
		xPos /= 1.15
		yPos /= 1.15
		WindowW := ""
		FileRead, TemplateTMP, %templatePath%%Selected_NoteTemplate%
		TemplateTMP := trim(TemplateTMP,"`n")
		TemplateTMP := trim(TemplateTMP,"`r")
		NewTemplateArr := SubStr(TemplateTMP, InStr(TemplateTMP, "`n") + 1)
		TemplateArr := StrSplit(NewTemplateArr, "`n","`n")
		FileReadLine ListBoxWs, %templatePath%%Selected_NoteTemplate%, 1
		ListBoxWArr := StrSplit(ListBoxWs, "|","|")
		for k, v in TemplateArr {
			wTMP%k%:= ListBoxWarr[A_Index]
			wwTMP := wTMP%k%
			WindowW += wwTMP+3
		}
		gosub BuildTemplateInsertUI
		return
	}
	
	if A_GuiEvent in Normal
		{
		if (Selected_NoteTemplate = "")
			return
		Gui, nt:destroy
		Gui, ts:submit
		Gui, ts:destroy
		MouseGetPos, xPos, yPos
		xPos /= 1.15
		yPos /= 1.15
		WindowW := ""
		FileRead, TemplateTMP, %templatePath%%Selected_NoteTemplate%
		TemplateTMP := trim(TemplateTMP,"`n")
		TemplateTMP := trim(TemplateTMP,"`r")
		NewTemplateArr := SubStr(TemplateTMP, InStr(TemplateTMP, "`n") + 1)
		TemplateArr := StrSplit(NewTemplateArr, "`n","`n")
		FileReadLine ListBoxWs, %templatePath%%Selected_NoteTemplate%, 1
		ListBoxWArr := StrSplit(ListBoxWs, "|","|")
		for k, v in TemplateArr {
			wTMP%k%:= ListBoxWarr[A_Index]
			wwTMP := wTMP%k%
			WindowW += wwTMP+3
		}
		gosub BuildTemplateInsertUI
		return
	}
return

ntInsert:
	Gui, nt:Submit
	for k, v in TemplateArr {
		AddSpace :=
		AddSapce2 :=
		if (StrLen(NTeB%k%) > 0){
			AddSapce2 := A_SPACE
		}
		if (StrLen(NTLB%k%) > 0){
			AddSpace := A_SPACE
			AddSapce2 := 
		}
		NTLB%k% := trim(NTLB%k%)
		NTLB%k% := trim(NTLB%k%,"`n")
		NTLB%k% := trim(NTLB%k%,"`r")
		NTBody .= NTeB%k% AddSapce2 NTLB%k% AddSpace
	}
	Gui, nt:Destroy
	NL = `n
	if (RapidNTAppend = 1) {
		zbody = %NTBody%%NL%%zbody%
		zbody := trim(zbody,"`n")
		RapidNTAppend = 0
	}
	if (RapidNTAppend = 0 or RapidNTAppend = "") {
		GuiControlGet,Old_QuickNote,,%HQNB%
		if (StrLen(Old_QuickNote) > 0)
			NL = `n
		GuiControl,,%HQNB%,%NTBody%%NL%%Old_QuickNote%
	}
	if (LibWindow = 1) {
		GuiControlGet,Old_PreviewNote,,%HPB%
		if (StrLen(Old_PreviewNote) > 0)
			NL = `n
		GuiControl,,%HPB%,%NTBody%%NL%%Old_PreviewNote%
		LibWindow = 0
		gosub PreviewBox
	}
	for k, v in TemplateArr {
		NTLB%k% := ""
		wTMP%k% := ""
	}
	NL := ""
	NTBody := ""
	WindowW := ""
	TemplateArr := []
	ListBoxWArr := []
	NewTemplateArr :=[]
return

NoteTemplateEnterButton:
		LV_GetText(Selected_NoteTemplate,TemplateLVSelectedROW)
		;msgbox % Selected_NoteTemplate "  &  " TemplateLVSelectedROW
		if (Selected_NoteTemplate = "")
			return
		Gui, nt:destroy
		Gui, ts:submit
		Gui, ts:destroy
		MouseGetPos, xPos, yPos
		xPos /= 1.15
		yPos /= 1.15
		WindowW := ""
		FileRead, TemplateTMP, %templatePath%%Selected_NoteTemplate%
		TemplateTMP := trim(TemplateTMP,"`n")
		TemplateTMP := trim(TemplateTMP,"`r")
		NewTemplateArr := SubStr(TemplateTMP, InStr(TemplateTMP, "`n") + 1)
		TemplateArr := StrSplit(NewTemplateArr, "`n","`n")
		FileReadLine ListBoxWs, %templatePath%%Selected_NoteTemplate%, 1
		ListBoxWArr := StrSplit(ListBoxWs, "|","|")
		for k, v in TemplateArr {
			wTMP%k%:= ListBoxWarr[A_Index]
			wwTMP := wTMP%k%
			WindowW += wwTMP+3
		}
		
		gosub BuildTemplateInsertUI
return


ntInsertB:
	Gui, nt:Submit
	for k, v in TemplateArr {
		AddSpace :=
		AddSapce2 :=
		if (StrLen(NTeB%k%) > 0){
			AddSapce2 := A_SPACE
		}
		if (StrLen(NTLB%k%) > 0) {
			AddSpace := A_SPACE
			AddSapce2 :=
		}
		NTLB%k% := trim(NTLB%k%)
		NTLB%k% := trim(NTLB%k%,"`n")
		NTLB%k% := trim(NTLB%k%,"`r")
		NTBody .= NTeB%k% AddSapce2 NTLB%k% AddSpace
	}
	Gui, nt:Destroy
	NL = `n
	if (RapidNTAppend = 1) {
		zbody = %zbody%%NL%%NTBody%
		zbody := trim(zbody,"`n")
		RapidNTAppend = 0
	}
	if (RapidNTAppend = 0 or RapidNTAppend = "") {
		GuiControlGet,Old_QuickNote,,%HQNB%
		Old_QuickNote := RTrim(Old_QuickNote,"`n")
		if (Strlen(Old_QuickNote)>0)
			NL = `n
		Results = %Old_QuickNote%%NL%%NTBody%
		Results := Trim(Results,"`n")
		GuiControl,,%HQNB%,%Results%
	}
	if (LibWindow = 1) {
		GuiControlGet,Old_PreviewNote,,%HPB%
		Old_PreviewNote :=RTrim(Old_PreviewNote,"`n")
		if (StrLen(Old_PreviewNote) > 0) {
			NL = `n
			}
		Results = %Old_PreviewNote%%NL%%NTBody%
		Results := Trim(Results,"`n")
		GuiControl,,%HPB%,%Results%
		LibWindow = 0
		gosub PreviewBox
	}
	for k, v in TemplateArr {
		NTLB%k% := ""
		wTMP%k% := ""
	}
	NL := ""
	NTBody := ""
	WindowW := ""
	TemplateArr := []
	ListBoxWArr := []
	NewTemplateArr :=[]
return


NoteTemplateMaker:
	gui, ntm:new,hwndHNTM ,Template Maker - FlatNotes
	Gui, ntm:Margin, 3,3
	Gui, ntm:Font, s10, Courier New,
	Gui, ntm:Color,%U_SBG%, %U_MBG%
	Gui, ntm:add, text, c%U_SFC% section y+3 w50, Name:
	Gui, ntm:add, Edit, c%U_MFC% x+3 w300 r1 -E0x200 vTemplateFileName,
	Gui, ntm:add, text, c%U_SFC% x+3 w50, .txt
	Gui, ntm:add, text, section xs center h0 w0 hidden
	Gui, ntm:add, text, c%U_SFC% center w400, Width of each list: (50|70|100)
	Gui, ntm:add, text, c%U_SFC% center w200 gAutoWidth, [ Auto Width ]
	Gui, ntm:add, text, c%U_SFC% center w200 x+3 gntSAVE, [ Save ]
	Gui, ntm:add, Edit, c%U_MFC% section xs w400 r1 -E0x200 vListBoxWidthRow,

	Gui, ntm:add, text, c%U_SFC%section xs center w400, List below here: (Red|Blue|Green) 
	Loop %NewTemplateRows% {
		Gui, ntm:add, text, c%U_SFC% section xs w30, %a_index%:
		Gui, ntm:add, Edit, c%U_MFC% x+3 w370 r1 -E0x200  vTMLB%a_index%,
		Gui, ntm:add, text, center c%U_SFC% x+5 w12 gTMup%a_index%,%TemplateAboveSymbol%
		Gui, ntm:add, text, center c%U_SFC% x+5 w12 gTMdown%a_index%,%TemplateBelowSymbol%
	}
	Gui, ntm:show
return 


AutoWidth:
BigSizeList :=""
 Loop %NewTemplateRows% {
	GuiControlGet,TMLB%a_index%
	TmpArr := strsplit(TMLB%a_index%,"|","|")
	num++
	for k, v in TmpArr
		SizeList%num% .= StrLen(v) ","
	Sort SizeList%num%, N R D,
	RegExMatch(SizeList%num%, "\d+" , Match)
	SizeList%num% := Match * 9
	BigSizeList .= SizeList%num% "|"
 }
 BigSizeList := trim(BigSizeList,"|")
 GuiControl,,ListBoxWidthRow, %BigSizeList%
 ;MsgBox % SizeList1 "|" SizeList2
return



ntSAVE:
	GuiControlGet,TemplateFileName
		if (TemplateFileName = ""){
			msgbox Name can't be blank.
			return
		}
		IfExist, %templatePath%%TemplateFileName%.txt
		{
			OnMessage(0x44, "OnMsgBox")
			MsgBox 0x40040, ,, Overwrite?, Overwrite existing template?
			OnMessage(0x44, "")
			IfMsgBox Yes, {
				
			} Else IfMsgBox No, {
				return
			}
		}
	GuiControlGet,ListBoxWidthRow
	TemplateFileText := ListBoxWidthRow "`n"
	Loop %NewTemplateRows% {
		GuiControlGet,TMLB%a_index%
		
		if (TMLB%a_index% > 0)
			TemplateFileText .= TMLB%a_index% "`n"
	}
	FileRecycle,%templatePath%%TemplateFileName%.txt
	FileAppend,%TemplateFileText%,%templatePath%%TemplateFileName%.txt, UTF-8
		IfExist, %templatePath%%TemplateFileName%.txt
		{
			Gui, ntm:destroy
			if (WinExist("Template Select - FlatNotes")) {
				gui, ts:destroy
				gosub NoteTemplateSelectUI
				}
			return
		}else {
			msgbox 0x40040, ,Something went wrong... this is normally cuased by a missing template folder it has been remade please try again. If you see this message again you might be missing details in the template.
			FileCreateDir, NoteTemplates
		}
return


ntGuiEscape:
ntGuiClose:
	Gui, nt:Destroy
	RapidNTAppend = 0
return

ntmGuiClose:
	Gui, ntm:Destroy
return

tsGuiClose:
tsGuiEscape:
	Gui, ts:Destroy
	RapidNTAppend = 0
return

tGuiClose:
tGuiEscape:
	Gui, t:Destroy
return



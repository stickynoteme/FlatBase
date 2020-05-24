DummyGUI1:
{
	Gui, 5:New,, FlatNotes - Library
	Gui, 5:Margin , 0, 0 
	Gui, 5:Font, s%SearchFontSize% Q%FontRendering%, %SearchFontFamily%, %U_MFC%
	Gui, 5:Color,%U_SBG%, %U_MBG%
	Gui, 5:Add,Edit, c%U_FBCA% w%LibW% y%FontSize% x6 y8  gSearch -E0x200
	;ListBox used as background color for search area padding

	Gui, 5:Add, ListBox, vLB1 +0x100 h8 w%LibW% x0 y0 -E0x200 Disabled 
	Gui, 5:Add, ListBox, vlB2 +0x100 h15 w%LibW% x0 ys0 -E0x200 Disabled
	Gui, 5:Font, s%ResultFontSize% Q%FontRendering%, %ResultFontFamily%, %U_SFC%
	Gui, 5:Add, text, x-3 c%U_SFC% w%StarColW% center gSortStar , *
	Gui, 5:Add, text, c%U_SFC% xp+%StarColW% w%NameColW% center gSortName , Name
	Gui, 5:Add, text, c%U_SFC% xp+%NameColW% yp+1 w%BodyColW% center gSortBody , Body
	Gui, 5:Add, text, yp+1 xp+%BodyColW% w%AddColW% center c%U_SFC% gSortAdded , Added
	Gui, 5:Add, text, yp+1 xp+%AddColW% w%ModColW% center c%U_SFC% gSortModded , Modified
	Gui, 5:Add, ListView, -E0x200 -hdr NoSort NoSortHdr LV0x10000 grid r%ResultRows% w%libWAdjust% x-3 C%U_MFC%  hwndHLV gNoteListView +altsubmit -Multi Report, Star|Title|Body|Added|Modified|RawAdded|RawModded|FileName|RawStar

	;Allow User set prevent/edit font
	Gui, 5:Font, s%PreviewFontSize% Q%FontRendering%, %PreviewFontFamily%, %U_SFC%

	title_h := PreviewFontSize*1.7
	Gui, 5:add, Edit,  h0 x-1000 y-1000
	Gui, 5:Add,edit, readonly center xs -E0x200  x0  C%U_SFC% w%LibW% h%title_h%, Name

	Gui, 5:Add,Edit, -E0x200 r%PreviewRows% w%LibW% yp+18 x0 C%U_MFC% gPreviewBox , Sample Text `nSample Text `nSample Text
	
	
	LV_Add(,Star1, "Name", "Body", "20/20/20","Sample")
	LV_Add(,Star2, "Name", "Body", "20/20/20","Sample")
	LV_Add(,Star3, "Name", "Body", "20/20/20","Sample")
	LV_Add(,Star4, "Name", "Body", "20/20/20","Sample")
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
	CLV2 := New LV_Colors(HLV2)
	CLV2.SelectionColors(rowSelectColor,rowSelectTextColor)
	fakeY := round((A_ScreenHeight/3))
	
		;statusbar
	if (ShowStatusBar=1) {
		Gui, 5:Font, s8 Q%FontRendering%
		StatusWidth := LibW//3
		Gui, 5:add,text, xs left w%StatusWidth% C%U_SFC%, %TotalNotes% of %TotalNotes%
		Gui, 5:add,text, x+0 center  w%StatusWidth% C%U_SFC%,M: 00/00/00
		Gui, 5:add,text, x+0 right  w%StatusWidth% C%U_SFC%,A: 00/00/00
		Gui, 5:Font, s2
		Gui, 5:add,text, xs
	}
	
	Gui, 5:SHOW, w%LibW% x25 y%fakeY%
	if WinActive("FlatNotes - Sample")
		sendinput Sample
	WinActivate,FlatNotes - Options
	return
}
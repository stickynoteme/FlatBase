Build_Stickynote_GUI(NoteName,NoteFile)
{
	global SNB
	global SNT
	global SNX
	FileRead, StickyBody, %U_NotePath%%NoteFile%
	Gui, %NoteName%:-Caption +ToolWindow
	Gui, %NoteName%:
	Gui, %NoteName%:Margin , 0, 0 
	Gui, %NoteName%:Font, s%SearchFontSize% Q%FontRendering%, %SearchFontFamily%, %U_MFC%
	Gui, %NoteName%:Color,%U_SBG%, %U_MBG%
	Gui, %NoteName%:add, text, center  GuiMove x0 y0 h20 w190,%NoteName%
	Gui, %NoteName%:add, text, center  gUsticky x+0 y0 h20 w20,-
	Gui, %NoteName%:add, text, center  gHsticky x+0 y0 h20 w20,#
	Gui, %NoteName%:add, text, center  gXsticky x+0 y0 h20 w20,X
	Gui, %NoteName%:add, edit, -Tabstop readonly w270 h180 -E0x200 x0 vSNB,%StickyBody%
	;WinSet, Style,  -0xC00000,%NoteName%
	Gui, %NoteName%:show, w250
	return
}
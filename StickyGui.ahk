Build_Stickynote_GUI(NoteName,NoteFile)
{
	oNoteName := NoteName
	NoteName :=  NameEncodeSticky(NoteName)
	FileRead, StickyBody, %U_NotePath%%NoteFile%
	Gui, %NoteName%:new,-Caption +ToolWindow,Sticky-%NoteName%
	Gui, %NoteName%:Margin , 0, 0 
	Gui, %NoteName%:Font, s10 Q%FontRendering%, Verdana, %U_MFC%
	Gui, %NoteName%:Color,%U_SBG%, %U_MBG%
	Gui, %NoteName%:add, text, center  gPinsticky x+0 y0 h20 w20,=

	Gui, %NoteName%:add, text, center  GuiMove x20 y0 h20 w%StickyTW%,%oNoteName%
	Gui, %NoteName%:Font, s%StickyFontSize% Q%FontRendering%, %StickyFontFamily%, %U_MFC%
	Gui, %NoteName%:add, text, center  gUsticky x+0 y0 h20 w20,-
	Gui, %NoteName%:add, text, center  gHsticky x+0 y0 h20 w20,#
	Gui, %NoteName%:add, text, center  gXsticky x+0 y0 h20 w20,X
	Gui, %NoteName%:add, edit, -Tabstop readonly w%StickyAdjustW% r%StickyRows% -E0x200 x0 ,%StickyBody%
	Gui, %NoteName%:show, w%StickyW%
	WinGetPos,,,, StickyMaxH,Sticky-%NoteName%
	return
}
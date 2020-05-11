ColorPicked:
{
if (A_GuiEvent == "Normal"){

GuiControlGet, ColorPicked,,ColorChoice
if (A_GuiEvent = "Normal" && ColorPicked = "Black" ) {
IniWrite, 000000, %iniPath%, Colors, MainBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, SubBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, MainFontColor
IniWrite, 000000, %iniPath%, Colors, SubFontColor
IniWrite, 2, %iniPath%, Theme, UserSetting


IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
if (A_GuiEvent = "Normal" && ColorPicked = "White" ) {
IniWrite, ffffff, %iniPath%, Colors, MainBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, SubBackgroundColor
IniWrite, 000000, %iniPath%, Colors, MainFontColor
IniWrite, 000000, %iniPath%, Colors, SubFontColor
IniWrite, 12, %iniPath%, Theme, UserSetting

IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
if (A_GuiEvent = "Normal" && ColorPicked = "Green-Dark" ) {
IniWrite, 003300, %iniPath%, Colors, MainBackgroundColor
IniWrite, 001100, %iniPath%, Colors, SubBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, MainFontColor
IniWrite, ffff00, %iniPath%, Colors, SubFontColor
IniWrite, 6, %iniPath%, Theme, UserSetting

IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
if (A_GuiEvent = "Normal" && ColorPicked = "Green-Light" ) {
IniWrite, 99dd99, %iniPath%, Colors, MainBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, SubBackgroundColor
IniWrite, 000000, %iniPath%, Colors, MainFontColor
IniWrite, 000000, %iniPath%, Colors, SubFontColor
IniWrite, 7, %iniPath%, Theme, UserSetting

IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
if (A_GuiEvent = "Normal" && ColorPicked = "Pink-Light" ) {
IniWrite, dd99dd, %iniPath%, Colors, MainBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, SubBackgroundColor
IniWrite, 000000, %iniPath%, Colors, MainFontColor
IniWrite, 000000, %iniPath%, Colors, SubFontColor
IniWrite, 9, %iniPath%, Theme, UserSetting

IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
if (A_GuiEvent = "Normal" && ColorPicked = "Brown-Dark" ) {
IniWrite, 331100, %iniPath%, Colors, MainBackgroundColor
IniWrite, 110500, %iniPath%, Colors, SubBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, MainFontColor
IniWrite, 55ff55, %iniPath%, Colors, SubFontColor
IniWrite, 5, %iniPath%, Theme, UserSetting

IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
if (A_GuiEvent = "Normal" && ColorPicked = "Violet-Dark" ) {
IniWrite, 330033, %iniPath%, Colors, MainBackgroundColor
IniWrite, 110011, %iniPath%, Colors, SubBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, MainFontColor
IniWrite, ffaaff, %iniPath%, Colors, SubFontColor
IniWrite, 10, %iniPath%, Theme, UserSetting

IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
if (A_GuiEvent = "Normal" && ColorPicked = "Violet-Light" ) {
IniWrite, 9999dd, %iniPath%, Colors, MainBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, SubBackgroundColor
IniWrite, 000000, %iniPath%, Colors, MainFontColor
IniWrite, 000000, %iniPath%, Colors, SubFontColor
IniWrite, 11, %iniPath%, Theme, UserSetting

IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
if (A_GuiEvent = "Normal" && ColorPicked = "Blue-Light" ) {
IniWrite, 99dddd, %iniPath%, Colors, MainBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, SubBackgroundColor
IniWrite, 000000, %iniPath%, Colors, MainFontColor
IniWrite, 000000, %iniPath%, Colors, SubFontColor
IniWrite, 4, %iniPath%, Theme, UserSetting

IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
if (A_GuiEvent = "Normal" && ColorPicked = "Blue-Dark" ) {
IniWrite, 001133, %iniPath%, Colors, MainBackgroundColor
IniWrite, 000011, %iniPath%, Colors, SubBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, MainFontColor
IniWrite, aaaaff, %iniPath%, Colors, SubFontColor
IniWrite, 3, %iniPath%, Theme, UserSetting

IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
if (A_GuiEvent = "Normal" && ColorPicked = "Yellow-Light" ) {
IniWrite, dddd99, %iniPath%, Colors, MainBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, SubBackgroundColor
IniWrite, 000000, %iniPath%, Colors, MainFontColor
IniWrite, 000000, %iniPath%, Colors, SubFontColor
IniWrite, 14, %iniPath%, Theme, UserSetting

IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
if (A_GuiEvent = "Normal" && ColorPicked = "Orange-Light" ) {
IniWrite, dd9933, %iniPath%, Colors, MainBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, SubBackgroundColor
IniWrite, 000000, %iniPath%, Colors, MainFontColor
IniWrite, 000000, %iniPath%, Colors, SubFontColor
IniWrite, 8, %iniPath%, Theme, UserSetting

IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
if (A_GuiEvent = "Normal" && ColorPicked = "Aqua-Dark" ) {
IniWrite, 005867, %iniPath%, Colors, MainBackgroundColor
IniWrite, 0088aa, %iniPath%, Colors, SubBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, MainFontColor
IniWrite, 000000, %iniPath%, Colors, SubFontColor
IniWrite, 1, %iniPath%, Theme, UserSetting

IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
if (A_GuiEvent = "Normal" && ColorPicked = "Yellow-Dark" ) {
IniWrite, 996600, %iniPath%, Colors, MainBackgroundColor
IniWrite, dd9933, %iniPath%, Colors, SubBackgroundColor
IniWrite, ffffff, %iniPath%, Colors, MainFontColor
IniWrite, 000000, %iniPath%, Colors, SubFontColor
IniWrite, 13, %iniPath%, Theme, UserSetting

IniRead, U_MBG, %iniPath%, Colors, MainBackgroundColor , 000000
IniRead, U_SBG, %iniPath%, Colors, SubBackgroundColor , ffffff
IniRead, U_MFC, %iniPath%, Colors, MainFontColor , ffffff
IniRead, U_SFC, %iniPath%, Colors, SubFontColor , 000000
}
send !^6
sleep 50
send !^6
sleep 150
if WinExist("FlatNotes - Options")
    WinActivate ; use the window found above
else
    WinActivate, FlatNotes
}
return
}
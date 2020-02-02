//==============================================================================
//  This version of UT2K4PlayInfoPanel displays PlayInfo settings
//  on a single page, subdividing PlayInfo groups into sections
//
//  Created by Ron Prestenback
//  © 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class IAMultiColumnRulesPanel extends UT2K4PlayInfoPanel;

var automated moCheckBox                ch_Advanced;    // toggles advanced property display
var automated moButton                  b_Symbols;
var automated GUIImage					i_bk;

var() config string RedSym, BlueSym;
var() string        TeamSymbolPage;

var() editconst UT2K4GamePageBase p_Anchor;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    // Set a pointer to the parent page for quick-access
    if (UT2K4GamePageBase(Controller.ActivePage) != None)
        p_Anchor = UT2K4GamePageBase(Controller.ActivePage);

    ch_Advanced.Checked(Controller.bExpertMode);
    lb_Rules.SetPosition(0.024912,0.080739, 0.950175,0.713178);
    li_Rules.ColumnWidth=0.96;
}

function Refresh()
{
    local int i;

	RedSym = default.RedSym;
	BlueSym = default.BlueSym;

    bRefresh = True;
    bUpdate = True;

	SetGamePI();

    // Clear any PlayInfo setting from our local copy of the PlayInfoData array
    if (InfoRules.Length > 0)
        InfoRules.Remove(0, InfoRules.Length);

	for ( i = 0; i < GamePI.Settings.Length; i++ )
		if ( ShouldDisplayRule(i) )
			InfoRules[InfoRules.Length] = GamePI.Settings[i];

    ClearRules();
    LoadRules();
}

protected function SetGamePI()
{
	GamePI = p_Anchor.RuleInfo;
	GamePI.Sort(0);
}

// No array index validation!
protected function bool ShouldDisplayRule(int Index)
{
	if ( GamePI.Settings[Index].bAdvanced && !Controller.bExpertMode )
		return false;

    // Remove all multiplayer-only PlayInfo settings - they will be displayed on Server Rules tab, if this is a multiplayer game.
    return !GamePI.Settings[Index].bMPOnly;
}

function LoadRules()
{
    local int i;

    // Now settings in PlayInfo have been sorted by Group
    // We can now simply check if this setting's group is different from the last,
    // and if so, create a header for it.
    for (i = 0; i < InfoRules.Length; i++)
    {
        if (i == 0 || InfoRules[i].Grouping != InfoRules[i - 1].Grouping)
            AddGroupHeader(i,li_Rules.Elements.Length == 0);

        // Now add the setting to the GUIMultiOptionList
        AddRule(InfoRules[i], i);
    }
    Super.LoadRules();

    if ( GamePI != None )
    {
    	i = GamePI.FindIndex("BotMode");
    	if ( i != -1 )
    		UpdateBotSetting(i);
    }

	UpdateAdvancedCheckbox();
	UpdateSymbolButton();
}

protected function StoreSetting( int Index, string NewValue )
{
    GamePI.StoreSetting(Index, NewValue);

    // Hack for bot setting
    if (InStr(GamePI.Settings[Index].SettingName, "BotMode") != -1)
    	UpdateBotSetting(Index);
}

// mother of all hacks - all just to make sure that in single player, botmode drop down doesn't display
// Use Map Defaults, and MinPlayers setting says "Number of Bots", instead of "Min Players"
function UpdateBotSetting(int BotModeIndex)
{
	local int MinPlayerListIndex, MinPlayerIndex;
	local moNumericEdit nu;

	if ( li_Rules == None || GamePI == None || p_Anchor == None || p_Anchor.c_Tabs == None || BotModeIndex < 0 || BotModeIndex >= GamePI.Settings.Length )
		return;

	// Find the PlayInfo index of the MinPlayers setting

	for ( MinPlayerIndex = 0; MinPlayerIndex < InfoRules.Length; MinPlayerIndex++ )
		if ( InStr(InfoRules[MinPlayerIndex].SettingName, "MinPlayers") != -1 )
			break;

	if ( MinPlayerIndex < InfoRules.Length )
	{
		// Find the MinPlayers component in the list (caption might be different, so must search by tag)
		MinPlayerListIndex = FindComponentWithTag(MinPlayerIndex);

		if ( li_Rules.ValidIndex(MinPlayerListIndex) )
			nu = moNumericEdit(li_Rules.Elements[MinPlayerListIndex]);
	}

	p_Anchor.UpdateBotSetting(GamePI.Settings[BotModeIndex].Value, nu);
}

function SymbolConfigClosed(optional bool bCancelled)
{
	local TeamSymbolConfig SymConfig;
	local Material Sym;
	local bool bSave;

	SymConfig = TeamSymbolConfig(Controller.ActivePage);

	if ( SymConfig.i_RedPreview.Image != None )
		Sym = SymConfig.i_RedPreview.Image;
	else Sym = None;

	if ( Sym != None )
	{
		bSave = !(string(Sym) ~= RedSym);
		RedSym = string(Sym);
	}
	else if ( RedSym != "" )
	{
		RedSym = "";
		bSave = True;
	}

	if ( SymConfig.i_BluePreview.Image != None )
		Sym = SymConfig.i_BluePreview.Image;
	else Sym = None;

	if ( Sym != None )
	{
		bSave = bSave || !(string(Sym) ~= BlueSym);
		BlueSym = string(Sym);
	}
	else if ( BlueSym != "" )
	{
		BlueSym = "";
		bSave = True;
	}

	if ( bSave )
		SaveConfig();
}

function InternalOnChange(GUIComponent Sender)
{
	local class<GameInfo> GameClass;

    if (Sender == ch_Advanced)
    {
    	// Save our preference
        Controller.bExpertMode = ch_Advanced.IsChecked();
        Controller.SaveConfig();

		// Reload the playinfo settings and repopulate the MultiOptionList
        p_Anchor.SetRuleInfo();
        //reload maplist
        p_Anchor.p_Main.InitMaps();
        return;
    }

    else if ( Sender == b_Symbols )
    {
    	GameClass = class<GameInfo>(GamePI.InfoClasses[0]);

		if ( RedSym == "" )
			RedSym = string(GameClass.static.GetRandomTeamSymbol(0));
		if ( BlueSym == "" )
			BlueSym = string(GameClass.static.GetRandomTeamSymbol(10));

    	if ( Controller.OpenMenu(TeamSymbolPage, RedSym, BlueSym) )
    		Controller.ActivePage.OnClose = SymbolConfigClosed;

    	return;
    }

    Super.InternalOnChange(Sender);
}

function UpdateSymbolButton()
{
	if ( p_Anchor.p_Main.GetIsTeamGame() )
		EnableComponent(b_Symbols);
	else DisableComponent(b_Symbols);
}

function UpdateAdvancedCheckbox()
{
	if ( Controller != None && Controller.bExpertMode != ch_Advanced.IsChecked() )
		ch_Advanced.SetComponentValue( Controller.bExpertMode, True );
}

function string Play()
{
	local string S;

	if ( RedSym != "" )
		S $= "?RedTeamSymbol=" $ RedSym;

	if ( BlueSym != "" )
		S $= "?BlueTeamSymbol=" $ BlueSym;

	return s;
}

defaultproperties
{
     Begin Object Class=moCheckBox Name=AdvancedButton
         Caption="View Advanced Options"
         OnCreateComponent=AdvancedButton.InternalOnCreateComponent
         Hint="Toggles whether advanced properties are displayed"
         WinTop=0.948334
         WinLeft=0.136725
         WinWidth=0.300000
         WinHeight=0.040000
         RenderWeight=1.000000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnChange=IAMultiColumnRulesPanel.InternalOnChange
     End Object
     ch_Advanced=moCheckBox'GUI2K4.IAMultiColumnRulesPanel.AdvancedButton'

     Begin Object Class=moButton Name=SymbolButton
         ButtonCaption="Configure"
         ComponentWidth=0.400000
         Caption="Team Symbols"
         OnCreateComponent=SymbolButton.InternalOnCreateComponent
         Hint="Choose the banner symbols for each team."
         WinTop=0.936182
         WinLeft=0.523664
         WinWidth=0.329346
         WinHeight=0.056282
         TabOrder=2
         OnChange=IAMultiColumnRulesPanel.InternalOnChange
     End Object
     b_Symbols=moButton'GUI2K4.IAMultiColumnRulesPanel.SymbolButton'

     Begin Object Class=GUIImage Name=Bk1
         Image=Texture'2K4Menus.NewControls.Display99'
         ImageStyle=ISTY_Stretched
         WinTop=0.014733
         WinLeft=0.000505
         WinWidth=0.996997
         WinHeight=0.907930
     End Object
     i_bk=GUIImage'GUI2K4.IAMultiColumnRulesPanel.Bk1'

     TeamSymbolPage="GUI2K4.TeamSymbolConfig"
     NumColumns=2
}

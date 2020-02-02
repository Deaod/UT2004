//==============================================================================
//  Created on: 12/11/2003
//  Description
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4GamePageSP extends UT2K4GamePageBase;

function PrepareToPlay(out string GameURL, optional string OverrideMap)
{
	local int i;
	local byte Value;

	Super.PrepareToPlay(GameURL, OverrideMap);

	i = RuleInfo.FindIndex("BotMode");
	if ( i != -1 )
	{
		Value = byte(RuleInfo.Settings[i].Value) & 3;
	    // Use Map Defaults
		if ( Value == 1 )
			GameURL $= "?bAutoNumBots=True";

		// Use Bot Roster
		else if ( Value == 2 )
			GameURL $= p_BotConfig.Play();

		// Specify Number
		else
		{
			i = RuleInfo.FindIndex("MinPlayers");
			if ( i >= 0 )
				GameURL $= "?bAutoNumBots=False?NumBots="$RuleInfo.Settings[i].Value;
		}
	}
}

function StartGame(string GameURL, bool bAlt)
{
    if (bAlt)
	   	GameURL $= "?SpectatorOnly=1";

	Console(Controller.Master.Console).DelayedConsoleCommand("start"@GameURL);
	Controller.CloseAll(false,True);
}

function SetupBotText( class<GameInfo> GameClass )
{
	GameClass.static.AdjustBotInterface(True);
}

function string GetBotTabName()
{
	if ( PanelCaption.Length > 4 )
		return PanelCaption[4];

	return "";
}

function UpdateBotSetting( string NewValue, moNumericEdit BotControl )
{
	local GUITabButton BotTab;
	local byte Value;

	if ( BotControl == None || NewValue == "" )
		return;

	BotTab = GetBotTab();
	Value = byte(NewValue) & 3;

	if ( Value == 1 )
	{
		DisableComponent(BotControl);
		DisableComponent(BotTab);
	}

	else if ( Value == 2 )
	{
		DisableComponent(BotControl);
		EnableComponent(BotTab);
	}

	else
	{
		EnableComponent(BotControl);
		DisableComponent(BotTab);
	}
}

defaultproperties
{
     PageCaption="Instant Action"
     Begin Object Class=UT2K4GameFooter Name=SPFooter
         PrimaryCaption="PLAY"
         PrimaryHint="Start A Match With These Settings"
         SecondaryCaption="SPECTATE"
         SecondaryHint="Spectate A Match With These Settings"
         Justification=TXTA_Left
         TextIndent=5
         FontScale=FNS_Small
         WinTop=0.957943
         RenderWeight=0.300000
         TabOrder=8
         OnPreDraw=SPFooter.InternalOnPreDraw
     End Object
     t_Footer=UT2K4GameFooter'GUI2K4.UT2K4GamePageSP.SPFooter'

     PanelClass(0)="GUI2K4.UT2K4Tab_GameTypeSP"
     PanelClass(1)="GUI2K4.UT2K4Tab_MainSP"
     PanelClass(2)="GUI2K4.UT2K4Tab_RulesBase"
     PanelClass(3)="GUI2K4.UT2K4Tab_MutatorSP"
     PanelClass(4)="GUI2K4.UT2K4Tab_BotConfigSP"
}

//==============================================================================
//  Created on: 12/11/2003
//  Description
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4GamePageMP extends UT2K4GamePageBase;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);
	mcServerRules = UT2K4Tab_ServerRulesPanel(c_Tabs.InsertTab(3, PanelCaption[5], PanelClass[5],, PanelHint[5]));

	p_Main.b_Primary = UT2K4GameFooter(t_Footer).b_Primary;
	p_Main.b_Secondary = UT2K4GameFooter(t_Footer).b_Secondary;
}

function PrepareToPlay(out string GameURL, optional string OverrideMap)
{
	local int i;
	local byte Value;

	Super.PrepareToPlay(GameURL, OverrideMap);

    // Append bot options
    i = RuleInfo.FindIndex("BotMode");
    if ( i != -1 )
    {
		value = byte(RuleInfo.Settings[i].Value) & 28;

    	// Bot roster
		if ( Value == 8 )
			GameURL $= p_BotConfig.Play();
		else if ( Value == 16 )
			GameURL $= "?VsBots=true";
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
	local GUIController C;

	C = Controller;

    if (bAlt)
	{
	    if ( mcServerRules != None )
			GameURL $= mcServerRules.Play();

	    // Append optional server flags
		PlayerOwner().ConsoleCommand("relaunch"@GameURL@"-server -log=server.log");
	}
    else
        PlayerOwner().ClientTravel(GameURL $ "?Listen",TRAVEL_Absolute,False);

    C.CloseAll(false,True);
}

function SetupBotText( class<GameInfo> GameClass )
{
    // Set the "Min Players" text to the appropriate text for this type of game
    GameClass.static.AdjustBotInterface(false);
}


function InitRuleInfo( array<class<Info> > InfoClasses )
{
	Super.InitRuleInfo( InfoClasses );

	if( mcServerRules != None )
		mcServerRules.Refresh();
}

function UpdateBotSetting( string NewValue, moNumericEdit BotControl )
{
	local GUITabButton BotTab;
	local byte Value;

	if ( BotControl == None || NewValue == "" )
		return;

	BotTab = GetBotTab();
	Value = byte(NewValue) & 28;

	if ( Value == 1 )
	{
		DisableComponent(BotControl);
		DisableComponent(BotTab);
	}

	else if ( (Value == 8) || (Value == 16) )
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
     PageCaption="Host Game"
     Begin Object Class=UT2K4GameFooter Name=MPFooter
         PrimaryCaption="LISTEN"
         PrimaryHint="Start A Listen Server With These Settings"
         SecondaryCaption="DEDICATED"
         SecondaryHint="Start a Dedicated Server With These Settings"
         Justification=TXTA_Left
         TextIndent=5
         FontScale=FNS_Small
         WinTop=0.957943
         RenderWeight=0.300000
         TabOrder=8
         OnPreDraw=MPFooter.InternalOnPreDraw
     End Object
     t_Footer=UT2K4GameFooter'GUI2K4.UT2K4GamePageMP.MPFooter'

     PanelClass(0)="GUI2K4.UT2K4Tab_GameTypeMP"
     PanelClass(1)="GUI2K4.UT2K4Tab_MainSP"
     PanelClass(2)="GUI2K4.UT2K4Tab_RulesBase"
     PanelClass(3)="GUI2K4.UT2K4Tab_MutatorMP"
     PanelClass(4)="GUI2K4.UT2K4Tab_BotConfigMP"
     PanelClass(5)="GUI2K4.UT2K4Tab_ServerRulesPanel"
     PanelCaption(5)="Server Rules"
     PanelHint(5)="Configure the server settings..."
}

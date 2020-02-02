//==============================================================================
//  Created on: 12/11/2003
//  Base class for Instant Action & Host Multiplayer pages
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4GamePageBase extends UT2k4MainPage;

#exec OBJ LOAD FILE=InterfaceContent.utx

var() localized string PageCaption;
var() config bool bUseTabs;

var() editconst noexport GUIButton b_Primary, b_Secondary, b_Back;

var() editconst noexport PlayInfo RuleInfo;
var() editconst noexport CacheManager.GameRecord    CurrentGame;

var() editconst noexport UT2K4Tab_GameTypeBase      p_Game;
var() editconst noexport UT2K4Tab_MainBase          p_Main;
var() editconst noexport UT2K4Tab_RulesBase         p_Rules;
var() editconst noexport IAMultiColumnRulesPanel    mcRules;
var() editconst noexport UT2K4Tab_ServerRulesPanel	mcServerRules;  // added by BDB
var() editconst noexport UT2K4Tab_MutatorBase       p_Mutators;
var() editconst noexport UT2K4Tab_BotConfigBase     p_BotConfig;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Super.Initcomponent(MyController, MyOwner);

    RuleInfo = new(None) class'Engine.PlayInfo';

	p_Game = UT2K4Tab_GameTypeBase( c_Tabs.AddTab(PanelCaption[i], PanelClass[i],, PanelHint[i++], True) );
	p_Game.OnChangeGameType = ChangeGameType;

    p_Main        = UT2K4Tab_MainBase(c_Tabs.AddTab(PanelCaption[i],PanelClass[i],,PanelHint[i++]) );
    p_Game.tp_Main = p_Main;

    // if bUseTabs, we'll use a tabcontrol display for setting groups
    // if not, we'll use a mult-column multioptionlist, with section headers
    if (bUseTabs)
        p_Rules       = UT2K4Tab_RulesBase(c_Tabs.AddTab(PanelCaption[i],PanelClass[i],,PanelHint[i++]));
    else
		mcRules = IAMultiColumnRulesPanel(c_Tabs.AddTab(PanelCaption[i], "GUI2K4.IAMultiColumnRulesPanel",, PanelHint[i++]));

    p_Mutators    = UT2K4Tab_MutatorBase(c_Tabs.AddTab(PanelCaption[i],PanelClass[i],,PanelHint[i++]));
    p_BotConfig   = UT2K4Tab_BotConfigBase(c_Tabs.AddTab(PanelCaption[i],PanelClass[i],,PanelHint[i++]));

	b_Back = UT2K4GameFooter(t_Footer).b_Back;
	b_Secondary = UT2K4GameFooter(t_Footer).b_Secondary;
	b_Primary = UT2K4GameFooter(t_Footer).b_Primary;
}

function InternalOnOpen()
{
   	ChangeGameType(False);
}

// Forces the player to choose a gametype if none has been chosen - prevents having to load any gametypes until one is chosen, and speeds the page load
function bool GameTypeLocked()
{
	local int i;
	local GUITabButton tb;

	// Don't lock if we don't have a gametype tab (for whatever reason)
	if ( p_Game == None )
		return false;

	if ( Controller.LastGameType == "" )
	{
		for ( i = 0; i < c_Tabs.TabStack.Length; i++ )
		{
			tb = c_Tabs.TabStack[i];
			if ( tb != None && tb != p_Game.MyButton )
				DisableComponent(tb);
		}

		DisableComponent(b_Primary);
		DisableComponent(b_Secondary);

		return true;
	}

	else
	{
		for ( i = 0; i < c_Tabs.TabStack.Length; i++ )
		{
			tb = c_Tabs.TabStack[i];
			if ( tb != None )
			{
				if ( tb.MyPanel == p_Mutators && class'LevelInfo'.static.IsDemoBuild() )
					DisableComponent(tb);
				else EnableComponent(tb);
			}
		}

		EnableComponent(b_Primary);
		EnableComponent(b_Secondary);
		// Update the botmode stuff (tab button & minplayers property control)
		if ( RuleInfo != None && mcRules != None )
		{
			i = RuleInfo.FindIndex("BotMode");
			if ( i != -1 )
				mcRules.UpdateBotSetting(i);
		}

	}

	return false;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local string URL;

    if (Sender == b_Back)
    {
    	if ( RuleInfo != None )
    		RuleInfo.SaveSettings();

        Controller.CloseMenu(true);
        return true;
    }

    if (Sender == b_Primary || Sender == b_Secondary)
    {
    	PrepareToPlay( URL );
    	StartGame(URL, Sender == b_Secondary);
        return true;
    }

    return false;
}

function PrepareToPlay(out string GameURL, optional string OverrideMap)
{
	// Determine the starting map
    GameURL = p_Main.Play();


    if (OverrideMap != "")
        GameURL = OverrideMap;

	// Append the gametype
    GameURL $= "?Game="$p_Main.GetGameClass();
    // Append the configured mutator options
    GameURL $= p_Mutators.Play();

    if ( mcRules != None )
    	GameURL $= mcRules.Play();

    RuleInfo.SaveSettings();
}

function StartGame(string GameURL, bool bAlt);

function InternalOnChange(GUIComponent Sender)
{
    if (GUITabButton(Sender)==none)
        return;

    t_Header.SetCaption(PageCaption@"|"@GUITabButton(Sender).Caption);
}

function ChangeGameType(bool bIsCustom)
{
	if ( GameTypeLocked() )
		return;

    // We've changed the gametype, so the settings in PlayInfo may no longer be applicable
    // Re-initialize PlayInfo and refresh the applicable pages, then update the maplists
    // and bot configurations
    if (p_Main != None)
	{
        p_Main.InitGameType();
	    if ( p_Mutators != None )
	    	p_Mutators.SetCurrentGame(p_Main.CurrentGameType);
	}

    SetRuleInfo();
    if (!bIsCustom && Controller.bCurMenuInitialized)
        c_Tabs.ActivateTabByName(PanelCaption[1], True);

    if (p_BotConfig!=None)
        p_BotConfig.SetupBotLists(p_Main.GetIsTeamGame());
}

function ChangeMutators( string ActiveMutatorString )
{
    SetRuleInfo();
}

function SetRuleInfo(optional string GameName)
{
    local int i;
    local class<GameInfo>       GameClass;
    local class<AccessControl>  ACClass;
    local array<class<Info> >   PIClasses;

	if ( RuleInfo != None && RuleInfo.InfoClasses.Length > 0 )
		RuleInfo.SaveSettings();

    // PlayInfo can now handle calling FillPlayInfo() on the necessary classes itself
    // Let's build an array of classes to pass to PlayInfo
    if (GameName == "")
    {
    	if ( Controller.LastGameType == "" )
    		GameName = "UnrealGame.DeathMatch";
		else GameName = Controller.LastGameType;
    }

    /* This is the standard way PlayInfo is loaded -
    1. GameInfo will be first.  Keep in mind that GameInfo will always automatically call
        FillPlayInfo() on GameReplicationInfo and VotingHandlerClass.  Since these classes
		are popped off the PlayInfo.ClassStack, we can use this to figure out which classes
		can be culled from PlayInfo if we need to

    2. Next up is Access Control - this will add administration settings to playinfo
    */
    GameClass = class<GameInfo>(DynamicLoadObject(GameName, class'Class'));
    if (GameClass != None)
    {
        PIClasses[i++] = GameClass;

		SetupBotText( GameClass );
        ACClass = class<AccessControl>(DynamicLoadObject(GameClass.default.AccessControlClass, class'Class'));
        if (ACClass != None)
            PIClasses[i++] = ACClass;

/*      Uncomment to allow mutator properties to appear in the main GameRules panel

        MutClass = class<Mutator>(DynamicLoadObject(GameClass.default.MutatorClass,class'Class'));
        if (MutClass != None)
            PIClasses[i++] = MutClass;

        if (pMutators != None)
        {
            pMutators.Play();
            MutString = pMutators.LastActiveMutators;
            if (MutString != "")
            {
                Split(MutString, ",", MutClassNames);
                for (j = 0; j < MutClassNames.Length; j++)
                {
                    MutClass = class<Mutator>(DynamicLoadObject(MutClassNames[j], class'Class'));
                    if (MutClass != None)
                        PIClasses[i++] = MutClass;
                }
            }

        }
*/
        InitRuleInfo(PIClasses);
    }
}

function InitRuleInfo(array<class<Info> > PIClasses)
{
    RuleInfo.Init(PIClasses);
    if (p_Rules != None)
        p_Rules.Refresh();

    else if (mcRules != None)
        mcRules.Refresh();
}

function SetupBotText( class<GameInfo> GameClass );

event Free()
{
	if ( !bPersistent )
		RuleInfo = None;

	Super.Free();
}

event bool NotifyLevelChange()
{
	bPersistent = False;
	LevelChanged();
	return true;
}

function string GetBotTabName()
{
	if ( PanelCaption.Length > 4 )
		return PanelCaption[4];

	return "";
}

function GUITabButton GetBotTab()
{
	local string s;
	local int i;

	s = GetBotTabName();
	if ( s == "" )
		return None;

	if ( c_Tabs == None )
		return None;

	i = c_Tabs.TabIndex(s);
	if ( i > 0 && i < c_Tabs.TabStack.Length )
		return c_Tabs.TabStack[i];

	return None;
}

function UpdateBotSetting( string NewValue, moNumericEdit BotControl );

defaultproperties
{
     Begin Object Class=GUIHeader Name=GamePageHeader
         RenderWeight=0.300000
     End Object
     t_Header=GUIHeader'GUI2K4.UT2K4GamePageBase.GamePageHeader'

     PanelCaption(0)="Gametype"
     PanelCaption(1)="Select Map"
     PanelCaption(2)="Game Rules"
     PanelCaption(3)="Mutators"
     PanelCaption(4)="Bot Config"
     PanelHint(0)="Choose the gametype to play..."
     PanelHint(1)="Preview the maps for the currently selected gametype..."
     PanelHint(2)="Configure the current game type..."
     PanelHint(3)="Select and configure any mutators to use..."
     PanelHint(4)="Configure any bots that will be in the session..."
     OnOpen=UT2K4GamePageBase.InternalOnOpen
}

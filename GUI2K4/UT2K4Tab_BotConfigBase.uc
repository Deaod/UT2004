//==============================================================================
//  Created on: 12/11/2003
//  Description
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4Tab_BotConfigBase extends UT2K4GameTabBase;

var automated GUISectionBackground sb_Bots, sb_Red, sb_Blue;
var automated AltSectionBackground sb_PBK;
var automated GUICharacterList  li_Bots;
var automated   GUIImage        i_Portrait;

var automated   GUIVertImageListBox lb_Red, lb_Blue;
var() noexport editconst GUIVertImageList     li_Red, li_Blue;

var automated   GUIButton       b_AddR, b_RemoveR, b_AddB, b_RemoveB,
                                b_Config, b_Left, b_Right, b_DoConfig;

var() bool                bIgnoreListChange, bTeamGame, bPlaySounds;
var() config bool         bAllowDuplicates;
var() localized string DMCaption, RedCaption;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.Initcomponent(MyController, MyOwner);

    li_Red = lb_Red.List;
    li_Red.bDropSource = True;
    li_Red.bDropTarget = True;
    li_Red.OnDragDrop = InternalOnDragDrop;
    li_Red.OnBeginDrag = InternalOnBeginDrag;
    li_Red.OnEndDrag = InternalOnEndDrag;
//    li_Red.HandleMouseOver = InternalMouseOver;
//    li_Red.AddLinkObject(b_RemoveR);
    li_Red.AddLinkObject(b_Config);
    li_Red.AddLinkObject(b_DoConfig);

    li_Blue = lb_Blue.List;
    li_Blue.bDropSource = True;
    li_Blue.bDropTarget = True;
    li_Blue.OnDragDrop = InternalOnDragDrop;
    li_Blue.OnBeginDrag = InternalOnBeginDrag;
    li_Blue.OnEndDrag = InternalOnEndDrag;
//    li_Blue.HandleMouseOver = InternalMouseOver;
//    li_Blue.AddLinkObject(b_RemoveB);
    li_Blue.AddLinkObject(b_Config);
    li_Blue.AddLinkObject(b_DoConfig);

//    li_Bots.AddLinkObject(b_AddB);
//    li_Bots.AddLinkObject(b_AddR);
    li_Bots.AddLinkObject(b_Config);
    li_Bots.AddLinkObject(b_DoConfig);
    li_Bots.CheckLinkedObjects = UpdateLinks;
	li_Bots.SetIndex(0);
    sb_Red.ManageComponent(lb_Red);
    sb_Blue.ManageComponent(lb_Blue);
    sb_PBK.ManageComponent(i_Portrait);

}

function ShowPanel(bool bShow)
{
    Super.ShowPanel(bShow);

//    bPlaySounds = bShow;
    if (bShow)
        SetVis(bTeamGame);
}

function SetVis(bool bIsTeam)
{
    // Team Game only
//    b_AddB.SetVisibility(bIsTeam);
//    b_RemoveB.SetVisibility(bIsTeam);
    lb_Blue.SetVisibility(bIsTeam);
    sb_Blue.SetVisibility(bIsTeam);

	if ( bIsTeam )
		sb_Red.Caption = RedCaption;
	else sb_Red.Caption = DMCaption;
}

function SetupBotLists(bool bIsTeam)
{
    local int i, j;
    local class<TeamInfo> TIClass;
    local array<string> Chars;

    bTeamGame = bIsTeam;

    li_Red.Clear();
    li_Blue.Clear();

    if (bTeamGame)
    {
    	TIClass = class<TeamInfo>(DynamicLoadObject("XGame.TeamRedConfigured",class'Class'));
    	if ( TIClass != None )
    	{
    		TIClass.static.GetAllCharacters(Chars);
    		for ( i = 0; i < Chars.Length; i++ )
    		{
    			for ( j = 0; j < li_Bots.PlayerList.Length; j++ )
    				if ( li_Bots.PlayerList[j].DefaultName ~= Chars[i] )
    					li_Red.Add(li_Bots.PlayerList[j].Portrait, j);
    		}
    	}

    	TIClass = class<TeamInfo>(DynamicLoadObject("XGame.TeamBlueConfigured",class'Class'));
    	if ( TIClass != None )
		{
    		TIClass.static.GetAllCharacters(Chars);
    		for ( i = 0; i < Chars.Length; i++ )
    		{
    			for ( j = 0; j < li_Bots.PlayerList.Length; j++ )
    				if ( li_Bots.PlayerList[j].DefaultName ~= Chars[i] )
    					li_Blue.Add(li_Bots.PlayerList[j].Portrait, j);
    		}
    	}
    }
    else
    {
    	TIClass = class<TeamInfo>(DynamicLoadObject("XGame.DMRosterConfigured",class'Class'));
    	if ( TIClass != None )
		{
    		TIClass.static.GetAllCharacters(Chars);
    		for ( i = 0; i < Chars.Length; i++ )
    		{
    			for ( j = 0; j < li_Bots.PlayerList.Length; j++ )
    				if ( li_Bots.PlayerList[j].DefaultName ~= Chars[i] )
    					li_Red.Add(li_Bots.PlayerList[j].Portrait, j);
    		}
    	}
    }

    SetVis(bTeamGame);

}

// Play is called when the play button is pressed.  It saves any releavent data and then
// returns any additions to the URL
function string Play()
{
    local int i;
    local class<TeamInfo> TIClass;
    local array<string> Characters;
    local bool b1,b2;
    local string url;
    local int MinPlayers;

    if (bTeamGame)
    {

        TIClass = class<TeamInfo>(DynamicLoadObject("XGame.TeamRedConfigured", class'Class'));
        if ( TIClass != None )
        {
        	Characters.Length = li_Red.ItemCount;
        	for ( i = 0; i < li_Red.ItemCount; i++ )
        		Characters[i] = li_Bots.GetNameAt(li_Red.GetItemIntAtIndex(i));

        	TIClass.static.SetCharacters(Characters);
			TIClass.static.StaticSaveConfig();

            MinPlayers += li_Red.ItemCount;
            b1 = true;
        }

		TIClass = class<TeamInfo>(DynamicLoadObject("XGame.TeamBlueConfigured", class'Class'));
		if ( TIClass != None )
		{
			Characters.Length = li_Blue.ItemCount;
			for ( i = 0; i < li_Blue.ItemCount; i++ )
				Characters[i] = li_Bots.GetNameAt(li_Blue.GetItemIntAtIndex(i));

			TIClass.static.SetCharacters(Characters);
			TIClass.static.StaticSaveConfig();

			MinPlayers += li_Blue.ItemCount;
			b2 = True;
		}

        if (b1)
            url $= "?RedTeam=XGame.TeamRedConfigured";

        if (b2)
            url $= "?BlueTeam=XGame.TeamBlueConfigured";
    }
    else
    {
 		TIClass = class<TeamInfo>(DynamicLoadObject("XGame.DMRosterConfigured", class'Class'));
        if ( TIClass != None )
        {
        	Characters.Length = li_Red.ItemCount;
        	for ( i = 0; i < li_Red.ItemCount; i++ )
        		Characters[i] = li_Bots.GetNameAt(li_Red.GetItemIntAtIndex(i));

        	TIClass.static.SetCharacters(Characters);
            TIClass.static.StaticSaveConfig();

            MinPlayers += li_Red.ItemCount;
        }

        if (MinPlayers > 0)
            url $= "?DMTeam=xgame.DMRosterConfigured";
    }

    return url;
}

function CharListChange(GUIComponent Sender)
{
    local sound NameSound;

    i_Portrait.Image = li_Bots.GetPortrait();
    sb_PBK.Caption = li_Bots.GetName();

    // Play the bots name
    if(bPlaySounds)
    {
        NameSound = li_Bots.GetSound();
        PlayerOwner().ClientPlaySound(NameSound,,,SLOT_Interface);
    }
}

function UpdateLinks(GUIListBase List)
{
	local int MaxCount;
	local bool bRedValid, bBlueValid, bMainValid;

	bRedValid = li_Red.IsValid();
	bBlueValid = li_Blue.IsValid();
	bMainValid = li_Bots.IsValid();

	// each list's linked objects overlap, so first disable the ones that are invalid
	if ( !bRedValid )
		li_Red.DisableLinkedObjects();
	if ( !bBlueValid )
		li_Blue.DisableLinkedObjects();
	if ( !bMainValid )
		li_Bots.DisableLinkedObjects();

	// then enable the ones that are valid
	if ( bRedValid )
		li_Red.EnableLinkedObjects();
	if ( bBlueValid )
		li_Blue.EnableLinkedObjects();
	if ( bMainValid )
		li_Bots.EnableLinkedObjects();

    if (bTeamGame)
        MaxCount = 16;
    else MaxCount = 32;

//	if ( li_Red.ItemCount >= MaxCount )
//		DisableComponent(b_AddR);
//	else EnableComponent(b_AddR);

//	if ( li_Blue.ItemCount >= MaxCount )
//		DisableComponent(b_AddB);
//	else EnableComponent(b_AddB);
}

function ListChange(GUIComponent Sender)
{
    if (Sender == lb_Blue || Sender == lb_Red)
    {
    	if ( GUIVertImageListBox(Sender).List.IsValid() )
    		li_Bots.SetIndex(GUIVertImageListBox(Sender).List.GetItem());
    }
}

function bool InternalOnClick(GUIComponent Sender)
{
    if (Sender==b_Left)
    {
    	li_Bots.SetFocus(none);
        li_Bots.PgUp();
        return true;
    }

    if (Sender==b_Right)
    {
    	li_Bots.SetFocus(none);
        li_Bots.PgDown();
        return true;
    }

    if (Sender == b_AddR)
    {
        bIgnoreListChange = True;
		li_Red.Add( li_Bots.GetPortrait(), li_Bots.Index );
        return true;
    }

    if (Sender == b_AddB)
    {
        bIgnoreListChange = True;
		li_Blue.Add( li_Bots.GetPortrait(), li_Bots.Index );
        return true;
    }

    if (Sender == b_RemoveR)
    {
        li_Red.Remove(li_Red.Index);
        return true;
    }

    if (Sender == b_RemoveB)
    {
        li_Blue.Remove(li_Blue.Index);
        return true;
    }

    if (Sender == b_Config)
    {
        if (Controller.OpenMenu("GUI2K4.UT2K4BotInfoPage"))
            UT2K4BotInfoPage(Controller.ActivePage).SetupBotInfo(li_bots.GetPortrait(), li_Bots.GetDecoText(), li_Bots.GetRecord());
        return true;
    }
    if (Sender == b_DoConfig)
    {
        if (Controller.OpenMenu("GUI2K4.UT2K4BotConfigPage"))
            UT2K4BotConfigPage(Controller.ActivePage).SetupBotInfo(li_Bots.GetPortrait(), li_Bots.GetDecoText(), li_Bots.GetRecord());
        return true;
    }

    return false;
}

function bool InternalOnBeginDrag(GUIComponent Sender)
{
    local bool Result, bTemp;

    bTemp = bPlaySounds;
    bPlaySounds = False;
    Result = GUIListBase(Sender).InternalOnBeginDrag(Sender);
    bPlaySounds = bTemp;
    return Result;
}

// Called on the drop source when when an Item has been dropped.  bAccepted tells it whether
// the operation was successful or not.
function InternalOnEndDrag(GUIComponent Accepting, bool bAccepted)
{
	local GUIVertImageList List;

	List = GUIVertImageList(Controller.DropSource);
	if ( List == None )
		return;
//	log(Name@"InternalOnEndDrag Accepting:"$Accepting@"bAccepted:"$bAccepted);

	if ( Accepting == None )
		Accepting = li_Bots;

	List.InternalOnEndDrag(Accepting,True);
}

function bool InternalMouseOver( GUIComponent Sender, Canvas C, out int X, out int Y, out int XL, out int YL )
{
	local int idx;
	local GUIVertImageList List;

	List = GUIVertImageList(Sender);
	if ( List == None )
		return false;

	idx = List.CalculateIndex(True);
	if ( !List.IsValidIndex(idx) )
		return false;

	List.SetHint( li_Bots.GetNameAt(List.GetItemIntAtIndex(idx)) );
	return false;
}

// Called on the drop target when the mouse is released - Sender is always DropTarget
function bool InternalOnDragDrop(GUIComponent Target)
{
	local GUIVertImageList TList;
	local GUIVertImageList SList;

    local array<xUtil.PlayerRecord> AddingBots;
    local int i, j, MaxCount;
    local bool Result;

	SList = GUIVertImageList(Controller.DropSource);
	TList = GUIVertImageList(Target);
    if (TList != None)
    {
    	if ( bTeamGame )
    		MaxCount = 16;
    	else MaxCount = 31;

		if ( TList.ItemCount >= MaxCount )
			return false;

	    // Dragging from list to list
        if ( SList != None )
        {
       		j = SList.SelectedElements.Length;
        	while ( j > 0 && j + TList.ItemCount > MaxCount )
        	{
        		for ( i = 0; i < SList.SelectedItems.Length; i++ )
        			if ( SList.Elements[SList.SelectedItems[i]] == SList.SelectedElements[j - 1] )
        			{
        				SList.SelectedItems.Remove(i,1);
        				break;
        			}

        		SList.SelectedElements.Remove( j - 1, 1 );
        		j = SList.SelectedElements.Length;
        	}

            Result = TList.InternalOnDragDrop(Target);
            if (Result)
                UpdateLinks(li_Bots);

            return Result;
        }

        else if (Controller.DropSource == li_Bots)
        {
	    	AddingBots = li_Bots.GetPendingElements();
			for ( i = 0; i < AddingBots.Length; i++ )
			{
				if ( TList.ItemCount >= MaxCount )
				{
					UpdateLinks(TList);
					return true;
				}

				bIgnoreListChange = True;
				for ( j = 0; j < li_Bots.PlayerList.Length; j++ )
					if ( li_Bots.Playerlist[j] == AddingBots[i] )
						break;

				TList.Add(li_Bots.Playerlist[j].Portrait, j);
			}

			return true;
        }
    }

    else if (Target == li_Bots)
		return li_Bots.InternalOnDragDrop(Target);

    return false;
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=BotConfigMainBG
         Caption="Drag a character on to its respective team"
         WinTop=0.650734
         WinLeft=0.058516
         WinWidth=0.887501
         WinHeight=0.328047
         OnPreDraw=BotConfigMainBG.InternalPreDraw
     End Object
     sb_Bots=GUISectionBackground'GUI2K4.UT2K4Tab_BotConfigBase.BotConfigMainBG'

     Begin Object Class=GUISectionBackground Name=BotConfigRedBackground
         Caption="Red Team"
         WinTop=0.008334
         WinLeft=0.011758
         WinWidth=0.358731
         WinHeight=0.576876
         OnPreDraw=BotConfigRedBackground.InternalPreDraw
     End Object
     sb_Red=GUISectionBackground'GUI2K4.UT2K4Tab_BotConfigBase.BotConfigRedBackground'

     Begin Object Class=GUISectionBackground Name=BotConfigBlueBackground
         Caption="Blue Team"
         WinTop=0.008334
         WinLeft=0.629743
         WinWidth=0.358731
         WinHeight=0.576876
         OnPreDraw=BotConfigBlueBackground.InternalPreDraw
     End Object
     sb_Blue=GUISectionBackground'GUI2K4.UT2K4Tab_BotConfigBase.BotConfigBlueBackground'

     Begin Object Class=AltSectionBackground Name=BotConfigPortraitBackground
         FontScale=FNS_Small
         WinTop=0.037820
         WinLeft=0.392777
         WinWidth=0.220218
         WinHeight=0.512104
         OnPreDraw=BotConfigPortraitBackground.InternalPreDraw
     End Object
     sb_PBK=AltSectionBackground'GUI2K4.UT2K4Tab_BotConfigBase.BotConfigPortraitBackground'

     Begin Object Class=GUICharacterList Name=BotConfigCharList
         StyleName="CharButton"
         Hint="To add a bot, drag the portrait to the desired team's list, or use the arrow buttons above"
         WinTop=0.714826
         WinLeft=0.139140
         WinWidth=0.724609
         WinHeight=0.236758
         TabOrder=7
         bDropSource=True
         bDropTarget=True
         OnClick=BotConfigCharList.InternalOnClick
         OnRightClick=BotConfigCharList.InternalOnRightClick
         OnMousePressed=BotConfigCharList.InternalOnMousePressed
         OnMouseRelease=BotConfigCharList.InternalOnMouseRelease
         OnChange=UT2K4Tab_BotConfigBase.CharListChange
         OnKeyEvent=BotConfigCharList.InternalOnKeyEvent
         OnBeginDrag=UT2K4Tab_BotConfigBase.InternalOnBeginDrag
         OnEndDrag=BotConfigCharList.InternalOnEndDrag
         OnDragDrop=BotConfigCharList.InternalOnDragDrop
         OnDragEnter=BotConfigCharList.InternalOnDragEnter
         OnDragLeave=BotConfigCharList.InternalOnDragLeave
         OnDragOver=BotConfigCharList.InternalOnDragOver
     End Object
     li_Bots=GUICharacterList'GUI2K4.UT2K4Tab_BotConfigBase.BotConfigCharList'

     Begin Object Class=GUIImage Name=BotConfigPortrait
         DropShadow=Texture'2K4Menus.Controls.Shadow'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         DropShadowY=6
         WinTop=0.003986
         WinLeft=0.400000
         WinWidth=0.200000
         WinHeight=0.573754
         RenderWeight=1.101000
     End Object
     i_Portrait=GUIImage'GUI2K4.UT2K4Tab_BotConfigBase.BotConfigPortrait'

     Begin Object Class=GUIVertImageListBox Name=BotConfigRedList
         ImageScale=0.200000
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=BotConfigRedList.InternalOnCreateComponent
         Hint="These are the bots that will play on the red team"
         WinTop=0.060750
         WinLeft=0.014258
         WinWidth=0.345352
         WinHeight=0.504883
         TabOrder=0
         OnChange=UT2K4Tab_BotConfigBase.ListChange
     End Object
     lb_Red=GUIVertImageListBox'GUI2K4.UT2K4Tab_BotConfigBase.BotConfigRedList'

     Begin Object Class=GUIVertImageListBox Name=BotConfigBlueList
         ImageScale=0.200000
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=BotConfigBlueList.InternalOnCreateComponent
         Hint="These are the bots that will play on the blue team"
         WinTop=0.060750
         WinLeft=0.634728
         WinWidth=0.345352
         WinHeight=0.504883
         TabOrder=5
         OnChange=UT2K4Tab_BotConfigBase.ListChange
     End Object
     lb_Blue=GUIVertImageListBox'GUI2K4.UT2K4Tab_BotConfigBase.BotConfigBlueList'

     Begin Object Class=GUIButton Name=IABotConfigConfig
         Caption="Info"
         Hint="View detailed stats for this bot."
         WinTop=0.593949
         WinLeft=0.357306
         WinWidth=0.136563
         WinHeight=0.049765
         TabOrder=9
         OnClick=UT2K4Tab_BotConfigBase.InternalOnClick
         OnKeyEvent=IABotConfigConfig.InternalOnKeyEvent
     End Object
     b_Config=GUIButton'GUI2K4.UT2K4Tab_BotConfigBase.IABotConfigConfig'

     Begin Object Class=GUIButton Name=BotLeft
         StyleName="ArrowLeft"
         WinTop=0.790963
         WinLeft=0.101953
         WinWidth=0.043555
         WinHeight=0.084414
         TabOrder=6
         bNeverFocus=True
         bRepeatClick=True
         OnClick=UT2K4Tab_BotConfigBase.InternalOnClick
         OnKeyEvent=BotLeft.InternalOnKeyEvent
     End Object
     b_Left=GUIButton'GUI2K4.UT2K4Tab_BotConfigBase.BotLeft'

     Begin Object Class=GUIButton Name=BotRight
         StyleName="ArrowRight"
         WinTop=0.790963
         WinLeft=0.854649
         WinWidth=0.043555
         WinHeight=0.084414
         TabOrder=8
         bNeverFocus=True
         bRepeatClick=True
         OnClick=UT2K4Tab_BotConfigBase.InternalOnClick
         OnKeyEvent=BotRight.InternalOnKeyEvent
     End Object
     b_Right=GUIButton'GUI2K4.UT2K4Tab_BotConfigBase.BotRight'

     Begin Object Class=GUIButton Name=IABotConfigDoConfig
         Caption="Edit"
         Hint="Customize the AI attributes for this bot"
         WinTop=0.593949
         WinLeft=0.505743
         WinWidth=0.136563
         WinHeight=0.049765
         TabOrder=10
         OnClick=UT2K4Tab_BotConfigBase.InternalOnClick
         OnKeyEvent=IABotConfigDoConfig.InternalOnKeyEvent
     End Object
     b_DoConfig=GUIButton'GUI2K4.UT2K4Tab_BotConfigBase.IABotConfigDoConfig'

     bAllowDuplicates=True
     DMCaption="DeathMatch Team"
     RedCaption="Red Team"
     WinTop=0.150000
     WinHeight=0.770000
}

//====================================================================
//  xVoting.KickInfoPage
//  Player Information Page.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class KickInfoPage extends LargeWindow;

var automated GUIButton        b_ReturnButton;
var automated GUIImage         i_PlayerPortrait;
var automated GUILabel         l_PlayerName;
var automated PlayerInfoMultiColumnListBox lb_PlayerInfoBox;

var localized string PlayerText, PingText, ScoreText, IDText, IPText, KillsText,
                     DeathsText, SuicidesText, MultiKillsText, SpreesText;
//------------------------------------------------------------------------------------------------
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	b_ReturnButton.OnClick=ReturnButtonOnClick;
}
//------------------------------------------------------------------------------------------------
function HandleParameters(string Param1, string Param2)
{
    LoadInfo(Param1);
}
//------------------------------------------------------------------------------------------------
function LoadInfo(string PlayerName)
{
	local int i, MultiKills, Sprees;
	local Material Portrait;
	local PlayerReplicationInfo PRI;

    if(PlayerName == "")
        return;

    if (!Controller.bCurMenuInitialized)
        return;

	for( i=0; i<PlayerOwner().GameReplicationInfo.PRIArray.Length; i++ )
	{
		if( PlayerOwner().GameReplicationInfo.PRIArray[i].PlayerName == PlayerName )
		{
			PRI = PlayerOwner().GameReplicationInfo.PRIArray[i];
			break;
		}
	}

    Portrait = PRI.GetPortrait();
    if(Portrait == None)
        Portrait = Material(DynamicLoadObject("PlayerPictures.cDefault", class'Material'));

    i_PlayerPortrait.Image = Portrait;
    l_PlayerName.Caption = PlayerName;

    lb_PlayerInfoBox.Add(PingText,string(PRI.Ping));
	lb_PlayerInfoBox.Add(ScoreText,string(PRI.Score));
	lb_PlayerInfoBox.Add(KillsText,string(PRI.Kills));
	lb_PlayerInfoBox.Add(DeathsText,string(PRI.Deaths));

	if( TeamPlayerReplicationInfo(PRI) != none )
	{
		lb_PlayerInfoBox.Add(SuicidesText,string(TeamPlayerReplicationInfo(PRI).Suicides));
		for (i = 0; i < 7; i++)
			MultiKills += TeamPlayerReplicationInfo(PRI).MultiKills[i];
		lb_PlayerInfoBox.Add(MultiKillsText,string(MultiKills));
		for (i = 0; i < 6; i++)
			Sprees += TeamPlayerReplicationInfo(PRI).Spree[i];
		lb_PlayerInfoBox.Add(SpreesText,string(Sprees));
	}
}
//------------------------------------------------------------------------------------------------
function bool ReturnButtonOnClick(GUIComponent Sender)
{
	Controller.CloseMenu(true);
	return true;
}
//------------------------------------------------------------------------------------------------

defaultproperties
{
     Begin Object Class=GUIButton Name=ExitButton
         Caption="Close"
         WinTop=0.531692
         WinLeft=0.670934
         WinWidth=0.120000
         WinHeight=0.033203
         RenderWeight=1.000000
         TabOrder=2
         OnKeyEvent=ExitButton.InternalOnKeyEvent
     End Object
     b_ReturnButton=GUIButton'xVoting.KickInfoPage.ExitButton'

     Begin Object Class=GUIImage Name=KickImagePlayerPortrait
         Image=Texture'2K4Menus.Controls.buttonThick_b'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.193199
         WinLeft=0.206924
         WinWidth=0.155814
         WinHeight=0.358525
     End Object
     i_PlayerPortrait=GUIImage'xVoting.KickInfoPage.KickImagePlayerPortrait'

     Begin Object Class=GUILabel Name=PlayerNameLabel
         Caption="PlayerName"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2SmallHeaderFont"
         WinTop=0.195429
         WinLeft=0.365679
         WinWidth=0.425371
         WinHeight=0.038297
         RenderWeight=0.300000
     End Object
     l_PlayerName=GUILabel'xVoting.KickInfoPage.PlayerNameLabel'

     Begin Object Class=PlayerInfoMultiColumnListBox Name=PlayerInfoBoxControl
         bVisibleWhenEmpty=True
         OnCreateComponent=PlayerInfoBoxControl.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.234286
         WinLeft=0.366960
         WinWidth=0.422477
         WinHeight=0.299483
     End Object
     lb_PlayerInfoBox=PlayerInfoMultiColumnListBox'xVoting.KickInfoPage.PlayerInfoBoxControl'

     PingText="Ping"
     ScoreText="Score"
     IDText="Player ID"
     IPText="IP Address"
     KillsText="Kills"
     DeathsText="Deaths"
     SuicidesText="Suicides"
     MultiKillsText="MultiKills"
     SpreesText="Sprees"
     bRequire640x480=False
     bAllowedAsLast=True
     WinTop=0.151276
     WinLeft=0.188743
     WinWidth=0.622502
     WinHeight=0.440703
     bAcceptsInput=False
}

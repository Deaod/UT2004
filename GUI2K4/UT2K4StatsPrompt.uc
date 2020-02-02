//==============================================================================
//	Created on: 09/01/2003
//	Menu which appears when attempting to connect to a stats-enabled server when
//  client doesn't have stats enabled
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4StatsPrompt extends UT2StatsPrompt;

var automated GUIImage i_Background, i_PageBG;
var automated GUIButton b_OK, b_Cancel;
var automated GUILabel l_Title, l_Message;

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_OK )
	{
		if ( Controller.OpenMenu(Controller.GetSettingsPage(), class'UT2K4SettingsPage'.default.PanelCaption[3]) )
		{
			if ( UT2K4SettingsPage(Controller.ActivePage) != None && UT2K4SettingsPage(Controller.ActivePage).tp_Game != None )
					UT2K4SettingsPage(Controller.ActivePage).tp_Game.ch_TrackStats.Checked(True);
		}
	}

	else if ( Sender == b_Cancel )
		Controller.ReplaceMenu( Controller.GetServerBrowserPage(),,,True );

	return true;
}

function ReOpen()
{
	if(Len(PlayerOwner().StatsUserName) >= 4 && Len(PlayerOwner().StatsPassword) >= 6)
		OnClose();
}

defaultproperties
{
     Begin Object Class=GUIImage Name=PasswordBackground
         Image=Texture'2K4Menus.Controls.editbox_b'
         DropShadow=Texture'2K4Menus.Controls.Shadow'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         DropShadowY=10
         WinHeight=251.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_Background=GUIImage'GUI2K4.UT2K4StatsPrompt.PasswordBackground'

     Begin Object Class=GUIImage Name=menuBackground
         Image=Texture'2K4Menus.Controls.menuBackground'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         X1=0
         Y1=0
         X2=1024
         Y2=768
         WinHeight=1.000000
         RenderWeight=0.000100
     End Object
     i_PageBG=GUIImage'GUI2K4.UT2K4StatsPrompt.menuBackground'

     Begin Object Class=GUIButton Name=YesButton
         Caption="YES"
         WinTop=0.810000
         WinLeft=0.125000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=UT2K4StatsPrompt.InternalOnClick
         OnKeyEvent=YesButton.InternalOnKeyEvent
     End Object
     b_OK=GUIButton'GUI2K4.UT2K4StatsPrompt.YesButton'

     Begin Object Class=GUIButton Name=NoButton
         Caption="NO"
         WinTop=0.810000
         WinLeft=0.650000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=UT2K4StatsPrompt.InternalOnClick
         OnKeyEvent=NoButton.InternalOnKeyEvent
     End Object
     b_Cancel=GUIButton'GUI2K4.UT2K4StatsPrompt.NoButton'

     Begin Object Class=GUILabel Name=PromptHeader
         Caption="This server has UT2004 stats ENABLED!"
         TextAlign=TXTA_Center
         bMultiLine=True
         FontScale=FNS_Large
         StyleName="TextLabel"
         WinTop=0.354166
         WinHeight=0.051563
     End Object
     l_Title=GUILabel'GUI2K4.UT2K4StatsPrompt.PromptHeader'

     Begin Object Class=GUILabel Name=PromptDesc
         Caption="You will only be able to join this server by turning on "Track Stats" and setting a unique Stats Username and Password. Currently you will only be able to connect to servers with stats DISABLED.||Would you like to configure your Stats Username and Password now?"
         TextAlign=TXTA_Center
         bMultiLine=True
         StyleName="TextLabel"
         WinTop=0.422917
         WinHeight=0.256251
     End Object
     l_Message=GUILabel'GUI2K4.UT2K4StatsPrompt.PromptDesc'

     bAlwaysAutomate=True
}

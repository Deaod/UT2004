// ====================================================================
//  Class:  XInterface.UT2StatsPrompt
//  Parent: XInterface.GUIMultiComponent
//
//  <Enter a description here>
// ====================================================================

class UT2StatsPrompt extends UT2K3GUIPage;

delegate OnStatsConfigured();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(Mycontroller, MyOwner);
	PlayerOwner().ClearProgressMessages();
}


function bool InternalOnClick(GUIComponent Sender)
{
	local	UT2SettingsPage	SettingsPage;
    local	GUITabControl Tabs;
    local 	moCheckBox Check;

	if(Sender == Controls[1])
	{
		Controller.OpenMenu("XInterface.UT2SettingsPage");
		SettingsPage = UT2SettingsPage(Controller.ActivePage);
		assert(SettingsPage != None);

        Tabs = GUITabControl(SettingsPage.Controls[1]);
		Tabs.ActivateTabByName(SettingsPage.NetworkTabLabel,true);

        Check = moCheckBox(SettingsPage.pNetwork.Controls[5]);
        if (Check!=None && (!Check.IsChecked()) )
        {
        	Check.Checked(true);
            SettingsPage.pNetwork.Controls[2].SetFocus(none);
        }

	}
	else
		Controller.CloseMenu(false);

	return true;
}

function ReOpen()
{
	if(Len(PlayerOwner().StatsUserName) >= 4 && Len(PlayerOwner().StatsPassword) >= 6)
	{
		Controller.CloseMenu();
		OnStatsConfigured();
	}
}

defaultproperties
{
     OnReOpen=UT2StatsPrompt.ReOpen
     Begin Object Class=GUIButton Name=PromptBackground
         StyleName="SquareBar"
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=PromptBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.UT2StatsPrompt.PromptBackground'

     Begin Object Class=GUIButton Name=YesButton
         Caption="YES"
         WinTop=0.810000
         WinLeft=0.125000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=UT2StatsPrompt.InternalOnClick
         OnKeyEvent=YesButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'XInterface.UT2StatsPrompt.YesButton'

     Begin Object Class=GUIButton Name=NoButton
         Caption="NO"
         WinTop=0.810000
         WinLeft=0.650000
         WinWidth=0.200000
         bBoundToParent=True
         OnClick=UT2StatsPrompt.InternalOnClick
         OnKeyEvent=NoButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'XInterface.UT2StatsPrompt.NoButton'

     Begin Object Class=GUILabel Name=PromptHeader
         Caption="This server has UT2003stats ENABLED!"
         TextAlign=TXTA_Center
         TextColor=(B=220,G=220,R=220)
         TextFont="UT2HeaderFont"
         bMultiLine=True
         WinTop=0.354166
         WinHeight=0.051563
     End Object
     Controls(3)=GUILabel'XInterface.UT2StatsPrompt.PromptHeader'

     Begin Object Class=GUILabel Name=PromptDesc
         Caption="You will only be able to join this server by turning on "Track Stats" and setting a unique Stats Username and Password. Currently you will only be able to connect to servers with stats DISABLED.||Would you like to configure your Stats Username and Password now?"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         bMultiLine=True
         WinTop=0.422917
         WinHeight=0.256251
     End Object
     Controls(4)=GUILabel'XInterface.UT2StatsPrompt.PromptDesc'

     WinTop=0.325000
     WinHeight=0.325000
}

// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class UT2ServerInfo extends GUIPage;

var(MidGame) config array<string>        PanelClass;
var(MidGame) localized array<string>     PanelCaption;
var(MidGame) localized array<string>     PanelHint;

var(MidGame) editconst noexport GUITabControl TabC;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
    Super.InitComponent(MyController, MyOwner);

	if ( PlayerOwner() != None && PlayerOwner().GameReplicationInfo != None )
	    SetTitle();

    TabC = GUITabControl(Controls[4]);
    TabC.MyFooter = GUIFooter(Controls[2]);

	for ( i = 0; i < PanelClass.Length && i < PanelCaption.Length && i < PanelHint.Length; i++ )
	    TabC.AddTab(PanelCaption[i],PanelClass[i],,PanelHint[i]);

    if (!bOldStyleMenus)
        Controls[3].Style = Controller.GetStyle("SquareButton",Controls[3].FontScale);
}

function bool ButtonClicked(GUIComponent Sender)
{
    Controller.CloseMenu(true);
    return true;
}

event ChangeHint(string NewHint)
{
    GUITitleBar(Controls[2]).SetCaption(NewHint);
}

function SetTitle()
{
	GUITitleBar(Controls[1]).SetCaption(PlayerOwner().GameReplicationInfo.ServerName);
}

function bool NotifyLevelChange()
{
	bPersistent = False;
	return true;
}

defaultproperties
{
     PanelClass(0)="XInterface.Tab_ServerMOTD"
     PanelClass(1)="XInterface.Tab_ServerInfo"
     PanelClass(2)="XInterface.Tab_ServerMapList"
     PanelCaption(0)="MOTD"
     PanelCaption(1)="Rules"
     PanelCaption(2)="Maps"
     PanelHint(0)="Message of the Day"
     PanelHint(1)="Game Rules"
     PanelHint(2)="Map Rotation"
     bRequire640x480=False
     bAllowedAsLast=True
     Begin Object Class=GUIImage Name=ServerInfoBackground
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Stretched
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(0)=GUIImage'XInterface.UT2ServerInfo.ServerInfoBackground'

     Begin Object Class=GUITitleBar Name=ServerInfoHeader
         Effect=FinalBlend'InterfaceContent.Menu.CO_Final'
         StyleName="Header"
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(1)=GUITitleBar'XInterface.UT2ServerInfo.ServerInfoHeader'

     Begin Object Class=GUIFooter Name=ServerInfoFooter
         WinTop=0.925000
         WinHeight=0.075000
     End Object
     Controls(2)=GUIFooter'XInterface.UT2ServerInfo.ServerInfoFooter'

     Begin Object Class=GUIButton Name=ServerBackButton
         Caption="Close"
         Hint="Close this menu"
         WinTop=0.934167
         WinLeft=0.848750
         WinWidth=0.120000
         WinHeight=0.055000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=UT2ServerInfo.ButtonClicked
         OnKeyEvent=ServerBackButton.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.UT2ServerInfo.ServerBackButton'

     Begin Object Class=GUITabControl Name=ServerInfoTabs
         bFillSpace=True
         bDockPanels=True
         TabHeight=0.045000
         WinTop=0.083333
         WinLeft=0.012500
         WinWidth=0.974999
         WinHeight=0.060000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=True
         OnActivate=ServerInfoTabs.InternalOnActivate
     End Object
     Controls(4)=GUITabControl'XInterface.UT2ServerInfo.ServerInfoTabs'

     WinTop=0.100000
     WinLeft=0.200000
     WinWidth=0.600000
     WinHeight=0.800000
}

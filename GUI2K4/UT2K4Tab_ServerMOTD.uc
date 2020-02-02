// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class UT2K4Tab_ServerMOTD extends MidGamePanel;

var automated GUISectionBackground sb_MOTD, sb_Admin;
var automated GUIScrollTextBox lb_Text;
var automated GUILabel l_AdminName, l_Email;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	super.Initcomponent(MyController, MyOwner);
	sb_MOTD.ManageComponent(lb_Text);
}

function bool InternalOnPreDraw(Canvas C)
{
	//Moved here from InitComponent() in case player hasn't received GameReplicationInfo yet
	if (PlayerOwner().GameReplicationInfo != None)
	{
		lb_Text.AddText(PlayerOwner().GameReplicationInfo.MessageOfTheDay);

		l_AdminName.Caption = PlayerOwner().GameReplicationInfo.AdminName;
		l_Email.Caption = PlayerOwner().GameReplicationInfo.AdminEmail;
	    OnPreDraw = None;
	}

	return false;
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=sbMOTD
         Caption="Message of the Day"
         LeftPadding=0.000000
         RightPadding=0.000000
         WinTop=0.030325
         WinLeft=0.035693
         WinWidth=0.922427
         WinHeight=0.644637
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=sbMOTD.InternalPreDraw
     End Object
     sb_MOTD=AltSectionBackground'GUI2K4.UT2K4Tab_ServerMOTD.sbMOTD'

     Begin Object Class=AltSectionBackground Name=sbAdmin
         Caption="Your Admin is"
         LeftPadding=0.000000
         RightPadding=0.000000
         WinTop=0.678274
         WinLeft=0.035693
         WinWidth=0.922427
         WinHeight=0.258224
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=sbAdmin.InternalPreDraw
     End Object
     sb_Admin=AltSectionBackground'GUI2K4.UT2K4Tab_ServerMOTD.sbAdmin'

     Begin Object Class=GUIScrollTextBox Name=MOTDText
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.000000
         TextAlign=TXTA_Center
         OnCreateComponent=MOTDText.InternalOnCreateComponent
         WinTop=0.441667
         WinHeight=0.558333
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     lb_Text=GUIScrollTextBox'GUI2K4.UT2K4Tab_ServerMOTD.MOTDText'

     Begin Object Class=GUILabel Name=lAdminName
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2HeaderFont"
         WinTop=0.747420
         WinLeft=0.049329
         WinWidth=0.901341
         WinHeight=0.069115
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_AdminName=GUILabel'GUI2K4.UT2K4Tab_ServerMOTD.lAdminName'

     Begin Object Class=GUILabel Name=lEmail
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         FontScale=FNS_Small
         WinTop=0.801416
         WinLeft=0.049329
         WinWidth=0.893120
         WinHeight=0.069115
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_Email=GUILabel'GUI2K4.UT2K4Tab_ServerMOTD.lEmail'

     WinHeight=0.700000
     OnPreDraw=UT2K4Tab_ServerMOTD.InternalOnPreDraw
}

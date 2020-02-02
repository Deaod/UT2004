// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class Tab_ServerMOTD extends UT2K3TabPanel;

var GUIScrollTextBox MyScrollText;
var moEditBox AdminName, AdminEmail;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local string MOTDString;

 	Super.InitComponent(MyController, MyOwner);

    MyScrollText = GUIScrollTextBox(Controls[0]);
    AdminName  = moEditbox(Controls[1]);
    AdminEmail = moEditBox(Controls[2]);

	MOTDString = PlayerOwner().GameReplicationInfo.MessageOfTheDay;
	MyScrollText.SetContent(MOTDString);

    AdminName.SetText(PlayerOwner().GameReplicationInfo.AdminName);
    AdminEmail.SetText(PlayerOwner().GameReplicationInfo.AdminEmail);

    WinWidth = Controller.ActivePage.WinWidth;
    WinHeight = Controller.ActivePage.WinHeight *0.7;
    WinLeft = Controller.ActivePage.WinLeft;
}

defaultproperties
{
     Begin Object Class=GUIScrollTextBox Name=MOTDText
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.000000
         TextAlign=TXTA_Center
         OnCreateComponent=MOTDText.InternalOnCreateComponent
         WinTop=0.441667
         WinHeight=0.540625
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(0)=GUIScrollTextBox'XInterface.Tab_ServerMOTD.MOTDText'

     Begin Object Class=moEditBox Name=ServerAdminName
         bReadOnly=True
         CaptionWidth=0.330000
         Caption="Admin Name:"
         OnCreateComponent=ServerAdminName.InternalOnCreateComponent
         Hint="The owner of the server"
         WinTop=0.064583
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.060000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(1)=moEditBox'XInterface.Tab_ServerMOTD.ServerAdminName'

     Begin Object Class=moEditBox Name=ServerAdminEmail
         bReadOnly=True
         CaptionWidth=0.330000
         Caption="      Email:"
         OnCreateComponent=ServerAdminEmail.InternalOnCreateComponent
         Hint="How to contact the owner"
         WinTop=0.153333
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.060000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(2)=moEditBox'XInterface.Tab_ServerMOTD.ServerAdminEmail'

     Begin Object Class=GUIImage Name=ServerBK1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.352029
         WinLeft=0.021641
         WinWidth=0.293437
         WinHeight=0.016522
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(3)=GUIImage'XInterface.Tab_ServerMOTD.ServerBK1'

     Begin Object Class=GUIImage Name=ServerBK2
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.352029
         WinLeft=0.685704
         WinWidth=0.277812
         WinHeight=0.016522
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(4)=GUIImage'XInterface.Tab_ServerMOTD.ServerBK2'

     Begin Object Class=GUILabel Name=ServerMOTDLabel
         Caption="Message of the Day"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.308333
         WinHeight=32.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(5)=GUILabel'XInterface.Tab_ServerMOTD.ServerMOTDLabel'

     WinHeight=0.700000
}

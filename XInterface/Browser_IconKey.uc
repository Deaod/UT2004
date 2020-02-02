class Browser_IconKey extends UT2K3GUIPage;

function bool InternalOnClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);
	return true;
}



function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	Super.InitComponent(MyController, MyOwner);

	for(i=0; i<7; i++)
	{
		GUIImage(Controls[3+2*i]).Image = class'Browser_ServersList'.default.Icons[i];
		GUILabel(Controls[4+2*i]).Caption = class'Browser_ServersList'.default.IconDescriptions[i];
	}
}

defaultproperties
{
     bRequire640x480=False
     Begin Object Class=GUIButton Name=DialogBackground
         StyleName="ListBox"
         WinTop=0.256667
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=0.556251
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=DialogBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.Browser_IconKey.DialogBackground'

     Begin Object Class=GUIButton Name=OkButton
         Caption="OK"
         WinTop=0.750000
         WinLeft=0.400000
         WinWidth=0.200000
         OnClick=Browser_IconKey.InternalOnClick
         OnKeyEvent=OkButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'XInterface.Browser_IconKey.OkButton'

     Begin Object Class=GUILabel Name=DialogText
         Caption="Server Icon Key"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.278334
         WinHeight=32.000000
     End Object
     Controls(2)=GUILabel'XInterface.Browser_IconKey.DialogText'

     Begin Object Class=GUIImage Name=Icon1
         ImageStyle=ISTY_Scaled
         WinTop=0.350000
         WinLeft=0.300000
         WinWidth=16.000000
         WinHeight=16.000000
     End Object
     Controls(3)=GUIImage'XInterface.Browser_IconKey.Icon1'

     Begin Object Class=GUILabel Name=Label1
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.340000
         WinLeft=0.360000
         WinWidth=0.350000
         WinHeight=32.000000
     End Object
     Controls(4)=GUILabel'XInterface.Browser_IconKey.Label1'

     Begin Object Class=GUIImage Name=Icon2
         ImageStyle=ISTY_Scaled
         WinTop=0.410000
         WinLeft=0.300000
         WinWidth=16.000000
         WinHeight=16.000000
     End Object
     Controls(5)=GUIImage'XInterface.Browser_IconKey.Icon2'

     Begin Object Class=GUILabel Name=Label2
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.400000
         WinLeft=0.360000
         WinWidth=0.350000
         WinHeight=32.000000
     End Object
     Controls(6)=GUILabel'XInterface.Browser_IconKey.Label2'

     Begin Object Class=GUIImage Name=Icon3
         ImageStyle=ISTY_Scaled
         WinTop=0.470000
         WinLeft=0.300000
         WinWidth=16.000000
         WinHeight=16.000000
     End Object
     Controls(7)=GUIImage'XInterface.Browser_IconKey.Icon3'

     Begin Object Class=GUILabel Name=Label3
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.460000
         WinLeft=0.360000
         WinWidth=0.350000
         WinHeight=32.000000
     End Object
     Controls(8)=GUILabel'XInterface.Browser_IconKey.Label3'

     Begin Object Class=GUIImage Name=Icon4
         ImageStyle=ISTY_Scaled
         WinTop=0.530000
         WinLeft=0.300000
         WinWidth=16.000000
         WinHeight=16.000000
     End Object
     Controls(9)=GUIImage'XInterface.Browser_IconKey.Icon4'

     Begin Object Class=GUILabel Name=Label4
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.520000
         WinLeft=0.360000
         WinWidth=0.350000
         WinHeight=32.000000
     End Object
     Controls(10)=GUILabel'XInterface.Browser_IconKey.Label4'

     Begin Object Class=GUIImage Name=Icon5
         ImageStyle=ISTY_Scaled
         WinTop=0.590000
         WinLeft=0.300000
         WinWidth=16.000000
         WinHeight=16.000000
     End Object
     Controls(11)=GUIImage'XInterface.Browser_IconKey.Icon5'

     Begin Object Class=GUILabel Name=Label5
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.580000
         WinLeft=0.360000
         WinWidth=0.350000
         WinHeight=32.000000
     End Object
     Controls(12)=GUILabel'XInterface.Browser_IconKey.Label5'

     Begin Object Class=GUIImage Name=Icon6
         ImageStyle=ISTY_Scaled
         WinTop=0.650000
         WinLeft=0.300000
         WinWidth=16.000000
         WinHeight=16.000000
     End Object
     Controls(13)=GUIImage'XInterface.Browser_IconKey.Icon6'

     Begin Object Class=GUILabel Name=Label6
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.640000
         WinLeft=0.360000
         WinWidth=0.350000
         WinHeight=32.000000
     End Object
     Controls(14)=GUILabel'XInterface.Browser_IconKey.Label6'

     Begin Object Class=GUIImage Name=Icon7
         ImageStyle=ISTY_Scaled
         WinTop=0.710000
         WinLeft=0.300000
         WinWidth=16.000000
         WinHeight=16.000000
     End Object
     Controls(15)=GUIImage'XInterface.Browser_IconKey.Icon7'

     Begin Object Class=GUILabel Name=Label7
         TextColor=(B=255,G=255,R=255)
         StyleName="TextLabel"
         WinTop=0.700000
         WinLeft=0.360000
         WinWidth=0.350000
         WinHeight=32.000000
     End Object
     Controls(16)=GUILabel'XInterface.Browser_IconKey.Label7'

     WinHeight=1.000000
}

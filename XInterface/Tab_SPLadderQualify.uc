class Tab_SPLadderQualify extends Tab_SPLadderBase;

var array<LadderButton> DMButtons;

function InitPanel()
{
local int i;

	ScrollInfo=GUIScrollTextBox(Controls[4]);
	MapPicHolder=GUIImage(Controls[0]);
	MapNameLabel=GUILabel(Controls[3]);

	// Create DMButtons Array
	for (i=0; i<6; i++)
		DMButtons[DMButtons.Length] = NewLadderButton(0, i, 0.050195, 0.799215 - 0.128333 * i);

	OnProfileUpdated();
}

function OnProfileUpdated()
{
local int i;

	for (i=0; i<DMButtons.Length; i++)
		UpdateLadderButton(DMButtons[i], 0, i);

	SetYellowBar(0, 6, DMButtons);

	// When Profile is updated, display the top possible item;
	if (GetProfile() != None)
		SetActiveMatch(0, DMButtons);
	// Else
		// SetNoMatchInfo()
}

defaultproperties
{
     Begin Object Class=GUIImage Name=MapPic
         Image=Texture'InterfaceContent.Menu.NoLevelPreview'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.093489
         WinLeft=0.481796
         WinWidth=0.443750
         WinHeight=0.405312
     End Object
     Controls(0)=GUIImage'XInterface.Tab_SPLadderQualify.MapPic'

     Begin Object Class=GUIImage Name=MapPicBack
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.091406
         WinLeft=0.477891
         WinWidth=0.450000
         WinHeight=0.410000
     End Object
     Controls(1)=GUIImage'XInterface.Tab_SPLadderQualify.MapPicBack'

     Begin Object Class=GUIImage Name=MapInfoBack
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.521354
         WinLeft=0.477891
         WinWidth=0.450000
         WinHeight=0.410000
     End Object
     Controls(2)=GUIImage'XInterface.Tab_SPLadderQualify.MapInfoBack'

     Begin Object Class=GUILabel Name=MapInfoName
         Caption="No Match Selected"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.526822
         WinLeft=0.512304
         WinWidth=0.382813
         WinHeight=32.000000
     End Object
     Controls(3)=GUILabel'XInterface.Tab_SPLadderQualify.MapInfoName'

     Begin Object Class=GUIScrollTextBox Name=MapInfoScroll
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=MapInfoScroll.InternalOnCreateComponent
         WinTop=0.619325
         WinLeft=0.484569
         WinWidth=0.435000
         WinHeight=0.300000
         bNeverFocus=True
     End Object
     Controls(4)=GUIScrollTextBox'XInterface.Tab_SPLadderQualify.MapInfoScroll'

     Begin Object Class=GUIImage Name=DMBar1
         Image=Texture'InterfaceContent.SPMenu.BarVertical'
         ImageStyle=ISTY_Scaled
         WinTop=0.152813
         WinLeft=0.095312
         WinWidth=0.003906
         WinHeight=0.704102
     End Object
     Controls(5)=GUIImage'XInterface.Tab_SPLadderQualify.DMBar1'

     Begin Object Class=GUIImage Name=DMBar2
         Image=Texture'InterfaceContent.SPMenu.BarVerticalHi'
         ImageStyle=ISTY_Scaled
         WinTop=0.152813
         WinLeft=0.095312
         WinWidth=0.003906
         WinHeight=0.704102
         bVisible=False
     End Object
     Controls(6)=GUIImage'XInterface.Tab_SPLadderQualify.DMBar2'

     Begin Object Class=GUILabel Name=DMLabel0
         Caption="Tutorial"
         TextFont="UT2SmallFont"
         WinTop=0.889387
         WinLeft=0.175001
         WinWidth=0.400000
         WinHeight=0.080000
     End Object
     Controls(7)=GUILabel'XInterface.Tab_SPLadderQualify.DMLabel0'

     Begin Object Class=GUILabel Name=DMLabel1
         Caption="One on One"
         TextFont="UT2SmallFont"
         WinTop=0.723333
         WinLeft=0.173438
         WinWidth=0.400000
         WinHeight=0.080000
     End Object
     Controls(8)=GUILabel'XInterface.Tab_SPLadderQualify.DMLabel1'

     Begin Object Class=GUILabel Name=DMLabel2
         Caption="One on One"
         TextFont="UT2SmallFont"
         WinTop=0.555416
         WinLeft=0.173438
         WinWidth=0.400000
         WinHeight=0.080000
     End Object
     Controls(9)=GUILabel'XInterface.Tab_SPLadderQualify.DMLabel2'

     Begin Object Class=GUILabel Name=DMLabel3a
         Caption="Cut-throat"
         TextFont="UT2SmallFont"
         WinTop=0.366667
         WinLeft=0.173438
         WinWidth=0.400000
         WinHeight=0.080000
     End Object
     Controls(10)=GUILabel'XInterface.Tab_SPLadderQualify.DMLabel3a'

     Begin Object Class=GUILabel Name=DMLabel3b
         Caption="Deathmatch"
         TextFont="UT2SmallFont"
         WinTop=0.410416
         WinLeft=0.173438
         WinWidth=0.400000
         WinHeight=0.080000
     End Object
     Controls(11)=GUILabel'XInterface.Tab_SPLadderQualify.DMLabel3b'

     Begin Object Class=GUILabel Name=DMLabel4a
         Caption="Five-way"
         TextFont="UT2SmallFont"
         WinTop=0.201093
         WinLeft=0.173438
         WinWidth=0.400000
         WinHeight=0.080000
     End Object
     Controls(12)=GUILabel'XInterface.Tab_SPLadderQualify.DMLabel4a'

     Begin Object Class=GUILabel Name=DMLabel4b
         Caption="Deathmatch"
         TextFont="UT2SmallFont"
         WinTop=0.244270
         WinLeft=0.173438
         WinWidth=0.400000
         WinHeight=0.080000
     End Object
     Controls(13)=GUILabel'XInterface.Tab_SPLadderQualify.DMLabel4b'

     Begin Object Class=GUILabel Name=DMLabel5a
         Caption="Draft your team"
         TextFont="UT2SmallFont"
         WinTop=0.036927
         WinLeft=0.171875
         WinWidth=0.400000
         WinHeight=0.080000
     End Object
     Controls(14)=GUILabel'XInterface.Tab_SPLadderQualify.DMLabel5a'

     Begin Object Class=GUILabel Name=DMLabel5b
         Caption="then defeat them"
         TextFont="UT2SmallFont"
         WinTop=0.074219
         WinLeft=0.173438
         WinWidth=0.400000
         WinHeight=0.080000
     End Object
     Controls(15)=GUILabel'XInterface.Tab_SPLadderQualify.DMLabel5b'

     WinTop=0.150000
     WinHeight=0.770000
}

// ====================================================================
//  Written by Joe Wilcox
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class JoeTest extends TestPageBase;

#exec OBJ LOAD FILE=InterfaceContent.utx

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	Controls[2].OnClick=OnClick1;
}

function bool OnClick1(GUIComponent Sender)
{
	Controller.OpenMenu("xinterface.joetestB");
	return true;
}

function bool OnClick2(GUIComponent Sender)
{
//	Controller.CloseMenu(false);
	return true;
}

defaultproperties
{
     bCheckResolution=True
     Background=Texture'InterfaceContent.Backgrounds.bg10'
     Begin Object Class=GUIImage Name=TitleStrip
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Stretched
         WinTop=0.050000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.125000
     End Object
     Controls(0)=GUIImage'XInterface.JoeTest.TitleStrip'

     Begin Object Class=GUILabel Name=TitleText
         Caption="Joe's Amazing Test GUI"
         TextAlign=TXTA_Center
         TextColor=(B=128,G=255)
         TextFont="UT2LargeFont"
         WinTop=0.050000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.125000
     End Object
     Controls(1)=GUILabel'XInterface.JoeTest.TitleText'

     Begin Object Class=GUIButton Name=TestButton1
         Caption="Close Window"
         WinTop=0.250000
         WinLeft=0.250000
         WinWidth=0.500000
         OnKeyEvent=TestButton1.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'XInterface.JoeTest.TestButton1'

     Begin Object Class=GUINumericEdit Name=TestNumEdit
         MinValue=0
         MaxValue=999
         WinTop=0.400000
         WinLeft=0.250000
         WinWidth=0.125000
         OnDeActivate=TestNumEdit.ValidateValue
     End Object
     Controls(3)=GUINumericEdit'XInterface.JoeTest.TestNumEdit'

     Begin Object Class=GUIEditBox Name=TestNumEdit2
         IniOption="ini:Engine.Engine.RenderDevice HighDetailActors"
         WinTop=0.600000
         WinLeft=0.250000
         WinWidth=0.500000
         OnActivate=TestNumEdit2.InternalActivate
         OnDeActivate=TestNumEdit2.InternalDeactivate
         OnKeyType=TestNumEdit2.InternalOnKeyType
         OnKeyEvent=TestNumEdit2.InternalOnKeyEvent
     End Object
     Controls(4)=GUIEditBox'XInterface.JoeTest.TestNumEdit2'

     WinHeight=1.000000
}

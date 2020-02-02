class UT2SP_LadderEventPage extends UT2K3GUIPage;

var GUILabel lblTitle, lblCaption;
var GUIImage gImage;
var GUIButton btnOK, btnMap;
var string TutorialName;

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
	Super.Initcomponent(pMyController, MyOwner);
	lblTitle=GUILabel(Controls[0]);
	lblCaption=GUILabel(Controls[1]);
	btnOK=GUIButton(Controls[3]);
	gImage=GUIImage(Controls[2]);
	gImage.Image = Material(DynamicLoadObject("Laddershots.TeamDMShot", class'Material'));
	btnMap=GUIButton(Controls[5]);
	btnOK.OnClick=InternalOnClick;
	btnMap.OnClick=InternalOnClick;
}

function bool InternalOnClick(GUIComponent Sender)
{
	if (Sender==btnOK)
	{
		return Controller.CloseMenu();
	}
	else if (Sender==btnMap)
	{
		PlayerOwner().Level.Game.CurrentGameProfile.bInLadderGame=true;  // so that it'll reload into SP menus
		PlayerOwner().Level.Game.SavePackage(PlayerOwner().Level.Game.CurrentGameProfile.PackageName);
		PlayerOwner().ConsoleCommand ("START"@TutorialName$".ut2?quickstart=true?TeamScreen=false?savegame="$PlayerOwner().Level.Game.CurrentGameProfile.PackageName);
		Controller.CloseAll(false);
		return true;
	}
	return false;
}

function SetTutorialName(string tutname)
{
	TutorialName = tutname;
	if ( tutname == "" )
	{
		btnMap.bVisible=false;
		btnMap.bAcceptsInput=false;
	}
	else
	{
		btnMap.bVisible=true;
		btnMap.bAcceptsInput=true;
		BtnOK.WinLeft=0.2;
	}
}

defaultproperties
{
     Background=Texture'InterfaceContent.Backgrounds.bg10'
     Begin Object Class=GUILabel Name=SPLEPtitle
         Caption="CONGRATULATIONS!"
         TextAlign=TXTA_Center
         TextFont="UT2LargeFont"
         WinTop=0.068750
         WinHeight=0.100000
     End Object
     Controls(0)=GUILabel'XInterface.UT2SP_LadderEventPage.SPLEPtitle'

     Begin Object Class=GUILabel Name=SPLEPcaption
         TextAlign=TXTA_Center
         TextFont="UT2SmallFont"
         bMultiLine=True
         WinTop=0.716563
         WinHeight=0.350000
     End Object
     Controls(1)=GUILabel'XInterface.UT2SP_LadderEventPage.SPLEPcaption'

     Begin Object Class=GUIImage Name=SPLEPimage
         ImageStyle=ISTY_Stretched
         X1=0
         Y1=0
         X2=1023
         Y2=767
         WinTop=0.170000
         WinLeft=0.250000
         WinWidth=0.500000
         WinHeight=0.500000
     End Object
     Controls(2)=GUIImage'XInterface.UT2SP_LadderEventPage.SPLEPimage'

     Begin Object Class=GUIButton Name=SPLEPOK
         Caption="CONTINUE"
         WinTop=0.880000
         WinLeft=0.400000
         WinWidth=0.200000
         WinHeight=0.050000
         OnKeyEvent=SPLEPOK.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.UT2SP_LadderEventPage.SPLEPOK'

     Begin Object Class=GUIImage Name=SPLEPimageborder
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageStyle=ISTY_Stretched
         WinTop=0.166354
         WinLeft=0.247265
         WinWidth=0.505078
         WinHeight=0.507421
     End Object
     Controls(4)=GUIImage'XInterface.UT2SP_LadderEventPage.SPLEPimageborder'

     Begin Object Class=GUIButton Name=SPLEPMap
         Caption="VIEW TUTORIAL"
         WinTop=0.880000
         WinLeft=0.600000
         WinWidth=0.200000
         WinHeight=0.050000
         bVisible=False
         bAcceptsInput=False
         OnKeyEvent=SPLEPMap.InternalOnKeyEvent
     End Object
     Controls(5)=GUIButton'XInterface.UT2SP_LadderEventPage.SPLEPMap'

     WinHeight=1.000000
}

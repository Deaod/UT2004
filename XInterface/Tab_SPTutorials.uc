// ====================================================================
//  Class:  XInterface.Tab_SPTutorials
//  Parent: XInterface.Tab_SPPanelBase
//  Single player menu for calling up tutorials.
//  author:  capps 9/14/02  <-- great day to add a menu!
// ====================================================================

class Tab_SPTutorials extends Tab_SPPanelBase;

#exec OBJ LOAD File=Laddershots.utx

var array<GUIImage>		TutImages;		// gametype image
var array<GUIImage>		TutBorders;		// border for image
var array<GUILabel>		TutLabels;		// label for gametype
var array<GUIButton>    TutButtons;		// big button to overlay all that stuff

var localized string	SelectMessage;	// hint for selection

var config bool bTDMUnlocked, bDOMUnlocked, bCTFUnlocked, bBRUnlocked;  // whether these ladders have ever been unlocked

const DMIndex = 0;
const DOMIndex = 1;
const CTFIndex = 2;
const BRIndex = 3;

const NumButtons = 4;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	Super.Initcomponent(MyController, MyOwner);

	for (i = 0; i<NumButtons; i++)
	{
		TutImages[i] = GUIImage(Controls[i*4]);
		TutBorders[i] = GUIImage(Controls[(i*4) + 1]);
		TutLabels[i] = GUILabel(Controls[(i*4) + 2]);
		TutButtons[i] = GUIButton(Controls[(i*4) + 3]);
	}

	TutLabels[DMIndex].Caption = class'xGame.xDeathMatch'.default.GameName;
	TutLabels[DOMIndex].Caption = class'xGame.xDoubleDom'.default.GameName;
	TutLabels[CTFIndex].Caption = class'xGame.xCTFGame'.default.GameName;
	TutLabels[BRIndex].Caption = class'xGame.xBombingRun'.default.GameName;

	for (i = 0; i<NumButtons; i++)
		TutButtons[i].Hint = SelectMessage@TutLabels[i].Caption;

}

// switches images with money images depending on unlock state
function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);
	if (!bShow)
		return;

	bTDMUnlocked=default.bTDMUnlocked;
	bDOMUnlocked=default.bDOMUnlocked;
	bCTFUnlocked=default.bCTFUnlocked;
	bBRUnlocked=default.bBRUnlocked;

	TutImages[DMIndex].Image = Material(DynamicLoadObject("LadderShots.TeamDMShot", class'Material'));
	TutImages[DOMIndex].Image = Material(DynamicLoadObject("LadderShots.DOMShot", class'Material'));
	TutImages[CTFIndex].Image = Material(DynamicLoadObject("LadderShots.CTFShot", class'Material'));
	TutImages[BRIndex].Image = Material(DynamicLoadObject("LadderShots.BRShot", class'Material'));

	if ( class'Tab_PlayerSettings'.default.bUnlocked )
	{
		TutImages[DMIndex].Image = Material(DynamicLoadObject("LadderShots.TeamDMMoneyShot", class'Material'));
		TutImages[DOMIndex].Image = Material(DynamicLoadObject("LadderShots.DOMMoneyShot", class'Material'));
		TutImages[CTFIndex].Image = Material(DynamicLoadObject("LadderShots.CTFMoneyShot", class'Material'));
		TutImages[BRIndex].Image = Material(DynamicLoadObject("LadderShots.BRMoneyShot", class'Material'));
		return;
	}

	if ( bTDMUnlocked )
		TutImages[DMIndex].Image = Material(DynamicLoadObject("LadderShots.TeamDMMoneyShot", class'Material'));

	if ( bDOMUnlocked )
		TutImages[DOMIndex].Image = Material(DynamicLoadObject("LadderShots.DOMMoneyShot", class'Material'));

	if ( bCTFUnlocked )
		TutImages[CTFIndex].Image = Material(DynamicLoadObject("LadderShots.CTFMoneyShot", class'Material'));

	if ( bBRUnlocked )
		TutImages[BRIndex].Image = Material(DynamicLoadObject("LadderShots.BRMoneyShot", class'Material'));

}


function bool InternalOnClick(GUIComponent Sender)
{
	local string TutorialName;

	if (Sender == TutButtons[DMIndex])
	{
		TutorialName = "TUT-DM";
	}
	else if (Sender == TutButtons[DOMIndex])
	{
		TutorialName = "TUT-DOM";
	}
	else if (Sender == TutButtons[CTFIndex])
	{
		TutorialName = "TUT-CTF";
	}
	else if (Sender == TutButtons[BRIndex])
	{
		TutorialName = "TUT-BR";
	}
	else
		return false;

	if ( PlayerOwner().Level.Game.CurrentGameProfile != none ) {
		PlayerOwner().Level.Game.CurrentGameProfile.bInLadderGame=true;  // so that it'll reload into SP menus
		PlayerOwner().Level.Game.SavePackage(PlayerOwner().Level.Game.CurrentGameProfile.PackageName);
		PlayerOwner().ConsoleCommand ("START"@TutorialName$".ut2?quickstart=true?TeamScreen=false?savegame="$PlayerOwner().Level.Game.CurrentGameProfile.PackageName);
	}
	else
	{
		PlayerOwner().ConsoleCommand ("START"@TutorialName$".ut2?quickstart=true?TeamScreen=false");
	}
	Controller.CloseAll(false);

	return true;
}

// if no gameprofile loaded, or no team, can't show profile
function bool CanShowPanel ()
{
	return Super.CanShowPanel();
}

defaultproperties
{
     SelectMessage="Click to play tutorial for"
     bFillHeight=True
     Begin Object Class=GUIImage Name=SPTutDM
         ImageStyle=ISTY_Stretched
         X1=0
         Y1=0
         X2=1023
         Y2=767
         WinTop=0.050000
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.300000
     End Object
     Controls(0)=GUIImage'XInterface.Tab_SPTutorials.SPTutDM'

     Begin Object Class=GUIImage Name=SPTutDMB
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageStyle=ISTY_Stretched
         WinTop=0.045846
         WinLeft=0.097344
         WinWidth=0.304563
         WinHeight=0.305562
     End Object
     Controls(1)=GUIImage'XInterface.Tab_SPTutorials.SPTutDMB'

     Begin Object Class=GUILabel Name=SPTutDML
         TextAlign=TXTA_Center
         StyleName="TextButton"
         WinTop=0.350000
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.100000
     End Object
     Controls(2)=GUILabel'XInterface.Tab_SPTutorials.SPTutDML'

     Begin Object Class=GUIButton Name=SPTutDMButton
         StyleName="NoBackground"
         WinTop=0.033300
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.400000
         bFocusOnWatch=True
         OnClick=Tab_SPTutorials.InternalOnClick
         OnKeyEvent=SPTutDMButton.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.Tab_SPTutorials.SPTutDMButton'

     Begin Object Class=GUIImage Name=SPTutDOM
         ImageStyle=ISTY_Stretched
         X1=0
         Y1=0
         X2=1023
         Y2=767
         WinTop=0.500000
         WinLeft=0.100000
         WinWidth=0.300000
         WinHeight=0.300000
     End Object
     Controls(4)=GUIImage'XInterface.Tab_SPTutorials.SPTutDOM'

     Begin Object Class=GUIImage Name=SPTutDOMB
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageStyle=ISTY_Stretched
         WinTop=0.495846
         WinLeft=0.097344
         WinWidth=0.303000
         WinHeight=0.304000
     End Object
     Controls(5)=GUIImage'XInterface.Tab_SPTutorials.SPTutDOMB'

     Begin Object Class=GUILabel Name=SPTutDOML
         TextAlign=TXTA_Center
         StyleName="TextButton"
         WinTop=0.800000
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.100000
     End Object
     Controls(6)=GUILabel'XInterface.Tab_SPTutorials.SPTutDOML'

     Begin Object Class=GUIButton Name=SPTutDOMButton
         StyleName="NoBackground"
         WinTop=0.466660
         WinLeft=0.050000
         WinWidth=0.400000
         WinHeight=0.415000
         bFocusOnWatch=True
         OnClick=Tab_SPTutorials.InternalOnClick
         OnKeyEvent=SPTutDOMButton.InternalOnKeyEvent
     End Object
     Controls(7)=GUIButton'XInterface.Tab_SPTutorials.SPTutDOMButton'

     Begin Object Class=GUIImage Name=SPTutCTF
         ImageStyle=ISTY_Stretched
         X1=0
         Y1=0
         X2=1023
         Y2=767
         WinTop=0.050000
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.300000
     End Object
     Controls(8)=GUIImage'XInterface.Tab_SPTutorials.SPTutCTF'

     Begin Object Class=GUIImage Name=SPTutCTFB
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageStyle=ISTY_Stretched
         WinTop=0.045846
         WinLeft=0.597344
         WinWidth=0.303000
         WinHeight=0.304000
     End Object
     Controls(9)=GUIImage'XInterface.Tab_SPTutorials.SPTutCTFB'

     Begin Object Class=GUILabel Name=SPTutCTFL
         TextAlign=TXTA_Center
         StyleName="TextButton"
         WinTop=0.350000
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.100000
     End Object
     Controls(10)=GUILabel'XInterface.Tab_SPTutorials.SPTutCTFL'

     Begin Object Class=GUIButton Name=SPTutCTFButton
         StyleName="NoBackground"
         WinTop=0.033330
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.400000
         bFocusOnWatch=True
         OnClick=Tab_SPTutorials.InternalOnClick
         OnKeyEvent=SPTutCTFButton.InternalOnKeyEvent
     End Object
     Controls(11)=GUIButton'XInterface.Tab_SPTutorials.SPTutCTFButton'

     Begin Object Class=GUIImage Name=SPTutBR
         ImageStyle=ISTY_Stretched
         X1=0
         Y1=0
         X2=1023
         Y2=767
         WinTop=0.500000
         WinLeft=0.600000
         WinWidth=0.300000
         WinHeight=0.300000
     End Object
     Controls(12)=GUIImage'XInterface.Tab_SPTutorials.SPTutBR'

     Begin Object Class=GUIImage Name=SPTutBRB
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageStyle=ISTY_Stretched
         WinTop=0.495846
         WinLeft=0.597344
         WinWidth=0.303000
         WinHeight=0.304000
     End Object
     Controls(13)=GUIImage'XInterface.Tab_SPTutorials.SPTutBRB'

     Begin Object Class=GUILabel Name=SPTutBRL
         TextAlign=TXTA_Center
         StyleName="TextButton"
         WinTop=0.800000
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.100000
     End Object
     Controls(14)=GUILabel'XInterface.Tab_SPTutorials.SPTutBRL'

     Begin Object Class=GUIButton Name=SPTutBRButton
         StyleName="NoBackground"
         WinTop=0.466660
         WinLeft=0.550000
         WinWidth=0.400000
         WinHeight=0.415000
         bFocusOnWatch=True
         OnClick=Tab_SPTutorials.InternalOnClick
         OnKeyEvent=SPTutBRButton.InternalOnKeyEvent
     End Object
     Controls(15)=GUIButton'XInterface.Tab_SPTutorials.SPTutBRButton'

     WinTop=0.150000
     WinHeight=0.770000
}

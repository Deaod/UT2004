// ====================================================================
//  Class:  XInterface.Tab_InstantActionBotConfig
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_InstantActionBotConfig extends UT2K3TabPanel;

var GUIListBox			MyRedTeam;
var GUIListBox			MyBlueTeam;
var GUIImage			MyPortrait;
var GUICharacterList	MyBotList;
var GUIButton			MyBotMaker;
var GUILabel			MyBotName;

var	bool				bIgnoreListChange;
var bool				bTeamGame;
var bool				bPlaySounds;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	MyRedTeam 	=	GUIListBox(Controls[1]);
	MyBlueTeam	=	GUIListBox(Controls[8]);
	MyPortrait	= 	GUIImage(Controls[4]);
	MyBotList	= 	GUICharacterList(Controls[9]);
	MyBotMaker	= 	GUIButton(Controls[10]);
	MyBotName	= 	GUILabel(Controls[11]);

	MyPortrait.Image = MyBotList.GetPortrait();
	MyBotName.Caption = MyBotList.GetName();
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);

	if(bShow)
		bPlaySounds = true;
	else
		bPlaySounds = false;
}

function SetupBotLists(bool bIsTeam)
{
	local int i;
	local TeamRedConfigured tRed;
	local TeamBlueConfigured tBlue;
	local DMRosterConfigured tDM;

	bTeamGame = bIsTeam;

	MyRedTeam.List.Clear();
	MyBLueTeam.List.Clear();

	if (bTeamGame)
	{
		tRed = PlayerOwner().Spawn(class'TeamRedConfigured');
		for (i=0;i<tRed.Characters.Length;i++)
			MyRedTeam.List.Add(tRed.Characters[i]);

		tRed.Destroy();

		tBlue = PlayerOwner().Spawn(class'TeamBlueConfigured');
		for (i=0;i<tBlue.Characters.Length;i++)
			MyBlueTeam.List.Add(tBlue.Characters[i]);

		tBlue.Destroy();
	}
	else
	{
		tDM = PlayerOwner().Spawn(class'DMRosterConfigured');
		for (i=0;i<tDM.Characters.Length;i++)
			MyRedTeam.List.Add(tDM.Characters[i]);

		tDM.Destroy();
	}

	// Team Game only
	Controls[6].bVisible=bTeamGame;
	Controls[7].bVisible=bTeamGame;
	Controls[8].bVisible=bTeamGame;
	Controls[12].bVisible=bTeamGame;
	Controls[13].bVisible=bTeamGame;
	// Deathmatch only
	Controls[14].bVisible=!bTeamGame;
}

// Play is called when the play button is pressed.  It saves any releavent data and then
// returns any additions to the URL
function string Play()
{
	local int i;
	local TeamRedConfigured tRed;
	local TeamBlueConfigured tBlue;
	local DMRosterConfigured tDM;
	local bool b1,b2;
	local string url;
	local int MinPlayers;

	MinPlayers = 0;

	if (bTeamGame)
	{

	 	tRed = PlayerOwner().Spawn(class'TeamRedConfigured');

	 	if (tRed.Characters.Length>0)
	 		tRed.Characters.Remove(0,tRed.Characters.Length);

	 	if (MyRedTeam.ItemCount() > 0)
	 	{
	 		for (i=0;i<MyRedTeam.ItemCount();i++)
	 			tRed.Characters[i]=MyRedTeam.List.GetItemAtIndex(i);
	 		MinPlayers += MyRedTeam.ItemCount();
	 		b1 = true;
	 	}
	 	else
	 		b1 = false;


	 	tRed.SaveConfig();
	 	tRed.Destroy();

	 	tBlue = PlayerOwner().Spawn(class'TeamBlueConfigured');

	 	if (tBlue.Characters.Length>0)
	 		tBlue.Characters.Remove(0,tBlue.Characters.Length);

	 	if (MyBlueTeam.ItemCount()>0)
	 	{
	 		for (i=0;i<MyBlueTeam.ItemCount();i++)
	 			tBlue.Characters[i]=MyBlueTeam.List.GetItemAtIndex(i);
	 		MinPlayers += MyBlueTeam.ItemCount();
	 		b2 = true;
	 	}
	 	else
	 		b2 = false;

	 	tBlue.SaveConfig();
	 	tBlue.Destroy();

	 	if (b1)
	 		url = url$"?RedTeam=xgame.TeamRedConfigured";

	 	if (b2)
	 		url = url$"?BlueTeam=xgame.TeamBlueConfigured";
	}
	else
	{
	 	tDM = PlayerOwner().Spawn(class'DMRosterConfigured');

	 	if (tDM.Characters.Length>0)
	 		tDM.Characters.Remove(0,tDM.Characters.Length);

	 	if (MyRedTeam.ItemCount() > 0)
	 	{
	 		for (i=0;i<MyRedTeam.ItemCount();i++)
	 			tDM.Characters[i]=MyRedTeam.List.GetItemAtIndex(i);
	 		MinPlayers += MyRedTeam.ItemCount();
	 	}

		tDM.SaveConfig();
		tDM.Destroy();

		url = url$"?DMTeam=xgame.DMRosterConfigured";
	}

	url = url$"?MinPlayers="$MinPlayers;

	return url;
}

function CharListChange(GUIComponent Sender)
{
	local sound NameSound;

	MyPortrait.Image = MyBotList.GetPortrait();
	MyBotName.Caption = MyBotList.GetName();

	// Play the bots name
	if(bPlaySounds)
	{
		NameSound = MyBotList.GetSound();
		PlayerOwner().ClientPlaySound(NameSound,,,SLOT_Interface);
	}
}

function bool RedClickAdd(GUIComponent Sender)
{
	if (MyRedTeam.ItemCount() < 16)
	{
		bIgnoreListChange=true;
		MyRedTeam.List.Add(MyBotName.Caption);
	}

	return true;
}

function bool BlueClickAdd(GUIComponent Sender)
{
	if (MyBlueTeam.ItemCount() < 16)
	{
		bIgnoreListChange=true;
		MyBlueTeam.List.Add(MyBotName.Caption);
	}

	return true;
}

function bool RedClickRemove(GUIComponent Sender)
{
	local int index;

	if (MyRedTeam.ItemCount()==0)
		return true;

	Index = MyRedTeam.List.Index;
	if (Index<0)
		return true;

	bIgnoreListChange=true;
	MyRedTeam.List.Remove(Index,1);
	if (Index<MyRedTeam.List.ItemCount)
		MyRedTeam.List.SetIndex(Index);


	return true;
}

function bool BlueClickRemove(GUIComponent Sender)
{
	local int index;

	if (MyBlueTeam.ItemCount()==0)
		return true;

	Index = MyBlueTeam.List.Index;
	if (Index<0)
		return true;

	bIgnoreListChange=true;
	MyBlueTeam.List.Remove(Index,1);
	if (Index<MyBlueTeam.List.ItemCount)
		MyBlueTeam.List.SetIndex(Index);

	return true;
}


function ListChange(GUIComponent Sender)
{
	local GUIListBox Who;
	local string WhoName;

	if (bIgnoreListChange)
	{
		bIgnoreListChange=false;
		return;
	}

	WHo = GUIListBox(Sender);
	if (Who==None)
		return;

	WhoName = Who.List.Get();
	if (WhoName!="")
		MyBotList.Find(WhoName);



	return;
}

function bool InternalOnClick(GUIComponent Sender)
{
	if (Sender==Controls[15])
		MyBotList.PgUp();
	else if (Sender==Controls[16])
		MyBotList.PgDown();

	return true;
}

function bool BotInfoClick(GUIComponent Sender)
{
	if (Controller.OpenMenu("XInterface.UT2BotInfoPage"))
		UT2BotInfoPage(Controller.TopPage()).SetupBotInfo(MyBotList.GetPortrait(), MyBotList.GetDecoText(), MyBotList.GetRecord());

	return true;
}

function bool BotConfigClick(GUIComponent Sender)
{
	if (Controller.OpenMenu("XInterface.UT2BotConfigPage"))
		UT2BotConfigPage(Controller.TopPage()).SetupBotInfo(MyBotList.GetPortrait(), MyBotList.GetDecoText(), MyBotList.GetRecord());

	return true;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=IABotConfigBK1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.630156
         WinLeft=0.016758
         WinWidth=0.962383
         WinHeight=0.370860
         bVisible=False
     End Object
     Controls(0)=GUIImage'XInterface.Tab_InstantActionBotConfig.IABotConfigBK1'

     Begin Object Class=GUIListBox Name=IABotConfigRedList
         bVisibleWhenEmpty=True
         OnCreateComponent=IABotConfigRedList.InternalOnCreateComponent
         StyleName="SquareButton"
         Hint="The Red Team's Roster."
         WinTop=0.115833
         WinLeft=0.026758
         WinWidth=0.324414
         WinHeight=0.458751
         OnChange=Tab_InstantActionBotConfig.ListChange
     End Object
     Controls(1)=GUIListBox'XInterface.Tab_InstantActionBotConfig.IABotConfigRedList'

     Begin Object Class=GUIHorzScrollButton Name=IABotConfigRedAdd
         LeftButton=True
         Hint="Add Bot to Red Team"
         WinTop=0.208334
         WinLeft=0.357617
         WinWidth=0.064648
         WinHeight=0.079297
         OnClick=Tab_InstantActionBotConfig.RedClickAdd
         OnKeyEvent=IABotConfigRedAdd.InternalOnKeyEvent
     End Object
     Controls(2)=GUIHorzScrollButton'XInterface.Tab_InstantActionBotConfig.IABotConfigRedAdd'

     Begin Object Class=GUIHorzScrollButton Name=IABotConfigRedRemove
         Hint="Remove Bot from Red Team"
         WinTop=0.358073
         WinLeft=0.357617
         WinWidth=0.064648
         WinHeight=0.079297
         OnClick=Tab_InstantActionBotConfig.RedClickRemove
         OnKeyEvent=IABotConfigRedRemove.InternalOnKeyEvent
     End Object
     Controls(3)=GUIHorzScrollButton'XInterface.Tab_InstantActionBotConfig.IABotConfigRedRemove'

     Begin Object Class=GUIImage Name=IABotConfigPortrait
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.119166
         WinLeft=0.440547
         WinWidth=0.118711
         WinHeight=0.451251
     End Object
     Controls(4)=GUIImage'XInterface.Tab_InstantActionBotConfig.IABotConfigPortrait'

     Begin Object Class=GUIImage Name=IABotConfigPortraitBorder
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.115833
         WinLeft=0.438047
         WinWidth=0.123711
         WinHeight=0.458751
     End Object
     Controls(5)=GUIImage'XInterface.Tab_InstantActionBotConfig.IABotConfigPortraitBorder'

     Begin Object Class=GUIHorzScrollButton Name=IABotConfigBlueAdd
         Hint="Add Bot to Blue Team"
         WinTop=0.208334
         WinLeft=0.577344
         WinWidth=0.064648
         WinHeight=0.079297
         OnClick=Tab_InstantActionBotConfig.BlueClickAdd
         OnKeyEvent=IABotConfigBlueAdd.InternalOnKeyEvent
     End Object
     Controls(6)=GUIHorzScrollButton'XInterface.Tab_InstantActionBotConfig.IABotConfigBlueAdd'

     Begin Object Class=GUIHorzScrollButton Name=IABotConfigBlueRemove
         LeftButton=True
         Hint="Remove Bot from Blue Team"
         WinTop=0.358073
         WinLeft=0.577344
         WinWidth=0.064648
         WinHeight=0.079297
         OnClick=Tab_InstantActionBotConfig.BlueClickRemove
         OnKeyEvent=IABotConfigBlueRemove.InternalOnKeyEvent
     End Object
     Controls(7)=GUIHorzScrollButton'XInterface.Tab_InstantActionBotConfig.IABotConfigBlueRemove'

     Begin Object Class=GUIListBox Name=IABotConfigBlueList
         bVisibleWhenEmpty=True
         OnCreateComponent=IABotConfigBlueList.InternalOnCreateComponent
         StyleName="SquareButton"
         Hint="The Blue Team's Roster."
         WinTop=0.115833
         WinLeft=0.647853
         WinWidth=0.324414
         WinHeight=0.463633
         OnChange=Tab_InstantActionBotConfig.ListChange
     End Object
     Controls(8)=GUIListBox'XInterface.Tab_InstantActionBotConfig.IABotConfigBlueList'

     Begin Object Class=GUICharacterList Name=IABotConfigCharList
         StyleName="CharButton"
         Hint="Select a bot to add to a team"
         WinTop=0.689897
         WinLeft=0.137890
         WinWidth=0.724609
         WinHeight=0.236758
         OnClick=IABotConfigCharList.InternalOnClick
         OnRightClick=IABotConfigCharList.InternalOnRightClick
         OnMousePressed=IABotConfigCharList.InternalOnMousePressed
         OnMouseRelease=IABotConfigCharList.InternalOnMouseRelease
         OnChange=Tab_InstantActionBotConfig.CharListChange
         OnKeyEvent=IABotConfigCharList.InternalOnKeyEvent
         OnBeginDrag=IABotConfigCharList.InternalOnBeginDrag
         OnEndDrag=IABotConfigCharList.InternalOnEndDrag
         OnDragDrop=IABotConfigCharList.InternalOnDragDrop
         OnDragEnter=IABotConfigCharList.InternalOnDragEnter
         OnDragLeave=IABotConfigCharList.InternalOnDragLeave
         OnDragOver=IABotConfigCharList.InternalOnDragOver
     End Object
     Controls(9)=GUICharacterList'XInterface.Tab_InstantActionBotConfig.IABotConfigCharList'

     Begin Object Class=GUIButton Name=IABotConfigConfig
         Caption="More Info"
         Hint="Find out more info on this bot"
         WinTop=0.951199
         WinLeft=0.249806
         WinWidth=0.239063
         WinHeight=0.049765
         OnClick=Tab_InstantActionBotConfig.BotInfoClick
         OnKeyEvent=IABotConfigConfig.InternalOnKeyEvent
     End Object
     Controls(10)=GUIButton'XInterface.Tab_InstantActionBotConfig.IABotConfigConfig'

     Begin Object Class=GUILabel Name=IABotConfigName
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.581770
         WinHeight=0.130000
     End Object
     Controls(11)=GUILabel'XInterface.Tab_InstantActionBotConfig.IABotConfigName'

     Begin Object Class=GUILabel Name=IABotConfigRedName
         Caption="Red Team"
         TextColor=(B=0,R=255)
         WinTop=0.027082
         WinLeft=0.039063
         WinWidth=0.250000
         WinHeight=0.130000
     End Object
     Controls(12)=GUILabel'XInterface.Tab_InstantActionBotConfig.IABotConfigRedName'

     Begin Object Class=GUILabel Name=IABotConfigBlueName
         Caption="Blue Team"
         TextColor=(B=255)
         WinTop=0.027082
         WinLeft=0.655862
         WinWidth=0.250000
         WinHeight=0.130000
     End Object
     Controls(13)=GUILabel'XInterface.Tab_InstantActionBotConfig.IABotConfigBlueName'

     Begin Object Class=GUILabel Name=IABotConfigDMName
         Caption="Deathmatch"
         TextColor=(B=0,R=255)
         WinTop=0.032552
         WinLeft=0.039063
         WinWidth=0.250000
         WinHeight=0.130000
         bVisible=False
     End Object
     Controls(14)=GUILabel'XInterface.Tab_InstantActionBotConfig.IABotConfigDMName'

     Begin Object Class=GUIButton Name=BotLeft
         StyleName="ArrowLeft"
         WinTop=0.775783
         WinLeft=0.108203
         WinWidth=0.043555
         WinHeight=0.084414
         bNeverFocus=True
         bRepeatClick=True
         OnClick=Tab_InstantActionBotConfig.InternalOnClick
         OnKeyEvent=BotLeft.InternalOnKeyEvent
     End Object
     Controls(15)=GUIButton'XInterface.Tab_InstantActionBotConfig.BotLeft'

     Begin Object Class=GUIButton Name=BotRight
         StyleName="ArrowRight"
         WinTop=0.775783
         WinLeft=0.845899
         WinWidth=0.043555
         WinHeight=0.084414
         bNeverFocus=True
         bRepeatClick=True
         OnClick=Tab_InstantActionBotConfig.InternalOnClick
         OnKeyEvent=BotRight.InternalOnKeyEvent
     End Object
     Controls(16)=GUIButton'XInterface.Tab_InstantActionBotConfig.BotRight'

     Begin Object Class=GUIButton Name=IABotConfigDoConfig
         Caption="Customize"
         Hint="Change the AI attributes for this bot"
         WinTop=0.951199
         WinLeft=0.491993
         WinWidth=0.239063
         WinHeight=0.049765
         OnClick=Tab_InstantActionBotConfig.BotConfigClick
         OnKeyEvent=IABotConfigDoConfig.InternalOnKeyEvent
     End Object
     Controls(17)=GUIButton'XInterface.Tab_InstantActionBotConfig.IABotConfigDoConfig'

     WinTop=0.150000
     WinHeight=0.770000
}

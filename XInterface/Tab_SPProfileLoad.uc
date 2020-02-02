// ====================================================================
//  Single player menu for loading profile.
//  author:  capps 8/26/02
// ====================================================================

class Tab_SPProfileLoad extends Tab_SPPanelBase;

var GUIListBox		lbProfiles;
var moEditBox		ebPlayerName, ebTeamName, ebDifficulty;
var moEditBox		ebKills, ebDeaths, ebGoals, ebWins, ebMatches;
var GUIImage		imgPlayerSkin, imgTeamSymbol;
var GUIButton		butNew;

var localized string Difficulties[8];  // hardcoded for localization.  clamped 0,NumDifficulties where accessed.
var int NumDifficulties;			   // for external class access to size

var localized string DeleteMessage;

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
local GameProfile GP;

	Super.Initcomponent(pMyController, MyOwner);

	butNew=GUIButton(Controls[0]);
	lbProfiles=GUIListBox(Controls[1]);
	lbProfiles.List.OnDblClick=DoubleClickList;
	ebPlayerName=moEditBox(Controls[2]);
	ebTeamName=moEditBox(Controls[3]);
	ebDifficulty=moEditBox(Controls[4]);
	ebKills=moEditBox(Controls[5]);
	ebDeaths=moEditBox(Controls[6]);
	ebGoals=moEditBox(Controls[7]);
	imgPlayerSkin=GUIImage(Controls[8]);
	imgTeamSymbol=GUIImage(Controls[10]);
	ebWins=moEditBox(Controls[18]);
	ebMatches=moEditBox(Controls[19]);

	// if there exists a profile currently, set it to that one by default
	GP = GetProfile();
	if ( GP != none )
	{
		lbProfiles.List.Find(GP.PackageName);
		// MC: Then tell all pages that a profile is present
		ProfileUpdated();
		// Check if a Button was stored in GP and use it to focus entry page.
		if (LadderButton(GP.NextMatchObject) != None)
		{
			if (LadderButton(GP.NextMatchObject).LadderIndex > 0)
				MyTabControl().ActivateTabByName(class'UT2SinglePlayerMain'.default.TabNameLadder, true);
			else
				MyTabControl().ActivateTabByName(class'UT2SinglePlayerMain'.default.TabNameQualification, true);
		}
	}

	UpdateList();
}

function InitPanel()
{
	Super.InitPanel();
	MyButton.Hint = class'UT2SinglePlayerMain'.default.TabHintProfileLoad;
	UT2SinglePlayerMain(MyButton.MenuOwner.MenuOwner).ResetTitleBar(MyButton);
}

function OnProfileUpdated()
{
	UpdateList();
}

// update the profile listing by rechecking disk, needed after create or delete
function UpdateList()
{
local array<string> profilenames;
local int i;
local GameProfile GP;

	Controller.GetProfileList("",profilenames);
	lbProfiles.List.Clear();

	for ( i=0; i<profilenames.Length; i++ )
	{
		lbProfiles.List.Add(profilenames[i]);
	}

	GP = GetProfile();
	if ( GP != none )
		lbProfiles.List.Find(GP.PackageName);

	UpdateStats();
}

// update all the various boxes to show the stats of this profile
function UpdateStats()
{
	local string profilename;
	local GameProfile GP;
	local xUtil.PlayerRecord PR;

	// get current profile from list
	profilename = lbProfiles.List.Get();
	if ( profilename == "" )
	{
		// reset name, team, difficulty
		ebPlayerName.SetText("");
		ebTeamName.SetText("");
		ebDifficulty.SetText(Difficulties[2]);
		// reset character portrait and team symbol   was PlayerPictures.cDefault
		imgPlayerSkin.Image = Material(DynamicLoadObject("InterfaceContent.pEmptySlot", class'Material'));
		imgTeamSymbol.Image = none;
		// reset kills, death, goals
		ebKills.SetText("");
		ebDeaths.SetText("");
		ebGoals.SetText("");
		ebWins.SetText("");
		ebMatches.SetText("");
		return;
	}

	GP = PlayerOwner().Level.Game.LoadDataObject(class'GameProfile', "GameProfile", profilename);

	if ( GP == none ) {
		return;
	}

	PR = class'xGame.xUtil'.static.FindPlayerRecord(GP.PlayerCharacter);

	ebPlayerName.SetText(GP.PlayerName);
	ebTeamName.SetText(GP.TeamName);
	ebDifficulty.SetText(Difficulties[Clamp(int(GP.BaseDifficulty), 0, NumDifficulties)]);
	// reset character portrait and team symbol
	imgPlayerSkin.Image = PR.Portrait;
	imgTeamSymbol.Image = Material(DynamicLoadObject(GP.TeamSymbolName, class'Material'));
	// reset kills, death, goals
	ebKills.SetText(String(GP.Kills));
	ebDeaths.SetText(String(GP.Deaths));
	ebGoals.SetText(String(GP.Goals));
	ebWins.SetText(String(GP.Wins));
	ebMatches.SetText(String(GP.Matches));
}

////////////////////////////////////////////
// get current profile from list, load it, and apply it
//
function bool LoadClick(GUIComponent Sender)
{
local class<GameProfile> profileclass;
local string profilename;
local GameProfile GP;

	profilename = lbProfiles.List.Get();
	profileclass = class<GameProfile>(DynamicLoadObject("xGame.UT2003GameProfile", class'Class'));
	GP = PlayerOwner().Level.Game.LoadDataObject(profileclass, "GameProfile", profilename);
	if ( GP != none )
	{
		PlayerOwner().Level.Game.CurrentGameProfile = GP;
		GP.Initialize(PlayerOwner().Level.Game, profilename);
		if (GP.LadderRung[1] >= 0) { // player has unlocked main ladder
			MyTabControl().ActivateTabByName(class'UT2SinglePlayerMain'.default.TabNameLadder, true);
		} else {
			MyTabControl().ActivateTabByName(class'UT2SinglePlayerMain'.default.TabNameQualification, true);
		}

		ProfileUpdated();
	}
	return true;
}

function DeleteConfirm(byte bButton)
{
local string profilename;

	if (bButton == QBTN_Yes)
	{
		profilename = lbProfiles.List.Get();
		if ( GetProfile() != none && GetProfile().PackageName == profilename)
		{
			PlayerOwner().Level.Game.CurrentGameProfile = none;
		}
		if (!PlayerOwner().Level.Game.DeletePackage(profilename))
		{
			Log("SINGLEPLAYER Tab_SPProfileLoad::ButtonClick() failed to delete GameProfile "$profilename);
		}
		ProfileUpdated();
		UpdateList();
	}
}

////////////////////////////////////////////
// Delete the selected profile
//
function bool DeleteClick(GUIComponent Sender)
{
local GUIQuestionPage Page;
local string profilename;

	if (Controller.OpenMenu("XInterface.GUIQuestionPage"))
	{
		profilename = lbProfiles.List.Get();
		Page=GUIQuestionPage(Controller.TopPage());
		Page.SetupQuestion(Page.Replace(DeleteMessage, "prof", Caps(profilename)), QBTN_YesNo, QBTN_No);
		Page.OnButtonClick = DeleteConfirm;
	}
	return true;
}

//////////////////////////////////////////////////
// Activate the New Profile MenuPage.
//
function bool NewProfileClick(GUIComponent Sender)
{
	GUITabControl(MyButton.MenuOwner).ReplaceTab(MyButton, class'UT2SinglePlayerMain'.default.TabNameProfileNew, "xInterface.Tab_SPProfileNew", , , true);
	return true;
}

function InternalOnChange(GUIComponent Sender)
{
	UpdateStats();
}

function bool DoubleClickList(GUIComponent Sender)
{
	return LoadClick(Sender);
}

// when expose menu, might have come from the profile-create screen, so update the list
function ShowPanel(bool bShow) {
	Super.ShowPanel(bShow);
	if ( bShow ) {
		// just started game, no profiles exist, jump to create new
		if ( lbProfiles.List.ItemCount == 0 ) {
			UpdateStats();  // sets everything to empty
			NewProfileClick(butNew);
			return;
		}
	}
}

defaultproperties
{
     Difficulties(0)="Novice"
     Difficulties(1)="Average"
     Difficulties(2)="Experienced"
     Difficulties(3)="Skilled"
     Difficulties(4)="Adept"
     Difficulties(5)="Masterful"
     Difficulties(6)="Inhuman"
     Difficulties(7)="Godlike"
     NumDifficulties=8
     DeleteMessage="You are about to delete the profile for '%prof%'||Are you sure you want to delete this profile?"
     Begin Object Class=GUIButton Name=btnNew
         Caption="NEW PROFILE"
         Hint="Go to the profile creation menu"
         WinTop=0.925000
         WinLeft=0.661250
         WinWidth=0.200000
         WinHeight=0.075000
         OnClick=Tab_SPProfileLoad.NewProfileClick
         OnKeyEvent=btnNew.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.Tab_SPProfileLoad.btnNew'

     Begin Object Class=GUIListBox Name=lboxProfile
         OnCreateComponent=lboxProfile.InternalOnCreateComponent
         Hint="Select a profile"
         WinTop=0.131667
         WinLeft=0.330562
         WinWidth=0.264609
         WinHeight=0.610624
         OnChange=Tab_SPProfileLoad.InternalOnChange
     End Object
     Controls(1)=GUIListBox'XInterface.Tab_SPProfileLoad.lboxProfile'

     Begin Object Class=moEditBox Name=moebPlayerName
         bReadOnly=True
         LabelJustification=TXTA_Right
         CaptionWidth=0.550000
         Caption="Player Name: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=moebPlayerName.InternalOnCreateComponent
         Hint="Your character's name"
         WinTop=0.143847
         WinLeft=0.495360
         WinWidth=0.493750
         WinHeight=0.060000
     End Object
     Controls(2)=moEditBox'XInterface.Tab_SPProfileLoad.moebPlayerName'

     Begin Object Class=moEditBox Name=moebTeamName
         bReadOnly=True
         LabelJustification=TXTA_Right
         CaptionWidth=0.550000
         Caption="Team Name: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=moebTeamName.InternalOnCreateComponent
         Hint="The name of your team"
         WinTop=0.212590
         WinLeft=0.495360
         WinWidth=0.493750
         WinHeight=0.060000
     End Object
     Controls(3)=moEditBox'XInterface.Tab_SPProfileLoad.moebTeamName'

     Begin Object Class=moEditBox Name=moebDifficulty
         bReadOnly=True
         LabelJustification=TXTA_Right
         CaptionWidth=0.550000
         Caption="Difficulty: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=moebDifficulty.InternalOnCreateComponent
         Hint="Difficulty rating of this tournament"
         WinTop=0.280038
         WinLeft=0.495360
         WinWidth=0.493750
         WinHeight=0.060000
     End Object
     Controls(4)=moEditBox'XInterface.Tab_SPProfileLoad.moebDifficulty'

     Begin Object Class=moEditBox Name=moebKills
         bReadOnly=True
         LabelJustification=TXTA_Right
         CaptionWidth=0.550000
         Caption="Kills: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=moebKills.InternalOnCreateComponent
         Hint="Number of kills by this character"
         WinTop=0.391236
         WinLeft=0.495360
         WinWidth=0.493750
         WinHeight=0.060000
     End Object
     Controls(5)=moEditBox'XInterface.Tab_SPProfileLoad.moebKills'

     Begin Object Class=moEditBox Name=moebDeaths
         bReadOnly=True
         LabelJustification=TXTA_Right
         CaptionWidth=0.550000
         Caption="Deaths: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=moebDeaths.InternalOnCreateComponent
         Hint="Number of times this character has died"
         WinTop=0.458684
         WinLeft=0.495360
         WinWidth=0.493750
         WinHeight=0.060000
     End Object
     Controls(6)=moEditBox'XInterface.Tab_SPProfileLoad.moebDeaths'

     Begin Object Class=moEditBox Name=moebGoals
         bReadOnly=True
         LabelJustification=TXTA_Right
         CaptionWidth=0.550000
         Caption="Goals: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=moebGoals.InternalOnCreateComponent
         Hint="Number of goals scored by this character"
         WinTop=0.528632
         WinLeft=0.495360
         WinWidth=0.493750
         WinHeight=0.060000
     End Object
     Controls(7)=moEditBox'XInterface.Tab_SPProfileLoad.moebGoals'

     Begin Object Class=GUIImage Name=imagePlayerSkin
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         Hint="Your character's appearance"
         WinTop=0.162552
         WinLeft=0.173148
         WinWidth=0.133300
         WinHeight=0.500000
     End Object
     Controls(8)=GUIImage'XInterface.Tab_SPProfileLoad.imagePlayerSkin'

     Begin Object Class=GUIImage Name=imageSkinBack
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.158646
         WinLeft=0.171195
         WinWidth=0.138300
         WinHeight=0.510000
     End Object
     Controls(9)=GUIImage'XInterface.Tab_SPProfileLoad.imageSkinBack'

     Begin Object Class=GUIImage Name=imageTeamSymbol
         Image=FinalBlend'InterfaceContent.Menu.SimpleBorder_F'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         Hint="Your team's symbol"
         WinTop=0.262500
         WinLeft=0.016538
         WinWidth=0.150000
         WinHeight=0.277800
     End Object
     Controls(10)=GUIImage'XInterface.Tab_SPProfileLoad.imageTeamSymbol'

     Begin Object Class=GUIButton Name=btnDelete
         Caption="DELETE PROFILE"
         Hint="Delete the currently selected profile"
         WinTop=0.925000
         WinLeft=0.141250
         WinWidth=0.218750
         WinHeight=0.075000
         OnClick=Tab_SPProfileLoad.DeleteClick
         OnKeyEvent=btnDelete.InternalOnKeyEvent
     End Object
     Controls(11)=GUIButton'XInterface.Tab_SPProfileLoad.btnDelete'

     Begin Object Class=GUIButton Name=btnLoad
         Caption="LOAD PROFILE"
         Hint="Load the selected profile"
         WinTop=0.925000
         WinLeft=0.412500
         WinWidth=0.200000
         WinHeight=0.075000
         OnClick=Tab_SPProfileLoad.LoadClick
         OnKeyEvent=btnLoad.InternalOnKeyEvent
     End Object
     Controls(12)=GUIButton'XInterface.Tab_SPProfileLoad.btnLoad'

     Begin Object Class=GUIImage Name=SPPLDataBox
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.131250
         WinLeft=0.601563
         WinWidth=0.393751
         WinHeight=0.613750
     End Object
     Controls(13)=GUIImage'XInterface.Tab_SPProfileLoad.SPPLDataBox'

     Begin Object Class=GUIImage Name=SPPLImageBox
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.131250
         WinLeft=0.006251
         WinWidth=0.318752
         WinHeight=0.612187
     End Object
     Controls(14)=GUIImage'XInterface.Tab_SPProfileLoad.SPPLImageBox'

     Begin Object Class=GUILabel Name=SPPLLblStats
         Caption="PROFILE STATS"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2SmallFont"
         WinTop=0.734586
         WinLeft=0.592186
         WinWidth=0.400000
         WinHeight=0.100000
     End Object
     Controls(15)=GUILabel'XInterface.Tab_SPProfileLoad.SPPLLblStats'

     Begin Object Class=GUILabel Name=SPPLLblProfiles
         Caption="PROFILE LISTING"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2SmallFont"
         WinTop=0.730417
         WinLeft=0.264062
         WinWidth=0.400000
         WinHeight=0.100000
     End Object
     Controls(16)=GUILabel'XInterface.Tab_SPProfileLoad.SPPLLblProfiles'

     Begin Object Class=GUIImage Name=symbolBack
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.265417
         WinLeft=0.015922
         WinWidth=0.149042
         WinHeight=0.273672
     End Object
     Controls(17)=GUIImage'XInterface.Tab_SPProfileLoad.symbolBack'

     Begin Object Class=moEditBox Name=moebWins
         bReadOnly=True
         LabelJustification=TXTA_Right
         CaptionWidth=0.550000
         Caption="Wins: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=moebWins.InternalOnCreateComponent
         Hint="Number of matches won by this character"
         WinTop=0.597135
         WinLeft=0.495315
         WinWidth=0.493751
         WinHeight=0.060000
     End Object
     Controls(18)=moEditBox'XInterface.Tab_SPProfileLoad.moebWins'

     Begin Object Class=moEditBox Name=moebMatches
         bReadOnly=True
         LabelJustification=TXTA_Right
         CaptionWidth=0.550000
         Caption="Matches: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=moebMatches.InternalOnCreateComponent
         Hint="Number of matches played by this character"
         WinTop=0.667852
         WinLeft=0.495360
         WinWidth=0.493750
         WinHeight=0.060000
     End Object
     Controls(19)=moEditBox'XInterface.Tab_SPProfileLoad.moebMatches'

     WinTop=0.150000
     WinHeight=0.770000
}

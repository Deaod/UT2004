//==============================================================================
// Single player profile management
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SPTab_Profile extends UT2K4SPTab_Base;

var automated GUISectionBackground sbProfiles, sbDetailsBg, sbFaceBorder, sbSponsorBorder;
var automated GUIImage imgFace, imgFaceBlur, imgSponsor;
var automated GUIListBox lbProfiles;
var automated GUIButton	btnDelete, btnCreate, btnHighScores;
var automated GUIScrollTextBox sbDetails;

/** used to filter out double OnChange events */
var int HackyIndex;

var localized string NoProfileSelected, ProfileDetails, DeleteProfile, OverloadProfile, CheatWarning;
var localized string SpreeLabel[6];
var localized string MultiKillsLabel[7];

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
	Super.Initcomponent(pMyController, MyOwner);
	HackyIndex = -1;
	lbProfiles.List.OnDblClick = OnProfileDblClick;
	bInit = true;
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);
	if (bShow)
	{
		if (!Controller.bCurMenuInitialized) return;
		if (bInit)
		{
			bInit = false;
			UpdateProfileList();
		}
		MainWindow.btnPlay.Caption = CaptionLoad;
		if (lbProfiles.List.ItemCount != 0)
		{
			btnPlayEnabled(true);
			btnDelete.EnableMe();
		}
		else {
			btnPlayEnabled(false);
			btnDelete.DisableMe();
		}
		UpdateProfileDesc();
	}
}

/**
	Refresh the profile list
*/
function UpdateProfileList()
{
	local array<string> profilenames;
	local int i;

	Profile("GetProfileList");
	Controller.GetProfileList(MainWindow.ProfilePrefix, profilenames);
	Profile("GetProfileList");
	lbProfiles.List.Clear();
	for ( i = 0; i < profilenames.Length; i++ )
	{
		lbProfiles.List.Add(getProfileName(profilenames[i]));
	}
	if (GP != none) lbProfiles.List.Find(getProfileName(GP.PackageName));
	//UpdateProfileDesc();
}

/**
	Update the profile description
*/
function UpdateProfileDesc()
{
	local string SelectedProfile;
	local UT2K4GameProfile SelectedGP;
	local xUtil.PlayerRecord PR;
	local string NewDetails, tmp;
	local int i;

	Profile("UpdateProfileDesc");
	SelectedProfile = MainWindow.ProfilePreFix$lbProfiles.List.Get();
	if (SelectedProfile != "") SelectedGP = PlayerOwner().Level.Game.LoadDataObject(ProfileClass, "GameProfile", SelectedProfile);
	if (SelectedGP == none)
	{
		imgFace.Image = none;
		imgFace.ImageColor.A = 196;
		imgFaceBlur.bVisible = true;
		imgSponsor.Image = none;
		sbDetails.SetContent(NoProfileSelected);
	}
	else {
		if ((GP != none) && (SelectedGP.PackageName ~= GP.PackageName))
		{
			imgFaceBlur.bVisible = false;
			imgFace.ImageColor.A = 255;
		}
		else {
			imgFaceBlur.bVisible = true;
			imgFace.ImageColor.A = 196;
		}
		PR = class'xGame.xUtil'.static.FindPlayerRecord(SelectedGP.PlayerCharacter);
		imgFace.Image = PR.Portrait;
		imgSponsor.Image = Material(DynamicLoadObject(SelectedGP.TeamSymbolName, class'Material'));
		NewDetails = Repl(ProfileDetails, "%teamname%", SelectedGP.TeamName);
		NewDetails = Repl(NewDetails, "%playername%", SelectedGP.PlayerName);
		NewDetails = Repl(NewDetails, "%teammembers%", JoinArray(SelectedGP.PlayerTeam, ", ", true));
		NewDetails = Repl(NewDetails, "%totaltime%", int(round(SelectedGP.TotalTime / 60)));
		NewDetails = Repl(NewDetails, "%credits%", ProfileClass.static.MoneyToString(SelectedGP.Balance));
		NewDetails = Repl(NewDetails, "%matches%", SelectedGP.matches);
		NewDetails = Repl(NewDetails, "%wins%", SelectedGP.wins);
		NewDetails = Repl(NewDetails, "%kills%", SelectedGP.kills);
		NewDetails = Repl(NewDetails, "%deaths%", SelectedGP.deaths);
		NewDetails = Repl(NewDetails, "%Goals%", SelectedGP.goals);
		tmp = "";
		for (i = 0; i < 6; i++)
		{
			if (SelectedGP.spree[i] > 0) tmp $= "|"$SpreeLabel[i]@SelectedGP.spree[i];
		}
		NewDetails = Repl(NewDetails, "%sprees%", tmp);
		tmp = "";
		for (i = 0; i < 7; i++)
		{
			if (SelectedGP.MultiKills[i] > 0) tmp $= "|"$MultiKillsLabel[i]@SelectedGP.MultiKills[i];
		}
		NewDetails = Repl(NewDetails, "%multikills%", tmp);
		tmp = "";
		for (i = 0; i < 6; i++)
		{
			if (SelectedGP.SpecialAwards[i] > 0) tmp $= "|"$SelectedGP.msgSpecialAward[i]$":"@SelectedGP.SpecialAwards[i];
		}
		NewDetails = Repl(NewDetails, "%specialawards%", tmp);

		sbDetails.SetContent(NewDetails);

		// the Ultimate answer to Life, the Universe and Everything is ...
		// ... show debug controlls
		if (SelectedGP.PlayerName == "42")
		{
			MainWindow.btnDebugExec.bVisible = true;
			MainWindow.edDebugExec.bVisible = true;
		}
	}
	Profile("UpdateProfileDesc");
}

/**
	Create profile button clicked
*/
function bool btnCreateOnClick(GUIComponent Sender)
{
	btnPlayEnabled(true);
	MainWindow.c_Tabs.ReplaceTab(MyButton, MainWindow.PanelCaption[1], MainWindow.PanelClass[1], , MainWindow.PanelHint[1], true);
	return true;
}

/**
	Delete profile button clicked
*/
function bool btnDeleteOnClick(GUIComponent Sender)
{
	local GUIQuestionPage QPage;
	local string SelectedProfile;

	if (Controller.OpenMenu(Controller.QuestionMenuClass))
	{
		SelectedProfile = lbProfiles.List.Get();
		QPage=GUIQuestionPage(Controller.TopPage());
		QPage.SetupQuestion(QPage.Replace(DeleteProfile, "profile", SelectedProfile), QBTN_YesNo, QBTN_No);
		QPage.OnButtonClick = OnConfirmDelete;
	}
	return true;
}

/**
	User confirmed the deletion of the profile
*/
function OnConfirmDelete(byte bButton)
{
	local string SelectedProfile;

	if (bButton == QBTN_Yes)
	{
		SelectedProfile = MainWindow.ProfilePreFix$lbProfiles.List.Get();
		if ( GP != none && GP.PackageName == SelectedProfile)
		{
			GP = none;
			PlayerOwner().Level.Game.CurrentGameProfile = none;
			MainWindow.UpdateTabs();
		}
		if (!PlayerOwner().Level.Game.DeletePackage(SelectedProfile))
		{
			Log("Failed to delete profile "$SelectedProfile, LogPrefix);
		}
		UpdateProfileList();
		btnPlayEnabled(lbProfiles.List.ItemCount != 0);
	}
}

/**
	User has selected a diffirent profile
*/
function onProfileChange(GUIComponent Sender)
{
	local string Selected;
	if (HackyIndex == lbProfiles.List.Index) return;
	HackyIndex = lbProfiles.List.Index;
	Selected = lbProfiles.List.Get();
	if ((Selected != "") || ((GP != none) && ((MainWindow.ProfilePreFix$Selected) == GP.PackageName)))
	{
		btnPlayEnabled(true);
		btnDelete.EnableMe();
	}
	else {
		btnPlayEnabled(false);
		btnDelete.DisableMe();
	}
	UpdateProfileDesc();
}

/**
	Double clicked the profile list -> load profile
*/
function bool OnProfileDblClick( GUIComponent Sender)
{
	return onPlayClick();
}

/**
	Load the selected profile, warn if already a profile loaded
*/
function bool onPlayClick()
{
	local GUIQuestionPage QPage;
	local string SelectedProfile;

	if (GP != none)
	{
		SelectedProfile = lbProfiles.List.Get();
		if (GP.PackageName ~= (MainWindow.ProfilePreFix$SelectedProfile)) return true; // selected profile is already loaded

		if (Controller.OpenMenu(Controller.QuestionMenuClass))
		{
			QPage=GUIQuestionPage(Controller.TopPage());
			QPage.SetupQuestion(OverloadProfile, QBTN_YesNo, QBTN_No);
			QPage.OnButtonClick = OnConfirmLoad;
		}
		return true;
	}
	else {
		OnConfirmLoad(QBTN_Yes);
		return true;
	}
}

/**
	User confirmed loading of a new profile
*/
function OnConfirmLoad(byte bButton)
{
	local GUIQuestionPage QPage;
	local string SelectedProfile;

	if (bButton == QBTN_Yes)
	{
		if (GP != none) PlayerOwner().Level.Game.SavePackage(GP.PackageName); // save before loading new profile
		SelectedProfile = MainWindow.ProfilePreFix$lbProfiles.List.Get();
		GP = PlayerOwner().Level.Game.LoadDataObject(ProfileClass, "GameProfile", SelectedProfile);
		if (GP.StoredPlayerID() != PlayerOwner().GetPlayerIDHash())
		{
			if (Controller.OpenMenu(Controller.QuestionMenuClass))
			{
				QPage=GUIQuestionPage(Controller.TopPage());
				QPage.SetupQuestion(CheatWarning, QBTN_YesNo, QBTN_No);
				QPage.OnButtonClick = OnFinalLoad;
			}
		}
		else OnFinalLoad(QBTN_Continue);
	}
}

/** */
function OnFinalLoad(byte bButton)
{
	local string SelectedProfile;
	if (bButton == QBTN_Yes || bButton == QBTN_Continue)
	{
		GP.LoadProfile(PlayerOwner());
		if ( GP != none )
		{
			SelectedProfile = MainWindow.ProfilePreFix$lbProfiles.List.Get();
			PlayerOwner().Level.Game.CurrentGameProfile = GP;
			GP.Initialize(PlayerOwner().Level.Game, SelectedProfile);
			GP.bInLadderGame = true;
			GP.bIsChallenge = false;
			MainWindow.UpdateTabs(true);
			MainWindow.HandleGameProfile();
			GP.bInLadderGame = false;
			if (MainWindow.SetActiveTab != none) MainWindow.c_Tabs.ActivateTab(MainWindow.SetActiveTab.MyButton, true);
		}
	}
	else {
		GP = none;
		PlayerOwner().Level.Game.CurrentGameProfile = none;
	}
}

function bool btnHighScoresOnClick(GUIComponent Sender)
{
	return Controller.OpenMenu(MainWindow.HighScorePage);
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=SPPsbProfiles
         Caption="Profiles"
         WinTop=0.046588
         WinLeft=0.023243
         WinWidth=0.270899
         WinHeight=0.803050
         bBoundToParent=True
         OnPreDraw=SPPsbProfiles.InternalPreDraw
     End Object
     sbProfiles=GUISectionBackground'GUI2K4.UT2K4SPTab_Profile.SPPsbProfiles'

     Begin Object Class=GUISectionBackground Name=SPPsbDetailsBg
         Caption="Details"
         WinTop=0.368975
         WinLeft=0.610000
         WinWidth=0.370000
         WinHeight=0.484668
         OnPreDraw=SPPsbDetailsBg.InternalPreDraw
     End Object
     sbDetailsBg=GUISectionBackground'GUI2K4.UT2K4SPTab_Profile.SPPsbDetailsBg'

     Begin Object Class=AltSectionBackground Name=SPPimgFaceBorder
         WinTop=0.050000
         WinLeft=0.310000
         WinWidth=0.280000
         WinHeight=0.800000
         bBoundToParent=True
         OnPreDraw=SPPimgFaceBorder.InternalPreDraw
     End Object
     sbFaceBorder=AltSectionBackground'GUI2K4.UT2K4SPTab_Profile.SPPimgFaceBorder'

     Begin Object Class=GUISectionBackground Name=SPPimgSponsorBorder
         bAltCaption=True
         WinTop=0.050000
         WinLeft=0.610000
         WinWidth=0.370000
         WinHeight=0.292959
         bBoundToParent=True
         OnPreDraw=SPPimgSponsorBorder.InternalPreDraw
     End Object
     sbSponsorBorder=GUISectionBackground'GUI2K4.UT2K4SPTab_Profile.SPPimgSponsorBorder'

     Begin Object Class=GUIImage Name=SPPimgFace
         ImageColor=(A=196)
         ImageStyle=ISTY_Scaled
         WinTop=0.106977
         WinLeft=0.324005
         WinWidth=0.251990
         WinHeight=0.686098
         RenderWeight=0.300000
         bBoundToParent=True
     End Object
     imgFace=GUIImage'GUI2K4.UT2K4SPTab_Profile.SPPimgFace'

     Begin Object Class=GUIImage Name=SPPimgFaceBlur
         Image=TexPanner'InterfaceContent.Menu.pEmptySlot'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.106977
         WinLeft=0.324005
         WinWidth=0.251990
         WinHeight=0.686098
         RenderWeight=0.200000
         bBoundToParent=True
     End Object
     imgFaceBlur=GUIImage'GUI2K4.UT2K4SPTab_Profile.SPPimgFaceBlur'

     Begin Object Class=GUIImage Name=SPPimgSponsor
         ImageStyle=ISTY_Justified
         ImageRenderStyle=MSTY_Normal
         ImageAlign=IMGA_Center
         WinTop=0.108412
         WinLeft=0.625255
         WinWidth=0.338214
         WinHeight=0.221199
         RenderWeight=0.300000
         bBoundToParent=True
     End Object
     imgSponsor=GUIImage'GUI2K4.UT2K4SPTab_Profile.SPPimgSponsor'

     Begin Object Class=GUIListBox Name=SPPlbProfiles
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=SPPlbProfiles.InternalOnCreateComponent
         FontScale=FNS_Medium
         Hint="Select a profile"
         WinTop=0.125901
         WinLeft=0.041832
         WinWidth=0.236888
         WinHeight=0.689871
         TabOrder=1
         bBoundToParent=True
         OnChange=UT2K4SPTab_Profile.onProfileChange
     End Object
     lbProfiles=GUIListBox'GUI2K4.UT2K4SPTab_Profile.SPPlbProfiles'

     Begin Object Class=GUIButton Name=SPPbtnDelete
         Caption="DELETE"
         FontScale=FNS_Small
         Hint="Delete the selected profile"
         WinTop=0.900000
         WinLeft=0.180000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=3
         bBoundToParent=True
         OnClick=UT2K4SPTab_Profile.btnDeleteOnClick
         OnKeyEvent=SPPbtnDelete.InternalOnKeyEvent
     End Object
     btnDelete=GUIButton'GUI2K4.UT2K4SPTab_Profile.SPPbtnDelete'

     Begin Object Class=GUIButton Name=SPPbtnCreate
         Caption="CREATE NEW"
         FontScale=FNS_Small
         Hint="Create a new profile"
         WinTop=0.900000
         WinLeft=0.400000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=4
         bBoundToParent=True
         OnClick=UT2K4SPTab_Profile.btnCreateOnClick
         OnKeyEvent=SPPbtnCreate.InternalOnKeyEvent
     End Object
     btnCreate=GUIButton'GUI2K4.UT2K4SPTab_Profile.SPPbtnCreate'

     Begin Object Class=GUIButton Name=SPPbtnHighScores
         Caption="HIGH SCORES"
         FontScale=FNS_Small
         Hint="View the high scores"
         WinTop=0.900000
         WinLeft=0.620000
         WinWidth=0.200000
         WinHeight=0.050000
         TabOrder=5
         bBoundToParent=True
         OnClick=UT2K4SPTab_Profile.btnHighScoresOnClick
         OnKeyEvent=SPPbtnHighScores.InternalOnKeyEvent
     End Object
     btnHighScores=GUIButton'GUI2K4.UT2K4SPTab_Profile.SPPbtnHighScores'

     Begin Object Class=GUIScrollTextBox Name=SPPsbDetails
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=SPPsbDetails.InternalOnCreateComponent
         WinTop=0.439184
         WinLeft=0.634133
         WinWidth=0.325485
         WinHeight=0.388622
         TabOrder=2
         bBoundToParent=True
     End Object
     sbDetails=GUIScrollTextBox'GUI2K4.UT2K4SPTab_Profile.SPPsbDetails'

     NoProfileSelected="No profile selected..."
     ProfileDetails="Team: %teamname%|Leader: %playername%|Members: %teammembers%||Total game time: %totaltime% minutes|Balance: %credits%||Matches: %matches%|Wins: %wins%|Kills: %kills%|Deaths: %deaths%|Goals: %Goals%|%sprees%|%multikills%|%specialawards%"
     DeleteProfile="You are about to delete the profile for '%profile%'||Are you sure you want to delete this profile?"
     OverloadProfile="You already have a profile loaded.||Are you sure you want to load this profile?"
     CheatWarning="Warning!|This profile does NOT originate from your machine.|This profile is not eligible for unlocking characters.|Do you want to load this profile?"
     SpreeLabel(0)="Killing Spree:"
     SpreeLabel(1)="Rampage:"
     SpreeLabel(2)="Dominating:"
     SpreeLabel(3)="Unstoppable:"
     SpreeLabel(4)="GODLIKE:"
     SpreeLabel(5)="WICKED SICK:"
     MultiKillsLabel(0)="Double Kill:"
     MultiKillsLabel(1)="MultiKill:"
     MultiKillsLabel(2)="MegaKill:"
     MultiKillsLabel(3)="UltraKill:"
     MultiKillsLabel(4)="MONSTER KILL:"
     MultiKillsLabel(5)="LUDICROUS KILL:"
     MultiKillsLabel(6)="HOLY SHIT:"
     PanelCaption="Profile"
}

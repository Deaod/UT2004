//==============================================================================
//	Description
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class UT2K4Tab_PlayerSettings extends Settings_Tabs;

var localized string HandNames[4];
var localized string TeamNames[3];
var localized string ClickInst;
var localized string All;
var localized string Previews[3];

var bool bChanged;

// Used for character (not just weapons!)
var() editinline editconst noexport SpinnyWeap		SpinnyDude; // MUST be set to null when you leave the window
var() vector			SpinnyDudeOffset;
var() bool				bRenderDude;
var localized string	ShowBioCaption;
var localized string	Show3DViewCaption;
var localized string    DefaultText;

var string OriginalTeam;
var automated GUISectionBackground i_BG1, i_BG2, i_BG3;
var automated GUIImage	i_Portrait;
var automated GUIButton	b_Left, b_Right, b_Pick, b_3DView, b_DropTarget;
var automated GUIScrollTextBox	lb_Scroll;
var automated moEditBox		ed_Name;
var automated moCheckBox	ch_SmallWeaps;
var automated moComboBox	co_Team, co_Hand, co_Voice;
var automated moNumericEdit	nu_FOV;
var automated GUILabel lbl_ModelName;
var automated GUIComboBox co_SkinPreview;

var array<class<xVoicePack> > VoiceClasses;


var() string	sChar, sName, sNameD, sCharD, sVoice, sVoiceD;
var() int		iTeam, iHand, iFOV, iTeamD, iHandD, iFOVD;
var() bool	bWeaps, bWeapsD;
var() int		nfov;
var() xUtil.PlayerRecord PlayerRec;
var() int YawValue;

delegate VoiceTypeChanged(string NewVoiceType);

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	co_Hand.AddItem(HandNames[0]);
	co_Hand.AddItem(HandNames[1]);
	co_Hand.AddItem(HandNames[2]);
	co_Hand.AddItem(HandNames[3]);
	co_Hand.ReadOnly(true);

	co_Team.AddItem(TeamNames[0]);
	co_Team.AddItem(TeamNames[1]);
	co_Team.AddItem(TeamNames[2]);
	co_Team.ReadOnly(true);

	// Spawn spinning character actor
	if ( SpinnyDude == None )
		SpinnyDude = PlayerOwner().spawn(class'XInterface.SpinnyWeap');

	SpinnyDude.bPlayCrouches = false;
    SpinnyDude.bPlayRandomAnims = false;

	SpinnyDude.SetDrawType(DT_Mesh);
	SpinnyDude.SetDrawScale(0.9);
	SpinnyDude.SpinRate = 0;

	b_3DView.Caption = Show3DViewCaption;

	ed_Name.MyEditBox.bConvertSpaces = true;
	ed_Name.MyEditBox.MaxWidth=16;  // as per polge, check UT2K4Tab_PlayerSettings if you change this

	nu_FOV.MyNumericEdit.Step = 5;

    co_SkinPreview.AddItem(Previews[0]);
    co_SkinPreview.AddItem(Previews[1]);
    co_SkinPreview.AddItem(Previews[2]);

	i_BG2.Managecomponent(ed_Name);
    i_BG2.Managecomponent(ch_SmallWeaps);
    i_BG2.Managecomponent(co_Team);
    i_BG2.Managecomponent(co_Hand);
    i_BG2.Managecomponent(co_Voice);
    i_BG2.Managecomponent(nu_FOV);

    i_BG3.Managecomponent(lb_Scroll);
}

function SetPlayerRec()
{
	local int i;
	local array<xUtil.PlayerRecord> PList;

	class'xUtil'.static.GetPlayerList(PList);

	// Filter out to only characters without the 's' menu setting
	for(i=0; i<PList.Length; i++)
	{
    	if ( sChar ~= Plist[i].DefaultName )
    	{
        	PlayerRec = PList[i];
        	break;
        }
    }

	UpdateVoiceOptions();
	UpdateScroll();
	ShowSpinnyDude();
}

function ShowPanel(bool bShow)
{
	local int i;
    local array<string> VoiceClassNames;
    local class<xVoicePack> VP;

	Super.ShowPanel(bShow);
	if ( bShow )
	{
		if ( bInit )
		{
			bInit = False;

		    PlayerOwner().GetAllInt("XGame.xVoicePack", VoiceClassNames);
		    VoiceClasses.Remove(0, VoiceClasses.Length);

		    for ( i = 0; i < VoiceClassNames.Length; i++ )
		    {
		    	VP = class<xVoicePack>(DynamicLoadObject(VoiceClassNames[i],class'Class'));
		    	if ( VP != None )
		    		VoiceClasses[VoiceClasses.Length] = VP;
		    }

		    bRenderDude = True;
		    SetPlayerRec();
			for (i = 0; i < Components.Length; i++)
				Components[i].OnChange = InternalOnChange;
		}
	}
}

function SaveSettings()
{
	local bool bSave;
	local PlayerController PC;

	Super.SaveSettings();
	PC = PlayerOwner();

	if (sNameD != sName)
	{
		PC.ReplaceText(sName, "\"", "");
		sNameD = sName;
		PC.ConsoleCommand("SetName"@sName);
	}

	if (iTeam == 2)
		iTeam = 255;

	if (iTeamD != iTeam)
	{
		iTeamD = iTeam;
		PC.UpdateUrl("Team", string(iTeam), True);
		PC.ChangeTeam(iTeam);
	}

	if (iTeam == 255)
		iTeam = 2;

	if (bWeapsD != bWeaps)
	{
		bWeapsD = bWeaps;
		PC.bSmallWeapons = bWeaps;
		bSave = True;
	}

	if (iHandD != iHand)
	{
		iHandD = iHand;
		PC.Handedness = iHand - 1;
		PC.SetHand(iHand - 1);
		bSave = False;
	}

	if (iFOVD != iFOV)
	{
		iFOVD = iFOV;
		PC.FOV( float(iFOV) );
		bSave = False;
	}

	if (sChar != sCharD)
	{
		sCharD = sChar;
		PC.ConsoleCommand("ChangeCharacter"@sChar);
		if ( PC.IsA('xPlayer') )
			bSave = False;
		else PC.UpdateURL("Character", sChar, True);

		if ( PlayerRec.Sex ~= "Female" )
			PC.UpdateURL("Sex", "F", True);
		else
			PC.UpdateURL("Sex", "M", True);
	}

	if (sVoice != sVoiceD)
	{
		sVoiceD = sVoice;
		PC.SetVoice(sVoice);
	}

	if (bSave)
		PC.SaveConfig();
}

function ResetClicked()
{
	local int i;
	local bool bTemp;
	local PlayerController PC;

	Super.ResetClicked();

	PC = PlayerOwner();
	PC.ConsoleCommand("ChangeCharacter Jakob");
	PC.ConsoleCommand("setname Player");
	PC.ChangeTeam(255);

	PC.UpdateURL("Name", "Player", True);
	PC.UpdateURL("Character", "Jakob", True);
	PC.UpdateURL("Sex", "M", True);
	PC.UpdateURL("Team", "255", True);


	class'Controller'.static.ResetConfig("Handedness");
	class'PlayerController'.static.ResetConfig("bSmallWeapons");
	class'PlayerController'.static.ResetConfig("DefaultFOV");

	bTemp = Controller.bCurMenuInitialized;
	Controller.bCurMenuInitialized = False;

	for (i = 0; i < Controls.Length; i++)
		Controls[i].LoadINI();

    bRenderDude = True;
    SetPlayerRec();

	Controller.bCurMenuInitialized = bTemp;
}

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local PlayerController PC;

	PC = PlayerOwner();
	if (GUIMenuOption(Sender) != None)
	{
		switch (GUIMenuOption(Sender))
		{
		case ed_Name:
			sName = PC.GetUrlOption("Name");
			sNameD = sName;
			ed_Name.SetText(sName);
			break;

		case co_Team:
			if (PC.PlayerReplicationInfo == None || PC.PlayerReplicationInfo.Team == None)
				iTeam = int(PC.GetUrlOption("Team"));
			else iTeam = PC.PlayerReplicationInfo.Team.TeamIndex;

			iTeamD = iTeam;
			if (iTeam > 1)
				iTeam = 2;

			co_Team.SetIndex(iTeam);
			break;

		case co_Voice:
			if ( PC.PlayerReplicationInfo == None || PC.PlayerReplicationInfo.VoiceTypeName == "" )
				sVoice = PC.GetUrlOption("Voice");
			else sVoice = PC.PlayerReplicationInfo.VoiceTypeName;
			sVoiceD = sVoice;
			break;

		case ch_SmallWeaps:
			bWeaps = PC.bSmallWeapons;
			bWeapsD = bWeaps;
			ch_SmallWeaps.Checked(bWeaps);
			break;

		case co_Hand:
			iHand = PC.Handedness + 1;
			iHandD = iHand;
			co_Hand.SetIndex(iHand);
			break;

		case nu_FOV:
			iFOV = PC.DefaultFOV;
			iFOVD = iFOV;
			nu_FOV.SetValue(iFOV);
			break;

		default:
			log(Name@"Unknown component calling LoadINI:"$ GUIMenuOption(Sender).Caption);
			GUIMenuOption(Sender).SetComponentValue(s,true);
		}
	}

	else if ( Sender == i_Portrait )
	{
		sChar = PC.GetUrlOption("Character");
		sCharD = sChar;
	}
}

function InternalOnChange(GUIComponent Sender)
{
	local PlayerController PC;

	PC = PlayerOwner();
	Super.InternalOnChange(Sender);
	if (GUIMenuOption(Sender) != None)
	{
		switch (GUIMenuOption(Sender))
		{
		case ed_Name:
			sName = ed_Name.GetText();
			break;

		case co_Team:
			iTeam = co_Team.GetIndex();
			break;

		case ch_SmallWeaps:
			bWeaps = ch_SmallWeaps.IsChecked();
			break;

		case co_Hand:
			iHand = co_Hand.GetIndex();
			break;

		case nu_FOV:
			iFOV = nu_FOV.GetValue();
			break;

		case co_Voice:
			sVoice = co_Voice.GetExtra();
			PreviewVoice( class<xVoicePack>(co_Voice.GetObject()) );
			VoiceTypeChanged(sVoice);
			break;
		}
	}

	else if ( Sender == co_SkinPreview )
		UpdateSpinnyDude();
}

function PreviewVoice(class<xVoicePack> NewVoiceClass)
{
	local int Index;

	if ( NewVoiceClass == None )
		return;

	Index = NewVoiceClass.static.PickCustomTauntFor( PlayerOwner(), True, False, 21 );
	PlayerOwner().ClientPlaySound(NewVoiceClass.default.TauntSound[Index],,,SLOT_Interface);
}
function UpdateVoiceOptions()
{
	local int i;
	local bool bTemp;

	bTemp = Controller.bCurMenuInitialized;
	Controller.bCurMenuInitialized = False;

	co_Voice.MyComboBox.List.Clear();
	co_Voice.AddItem(DefaultText);
	for ( i = 0; i < VoiceClasses.Length; i++ )
	{
		if ( class'TeamVoicePack'.static.VoiceMatchesGender(VoiceClasses[i].default.VoiceGender, PlayerRec.Sex) )
			co_Voice.AddItem(VoiceClasses[i].default.VoicePackName,VoiceClasses[i],string(VoiceClasses[i]));
	}

	i = co_Voice.FindIndex(sVoice,,True);
	if ( i != -1 )
		co_Voice.SetIndex(i);
	else co_Voice.SetIndex(0);

	Controller.bCurMenuInitialized = bTemp;
}

function UpdateScroll()
{
	lb_Scroll.SetContent(Controller.LoadDecoText("",PlayerRec.TextName));
}

function UpdateSpinnyDude()
{
	local Mesh PlayerMesh;
	local Material BodySkin, HeadSkin;
    local string BodySkinName, HeadSkinName, TeamSuffix;
    local bool bBrightSkin;
	
	i_Portrait.Image = PlayerRec.Portrait;
	PlayerMesh = Mesh(DynamicLoadObject(PlayerRec.MeshName, class'Mesh'));
	if(PlayerMesh == None)
	{
		Log("Could not load mesh: "$PlayerRec.MeshName$" For player: "$PlayerRec.DefaultName);
		return;
	}


	// Setup options
	TeamSuffix = Eval( co_SkinPreview.GetIndex() > 0, Eval(co_SkinPreview.GetIndex() == 1, "_0", "_1"), "" );

	// Get the body skin
    BodySkinName = PlayerRec.BodySkinName $ TeamSuffix;
	bBrightSkin = class'DMMutator'.default.bBrightSkins && Left(BodySkinName,12) ~= "PlayerSkins.";

    if ( bBrightSkin && TeamSuffix != "" )
    	BodySkinName = "Bright" $ BodySkinName $ "B";

	// Get the head skin
    HeadSkinName = PlayerRec.FaceSkinName;
    if ( PlayerRec.TeamFace )
    	HeadSkinName $= TeamSuffix;

	BodySkin = Material(DynamicLoadObject(BodySkinName, class'Material'));
	if(BodySkin == None)
	{
		Log("Could not load body material: "$PlayerRec.BodySkinName$" For player: "$PlayerRec.DefaultName);
		return;
	}

	if ( bBrightSkin )
		SpinnyDude.AmbientGlow = SpinnyDude.default.AmbientGlow * 0.8;
	else SpinnyDude.AmbientGlow = SpinnyDude.default.AmbientGlow;


	HeadSkin = Material(DynamicLoadObject(HeadSkinName, class'Material'));
	if(HeadSkin == None)
	{
		Log("Could not load head material: "$HeadSkinName$" For player: "$PlayerRec.DefaultName);
		return;
	}

	SpinnyDude.LinkMesh(PlayerMesh);
	SpinnyDude.Skins[0] = BodySkin;
	SpinnyDude.Skins[1] = HeadSkin;
	SpinnyDude.LoopAnim( 'Idle_Rest', 1.0/SpinnyDude.Level.TimeDilation );
}

function bool InternalDraw(Canvas canvas)
{
	local vector CamPos, X, Y, Z;
	local rotator CamRot;
	local float   oOrgX, oOrgY;
	local float   oClipX, oClipY;

	if(bRenderDude)
	{
    	oOrgX = Canvas.OrgX;
        oOrgY = Canvas.OrgY;
        oClipX = Canvas.ClipX;
        oClipY = Canvas.ClipY;

        Canvas.OrgX = b_DropTarget.ActualLeft();
        Canvas.OrgY = b_DropTarget.ActualTop();
        Canvas.ClipX = b_DropTarget.ActualWidth();
        Canvas.ClipY = b_DropTarget.ActualHeight();

		canvas.GetCameraLocation(CamPos, CamRot);
		GetAxes(CamRot, X, Y, Z);

		SpinnyDude.SetLocation(CamPos + (SpinnyDudeOffset.X * X) + (SpinnyDudeOffset.Y * Y) + (SpinnyDudeOffset.Z * Z));
		canvas.DrawActorClipped(SpinnyDude, false,  b_DropTarget.ActualLeft(), b_DropTarget.ActualTop(), b_DropTarget.ActualWidth(), b_DropTarget.ActualHeight(), true, nFov);

        Canvas.OrgX = oOrgX;
	    Canvas.OrgY = oOrgY;
    	Canvas.ClipX = oClipX;
        Canvas.ClipY = oClipY;
	}

	return bRenderDude;
}

function bool PickModel(GUIComponent Sender)
{
    if ( Controller.OpenMenu("GUI2K4.UT2K4ModelSelect",
                              PlayerRec.DefaultName,
		                      Eval(Controller.CtrlPressed, PlayerRec.Race, "")) )
    	Controller.ActivePage.OnClose = ModelSelectClosed;

    return true;
}

function ModelSelectClosed( optional bool bCancelled )
{
	local string str;

	if ( bCancelled )
		return;

	str = Controller.ActivePage.GetDataString();
	if ( str != "" )
	{
		sChar = str;
		SetPlayerRec();
	}
}

function ShowSpinnyDude()
{
	if ( bRenderDude )
	{
		UpdateSpinnyDude(); // Load current character
        co_SkinPreview.SetVisibility(true);
		b_3DView.Caption = ShowBioCaption; // Change button caption
		b_DropTarget.MouseCursorIndex = 5;
	}
	else
	{
		// Put text back into box
		i_Portrait.Image = PlayerRec.Portrait;
		b_3DView.Caption = Show3DViewCaption;
        co_SkinPreview.SetVisibility(false);
		SpinnyDude.LinkMesh(None);
		b_DropTarget.MouseCursorIndex = 0;
	}

}

function bool Toggle3DView(GUIComponent Sender)
{
	bRenderDude = !bRenderDude;
	ShowSpinnyDude();

	return true;
}

function bool NextAnim(GUIComponent Sender)
{
	if(bRenderDude)
	{
		SpinnyDude.PlayNextAnim();
	}

	return true;
}

function bool RaceCapturedMouseMove(float deltaX, float deltaY)
{
	local rotator r;
  	r = SpinnyDude.Rotation;
    r.Yaw -= (256 * DeltaX);
    SpinnyDude.SetRotation(r);
    return true;
}

event Opened(GUIComponent Sender)
{
	local rotator R;

	Super.Opened(Sender);

	if ( SpinnyDude != None )
	{
		R.Yaw = 32768;
		R.Pitch = -1024;
		SpinnyDude.SetRotation(R+PlayerOwner().Rotation);
		SpinnyDude.bHidden = false;
	}
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender, bCancelled);
	if ( SpinnyDude != None )
		SpinnyDude.bHidden = true;
}

function Free()
{
	Super.Free();

	VoiceClasses.Remove(0, VoiceClasses.Length);
	if ( co_Voice != None )
		co_Voice.MyComboBox.List.Clear();

	if ( SpinnyDude != None )
		SpinnyDude.Destroy();

	SpinnyDude = None;
}
/*
function bool CoolOnKeyEvent(out byte Key, out byte State, float delta)
{
	local rotator r;
	local Interactions.EInputKey iKey;

	iKey = EInputKey(Key);

	if ( State != 1 )
		return false;

	if ( iKey == IK_A || iKey == IK_Left )
	if (key==69 && state==1)
    {
    	SpinnyDudeOffset.X = SpinnyDudeOffset.X - 1;
    	logspinnydude();
        return true;
    }

	if (key==67 && state==1)
    {
    	SpinnyDudeOffset.X = SpinnyDudeOffset.X + 1;
    	logspinnydude();
        return true;
    }

	if (key==65 && state==1)
    {
    	SpinnyDudeOffset.Y = SpinnyDudeOffset.Y - 1;
    	logspinnydude();
        return true;
    }

	if (key==68 && state==1)
    {
    	SpinnyDudeOffset.Y = SpinnyDudeOffset.Y + 1;
    	logspinnydude();
        return true;
    }

	if (key==87 && state==1)
    {
    	SpinnyDudeOffset.Z = SpinnyDudeOffset.Z - 1;
    	logspinnydude();
        return true;
    }

	if (key==88 && state==1)
    {
    	SpinnyDudeOffset.Z = SpinnyDudeOffset.Z + 1;
    	logspinnydude();
        return true;
    }

	if (key==81 && state==1)
    {
    	r = SpinnyDude.Rotation;
        r.Yaw += 1024;
        SpinnyDude.SetRotation(r);
    	logspinnydude();
        return true;
    }

	if (key==90 && state==1)
    {
    	r = SpinnyDude.Rotation;
        r.Yaw -= 1024;
        SpinnyDude.SetRotation(r);
    	logspinnydude();
        return true;
    }

	if (key==82 && state==1)
    {
    	r = SpinnyDude.Rotation;
        r.Pitch += 1024;
        SpinnyDude.SetRotation(r);
    	logspinnydude();
        return true;
    }

	if (key==86 && state==1)
    {
    	r = SpinnyDude.Rotation;
        r.Pitch -= 1024;
        SpinnyDude.SetRotation(r);
    	logspinnydude();
        return true;
    }

	if (key==49 && state==1)
    {
        nFOV+=5;
    	logspinnydude();
        return true;
    }

	if (key==50 && state==1)
    {
        nFOV-=5;
    	logspinnydude();
        return true;
    }


    return false;
}
*/
function logspinnydude()
{
	log("SpinnyDudeOffset X:"$SpinnyDudeOffset.X@"Y:"$SpinnyDudeOffset.Y@"Z:"$SpinnyDudeOffset.Z@"Roll:"$SpinnyDude.Rotation.Roll@"Pitch:"$SpinnyDude.Rotation.Pitch@"Yaw:"$SpinnyDude.Rotation.Yaw@"FOV:"$nfov);
}

defaultproperties
{
     HandNames(0)="Left"
     HandNames(1)="Center"
     HandNames(2)="Right"
     HandNames(3)="Hidden"
     TeamNames(0)="Red"
     TeamNames(1)="Blue"
     TeamNames(2)="None"
     ClickInst="Double-Click or drag to select"
     All="All"
     Previews(0)="View Normal Skin"
     Previews(1)="View Red Skin"
     Previews(2)="View Blue Skin"
     SpinnyDudeOffset=(X=70.000000)
     ShowBioCaption="Portrait"
     Show3DViewCaption="3D View"
     DefaultText="Default"
     Begin Object Class=GUISectionBackground Name=PlayerBK1
         Caption="3D View"
         WinTop=0.017969
         WinLeft=0.004063
         WinWidth=0.446758
         WinHeight=0.963631
         OnPreDraw=PlayerBK1.InternalPreDraw
     End Object
     i_BG1=GUISectionBackground'GUI2K4.UT2K4Tab_PlayerSettings.PlayerBK1'

     Begin Object Class=GUISectionBackground Name=PlayerBK2
         Caption="Misc."
         WinTop=0.017969
         WinLeft=0.463047
         WinWidth=0.531719
         WinHeight=0.573006
         OnPreDraw=PlayerBK2.InternalPreDraw
     End Object
     i_BG2=GUISectionBackground'GUI2K4.UT2K4Tab_PlayerSettings.PlayerBK2'

     Begin Object Class=GUISectionBackground Name=PlayerBK3
         bFillClient=True
         Caption="Biography"
         LeftPadding=0.020000
         RightPadding=0.020000
         TopPadding=0.020000
         BottomPadding=0.020000
         WinTop=0.610417
         WinLeft=0.463047
         WinWidth=0.531719
         WinHeight=0.372811
         OnPreDraw=PlayerBK3.InternalPreDraw
     End Object
     i_BG3=GUISectionBackground'GUI2K4.UT2K4Tab_PlayerSettings.PlayerBK3'

     Begin Object Class=GUIImage Name=PlayerPortrait
         Image=Texture'2K4Menus.Controls.thinpipe_b'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         IniOption="@Internal"
         WinTop=0.094895
         WinLeft=0.057016
         WinWidth=0.334368
         WinHeight=0.798132
         RenderWeight=0.300000
         OnDraw=UT2K4Tab_PlayerSettings.InternalDraw
         OnLoadINI=UT2K4Tab_PlayerSettings.InternalOnLoadINI
     End Object
     i_Portrait=GUIImage'GUI2K4.UT2K4Tab_PlayerSettings.PlayerPortrait'

     Begin Object Class=GUIButton Name=bPickModel
         Caption="Change Character"
         Hint="Select a new Character."
         WinTop=0.901559
         WinLeft=0.177174
         WinWidth=0.233399
         WinHeight=0.050000
         TabOrder=2
         OnClick=UT2K4Tab_PlayerSettings.PickModel
         OnKeyEvent=bPickModel.InternalOnKeyEvent
     End Object
     b_Pick=GUIButton'GUI2K4.UT2K4Tab_PlayerSettings.bPickModel'

     Begin Object Class=GUIButton Name=Player3DView
         Caption="3D View"
         Hint="Toggle between 3D view and portrait of character."
         WinTop=0.901559
         WinLeft=0.043685
         WinWidth=0.130720
         WinHeight=0.050000
         TabOrder=1
         OnClick=UT2K4Tab_PlayerSettings.Toggle3DView
         OnKeyEvent=Player3DView.InternalOnKeyEvent
     End Object
     b_3DView=GUIButton'GUI2K4.UT2K4Tab_PlayerSettings.Player3DView'

     Begin Object Class=GUIButton Name=DropTarget
         StyleName="NoBackground"
         WinTop=0.114426
         WinLeft=0.013071
         WinWidth=0.427141
         WinHeight=0.798132
         MouseCursorIndex=5
         bTabStop=False
         bNeverFocus=True
         bDropTarget=True
         OnKeyEvent=DropTarget.InternalOnKeyEvent
         OnCapturedMouseMove=UT2K4Tab_PlayerSettings.RaceCapturedMouseMove
     End Object
     b_DropTarget=GUIButton'GUI2K4.UT2K4Tab_PlayerSettings.DropTarget'

     Begin Object Class=GUIScrollTextBox Name=PlayerScroll
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=PlayerScroll.InternalOnCreateComponent
         WinTop=0.321365
         WinLeft=0.291288
         WinWidth=0.686915
         WinHeight=0.260351
         TabOrder=9
     End Object
     lb_Scroll=GUIScrollTextBox'GUI2K4.UT2K4Tab_PlayerSettings.PlayerScroll'

     Begin Object Class=moEditBox Name=PlayerName
         Caption="Name"
         OnCreateComponent=PlayerName.InternalOnCreateComponent
         IniOption="@INTERNAL"
         IniDefault="Player"
         Hint="Changes the alias you play as."
         WinTop=0.076042
         WinLeft=0.301757
         WinWidth=0.373242
         TabOrder=3
         OnLoadINI=UT2K4Tab_PlayerSettings.InternalOnLoadINI
     End Object
     ed_Name=moEditBox'GUI2K4.UT2K4Tab_PlayerSettings.PlayerName'

     Begin Object Class=moCheckBox Name=PlayerSmallWeap
         CaptionWidth=0.940000
         Caption="Small Weapons"
         OnCreateComponent=PlayerSmallWeap.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="Makes your first person weapon smaller."
         WinTop=0.150261
         WinLeft=0.705430
         WinWidth=0.266797
         TabOrder=8
         OnLoadINI=UT2K4Tab_PlayerSettings.InternalOnLoadINI
     End Object
     ch_SmallWeaps=moCheckBox'GUI2K4.UT2K4Tab_PlayerSettings.PlayerSmallWeap'

     Begin Object Class=moComboBox Name=PlayerTeam
         bReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Preferred Team"
         OnCreateComponent=PlayerTeam.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="Red"
         Hint="Changes the team you will play on by default."
         WinTop=0.150261
         WinLeft=0.301757
         WinWidth=0.374219
         TabOrder=6
         OnLoadINI=UT2K4Tab_PlayerSettings.InternalOnLoadINI
     End Object
     co_Team=moComboBox'GUI2K4.UT2K4Tab_PlayerSettings.PlayerTeam'

     Begin Object Class=moComboBox Name=PlayerHand
         bReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Weapon Hand"
         OnCreateComponent=PlayerHand.InternalOnCreateComponent
         IniOption="@INTERNAL"
         IniDefault="Right"
         Hint="Changes whether your weapon is visible."
         WinTop=0.212761
         WinLeft=0.705430
         WinWidth=0.264766
         TabOrder=7
         OnLoadINI=UT2K4Tab_PlayerSettings.InternalOnLoadINI
     End Object
     co_Hand=moComboBox'GUI2K4.UT2K4Tab_PlayerSettings.PlayerHand'

     Begin Object Class=moComboBox Name=VoiceType
         bReadOnly=True
         ComponentJustification=TXTA_Left
         Caption="Voice Type"
         OnCreateComponent=VoiceType.InternalOnCreateComponent
         IniOption="@Internal"
         Hint="Choose how your character's voice will sound in the game."
         WinTop=0.212761
         WinLeft=0.301757
         WinWidth=0.372266
         TabOrder=4
         OnLoadINI=UT2K4Tab_PlayerSettings.InternalOnLoadINI
     End Object
     co_Voice=moComboBox'GUI2K4.UT2K4Tab_PlayerSettings.VoiceType'

     Begin Object Class=moNumericEdit Name=PlayerFOV
         MinValue=80
         MaxValue=100
         ComponentJustification=TXTA_Left
         CaptionWidth=0.700000
         Caption="Default FOV"
         OnCreateComponent=PlayerFOV.InternalOnCreateComponent
         IniOption="@INTERNAL"
         IniDefault="85"
         Hint="This value will change your field of view while playing."
         WinTop=0.076042
         WinLeft=0.705430
         WinWidth=0.266797
         TabOrder=5
         OnLoadINI=UT2K4Tab_PlayerSettings.InternalOnLoadINI
     End Object
     nu_FOV=moNumericEdit'GUI2K4.UT2K4Tab_PlayerSettings.PlayerFOV'

     Begin Object Class=GUIComboBox Name=SkinPreview
         bReadOnly=True
         Hint="Show how the model looks using the selected skin."
         WinTop=0.111470
         WinLeft=0.053531
         WinWidth=0.346258
         WinHeight=0.030000
         TabOrder=0
         OnChange=UT2K4Tab_PlayerSettings.InternalOnChange
         OnKeyEvent=SkinPreview.InternalOnKeyEvent
     End Object
     co_SkinPreview=GUIComboBox'GUI2K4.UT2K4Tab_PlayerSettings.SkinPreview'

     nfov=65
     PanelCaption="Player"
     WinTop=0.150000
     WinHeight=0.720000
}

// ====================================================================
//  Class:  XInterface.Tab_OnlineSettings
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_PlayerSettings extends UT2K3TabPanel;

var localized string HandNames[4];
var localized string TeamNames[2];

var config bool bUnlocked;		// whether the boss characters have been unlocked
var bool bChanged;

// Used for character (not just weapons!)
var SpinnyWeap			SpinnyDude; // MUST be set to null when you leave the window
var vector				SpinnyDudeOffset;
var bool				bRenderDude;
var localized string	ShowBioCaption;
var localized string	Show3DViewCaption;

var string OriginalTeam;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	Super.Initcomponent(MyController, MyOwner);

	for (i=0;i<Controls.Length;i++)
		Controls[i].OnChange=InternalOnChange;

	moComboBox(Controls[3]).AddItem(HandNames[0]);
	moComboBox(Controls[3]).AddItem(HandNames[1]);
	moComboBox(Controls[3]).AddItem(HandNames[2]);
	moComboBox(Controls[3]).AddItem(HandNames[3]);
	moComboBox(Controls[3]).ReadOnly(true);

	moComboBox(Controls[2]).AddItem(TeamNames[0]);
	moComboBox(Controls[2]).AddItem(TeamNames[1]);
	moComboBox(Controls[2]).ReadOnly(true);
    moComboBox(Controls[2]).MyComboBox.OnChange = TeamChange;

	if (bUnlocked)
		GUICharacterListTeam(Controls[4]).InitListExclusive("DUP");
	else
		GUICharacterListTeam(Controls[4]).InitListExclusive("DUP", "UNLOCK");

	GUIImage(Controls[8]).Image = GUICharacterList(Controls[4]).GetPortrait();
	GUIScrollTextBox(Controls[5]).SetContent(Controller.LoadDecoText("",GUICharacterListTeam(Controls[4]).GetDecoText()));

	// Spawn spinning character actor
	SpinnyDude = PlayerOwner().spawn(class'XInterface.SpinnyWeap');
	SpinnyDude.SetRotation(PlayerOwner().Rotation);
	SpinnyDude.SetDrawType(DT_Mesh);
	SpinnyDude.bPlayRandomAnims = true;
	SpinnyDude.SetDrawScale(0.9);
	SpinnyDude.SpinRate = 12000;

	bRenderDude = false;
	GUIButton(Controls[9]).Caption = Show3DViewCaption;

	moEditBox(Controls[1]).MyEditBox.bConvertSpaces = true;
	moEditBox(Controls[1]).MyEditBox.MaxWidth=16;  // as per polge, check Tab_PlayerSettings if you change this

	moNumericEdit(Controls[12]).MyNumericEdit.Step = 5;

    moCheckBox(Controls[13]).Checked(PlayerOwner().bSmallWeapons);

    if (ExtendedConsole(PlayerOwner().Player.Console).MusicManager==None)
      Controls[14].bVisible = false;

}

function UpdateSpinnyDude()
{
	local xUtil.PlayerRecord Rec;
	local Mesh PlayerMesh;
	local Material BodySkin, HeadSkin;

	Rec = GUICharacterListTeam(Controls[4]).GetRecord();

	PlayerMesh = Mesh(DynamicLoadObject(Rec.MeshName, class'Mesh'));
	if(PlayerMesh == None)
	{
		Log("Could not load mesh: "$Rec.MeshName$" For player: "$Rec.DefaultName);
		return;
	}

	BodySkin = Material(DynamicLoadObject(Rec.BodySkinName, class'Material'));
	if(BodySkin == None)
	{
		Log("Could not load body material: "$Rec.BodySkinName$" For player: "$Rec.DefaultName);
		return;
	}

	HeadSkin = Material(DynamicLoadObject(Rec.FaceSkinName, class'Material'));
	if(HeadSkin == None)
	{
		Log("Could not load head material: "$Rec.FaceSkinName$" For player: "$Rec.DefaultName);
		return;
	}

	SpinnyDude.LinkMesh(PlayerMesh);
	SpinnyDude.Skins[0] = BodySkin;
	SpinnyDude.Skins[1] = HeadSkin;
	SpinnyDude.LoopAnim( 'Idle_Rest', 1.0 );
}

function bool InternalDraw(Canvas canvas)
{
	local vector CamPos, X, Y, Z;
	local rotator CamRot;

	if(bRenderDude)
	{
		canvas.GetCameraLocation(CamPos, CamRot);
		GetAxes(CamRot, X, Y, Z);

		SpinnyDude.SetLocation(CamPos + (SpinnyDudeOffset.X * X) + (SpinnyDudeOffset.Y * Y) + (SpinnyDudeOffset.Z * Z));

		canvas.DrawActor(SpinnyDude, false, true, 90.0);
	}

	return false;
}

function bool PlayList(GUIComponent Sender)
{
	ExtendedConsole(PlayerOwner().Player.Console).MusicMenu();
    return true;
}

function bool Toggle3DView(GUIComponent Sender)
{
	bRenderDude = !bRenderDude;

	if(bRenderDude)
	{
		UpdateSpinnyDude(); // Load current character
		Controls[5].bVisible = false; // Hide biography text
//		Controls[11].bVisible = true; // Show player border
		GUIButton(Controls[9]).Caption = ShowBioCaption; // Change button caption
	}
	else
	{
		// Put text back into box
		Controls[5].bVisible = true;
		Controls[11].bVisible = false;
		GUIButton(Controls[9]).Caption = Show3DViewCaption;
		SpinnyDude.LinkMesh(None);
	}

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

function InternalOnLoadINI(GUIComponent Sender, string s)
{
	local string CharName,TeamName;
	local int i;

	if (Sender==Controls[1])
	{
		moEditBox(Sender).SetText(PlayerOwner().GetUrlOption( "Name" ));
	}
	else if (Sender==Controls[2])
	{

		if ( (PlayerOwner().PlayerReplicationInfo==None) || (PlayerOwner().PlayerReplicationInfo.Team==None) )
			TeamName = PlayerOwner().GetURLOption("Team");
        else
        	TeamName = ""$PlayerOwner().PlayerReplicationInfo.Team.TeamIndex;

		OriginalTeam = TeamName;

		if (TeamName~="1")
		    moComboBox(Controls[2]).SetText(TeamNames[1]);
		else
			moComboBox(Controls[2]).SetText(TeamNames[0]);
	}

	else if (Sender==Controls[3])
	{
		i = class'PlayerController'.default.Handedness;

		if (i==2)
			moComboBox(Controls[3]).SetText(HandNames[1]);
		else if (i==-1)
			moComboBox(Controls[3]).SetText(HandNames[2]);
		else if (i==0)
			moComboBox(Controls[3]).SetText(HandNames[3]);
		else
			moComboBox(Controls[3]).SetText(HandNames[0]);

	}
	else if (Sender==Controls[4])
	{
		CharName = PlayerOwner().GetUrlOption( "Character" );
		GUICharacterList(Sender).find(charname);
		GUIImage(Controls[8]).Image = GUICharacterList(Controls[4]).GetPortrait();
		GUIScrollTextBox(Controls[5]).SetContent(Controller.LoadDecoText("",GUICharacterListTeam(Controls[4]).GetDecoText()));

	}
    else if (Sender==Controls[12])
		moNumericEdit(Controls[12]).SetValue(PlayerOwner().DefaultFOV);


}

function TeamChange(GUIComponent Sender)
{
	bChanged=true;
}

function InternalOnChange(GUIComponent Sender)
{

	local int i;
	local GUICharacterList c;
	local string cname;
	local sound NameSound;
	local bool CharName;

	if (!Controller.bCurMenuInitialized)
		return;

	if ((Sender==Controls[1]) || (Sender==Controls[2]) || (Sender==Controls[3]) || Sender==Controls[12] )
		bChanged=true;

	else if (Sender==Controls[4])
	{
		GUIImage(Controls[8]).Image = GUICharacterList(Controls[4]).GetPortrait();
		GUIScrollTextBox(Controls[5]).SetContent(Controller.LoadDecoText("",GUICharacterListTeam(Controls[4]).GetDecoText()));

		C = GUICharacterList(Controls[4]);
		cname = moEditBox(Controls[1]).GetText();

		// If the text box is an existing character name (or blank), change it when we click on new characters
		CharName=false;

		if(cname ~= "Nothing" || cname ~= "" || cname ~= "Player")
			CharName=true;

		for (i=0; i<C.PlayerList.Length && !CharName; i++)
		{
			if (C.PlayerList[i].DefaultName~=cname)
				CharName=true;
		}

		if(CharName)
			moEditBox(Controls[1]).SetText(GUICharacterList(Controls[4]).SelectedText());

		NameSound = GUICharacterList(Controls[4]).GetSound();
		PlayerOwner().ClientPlaySound(NameSound,,,SLOT_Interface);

		// Change 3D graphic if desplayed
		if(bRenderDude)
			UpdateSpinnyDude();

		bChanged=true;
	}
    else if (Sender==Controls[13])
    {
    	PlayerOwner().bSmallWeapons = moCheckBox(Controls[13]).IsChecked();
        PlayerOwner().SaveConfig();
    }

}

function bool InternalOnClick(GUIComponent Sender)
{

	if (Sender==Controls[6])
		GUICharacterList(Controls[4]).PgUp();
	else if (Sender==Controls[7])
		GUICharacterList(Controls[4]).PgDown();


	return true;
}



function bool InternalApply(GUIComponent Sender)
{
	local string PName, PChar, PTeam;
    local string NewTeam;

	if (!bChanged)
		return true;

	PName = moEditBox(Controls[1]).GetText();
	PChar = GUICharacterList(Controls[4]).SelectedText();
	PTeam  = moComboBox(Controls[2]).GetText();

	PlayerOwner().UpdateURL("Name",PName, true);
	PlayerOwner().UpdateURL("Character",pChar,true);

	if (PTeam~=TeamNames[1])
		NewTeam = "1";
    else
       	NewTeam = "0";

	if (NewTeam != OriginalTeam)
    {
		PlayerOwner().UpdateURL("Team", NewTeam, true);

		PlayerOwner().ChangeTeam(int(PlayerOwner().GetURLOption("Team")));
	}

	PlayerOwner().ConsoleCommand("setname"@PName);
	PlayerOwner().ConsoleCommand("changecharacter"@PChar);

	if (moComboBox(Controls[3]).GetText()==HandNames[1])
		PlayerOwner().SetHand(2);
	else if (moComboBox(Controls[3]).GetText()==HandNames[2])
		PlayerOwner().SetHand(-1);
	else if (moComboBox(Controls[3]).GetText()==HandNames[3])
		PlayerOwner().SetHand(0);
	else
		PlayerOwner().SetHand(1);

	PlayerOwner().FOV(moNumericEdit(Controls[12]).GetValue());

	bChanged = false;

	return true;

}

function ShowPanel(bool bShow)	// Show Panel should be subclassed if any special processing is needed
{
	Super.ShowPanel(bShow);

	if (!bShow)
		InternalApply(none);
}

defaultproperties
{
     HandNames(0)="Right"
     HandNames(1)="Hidden"
     HandNames(2)="Left"
     HandNames(3)="Center"
     TeamNames(0)="Red"
     TeamNames(1)="Blue"
     SpinnyDudeOffset=(X=150.000000,Y=77.000000,Z=-22.000000)
     bRenderDude=True
     ShowBioCaption="Bio"
     Show3DViewCaption="3D View"
     Begin Object Class=GUIImage Name=PlayerBK1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.008854
         WinLeft=0.506016
         WinWidth=0.434062
         WinHeight=0.377694
     End Object
     Controls(0)=GUIImage'XInterface.Tab_PlayerSettings.PlayerBK1'

     Begin Object Class=moEditBox Name=PlayerName
         CaptionWidth=0.250000
         Caption="Name"
         OnCreateComponent=PlayerName.InternalOnCreateComponent
         IniOption="@INTERNAL"
         IniDefault="Player"
         Hint="Changes the alias you play as."
         WinTop=0.714063
         WinLeft=0.121093
         WinWidth=0.300000
         WinHeight=0.060000
         OnLoadINI=Tab_PlayerSettings.InternalOnLoadINI
     End Object
     Controls(1)=moEditBox'XInterface.Tab_PlayerSettings.PlayerName'

     Begin Object Class=moComboBox Name=PlayerTeam
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="Preferred Team"
         OnCreateComponent=PlayerTeam.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="Red"
         Hint="Changes the team you will play on by default."
         WinTop=0.036979
         WinLeft=0.524766
         WinWidth=0.393750
         WinHeight=0.060000
         OnLoadINI=Tab_PlayerSettings.InternalOnLoadINI
     End Object
     Controls(2)=moComboBox'XInterface.Tab_PlayerSettings.PlayerTeam'

     Begin Object Class=moComboBox Name=PlayerHand
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="Weapon"
         OnCreateComponent=PlayerHand.InternalOnCreateComponent
         IniOption="@INTERNAL"
         IniDefault="High"
         Hint="Changes whether your weapon is visible."
         WinTop=0.130729
         WinLeft=0.524766
         WinWidth=0.393750
         WinHeight=0.060000
         OnLoadINI=Tab_PlayerSettings.InternalOnLoadINI
     End Object
     Controls(3)=moComboBox'XInterface.Tab_PlayerSettings.PlayerHand'

     Begin Object Class=GUICharacterListTeam Name=PlayerCharList
         IniOption="@Internal"
         StyleName="CharButton"
         Hint="Changes the character you play as."
         WinTop=0.813543
         WinLeft=0.036465
         WinWidth=0.453729
         WinHeight=0.189297
         OnClick=PlayerCharList.InternalOnClick
         OnRightClick=PlayerCharList.InternalOnRightClick
         OnMousePressed=PlayerCharList.InternalOnMousePressed
         OnMouseRelease=PlayerCharList.InternalOnMouseRelease
         OnKeyEvent=PlayerCharList.InternalOnKeyEvent
         OnLoadINI=Tab_PlayerSettings.InternalOnLoadINI
         OnBeginDrag=PlayerCharList.InternalOnBeginDrag
         OnEndDrag=PlayerCharList.InternalOnEndDrag
         OnDragDrop=PlayerCharList.InternalOnDragDrop
         OnDragEnter=PlayerCharList.InternalOnDragEnter
         OnDragLeave=PlayerCharList.InternalOnDragLeave
         OnDragOver=PlayerCharList.InternalOnDragOver
     End Object
     Controls(4)=GUICharacterListTeam'XInterface.Tab_PlayerSettings.PlayerCharList'

     Begin Object Class=GUIScrollTextBox Name=PlayerScroll
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=PlayerScroll.InternalOnCreateComponent
         WinTop=0.406000
         WinLeft=0.506132
         WinWidth=0.472071
         WinHeight=0.397070
         bNeverFocus=True
     End Object
     Controls(5)=GUIScrollTextBox'XInterface.Tab_PlayerSettings.PlayerScroll'

     Begin Object Class=GUIButton Name=PlayerLeft
         StyleName="ArrowLeft"
         WinTop=0.886460
         WinLeft=0.000781
         WinWidth=0.043555
         WinHeight=0.084414
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=Tab_PlayerSettings.InternalOnClick
         OnKeyEvent=PlayerLeft.InternalOnKeyEvent
     End Object
     Controls(6)=GUIButton'XInterface.Tab_PlayerSettings.PlayerLeft'

     Begin Object Class=GUIButton Name=PlayerRight
         StyleName="ArrowRight"
         WinTop=0.886460
         WinLeft=0.479688
         WinWidth=0.043555
         WinHeight=0.084414
         bNeverFocus=True
         bRepeatClick=True
         OnClickSound=CS_Up
         OnClick=Tab_PlayerSettings.InternalOnClick
         OnKeyEvent=PlayerRight.InternalOnKeyEvent
     End Object
     Controls(7)=GUIButton'XInterface.Tab_PlayerSettings.PlayerRight'

     Begin Object Class=GUIImage Name=PlayerPortrait
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.024583
         WinLeft=0.172250
         WinWidth=0.183000
         WinHeight=0.637000
     End Object
     Controls(8)=GUIImage'XInterface.Tab_PlayerSettings.PlayerPortrait'

     Begin Object Class=GUIButton Name=Player3DView
         Caption="3D View"
         Hint="Toggle between 3D view and biography of character."
         WinTop=0.977868
         WinLeft=0.620000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=Tab_PlayerSettings.Toggle3DView
         OnKeyEvent=Player3DView.InternalOnKeyEvent
     End Object
     Controls(9)=GUIButton'XInterface.Tab_PlayerSettings.Player3DView'

     Begin Object Class=GUIImage Name=PlayerPortraitBorder
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.018500
         WinLeft=0.168687
         WinWidth=0.188563
         WinHeight=0.647875
     End Object
     Controls(10)=GUIImage'XInterface.Tab_PlayerSettings.PlayerPortraitBorder'

     Begin Object Class=GUIImage Name=Player3DBack
         Image=Texture'InterfaceContent.Menu.BorderBoxA'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.156000
         WinLeft=0.506132
         WinWidth=0.472071
         WinHeight=0.742383
         bVisible=False
         bAcceptsInput=True
         OnClickSound=CS_Click
         OnClick=Tab_PlayerSettings.NextAnim
     End Object
     Controls(11)=GUIImage'XInterface.Tab_PlayerSettings.Player3DBack'

     Begin Object Class=moNumericEdit Name=PlayerFOV
         MinValue=80
         MaxValue=100
         ComponentJustification=TXTA_Left
         CaptionWidth=0.650000
         Caption="Default FOV"
         OnCreateComponent=PlayerFOV.InternalOnCreateComponent
         IniOption="@INTERNAL"
         IniDefault="85"
         Hint="This value will change your field of view while playing."
         WinTop=0.228123
         WinLeft=0.524766
         WinWidth=0.393750
         WinHeight=0.060000
         OnLoadINI=Tab_PlayerSettings.InternalOnLoadINI
     End Object
     Controls(12)=moNumericEdit'XInterface.Tab_PlayerSettings.PlayerFOV'

     Begin Object Class=moCheckBox Name=PlayerSmallWeap
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Small Weapons"
         OnCreateComponent=PlayerSmallWeap.InternalOnCreateComponent
         IniOption="@Internal"
         IniDefault="False"
         Hint="Makes your first person weapon smaller."
         WinTop=0.318333
         WinLeft=0.521875
         WinWidth=0.393750
         WinHeight=0.040000
     End Object
     Controls(13)=moCheckBox'XInterface.Tab_PlayerSettings.PlayerSmallWeap'

     Begin Object Class=GUIButton Name=PlayerOGG
         Caption="Play List"
         Hint="Configure your OGG Play List."
         WinTop=0.918750
         WinLeft=0.620000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=Tab_PlayerSettings.Playlist
         OnKeyEvent=PlayerOGG.InternalOnKeyEvent
     End Object
     Controls(14)=GUIButton'XInterface.Tab_PlayerSettings.PlayerOGG'

     WinTop=0.150000
     WinHeight=0.720000
     OnDraw=Tab_PlayerSettings.InternalDraw
}

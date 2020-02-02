// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class UT2k4ModelSelect extends LockedFloatingWindow;

#EXEC OBJ LOAD FILE=2K4Menus.utx
#exec obj load file=PlayerPictures.utx

var Material  LockedImage;
var automated GUIVertImageListBox CharList;
var automated MoComboBox co_Race;
var automated GUIImage i_bk;
var() array<xUtil.PlayerRecord> PlayerList;

var UT2K4Tab_PlayerSettings MyTab;		// Used for the callback

var SpinnyWeap				SpinnyDude; // MUST be set to null when you leave the window
var (SpinnyDude)	vector	SpinnyDudeOffset;

var int					nfov;

var() int YawValue;
var() private string InvalidTypes, IgnoredTypes;

var int DoneInit;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	sb_Main.SetPosition(0.040000,0.075000,0.680742,0.555859);
	sb_Main.RightPadding = 0.5;
	sb_Main.ManageComponent(CharList);

	class'xUtil'.static.GetPlayerList(PlayerList);
	RefreshCharacterList(InvalidTypes);

	co_Race.MyComboBox.List.bInitializeList = True;
	co_Race.ReadOnly(True);
	co_Race.AddItem("All");
	PopulateRaces();
	RaceChange(none);
	co_Race.OnChange=RaceChange;

	// Spawn spinning character actor
	if ( SpinnyDude == None )
		SpinnyDude = PlayerOwner().spawn(class'XInterface.SpinnyWeap');

	SpinnyDude.SetDrawType(DT_Mesh);
	SpinnyDude.SetDrawScale(0.9);
	SpinnyDude.SpinRate = 0;
}


event Opened( GUIComponent Sender )
{
	local rotator R;

	super.Opened(Sender);

	if ( SpinnyDude != None )
	{
		R.Yaw = 32768;
		SpinnyDude.SetRotation( R + PlayerOwner().Rotation );
	}
}

function PopulateRaces()
{
	local int i;
	local string specName;

	for(i=0; i<PlayerList.Length; i++)
	{
		specName=Caps(PlayerList[i].Race);
		if (specName!="" && co_Race.MyComboBox.List.FindIndex(specName,True) == -1)
   	    	co_Race.AddItem(specName);
	}
}

function RefreshCharacterList(string ExcludedChars, optional string Race)
{
	local int i, j;
	local array<string> Excluded;
	local bool blocked;

	// Prevent list from calling OnChange events
	CharList.List.bNotify = False;
	CharList.Clear();

	Split(ExcludedChars, ";", Excluded);
	for(i=0; i<PlayerList.Length; i++)
	{
		if ( Race == "" || Race ~= Playerlist[i].Race )
		{
			// Check that this character is selectable
			if ( PlayerList[i].Menu != "" )
			{
				for (j = 0; j < Excluded.Length; j++)
					if ( InStr(";" $ Playerlist[i].Menu $ ";", ";" $ Excluded[j] $ ";") != -1 )
						break;

				if ( j < Excluded.Length )
					continue;
			}

			bLocked = !IsUnLocked(PlayerList[i]);
			CharList.List.Add( Playerlist[i].Portrait, i, int(bLocked) );

		}
	}

	CharList.List.LockedMat = LockedImage;
	CharList.List.bNotify = True;
}

function ListChange(GUIComponent Sender)
{
	local ImageListElem Elem;

	CharList.List.GetAtIndex(CharList.List.Index, Elem.Image, Elem.Item,Elem.Locked);

	if ( Elem.Item >= 0 && Elem.Item < Playerlist.Length )
	{
		if ( Elem.Locked==1 )
			b_Ok.DisableMe();
		else
			b_Ok.EnableMe();

		sb_Main.Caption = PlayerList[Elem.Item].DefaultName;
		if (sb_Main.Caption ~= "Mr.Crow")
			PlayerOwner().ClientPlaySound(sound(DynamicLoadObject("AnnouncerNames.Mr_Crow", class'Sound')),,,SLOT_Interface);
	}
	else sb_Main.Caption = "";
	UpdateSpinnyDude();
}

function RaceChange(GUIComponent Sender)
{
	local string specName;

	specName = co_Race.GetText();
	if (specName=="All")
		specName="";

	RefreshCharacterList(InvalidTypes, specName);
}

function UpdateSpinnyDude()
{
	local int idx;
	local xUtil.PlayerRecord Rec;
	local Mesh PlayerMesh;
	local Material BodySkin, HeadSkin;
	local string BodySkinName, HeadSkinName, TeamSuffix;

	idx = CharList.List.GetItem();
	if ( idx < 0 || idx >= Playerlist.Length )
		return;

	Rec = PlayerList[idx];

	if (Rec.Race ~= "Juggernaut" || Rec.DefaultName~="Axon" || Rec.DefaultName~="Cyclops" || Rec.DefaultName ~="Virus" )
		SpinnyDudeOffset=vect(250.0,1.00,-14.00);
	else
	    SpinnyDudeOffset=vect(250.0,1.00,-24.00);

	PlayerMesh = Mesh(DynamicLoadObject(Rec.MeshName, class'Mesh'));
	if(PlayerMesh == None)
	{
		Log("Could not load mesh: "$Rec.MeshName$" For player: "$Rec.DefaultName);
		return;
	}

	// Get the body skin
	BodySkinName = Rec.BodySkinName;

	// Get the head skin
	HeadSkinName = Rec.FaceSkinName;
	if ( Rec.TeamFace )
		HeadSkinName $= TeamSuffix;

	BodySkin = Material(DynamicLoadObject(BodySkinName, class'Material'));
	if(BodySkin == None)
	{
		Log("Could not load body material: "$Rec.BodySkinName$" For player: "$Rec.DefaultName);
		return;
	}

	HeadSkin = Material(DynamicLoadObject(HeadSkinName, class'Material'));
	if(HeadSkin == None)
	{
		Log("Could not load head material: "$HeadSkinName$" For player: "$Rec.DefaultName);
		return;
	}

	SpinnyDude.LinkMesh(PlayerMesh);
	SpinnyDude.Skins[0] = BodySkin;
	SpinnyDude.Skins[1] = HeadSkin;
	SpinnyDude.LoopAnim( 'Idle_Rest', 1.0/SpinnyDude.Level.TimeDilation );
}

function bool InternalOnDraw(canvas Canvas)
{
	local vector CamPos, X, Y, Z;
	local rotator CamRot;
	local float   oOrgX, oOrgY;
	local float   oClipX, oClipY;

    if (DoneInit>=0)
    {
		CharList.List.MakeVisible(float(DoneInit) / float(CharList.List.ItemCount));
		DoneInit=-1;
    }

   	oOrgX = Canvas.OrgX;
	oOrgY = Canvas.OrgY;
	oClipX = Canvas.ClipX;
	oClipY = Canvas.ClipY;

	Canvas.OrgX = i_bk.ActualLeft();
	Canvas.OrgY = i_bk.ActualTop();
	Canvas.ClipX = i_bk.ActualWidth();
	Canvas.ClipY = i_bk.ActualHeight();

	canvas.GetCameraLocation(CamPos, CamRot);
	GetAxes(CamRot, X, Y, Z);

	SpinnyDude.SetLocation(CamPos + (SpinnyDudeOffset.X * X) + (SpinnyDudeOffset.Y * Y) + (SpinnyDudeOffset.Z * Z));
	canvas.DrawActorClipped(SpinnyDude, false,  i_bk.ActualLeft(), i_bk.ActualTop(), i_bk.ActualWidth(), i_bk.ActualHeight(), true, nFOV);
	Canvas.OrgX = oOrgX;
	Canvas.OrgY = oOrgY;
	Canvas.ClipX = oClipX;
	Canvas.ClipY = oClipY;

	return true;

}

function Free()
{
	Super.Free();

	if ( SpinnyDude != None )
		SpinnyDude.Destroy();
	SpinnyDude = None;
}

function HandleParameters( string Who, string Team )
{
	local int i;

	if (Team!="")
		co_Race.Find(team);

	for (i=0;i<PlayerList.Length;i++)
		if (PlayerList[i].DefaultName ~= Who && IsUnlocked(PlayerList[i]) )
		{
			DoneInit = i;
			CharList.List.SetIndex(CharList.List.FindItem(i));
		}

	UpdateSpinnyDude();
}

function string GetDataString()
{
	local int idx;

	idx = CharList.List.GetItem();
	if ( idx < 0 || idx >= PlayerList.Length )
		return "";

	return PlayerList[idx].DefaultName;
}


function bool IsHiddenCharacter( string CharacterMenuString )
{
	local int i;
	local array<string> RecordFilters;

	if ( CharacterMenuString == "" )
		return false;

	Split(CharacterMenuString, ";", RecordFilters);

	// Remove any exclusivity filters (filters not related to locked/unlocked characters)
	for ( i = RecordFilters.Length - 1; i >= 0; i-- )
	{
		if ( InStr(";" $ IgnoredTypes $ ";", ";" $ RecordFilters[i] $ ";") != -1 )
		{
			RecordFilters.Remove(i,1);
			continue;
		}
	}

	return RecordFilters.Length > 0;
}

function bool IsUnlocked( xUtil.PlayerRecord Test )
{
	// If character has no menu filter, just return true
	if ( !IsHiddenCharacter(Test.Menu) )
		return true;

	return class'UT2K4MainPage'.static.IsUnlocked(Test.Menu);
}

defaultproperties
{
     LockedImage=Texture'PlayerPictures.cDefault'
     Begin Object Class=GUIVertImageListBox Name=vil_CharList
         CellStyle=CELL_FixedCount
         NoVisibleRows=3
         NoVisibleCols=4
         OnCreateComponent=vil_CharList.InternalOnCreateComponent
         WinTop=0.185119
         WinLeft=0.102888
         WinWidth=0.403407
         WinHeight=0.658125
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=UT2k4ModelSelect.ListChange
     End Object
     CharList=GUIVertImageListBox'GUI2K4.UT2k4ModelSelect.vil_CharList'

     Begin Object Class=moComboBox Name=CharRace
         bReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.250000
         Caption="Race"
         OnCreateComponent=CharRace.InternalOnCreateComponent
         Hint="Filter the available characters by race."
         WinTop=0.880000
         WinLeft=0.052733
         WinWidth=0.388155
         WinHeight=0.042857
         TabOrder=4
         bBoundToParent=True
         bScaleToParent=True
     End Object
     co_Race=moComboBox'GUI2K4.UT2k4ModelSelect.CharRace'

     Begin Object Class=GUIImage Name=iBK
         Image=Texture'2K4Menus.Controls.buttonSquare_b'
         DropShadow=Texture'2K4Menus.Controls.Shadow'
         ImageColor=(A=128)
         ImageStyle=ISTY_Stretched
         DropShadowX=4
         DropShadowY=4
         WinTop=0.007507
         WinLeft=0.530206
         WinWidth=0.368945
         WinHeight=0.812500
         RenderWeight=0.520000
         bBoundToParent=True
         bScaleToParent=True
         OnDraw=UT2k4ModelSelect.InternalOnDraw
     End Object
     i_bk=GUIImage'GUI2K4.UT2k4ModelSelect.iBK'

     SpinnyDudeOffset=(X=250.000000,Y=1.000000,Z=-14.000000)
     nfov=15
     InvalidTypes="DUP"
     IgnoredTypes="SP"
     WindowName="Select Character"
}

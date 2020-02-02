// ====================================================================
//  Single player menu for establishing profile.
//  author:  capps 8/26/02
// ====================================================================

///////////
// TODO
// draw team picture in blue

class Tab_SPProfileNew extends Tab_SPPanelBase;

var GUIEditBox ePlayerName;
var GUIEditBox eTeamName;
var GUIComboBox cDifficulty;
var GUICharacterListTeam clPlayerSkins;
var GUIImageList iTeamSymbols;

var	localized string DefaultName, DefaultTeamName;
var string DefaultCharacter, TeamSymbolPrefix;
var int DefaultTeamSymbol;
var int CurrentTeamSymbolNum;			// currently displayed team symbol number

var localized string Err_ProfileExists;
var localized string Err_CantCreateProfile;

const MINSYMBOL = 1;
const MAXSYMBOL = 22;

function InitComponent(GUIController pMyController, GUIComponent MyOwner)
{
local int i;

	ePlayerName = GUIEditBox(GUIMenuOption(Controls[2]).MyComponent);
	ePlayerName.MaxWidth=16;  // as per polge, check Tab_PlayerSettings if you change this
	ePlayerName.bConvertSpaces=true;
	ePlayerName.OnClick=PlayerOnClick;
	eTeamName = GUIEditBox(GUIMenuOption(Controls[3]).MyComponent);
	eTeamName.MaxWidth=16;
	eTeamName.OnClick=PlayerOnClick;
	cDifficulty = GUIComboBox(GUIMenuOption(Controls[4]).MyComponent);
	clPlayerSkins = GUICharacterListTeam(Controls[6]);

	iTeamSymbols = GUIImageList(Controls[10]);

	Super.Initcomponent(pMyController, MyOwner);

	if (!class'Tab_PlayerSettings'.default.bUnlocked)
		clPlayerSkins.InitListExclusive("UNLOCK", "DUP");
	else
		clPlayerSkins.InitListExclusive("DUP");

	Controls[5].FocusInstead = clPlayerSkins;
	Controls[7].FocusInstead = clPlayerSkins;
	Controls[8].FocusInstead = clPlayerSkins;
	Controls[9].FocusInstead = iTeamSymbols;
	Controls[11].FocusInstead = iTeamSymbols;
	Controls[12].FocusInstead = iTeamSymbols;

	for (i=0; i<class'Tab_SPProfileLoad'.default.NumDifficulties; i++)
		cDifficulty.AddItem(class'Tab_SPProfileLoad'.default.Difficulties[i]);

	cDifficulty.ReadOnly(true);

	LoadSymbols();	// Symbols are loaded once only.
	ClearStats();

}

function InitPanel()
{
	Super.InitPanel();
	MyButton.Hint = class'UT2SinglePlayerMain'.default.TabHintProfileNew;
	UT2SinglePlayerMain(MyButton.MenuOwner.MenuOwner).ChangeHint(MyButton.Hint);
	UT2SinglePlayerMain(MyButton.MenuOwner.MenuOwner).ResetTitleBar(MyButton);
}

function bool PlayerOnClick(GUIComponent Sender) {
	if ( Sender == ePlayerName )
	{
		if ( ePlayerName.TextStr == DefaultName )
			ePlayerName.TextStr = "";
	}
	else if ( Sender == eTeamName )
	{
		if ( eTeamName.TextStr == DefaultTeamName )
			eTeamName.TextStr = "";
	}
	return Super.OnClick(Sender);
}

function string GetTeamSymbolName(int idx)
{
	return TeamSymbolPrefix$Right("0"$idx, 2);
}

function string CurrentTeamSymbolName()
{
	return String(iTeamSymbols.Image);
}

function LoadSymbols()
{
local int i;
local Material M;
local array<string> SymbolNames;

	Controller.GetTeamSymbolList(SymbolNames, true);  // get all usable team symbols

	for (i = 0; i < SymbolNames.Length; i++)
	{
		M = Material(DynamicLoadObject(SymbolNames[i], class'Material'));
		iTeamSymbols.AddMaterial(String(i), M);
	}
}

// update all the various boxes to show the stats of this profile
function ClearStats()
{
	// update name
	ePlayerName.TextStr = DefaultName;

	// update team name
	eTeamName.TextStr = DefaultTeamName;

	// update difficulty
	cDifficulty.SetText(class'xInterface.Tab_SPProfileLoad'.default.Difficulties[1]);

	// update character portrait

	clPlayerSkins.Find(DefaultCharacter);

	// update team symbol
	iTeamSymbols.FirstImage();
}

function bool CreateClick(GUIComponent Sender)
{
local class<GameProfile> profileclass;
local string profilename;
local GameProfile GP;
local GUIQuestionPage Page;
local array<string> profilenames;
local int i;
local bool bFileExists;

	if ( ePlayerName.TextStr == "" )
		ePlayerName.TextStr = DefaultName;

	if ( eTeamName.TextStr == "" )
		eTeamName.TextStr = DefaultTeamName;

	profilename = ePlayerName.TextStr;
	profileclass = class<GameProfile>(DynamicLoadObject("xGame.UT2003GameProfile", class'Class'));

	// test if a profile with this name already exists
	GP = PlayerOwner().Level.Game.LoadDataObject(profileclass, "GameProfile", profilename);

	if ( GP != none )
	{
		GP = none;

		// it may just still be lying around in memory, un GC'd, so test if there's a file there
		bFileExists=false;
		Controller.GetProfileList("",profilenames);
		for ( i=0; i<profilenames.Length; i++ )
		{
			if ( profilenames[i] ~= profilename )
			{
				bFileExists=true;
				break;
			}
		}

		// there's still a file there, too, so just exit with warning.
		if ( bFileExists )
		{
			// profile already exists, warn player
			if (Controller.OpenMenu("XInterface.GUIQuestionPage"))
			{
				Page = GUIQuestionPage(Controller.ActivePage);
				Page.SetupQuestion(Page.Replace(err_ProfileExists, "prof", Caps(profilename)), QBTN_Ok, QBTN_Ok);
			}
			return true;
		}
	}

	GP = PlayerOwner().Level.Game.CreateDataObject(profileclass, "GameProfile", profilename);
	if ( GP != none )
	{
		GP.PlayerName = ePlayerName.TextStr;
		GP.TeamName = eTeamName.TextStr;
		GP.TeamSymbolName = String(iTeamSymbols.Image);
		GP.PlayerCharacter = clPlayerSkins.GetName();
		GP.BaseDifficulty = cDifficulty.Index;
		PlayerOwner().Level.Game.CurrentGameProfile = GP;
		GP.Initialize(PlayerOwner().Level.Game, profilename);
		PlayerOwner().Level.Game.CurrentGameProfile.bInLadderGame=true;  // so it'll reload into SP menus
		if (!PlayerOwner().Level.Game.SavePackage(profilename))
		{
			Log("SINGLEPLAYER couldn't save profile package!");
		}

		GUITabControl(MyButton.MenuOwner).ReplaceTab(MyButton, class'UT2SinglePlayerMain'.default.TabNameProfileLoad, "xInterface.Tab_SPProfileLoad", , , true);
		GUITabControl(MyButton.MenuOwner).ActivateTabByName(class'UT2SinglePlayerMain'.default.TabNameQualification, true);

		// Broadcast about the new Profile
		ProfileUpdated();

		// launch the game introduction
		PlayerOwner().ConsoleCommand("START ut2-intro.ut2?quickstart=true?TeamScreen=False?savegame="$profilename);
		Controller.CloseAll(false);
	}
	else
	{
		// couldn't create profile, give warning
		if (Controller.OpenMenu("XInterface.GUIQuestionPage"))
		{
			Page = GUIQuestionPage(Controller.ActivePage);
			Page.SetupQuestion(Err_CantCreateProfile, QBTN_Ok, QBTN_Ok);
		}
		return true;
	}
	return true;
}

function bool PrevSkin(GUIComponent Sender)
{
	clPlayerSkins.ScrollLeft();
	return true;
}

function bool NextSkin(GUIComponent Sender)
{
	clPlayerSkins.ScrollRight();
	return true;
}

function bool PrevSymbol(GUIComponent Sender)
{
	iTeamSymbols.PrevImage();
	return true;
}

function bool NextSymbol(GUIComponent Sender)
{
	iTeamSymbols.NextImage();
	return true;
}

function bool BackClick(GUIComponent Sender)
{
	local array<string> profilenames;
	// if they click back and there are no existing profiles, take them to main by closing the SP menu
	Controller.GetProfileList("",profilenames);
	if ( profilenames.Length == 0 )
		Controller.CloseMenu();

	GUITabControl(MyButton.MenuOwner).ReplaceTab(MyButton, class'UT2SinglePlayerMain'.default.TabNameProfileLoad, "xInterface.Tab_SPProfileLoad", , , true);
	return true;
}

function bool DefaultsClick(GUIComponent Sender)
{
	ClearStats();
	return true;
}

defaultproperties
{
     DefaultName="Player"
     DefaultTeamName="Team"
     DefaultCharacter="Gorge"
     TeamSymbolPrefix="TeamSymbols_UT2003.sym"
     DefaultTeamSymbol=1
     Err_ProfileExists="Profile with name %prof% already exists!"
     Err_CantCreateProfile="Profile creation failed."
     Begin Object Class=GUIButton Name=btnSaveProfile
         Caption="CREATE PROFILE"
         Hint="Create a profile with these settings"
         WinTop=0.925000
         WinLeft=0.744060
         WinWidth=0.223438
         WinHeight=0.075000
         OnClick=Tab_SPProfileNew.CreateClick
         OnKeyEvent=btnSaveProfile.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'XInterface.Tab_SPProfileNew.btnSaveProfile'

     Begin Object Class=GUIImage Name=imgEditsBack
         Image=Texture'InterfaceContent.Menu.EditBox'
         ImageStyle=ISTY_Stretched
         WinTop=0.073000
         WinLeft=0.504375
         WinWidth=0.444304
         WinHeight=0.770000
         bNeverFocus=True
     End Object
     Controls(1)=GUIImage'XInterface.Tab_SPProfileNew.imgEditsBack'

     Begin Object Class=moEditBox Name=moebPlayerName
         bVerticalLayout=True
         Caption="Player Name: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=moebPlayerName.InternalOnCreateComponent
         Hint="Your character's name"
         WinTop=0.286087
         WinLeft=0.553125
         WinWidth=0.345000
         WinHeight=0.122500
     End Object
     Controls(2)=moEditBox'XInterface.Tab_SPProfileNew.moebPlayerName'

     Begin Object Class=moEditBox Name=moebTeamName
         bVerticalLayout=True
         Caption="Team Name: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=moebTeamName.InternalOnCreateComponent
         Hint="The name of your team"
         WinTop=0.428007
         WinLeft=0.553125
         WinWidth=0.345000
         WinHeight=0.122500
     End Object
     Controls(3)=moEditBox'XInterface.Tab_SPProfileNew.moebTeamName'

     Begin Object Class=moComboBox Name=mocbDifficulty
         bVerticalLayout=True
         Caption="Difficulty: "
         LabelFont="UT2SmallFont"
         LabelColor=(B=255,G=255,R=255)
         OnCreateComponent=mocbDifficulty.InternalOnCreateComponent
         Hint="Customize your challenge"
         WinTop=0.568803
         WinLeft=0.553125
         WinWidth=0.345000
         WinHeight=0.122500
     End Object
     Controls(4)=moComboBox'XInterface.Tab_SPProfileNew.mocbDifficulty'

     Begin Object Class=GUIImage Name=imgSkinsBack
         Image=Texture'InterfaceContent.Menu.EditBox'
         ImageStyle=ISTY_Stretched
         WinTop=0.073000
         WinLeft=0.055938
         WinWidth=0.215000
         WinHeight=0.770000
         bNeverFocus=True
     End Object
     Controls(5)=GUIImage'XInterface.Tab_SPProfileNew.imgSkinsBack'

     Begin Object Class=GUICharacterListTeam Name=clistPlayerSkins
         FixedItemsPerPage=1
         StyleName="CharButton"
         Hint="Your character's appearance, use arrow keys to change"
         WinTop=0.117917
         WinLeft=0.083462
         WinWidth=0.124694
         WinHeight=0.500000
         OnClick=clistPlayerSkins.InternalOnClick
         OnRightClick=clistPlayerSkins.InternalOnRightClick
         OnMousePressed=clistPlayerSkins.InternalOnMousePressed
         OnMouseRelease=clistPlayerSkins.InternalOnMouseRelease
         OnKeyEvent=clistPlayerSkins.InternalOnKeyEvent
         OnBeginDrag=clistPlayerSkins.InternalOnBeginDrag
         OnEndDrag=clistPlayerSkins.InternalOnEndDrag
         OnDragDrop=clistPlayerSkins.InternalOnDragDrop
         OnDragEnter=clistPlayerSkins.InternalOnDragEnter
         OnDragLeave=clistPlayerSkins.InternalOnDragLeave
         OnDragOver=clistPlayerSkins.InternalOnDragOver
     End Object
     Controls(6)=GUICharacterListTeam'XInterface.Tab_SPProfileNew.clistPlayerSkins'

     Begin Object Class=GUIGFXButton Name=btnPrevSkin
         Graphic=FinalBlend'InterfaceContent.Menu.fbArrowLeft'
         Position=ICP_Scaled
         Hint="Selects a new appearance for your character"
         WinTop=0.640000
         WinLeft=0.080000
         WinWidth=0.080000
         WinHeight=0.080000
         bNeverFocus=True
         OnClick=Tab_SPProfileNew.PrevSkin
         OnKeyEvent=btnPrevSkin.InternalOnKeyEvent
     End Object
     Controls(7)=GUIGFXButton'XInterface.Tab_SPProfileNew.btnPrevSkin'

     Begin Object Class=GUIGFXButton Name=btnNextSkin
         Graphic=FinalBlend'InterfaceContent.Menu.fbArrowRight'
         Position=ICP_Scaled
         Hint="Selects a new appearance for your character"
         WinTop=0.640000
         WinLeft=0.172187
         WinWidth=0.080000
         WinHeight=0.080000
         bNeverFocus=True
         OnClick=Tab_SPProfileNew.NextSkin
         OnKeyEvent=btnNextSkin.InternalOnKeyEvent
     End Object
     Controls(8)=GUIGFXButton'XInterface.Tab_SPProfileNew.btnNextSkin'

     Begin Object Class=GUIImage Name=imgSymbolsBack
         Image=Texture'InterfaceContent.Menu.EditBox'
         ImageStyle=ISTY_Stretched
         WinTop=0.073000
         WinLeft=0.280243
         WinWidth=0.215000
         WinHeight=0.770000
         bNeverFocus=True
     End Object
     Controls(9)=GUIImage'XInterface.Tab_SPProfileNew.imgSymbolsBack'

     Begin Object Class=GUIImageList Name=ilTeamSymbols
         bWrap=True
         ImageStyle=ISTY_Justified
         ImageRenderStyle=MSTY_Normal
         ImageAlign=IMGA_Center
         Hint="Your team's symbol; use arrow keys to change"
         WinTop=0.137175
         WinLeft=0.303972
         WinWidth=0.167212
         WinHeight=0.500000
     End Object
     Controls(10)=GUIImageList'XInterface.Tab_SPProfileNew.ilTeamSymbols'

     Begin Object Class=GUIGFXButton Name=btnPrevSymbol
         Graphic=FinalBlend'InterfaceContent.Menu.fbArrowLeft'
         Position=ICP_Scaled
         Hint="Selects a new symbol for your team"
         WinTop=0.640000
         WinLeft=0.298750
         WinWidth=0.080000
         WinHeight=0.080000
         bNeverFocus=True
         OnClick=Tab_SPProfileNew.PrevSymbol
         OnKeyEvent=btnPrevSymbol.InternalOnKeyEvent
     End Object
     Controls(11)=GUIGFXButton'XInterface.Tab_SPProfileNew.btnPrevSymbol'

     Begin Object Class=GUIGFXButton Name=btnNextSymbol
         Graphic=FinalBlend'InterfaceContent.Menu.fbArrowRight'
         Position=ICP_Scaled
         Hint="Selects a new symbol for your team"
         WinTop=0.640000
         WinLeft=0.389375
         WinWidth=0.080000
         WinHeight=0.080000
         bNeverFocus=True
         OnClick=Tab_SPProfileNew.NextSymbol
         OnKeyEvent=btnNextSymbol.InternalOnKeyEvent
     End Object
     Controls(12)=GUIGFXButton'XInterface.Tab_SPProfileNew.btnNextSymbol'

     Begin Object Class=GUIButton Name=btnBack
         Caption="BACK"
         Hint="Return to previous menu"
         WinTop=0.925000
         WinLeft=0.028125
         WinWidth=0.200000
         WinHeight=0.075000
         OnClick=Tab_SPProfileNew.BackClick
         OnKeyEvent=btnBack.InternalOnKeyEvent
     End Object
     Controls(13)=GUIButton'XInterface.Tab_SPProfileNew.btnBack'

     Begin Object Class=GUIButton Name=btnDefaults
         Caption="SET TO DEFAULTS"
         Hint="Set this profile back to default values"
         WinTop=0.925000
         WinLeft=0.367500
         WinWidth=0.232813
         WinHeight=0.075000
         OnClick=Tab_SPProfileNew.DefaultsClick
         OnKeyEvent=btnDefaults.InternalOnKeyEvent
     End Object
     Controls(14)=GUIButton'XInterface.Tab_SPProfileNew.btnDefaults'

     Begin Object Class=GUILabel Name=lblCharacter
         Caption="Select|Character"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2SmallFont"
         bMultiLine=True
         WinTop=0.724583
         WinLeft=0.064062
         WinWidth=0.200000
         WinHeight=0.100000
     End Object
     Controls(15)=GUILabel'XInterface.Tab_SPProfileNew.lblCharacter'

     Begin Object Class=GUILabel Name=lblTeamSymbol
         Caption="Select|Team Symbol"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2SmallFont"
         bMultiLine=True
         WinTop=0.724583
         WinLeft=0.284375
         WinWidth=0.200000
         WinHeight=0.100000
     End Object
     Controls(16)=GUILabel'XInterface.Tab_SPProfileNew.lblTeamSymbol'

     Begin Object Class=GUIImage Name=symbolBackground
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.237865
         WinLeft=0.296196
         WinWidth=0.179101
         WinHeight=0.297265
     End Object
     Controls(17)=GUIImage'XInterface.Tab_SPProfileNew.symbolBackground'

     Begin Object Class=GUIImage Name=portraitBackground
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.110469
         WinLeft=0.094141
         WinWidth=0.146680
         WinHeight=0.506094
         bVisible=False
     End Object
     Controls(18)=GUIImage'XInterface.Tab_SPProfileNew.portraitBackground'

     WinTop=0.150000
     WinHeight=0.770000
}

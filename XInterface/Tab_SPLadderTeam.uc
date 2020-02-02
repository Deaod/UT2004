// ====================================================================
//  Class:  XInterface.Tab_SPLadderTeam
//  Parent: XInterface.Tab_SPLadderBase
//  Single player menu for for selecting which match to play.
//  author:  capps 8/24/02
// ====================================================================

class Tab_SPLadderTeam extends Tab_SPLadderBase;

#exec OBJ LOAD FILE=InterfaceContent.utx

var array<LadderButton> TDMButtons;
var array<LadderButton> DOMButtons;
var array<LadderButton> BRButtons;
var array<LadderButton> CTFButtons;
var array<int>			LockIndexes;
var GUIGfxButton		ChampButton;
var GUIImage			ChampBorder;

function InitPanel()
{
local int i;

	ScrollInfo=GUIScrollTextBox(Controls[4]);
	MapPicHolder=GUIImage(Controls[1]);
	MapNameLabel=GUILabel(Controls[3]);
	ChampButton=GUIGfxButton(Controls[29]);
	ChampBorder=GUIImage(Controls[30]);

	// Create TDMButtons Array
	for (i=0; i<6; i++)
		TDMButtons[TDMButtons.Length] = NewLadderButton(1, i, 0.050195, 0.799215 - 0.128333 * i);

	for (i=0; i<5; i++)
		DOMButtons[DOMButtons.Length] = NewLadderButton(2, i, 0.176172, 0.799215 - 0.128333 * i);

	for (i=0; i<5; i++)
		BRButtons[BRButtons.Length] = NewLadderButton(4, i, 0.733789, 0.799215 - 0.128333 * i);

	for (i=0; i<6; i++)
		CTFButtons[CTFButtons.Length] = NewLadderButton(3, i, 0.860742, 0.799215 - 0.128333 * i);

	ScrollInfo.SetContent("");

	OnProfileUpdated();
}

function OnProfileUpdated()
{
local int i;

	for (i=0; i<6; i++)
	{
		UpdateLadderButton(TDMButtons[i], 1, i);
		UpdateLadderButton(CTFButtons[i], 3, i);
	}
		
	for (i=0; i<5; i++)
	{
		UpdateLadderButton(DOMButtons[i], 2, i);
		UpdateLadderButton(BRButtons[i], 4, i);
	}

	ChampBorder.bVisible=false;

	// Set the Yellow Bars and the Lock picture for completed ladders
	SetYellowBar(1, 12, TDMButtons);
	SetYellowBar(2, 20, DOMButtons); 	
	SetYellowBar(4, 24, BRButtons); 	
	SetYellowBar(3, 16, CTFButtons);
	SetChampionship(false);

	// Figure out which map info to display, always display lowest uncompleted ladder's next map
	if (GetProfile() != None)
	{
		GetProfile().ChampBorderObject = ChampBorder;

		if (!SetActiveMatch(1, TDMButtons) && !SetActiveMatch(2, DOMButtons) && !SetActiveMatch(3, CTFButtons) && !SetActiveMatch(4, BRButtons))
		{
			if (GetProfile().LadderRung[5] >= 0) {
				Log ( "SINGLEPLAYER Opening Championship." );
				SetChampionship(true);		// turn on button
				ChampMatch(ChampButton);	// and select it
			}
		}
	}
	// Else Display a No Picture avail (default picture)
}

function int SetYellowBar(int ladder, int index, out array<LadderButton> Buttons)
{
local int Rung, lockindex;
local string HiStr;

	Super.SetYellowBar(ladder, index, Buttons);

	if (GetProfile() != None)
	{
		Rung = GetProfile().LadderRung[ladder];
		lockindex = ladder;
		// Reset Lock pictures with the bars going to them

		HiStr = "";
		if (Rung == Buttons.Length)
			HiStr = "Hi";


		GUIImage(Controls[4+lockindex]).Image = DLOMaterial("InterfaceContent.SPMenu.Lock"$lockindex$HiStr);
		if (ladder < 3)
			GUIImage(Controls[index-2]).Image = DLOMaterial("InterfaceContent.SPMenu.BarCornerLeft"$HiStr);
		else
			GUIImage(Controls[index-2]).Image = DLOMaterial("InterfaceContent.SPMenu.BarCornerRight"$HiStr);
		GUIImage(Controls[index-3]).Image = DLOMaterial("InterfaceContent.SPMenu.BarHorizontal"$HiStr);
	}

	if (HiStr == "Hi")
		return 1;
	else 
		return 0;
}

// received click from the championship button
function bool ChampMatch (GUIComponent Sender) 
{
	local LadderButton LButton;
	local GameProfile GP;

	GP = GetProfile();
	if (GP != None ) 
	{
		if ( GP.ChampBorderObject != none ) 
			GUIImage(GP.ChampBorderObject).bVisible=true;
		GP.CurrentMenuRung = GP.LadderRung[5];
		GP.CurrentLadder = 5;
		LButton=LadderButton(GP.NextMatchObject);
		if ( LButton != none ) 
		{
			LButton.SetState(GP.LadderRung[LButton.LadderIndex]);
			LButton = none;
		}
		ShowMatchInfo( GP.GetMatchInfo ( GP.CurrentLadder, GP.CurrentMenuRung ) );
		MatchUpdated(GP.CurrentLadder, GP.CurrentMenuRung);
	}
	return true;
}

// 
function SetChampionship(bool bEnable) 
{
	local MatchInfo MI;
	local GameProfile GP;

	GP = GetProfile();
	if (GP != None ) 
	{
		ChampButton.bVisible=bEnable;
		ChampButton.bAcceptsInput=bEnable;
		ChampButton.bNeverFocus=!bEnable;

		if ( bEnable ) 
		{
			// completed or not?
			if ( GP.LadderRung[5] >= GP.GameLadder.default.ChampionshipMatches.Length ) 
			{
				ChampButton.Graphic = DLOMaterial("PlayerPictures.aDOM");
				// show trophy
			} 
			else 
			{
				// show thumb
				MI = GP.GetMatchInfo( 5, GP.LadderRung[5] );
				ChampButton.Graphic = DLOMaterial("SinglePlayerThumbs."$MI.LevelName);		
			}
		}
	}
}

defaultproperties
{
     LockIndexes(1)=1
     LockIndexes(2)=3
     LockIndexes(3)=2
     LockIndexes(4)=4
     bFillHeight=True
     Begin Object Class=GUIImage Name=MapPicBack
         Image=Texture'InterfaceContent.Menu.EditBox'
         ImageStyle=ISTY_Stretched
         WinTop=0.247917
         WinLeft=0.293164
         WinWidth=0.413281
         WinHeight=0.294141
     End Object
     Controls(0)=GUIImage'XInterface.Tab_SPLadderTeam.MapPicBack'

     Begin Object Class=GUIImage Name=MapPic
         Image=Texture'InterfaceContent.Menu.NoLevelPreview'
         ImageStyle=ISTY_Justified
         ImageAlign=IMGA_Center
         WinTop=0.255313
         WinLeft=0.299219
         WinWidth=0.401563
         WinHeight=0.279493
     End Object
     Controls(1)=GUIImage'XInterface.Tab_SPLadderTeam.MapPic'

     Begin Object Class=GUIImage Name=MapInfoBack
         Image=Texture'InterfaceContent.Menu.EditBox'
         ImageStyle=ISTY_Stretched
         WinTop=0.551823
         WinLeft=0.294141
         WinWidth=0.412305
         WinHeight=0.361524
     End Object
     Controls(2)=GUIImage'XInterface.Tab_SPLadderTeam.MapInfoBack'

     Begin Object Class=GUILabel Name=MapInfoName
         Caption="No Match Selected"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.562240
         WinLeft=0.301172
         WinWidth=0.396680
         WinHeight=0.051406
     End Object
     Controls(3)=GUILabel'XInterface.Tab_SPLadderTeam.MapInfoName'

     Begin Object Class=GUIScrollTextBox Name=MapInfoScroll
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=MapInfoScroll.InternalOnCreateComponent
         WinTop=0.616407
         WinLeft=0.299023
         WinWidth=0.402539
         WinHeight=0.290234
         bNeverFocus=True
     End Object
     Controls(4)=GUIScrollTextBox'XInterface.Tab_SPLadderTeam.MapInfoScroll'

     Begin Object Class=GUIImage Name=ImgLock1
         Image=Texture'InterfaceContent.SPMenu.Lock1'
         ImageStyle=ISTY_Scaled
         ImageAlign=IMGA_Center
         WinTop=0.064322
         WinLeft=0.437695
         WinWidth=0.062891
         WinHeight=0.087305
     End Object
     Controls(5)=GUIImage'XInterface.Tab_SPLadderTeam.ImgLock1'

     Begin Object Class=GUIImage Name=ImgLock2
         Image=Texture'InterfaceContent.SPMenu.Lock2'
         ImageStyle=ISTY_Scaled
         ImageAlign=IMGA_Center
         WinTop=0.150260
         WinLeft=0.437695
         WinWidth=0.062891
         WinHeight=0.087305
     End Object
     Controls(6)=GUIImage'XInterface.Tab_SPLadderTeam.ImgLock2'

     Begin Object Class=GUIImage Name=ImgLock3
         Image=Texture'InterfaceContent.SPMenu.Lock3'
         ImageStyle=ISTY_Scaled
         ImageAlign=IMGA_Center
         WinTop=0.064322
         WinLeft=0.500195
         WinWidth=0.062891
         WinHeight=0.087305
     End Object
     Controls(7)=GUIImage'XInterface.Tab_SPLadderTeam.ImgLock3'

     Begin Object Class=GUIImage Name=ImgLock4
         Image=Texture'InterfaceContent.SPMenu.Lock4'
         ImageStyle=ISTY_Scaled
         ImageAlign=IMGA_Center
         WinTop=0.150260
         WinLeft=0.500195
         WinWidth=0.062891
         WinHeight=0.087305
     End Object
     Controls(8)=GUIImage'XInterface.Tab_SPLadderTeam.ImgLock4'

     Begin Object Class=GUIImage Name=TopLeftBar
         Image=Texture'InterfaceContent.SPMenu.BarHorizontal'
         ImageStyle=ISTY_Scaled
         WinTop=0.105729
         WinLeft=0.099218
         WinWidth=0.338086
         WinHeight=0.003906
     End Object
     Controls(9)=GUIImage'XInterface.Tab_SPLadderTeam.TopLeftBar'

     Begin Object Class=GUIImage Name=TopLeftCorner
         Image=Texture'InterfaceContent.SPMenu.BarCornerLeft'
         ImageStyle=ISTY_Scaled
         WinTop=0.105729
         WinLeft=0.095312
         WinWidth=0.003906
         WinHeight=0.003906
     End Object
     Controls(10)=GUIImage'XInterface.Tab_SPLadderTeam.TopLeftCorner'

     Begin Object Class=GUIImage Name=TDMBar1
         Image=Texture'InterfaceContent.SPMenu.BarVertical'
         ImageStyle=ISTY_Scaled
         WinTop=0.109896
         WinLeft=0.095312
         WinWidth=0.003906
         WinHeight=0.682227
     End Object
     Controls(11)=GUIImage'XInterface.Tab_SPLadderTeam.TDMBar1'

     Begin Object Class=GUIImage Name=TDMBar2
         Image=Texture'InterfaceContent.SPMenu.BarVerticalHi'
         ImageStyle=ISTY_Scaled
         WinTop=0.109896
         WinLeft=0.095312
         WinWidth=0.003906
         WinHeight=0.682227
         bVisible=False
     End Object
     Controls(12)=GUIImage'XInterface.Tab_SPLadderTeam.TDMBar2'

     Begin Object Class=GUIImage Name=TopRightBar
         Image=Texture'InterfaceContent.SPMenu.BarHorizontal'
         ImageStyle=ISTY_Scaled
         WinTop=0.105729
         WinLeft=0.563085
         WinWidth=0.338086
         WinHeight=0.003906
     End Object
     Controls(13)=GUIImage'XInterface.Tab_SPLadderTeam.TopRightBar'

     Begin Object Class=GUIImage Name=TopRightCorner
         Image=Texture'InterfaceContent.SPMenu.BarCornerRight'
         ImageStyle=ISTY_Scaled
         WinTop=0.105729
         WinLeft=0.901171
         WinWidth=0.003906
         WinHeight=0.003906
     End Object
     Controls(14)=GUIImage'XInterface.Tab_SPLadderTeam.TopRightCorner'

     Begin Object Class=GUIImage Name=CTFBar1
         Image=Texture'InterfaceContent.SPMenu.BarVertical'
         ImageStyle=ISTY_Scaled
         WinTop=0.109896
         WinLeft=0.901171
         WinWidth=0.003906
         WinHeight=0.682227
     End Object
     Controls(15)=GUIImage'XInterface.Tab_SPLadderTeam.CTFBar1'

     Begin Object Class=GUIImage Name=CTFBar2
         Image=Texture'InterfaceContent.SPMenu.BarVerticalHi'
         ImageStyle=ISTY_Scaled
         WinTop=0.109896
         WinLeft=0.901171
         WinWidth=0.003906
         WinHeight=0.682227
         bVisible=False
     End Object
     Controls(16)=GUIImage'XInterface.Tab_SPLadderTeam.CTFBar2'

     Begin Object Class=GUIImage Name=MidLeftBar
         Image=Texture'InterfaceContent.SPMenu.BarHorizontal'
         ImageStyle=ISTY_Scaled
         WinTop=0.194218
         WinLeft=0.222266
         WinWidth=0.215039
         WinHeight=0.003906
     End Object
     Controls(17)=GUIImage'XInterface.Tab_SPLadderTeam.MidLeftBar'

     Begin Object Class=GUIImage Name=MidLeftCorner
         Image=Texture'InterfaceContent.SPMenu.BarCornerLeft'
         ImageStyle=ISTY_Scaled
         WinTop=0.194218
         WinLeft=0.219336
         WinWidth=0.003906
         WinHeight=0.003906
     End Object
     Controls(18)=GUIImage'XInterface.Tab_SPLadderTeam.MidLeftCorner'

     Begin Object Class=GUIImage Name=DOMBar1
         Image=Texture'InterfaceContent.SPMenu.BarVertical'
         ImageStyle=ISTY_Scaled
         WinTop=0.198125
         WinLeft=0.219336
         WinWidth=0.003906
         WinHeight=0.594688
     End Object
     Controls(19)=GUIImage'XInterface.Tab_SPLadderTeam.DOMBar1'

     Begin Object Class=GUIImage Name=DOMBar2
         Image=Texture'InterfaceContent.SPMenu.BarVerticalHi'
         ImageStyle=ISTY_Scaled
         WinTop=0.198125
         WinLeft=0.219336
         WinWidth=0.003906
         WinHeight=0.594688
         bVisible=False
     End Object
     Controls(20)=GUIImage'XInterface.Tab_SPLadderTeam.DOMBar2'

     Begin Object Class=GUIImage Name=MidRightBar
         Image=Texture'InterfaceContent.SPMenu.BarHorizontal'
         ImageStyle=ISTY_Scaled
         WinTop=0.194270
         WinLeft=0.563085
         WinWidth=0.213086
         WinHeight=0.003906
     End Object
     Controls(21)=GUIImage'XInterface.Tab_SPLadderTeam.MidRightBar'

     Begin Object Class=GUIImage Name=MidRightCorner
         Image=Texture'InterfaceContent.SPMenu.BarCornerRight'
         ImageStyle=ISTY_Scaled
         WinTop=0.194271
         WinLeft=0.776171
         WinWidth=0.003906
         WinHeight=0.003906
     End Object
     Controls(22)=GUIImage'XInterface.Tab_SPLadderTeam.MidRightCorner'

     Begin Object Class=GUIImage Name=BRBar1
         Image=Texture'InterfaceContent.SPMenu.BarVertical'
         ImageStyle=ISTY_Scaled
         WinTop=0.197970
         WinLeft=0.775976
         WinWidth=0.003906
         WinHeight=0.594687
     End Object
     Controls(23)=GUIImage'XInterface.Tab_SPLadderTeam.BRBar1'

     Begin Object Class=GUIImage Name=BRBar2
         Image=Texture'InterfaceContent.SPMenu.BarVerticalHi'
         ImageStyle=ISTY_Scaled
         WinTop=0.197970
         WinLeft=0.775976
         WinWidth=0.003906
         WinHeight=0.594687
         bVisible=False
     End Object
     Controls(24)=GUIImage'XInterface.Tab_SPLadderTeam.BRBar2'

     Begin Object Class=GUILabel Name=TDMLabel
         Caption="TEAM DEATHMATCH"
         TextAlign=TXTA_Center
         TextColor=(B=192,G=192,R=192)
         BackColor=(B=255,G=255,R=255)
         WinTop=0.060833
         WinLeft=0.118437
         WinWidth=0.347500
         WinHeight=0.043125
     End Object
     Controls(25)=GUILabel'XInterface.Tab_SPLadderTeam.TDMLabel'

     Begin Object Class=GUILabel Name=CTFLabel
         Caption="CAPTURE THE FLAG"
         TextAlign=TXTA_Center
         TextColor=(B=192,G=192,R=192)
         BackColor=(B=255,G=255,R=255)
         WinTop=0.060833
         WinLeft=0.544064
         WinWidth=0.346250
         WinHeight=0.043125
     End Object
     Controls(26)=GUILabel'XInterface.Tab_SPLadderTeam.CTFLabel'

     Begin Object Class=GUILabel Name=DOMLabel
         Caption="DOMINATION"
         TextAlign=TXTA_Center
         TextColor=(B=192,G=192,R=192)
         BackColor=(B=255,G=255,R=255)
         WinTop=0.149167
         WinLeft=0.242813
         WinWidth=0.223122
         WinHeight=0.043125
     End Object
     Controls(27)=GUILabel'XInterface.Tab_SPLadderTeam.DOMLabel'

     Begin Object Class=GUILabel Name=BRLabel
         Caption="BOMBING RUN"
         TextAlign=TXTA_Center
         TextColor=(B=192,G=192,R=192)
         BackColor=(B=255,G=255,R=255)
         WinTop=0.149166
         WinLeft=0.537818
         WinWidth=0.221874
         WinHeight=0.043125
     End Object
     Controls(28)=GUILabel'XInterface.Tab_SPLadderTeam.BRLabel'

     Begin Object Class=GUIGFXButton Name=SPLChampButton
         Graphic=Texture'InterfaceContent.SPMenu.Lock1'
         Position=ICP_Scaled
         WinTop=0.094322
         WinLeft=0.458633
         WinWidth=0.083925
         WinHeight=0.113688
         bVisible=False
         bAcceptsInput=False
         OnClick=Tab_SPLadderTeam.ChampMatch
         OnDblClick=Tab_SPLadderTeam.MatchDoubleClick
         OnKeyEvent=SPLChampButton.InternalOnKeyEvent
     End Object
     Controls(29)=GUIGFXButton'XInterface.Tab_SPLadderTeam.SPLChampButton'

     Begin Object Class=GUIImage Name=SPLChampBorder
         Image=FinalBlend'InterfaceContent.SPMenu.SP_FinalButton'
         ImageStyle=ISTY_Scaled
         WinTop=0.064895
         WinLeft=0.437930
         WinWidth=0.125722
         WinHeight=0.172673
         bVisible=False
     End Object
     Controls(30)=GUIImage'XInterface.Tab_SPLadderTeam.SPLChampBorder'

     WinTop=0.150000
     WinHeight=0.770000
}

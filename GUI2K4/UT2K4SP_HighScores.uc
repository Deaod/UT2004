//==============================================================================
// Single Player highscore list
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SP_HighScores extends UT2K4GUIPage;

var automated GUIImage imgBackground, imgDraw;
var automated GUIButton btnExport;
var automated GUIVertScrollBar sbScores;

/** highscore data file */
var SPHighScore HS;
/** used for drawing */
var float curY, incY, lineHeight;
/** finished scrolling the list */
var bool bFinished;
/** hilight this entry, pass an int value on HandleParameters to set it */
var int HilighEntry;
/** start drawing from this entry */
var int startoffset;
var GUIFont MainFont, TinyFont;

var localized string ColumnHeaders[4];
var localized string ClickToExit;

var array<xUtil.PlayerRecord> PlayerList;
var SpinnyWeap			SpinnyDude; // MUST be set to null when you leave the window
var vector				SpinnyDudeOffset;
var int					nfov;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	HS = PlayerOwner().Level.Game.LoadDataObject(class'GUI2K4.SPHighScore', "SPHighScore", class'UT2K4SP_Main'.default.HighScoreFile);
	if (HS == none)
	{
		Log("UT2K4SP_HighScores - UT2004HighScores doesn't exist, creating...");
		HS = PlayerOwner().Level.Game.CreateDataObject(class'GUI2K4.SPHighScore', "SPHighScore", class'UT2K4SP_Main'.default.HighScoreFile);
	}
	MainFont = new class'fntUT2k4Large';
	TinyFont = new class'fntUT2k4Small';
	bInit = false;
	startoffset = 0;
	sbScores.ItemCount = HS.Scores.length;
	sbScores.ItemsPerPage = 10;
	sbScores.BigStep = 5;
	sbScores.CurPos = startoffset;

	class'xUtil'.static.GetPlayerList(PlayerList);
	// Spawn spinning character actor
	if ( SpinnyDude == None )
		SpinnyDude = PlayerOwner().spawn(class'XInterface.SpinnyWeap');

	SpinnyDude.SetDrawType(DT_Mesh);
	SpinnyDude.SetDrawScale(0.9);
	SpinnyDude.SpinRate = 2004;
	SpinnyDude.bPlayCrouches = false;
	SpinnyDude.bPlayRandomAnims = true;
	SpinnyDude.AnimChangeInterval = 5.0;
	SpinnyDude.AnimNames.length = 0;
	SpinnyDude.AnimNames[0] = 'idle_rest';
	SpinnyDude.AnimNames[1] = 'idle_rest';
	SpinnyDude.AnimNames[2] = 'idle_rest';
	SpinnyDude.AnimNames[3] = 'idle_rest';
	SpinnyDude.AnimNames[4] = 'idle_rest';
	SpinnyDude.AnimNames[5] = 'gesture_cheer';
	SpinnyDude.AnimNames[6] = 'gesture_taunt01';
	SpinnyDude.AnimNames[7] = 'gesture_taunt02';
	SpinnyDude.AnimNames[8] = 'pthrust';
	UpdateSpinnyDude();
}

event HandleParameters(string Param1, string Param2)
{
	SetTimer(0.02, true);
	HilighEntry = -1;
	if (Param1 != "") HilighEntry = int(Param1);
	else {
		bFinished = true;
		bTimerRepeat = false;
		TimerInterval = 0;
		sbScores.bVisible=true;
	}
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

event Timer()
{
	if (!bInit) return;
	curY += incY;
	if (curY >= (lineHeight/2))
	{
		bFinished = true;
		bTimerRepeat = false;
		TimerInterval = 0;
		sbScores.bVisible=true;
		//btnExport.bVisible = true;
	}
}

function bool InternalOnDraw(canvas Canvas)
{
	local vector CamPos, X, Y, Z;
	local rotator CamRot;
	local float   oOrgX, oOrgY;
	local float   oClipX, oClipY;

   	oOrgX = Canvas.OrgX;
    oOrgY = Canvas.OrgY;
    oClipX = Canvas.ClipX;
    oClipY = Canvas.ClipY;

    Canvas.OrgX = imgDraw.ActualLeft();
    Canvas.OrgY = imgDraw.ActualTop();
    Canvas.ClipX = imgDraw.ActualWidth();
    Canvas.ClipY = imgDraw.ActualHeight();

    canvas.GetCameraLocation(CamPos, CamRot);
    GetAxes(CamRot, X, Y, Z);

    SpinnyDude.SetLocation(CamPos + (SpinnyDudeOffset.X * X) + (SpinnyDudeOffset.Y * Y) + (SpinnyDudeOffset.Z * Z));
    canvas.DrawActorClipped(SpinnyDude, false,  imgDraw.ActualLeft(), imgDraw.ActualTop(), imgDraw.ActualWidth(), imgDraw.ActualHeight(), true, nFOV);
    Canvas.OrgX = oOrgX;
    Canvas.OrgY = oOrgY;
    Canvas.ClipX = oClipX;
    Canvas.ClipY = oClipY;

	OnDrawScores(Canvas);
	return false;
}

function OnDrawScores(Canvas Canvas)
{
	local int i;
	local float cX, cY, outX, outY;
	local float columns[5]; // collumn width

	if (!bInit)
	{
		lineHeight = Canvas.SizeY/11;
		if (!bFinished)	curY = -1*HS.Scores.length*lineHeight;
		else curY = lineHeight/2;
		incY = Canvas.SizeY*0.01;
		bInit = true;
	}

	Canvas.Reset();
	Canvas.Style = 5;
	cY = CurY;
	cX = Canvas.SizeX*0.05;
	columns[0] = cX*2;					// 10%
	columns[1] = columns[0]+cX*7;		// 35%
	columns[2] = columns[1]+cX*6;		// 30%
	columns[3] = columns[2]+cX*2;		// 10%
	columns[4] = columns[3]+cX*2;		// 10%
	for (i = 0; i < HS.Scores.length; i++)
	{
		if (cY > Canvas.SizeY) break;
		if (i+startoffset >= HS.Scores.length) break;
		if (cY+lineHeight > 0)
		{
			if (MainFont != None) Canvas.Font = MainFont.GetFont(Canvas.SizeX / 3);
			if (HilighEntry == i+startoffset) Canvas.SetDrawColor(255, 225, 0, 255); // highlight this line
			else if (HS.Scores[i+startoffset].bDrone) Canvas.SetDrawColor(255, 255, 255, 128); // not a real player
			else Canvas.SetDrawColor(255, 255, 255, 255);

			Canvas.DrawTextJustified((i+startoffset+1)$". ", 2, 0, cY, columns[0], cY+lineHeight);
			Canvas.DrawTextJustified(HS.Scores[i+startoffset].Name, 0, columns[0], cY, columns[2], cY+lineHeight);
			Canvas.StrLen(HS.Scores[i+startoffset].Name, outX, outY);
			Canvas.DrawTextJustified(class'UT2K4GameProfile'.static.MoneyToString(HS.Scores[i+startoffset].Balance), 2, columns[0], cY, columns[2], cY+lineHeight);
			Canvas.DrawTextJustified(string(HS.Scores[i+startoffset].Matches), 2, columns[2], cY, columns[3], cY+lineHeight);
			Canvas.DrawTextJustified(string(HS.Scores[i+startoffset].Wins), 2, columns[3], cY, columns[4], cY+lineHeight);

			if (TinyFont != None)
				Canvas.Font = TinyFont.GetFont(Canvas.SizeX);

//			Canvas.DrawTextJustified(class'UT2K4SPTab_ProfileNew'.default.DifficultyLevels[int(HS.Scores[i+startoffset].Difficulty)], 0, columns[0], cY+lineHeight-(outY/2), columns[1], cY+lineHeight);
			Canvas.DrawTextJustified(class'UT2K4SPTab_ProfileNew'.default.DifficultyLevels[int(HS.Scores[i+startoffset].Difficulty)], 0, columns[0], cY+outY+(LineHeight*0.2), columns[1], cY+lineHeight);
		}
		cY += lineHeight;
		if (bFinished && i == 9) break;
	}
	if (bFinished)
	{
		Canvas.SetDrawColor(255, 255, 255, 196);
		cY = lineHeight*0.1;
		if (TinyFont != None) Canvas.Font = TinyFont.GetFont(Canvas.SizeX);
		Canvas.DrawTextJustified(ColumnHeaders[0], 1, columns[0], cY, columns[1], cY+(lineHeight/2));
		Canvas.DrawTextJustified(ColumnHeaders[1], 1, columns[1], cY, columns[2], cY+(lineHeight/2));
		Canvas.DrawTextJustified(ColumnHeaders[2], 1, columns[2], cY, columns[3], cY+(lineHeight/2));
		Canvas.DrawTextJustified(ColumnHeaders[3], 1, columns[3], cY, columns[4], cY+(lineHeight/2));
		Canvas.CurX = cX/2;
		Canvas.DrawHorizontal(cY+(lineHeight/2), cX*18.5); // 90%

		if (TinyFont != None) Canvas.Font = TinyFont.GetFont(Canvas.SizeX);
		Canvas.TextSize(ClickToExit, outX, outY);
		outY *= 1.005;
		Canvas.SetDrawColor(0, 0, 0, 196);
		Canvas.DrawTextJustified(ClickToExit, 1, 0+Canvas.SizeX*0.001, (Canvas.SizeY-outY)*1.001, Canvas.SizeX*1.001, Canvas.SizeY*1.001);
		Canvas.SetDrawColor(226, 196, 0, 196);
		Canvas.DrawTextJustified(ClickToExit, 1, 0, Canvas.SizeY-outY, Canvas.SizeX, Canvas.SizeY);
	}
}

function bool OnImgClick(GUIComponent Sender)
{
	Log(Sender);
	return Controller.CloseMenu(false);
}

function bool OnExportClick(GUIComponent Sender)
{
	local GUIQuestionPage QPage;
	ExportToFile();
	if (Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage"))
	{
		QPage=GUIQuestionPage(Controller.TopPage());
		QPage.SetupQuestion("High scores saved to: ..\\UserLogs\\UT2004_HighScores.txt", QBTN_Ok, QBTN_Ok);
	}
	return true;
}

function ExportToFile()
{
	local int i;
	local FileLog output;
	output = PlayerOwner().Spawn(class'FileLog');
	output.OpenLog("UT2004_HighScores", "txt");
	output.Logf(chr(9)$"name"$chr(9)$"balance"$chr(9)$"matches"$chr(9)$"wins");
	output.Logf("--------------------------------------------------------------------------------");
	for (i = 0; i < HS.Scores.length; i++)
	{
		output.Logf(string(i+1)$chr(9)$HS.Scores[i].Name$chr(9)$string(HS.Scores[i].Balance)$chr(9)$string(HS.Scores[i].Matches)$chr(9)$string(HS.Scores[i].Wins));
	}
	output.CloseLog();
}

function bool WindowOnKeyEvent(out byte Key, out byte State, float delta)
{
	if (!bFinished) return false;
	if (State != 1) return false;
	if ((Key == 0x26) || (Key == 236)) //up
	{
		sbScores.WheelUp();
		return true;
	}
	else if ((Key == 0x28) || (Key == 237)) //down
	{
		sbScores.WheelDown();
		return true;
	}
	// debug stuff
	else if (Key == 0x32) // 2
	{
		SpinnyDudeOffset.X = SpinnyDudeOffset.X+1;
	}
	else if (Key == 0x31) // 1
	{
		SpinnyDudeOffset.X = SpinnyDudeOffset.X-1;
	}
	else if (Key == 0x34) // 4
	{
		SpinnyDudeOffset.Y = SpinnyDudeOffset.Y+1;
	}
	else if (Key == 0x33) // 3
	{
		SpinnyDudeOffset.Y = SpinnyDudeOffset.Y-1;
	}
	else if (Key == 0x36) // 6
	{
		SpinnyDudeOffset.Z = SpinnyDudeOffset.Z+1;
	}
	else if (Key == 0x35) // 5
	{
		SpinnyDudeOffset.Z = SpinnyDudeOffset.Z-1;
	}
	else  if (Key == 0x38) // 8
	{
		SpinnyDude.SpinRate = SpinnyDude.SpinRate+1;
	}
	else  if (Key == 0x37) // 7
	{
		SpinnyDude.SpinRate = SpinnyDude.SpinRate-1;
	}
	else if (Key == 0x30) // 0
	{
		Log("SpinnyDudeOffset ="@SpinnyDudeOffset@" SpinnyDudeSpinRate ="@SpinnyDude.SpinRate);
	}

	return false;
}

function OnScrollPosChanged(int NewPos)
{
	startoffset=NewPos;
}

function UpdateSpinnyDude()
{
	local int idx;
	local xUtil.PlayerRecord Rec;
	local Mesh PlayerMesh;
	local Material BodySkin, HeadSkin;
    local string BodySkinName, HeadSkinName;
    local UT2K4GameProfile GP;

    GP = UT2K4GameProfile(PlayerOwner().Level.Game.CurrentGameProfile);
    if (GP != none)
    {
    	if (GP.bCompleted && (GP.PlayerCharacter ~= "Mr.Crow"))
    	{
    		PlayerMesh = Mesh(DynamicLoadObject("GenericSD.TC", class'Mesh'));
    		SpinnyDude.LinkMesh(PlayerMesh);
			SpinnyDude.Skins[0] = texture(DynamicLoadObject("GenericSD.ToiletCar", class'Texture'));
			SpinnyDudeOffset=vect(354.00,0.00,-19.00);
			SpinnyDude.bPlayRandomAnims = false;
			return;
    	}
    	if (GP.bCompleted)
    	{
    		if (HS.UnlockedChars.length > 0)
	    		BodySkinName = HS.UnlockedChars[HS.UnlockedChars.length-1];
    	}
    }

	idx = -1;
	if (BodySkinName != "")
	{
	    for (idx = 0; idx < Playerlist.length; idx++)
    	{
    		if (PlayerList[idx].DefaultName ~= BodySkinName) break;
	    }
    	BodySkinName = "";
    }

	if (idx >= Playerlist.Length || idx == -1) idx = rand(Playerlist.Length);
	if ( idx < 0 || idx >= Playerlist.Length )
		return;

	Rec = PlayerList[idx];

	if (Rec.Race ~= "Juggernaut" || Rec.DefaultName~="Axon" || Rec.DefaultName~="Cyclops" || Rec.DefaultName ~="Virus" )
    	SpinnyDudeOffset=vect(273.0,0.00,-11.00);
    else
	    SpinnyDudeOffset=vect(273.0,0.00,-17.00);

	PlayerMesh = Mesh(DynamicLoadObject(Rec.MeshName, class'Mesh'));
	if(PlayerMesh == None)
	{
		Log("Could not load mesh: "$Rec.MeshName$" for player: "$Rec.DefaultName);
		return;
	}

	// Get the body skin
    BodySkinName = Rec.BodySkinName;

	// Get the head skin
    HeadSkinName = Rec.FaceSkinName;

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

function Free()
{
	Super.Free();
	if ( SpinnyDude != None ) SpinnyDude.Destroy();
	SpinnyDude = None;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=SPMimgBackground
         Image=MaterialSequence'2K4Menus.Controls.background_anim'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinHeight=1.000000
         RenderWeight=0.001000
         bAcceptsInput=True
         bNeverFocus=True
         OnClick=UT2K4SP_HighScores.OnImgClick
         OnKeyEvent=UT2K4SP_HighScores.WindowOnKeyEvent
     End Object
     imgBackground=GUIImage'GUI2K4.UT2K4SP_HighScores.SPMimgBackground'

     Begin Object Class=GUIImage Name=SPMimgDraw
         WinHeight=1.000000
         RenderWeight=0.002000
         bAcceptsInput=True
         bNeverFocus=True
         OnDraw=UT2K4SP_HighScores.InternalOnDraw
         OnClick=UT2K4SP_HighScores.OnImgClick
         OnKeyEvent=UT2K4SP_HighScores.WindowOnKeyEvent
     End Object
     imgDraw=GUIImage'GUI2K4.UT2K4SP_HighScores.SPMimgDraw'

     Begin Object Class=GUIButton Name=SPMbtnExport
         Caption="SAVE TO FILE"
         FontScale=FNS_Small
         WinTop=0.950000
         WinLeft=0.400000
         WinWidth=0.200000
         WinHeight=0.004000
         RenderWeight=0.200000
         bVisible=False
         OnClick=UT2K4SP_HighScores.OnExportClick
         OnKeyEvent=SPMbtnExport.InternalOnKeyEvent
     End Object
     btnExport=GUIButton'GUI2K4.UT2K4SP_HighScores.SPMbtnExport'

     Begin Object Class=GUIVertScrollBar Name=SPMsbScores
         PositionChanged=UT2K4SP_HighScores.OnScrollPosChanged
         WinLeft=0.962500
         WinWidth=0.037500
         WinHeight=1.000000
         RenderWeight=1.000000
         bVisible=False
         OnPreDraw=SPMsbScores.GripPreDraw
     End Object
     sbScores=GUIVertScrollBar'GUI2K4.UT2K4SP_HighScores.SPMsbScores'

     ColumnHeaders(0)="name"
     ColumnHeaders(1)="balance"
     ColumnHeaders(2)="matches"
     ColumnHeaders(3)="wins"
     ClickToExit="C L I C K   T O   E X I T"
     SpinnyDudeOffset=(X=273.000000,Z=-11.000000)
     nfov=15
     WinTop=0.000000
     WinHeight=1.000000
     OnKeyEvent=UT2K4SP_HighScores.WindowOnKeyEvent
}

//==============================================================================
// Single player tutorial screen
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SPTab_Tutorials extends UT2K4SPTab_Base config;

#exec OBJ LOAD FILE=2K4Menus.utx
#exec OBJ LOAD FILE=Laddershots.utx

/**
	Single player tutorial record.
	Gameclass is used for the tutorial name
	Preview is the image to use when the tutorial is available
	PreviewLocked is used when it's locked
	Map is the url to start
*/
struct SPTutorial
{
	var string GameClass;
	var string Preview;
	var string PreviewLocked;
	var string Map;
	var bool unLocked;
};
var config array<SPTutorial> Tutorials;

var Material BorderMat, ShadowMat;

var localized string StartTutorial;

var array<GUIImage> TutImages;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	CreateButtons();
}

function CreateButtons()
{
	local int i, cols, rows, n;
	local float colWidth, rowHeight, cellWidth, cellHeight, spacingHeight, spacingWidth, X, Y;
	local GUIImage img;
	local GUISectionBackground sbg;
	local GUIButton btn;
	local CacheManager.GameRecord GR;

	rows = round(sqrt(Tutorials.Length));
	cols = ceil(float(Tutorials.Length)/float(rows));
	colWidth = WinWidth/cols;
	rowHeight = WinHeight/rows;
	cellWidth = colWidth*0.9;
	cellHeight = rowHeight*0.9;
	// calculate aspect ratio 1:1
	X = FMin(cellWidth, cellHeight);
	cellWidth = X;
	cellHeight = X;
	// find centers
	spacingHeight = (rowHeight-cellHeight)/2.0 + 0.005;
	spacingWidth = (colWidth-cellWidth)/2.0 + 0.005;

	for (i = 0; i < Tutorials.Length; i++)
	{
		X = (i%cols)*colWidth+spacingWidth+WinLeft;
		Y = (i/cols)*rowHeight+spacingHeight+WinTop;
		if (((i/cols)+1 == rows) && (rows*cols > Tutorials.Length))
		{
			// center last row
			n = rows*cols-Tutorials.Length;
			X = X+(colWidth*n)/2.0;
		}

		GR = class'CacheManager'.static.getGameRecord(Tutorials[i].GameClass);

		btn = new class'GUIButton';
		btn.StyleName = "NoBackground";
		btn.bFocusOnWatch = true;
		btn.WinHeight = cellWidth;
		btn.WinWidth = cellHeight;
		btn.WinTop = Y;
		btn.WinLeft = X;
		btn.OnClick = OnTutorialClick;
		btn.tag = i;
		btn.Hint = StartTutorial@GR.GameName;
		btn.RenderWeight = 0.4;
		btn.TabOrder = Controls.length+1;
		AppendComponent(btn, true);

		sbg = new class'AltSectionBackground';
		sbg.WinHeight = cellHeight;
		sbg.WinWidth = cellWidth;
		sbg.WinTop = Y;
		sbg.WinLeft = X;
		sbg.RenderWeight = 0.1;
		sbg.Caption = GR.GameName;
		AppendComponent(sbg, true);

		img = new class'GUIImage';
		img.ImageStyle = ISTY_Scaled;
		img.WinHeight = (cellHeight-0.09605);
		img.WinWidth = (cellWidth-0.02625);
		img.WinTop = Y+0.046667;
		img.WinLeft = X+0.01375;
		img.X1 = 0;
		img.Y1 = 0;
		img.X2 = 1023;
		img.Y2 = 767;
		img.RenderWeight = 0.17;
		AppendComponent(img, true);
		TutImages[i] = img;
	}
}

function ShowPanel(bool bShow)
{
	local int i;
	local Material ss;

	Super.ShowPanel(bShow);
	if (bShow) btnPlayEnabled(false);

	if (!bShow) return;
	for (i = 0; i < Tutorials.length; i++)
	{
		if (TutImages[i].Image == none)
		{
			if (Tutorials[i].unLocked || (Tutorials[i].PreviewLocked == ""))
				ss = Material(DynamicLoadObject(Tutorials[i].Preview, class'Material'));
				else ss = Material(DynamicLoadObject(Tutorials[i].PreviewLocked, class'Material'));
			TutImages[i].Image = ss;
		}
	}
}

function bool OnTutorialClick(GUIComponent Sender)
{
	GP = UT2K4GameProfile(PlayerOwner().Level.Game.CurrentGameProfile);
	if ( GP != none ) {
		GP.bInLadderGame = true;  // so that it'll reload into SP menus
		GP.SpecialEvent = "";
		GP.lmdFreshInfo = false;
		PlayerOwner().Level.Game.SavePackage(GP.PackageName);
		PlayerOwner().ConsoleCommand ("START"@Tutorials[Sender.Tag].Map$"?quickstart=true?TeamScreen=false?NumBots=0?savegame="$GP.PackageName);
	}
	else
	{
		PlayerOwner().ConsoleCommand ("START"@Tutorials[Sender.Tag].Map$"?quickstart=true?TeamScreen=false?NumBots=0");
	}
	MainWindow.bAllowedAsLast = true;
	Controller.CloseAll(false,true);
	return true;
}

static function unlockButton(string tag)
{
	if (tag ~= "TDM") Default.Tutorials[0].unlocked = true;
	else if (tag ~= "CTF") Default.Tutorials[1].unlocked = true;
	else if (tag ~= "DOM") Default.Tutorials[2].unlocked = true;
	else if (tag ~= "BR") Default.Tutorials[3].unlocked = true;
	//else if (tag ~= "AS") TutorialData[4].unlocked = true;
	StaticSaveConfig();
}

defaultproperties
{
     Tutorials(0)=(GameClass="xGame.xDeathMatch",Preview="LadderShots.TeamDMMoneyShot",PreviewLocked="LadderShots.TeamDMShot",Map="TUT-DM")
     Tutorials(1)=(GameClass="xGame.xCTFGame",Preview="LadderShots.CTFMoneyShot",PreviewLocked="LadderShots.CTFShot",Map="TUT-CTF")
     Tutorials(2)=(GameClass="xGame.xDoubleDom",Preview="LadderShots.DOMMoneyShot",PreviewLocked="LadderShots.DOMShot",Map="TUT-DOM2")
     Tutorials(3)=(GameClass="xGame.xBombingRun",Preview="LadderShots.BRMoneyShot",PreviewLocked="LadderShots.BRShot",Map="TUT-BR")
     BorderMat=Texture'2K4Menus.Controls.sectionback'
     ShadowMat=Texture'2K4Menus.Controls.Shadow'
     StartTutorial="Click to play tutorial for"
     PanelCaption="Tutorial"
}

//==============================================================================
// Single Player loading screen (rewrite)
//
// Written by Michiel Hendriks
// (c) 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UT2K4SP_LadderLoading extends UT2K4LoadingPageBase;

var UT2K4GameProfile GP;
var UT2K4MatchInfo MI;
var UnrealTeamInfo ETI;
var array<xUtil.PlayerRecord> PlayerList;

var Material MapScreenshot;
var Material ImageFrame;

/** number of team mates, if any */
var int NumTeamMates;

/** The frame to use for the team leader */
var Material LeaderFrame;
/** The frame around all players */
var Material CharFrame;
/** the image to use for mystery players */
var Material MysteryPlayer;
var Color	White, Yellow, Blue, Red;

var localized string LoadingMessage;
var localized string StatNames[5];

/** local storage to calculate the team stats */
var array<string> TeamPlayers, EnemyPlayers;

simulated event init()
{
	local class<UnrealTeamInfo> ETIclass;

	GP = UT2K4GameProfile(Level.Game.CurrentGameProfile);
	if (GP != none) MI = UT2K4MatchInfo(GP.GetMatchInfo(GP.CurrentLadder, GP.CurrentMenuRung));
	if ((GP == none) || (MI == none))
	{
		Warn("GP =="@GP@", MI =="@MI);
		return;
	}

	MapScreenshot = Material(DynamicLoadObject(GP.ActiveMap.ScreenshotRef, class'Material', true));
	if (MaterialSequence(MapScreenshot) != none) MapScreenshot = MaterialSequence(MapScreenshot).SequenceItems[0].Material;

	AddBackground();
	AddMatchInfo();

	//Sark: The Master Control Program has chosen you to serve your system on the game grid.
	ETIclass = class<UnrealTeamInfo>(DynamicLoadObject(GP.EnemyTeam, class'Class'));
	ETI = spawn(ETIclass);

	if ( ETI == None )
	{
		Warn("ETI =="@ETI@ETIclass@GP.EnemyTeam);
		return;
	}
	NumTeamMates = GP.GetNumTeammatesForMatch();
	if (UT2K4DMRoster(ETI) != none)	UT2K4DMRoster(ETI).PreInitialize(MI.NumBots-NumTeamMates);
	else ETI.Initialize(MI.NumBots-NumTeamMates);

	class'xUtil'.static.GetPlayerList(PlayerList);

	if (NumTeamMates == 0)
	{
		AddPlayerCircle();
	}
	else {
		AddTeamInfo();
		AddEnemyInfo();
		AddTeamCompare();
	}
}

/**
	Add a backgroun image
*/
simulated function AddBackground()
{
	local Material Bg;
	Bg = MapScreenshot;
	if (Bg == none) Bg = DLOTexture("InterfaceContent.Backgrounds.bg10");
	if (Bg != None) AddImage(Bg, 0.0, 0.0, 1.0, 1.0).DrawColor=Class'Canvas'.static.MakeColor(196,196,0);
}

/**
	Add match info
*/
simulated function AddMatchInfo()
{
	local string Title;
	local DrawOpText tmp;
	AddImage(ImageFrame, 0.34, 0.299, 0.32, 0.402);
	AddImage(MapScreenshot, 0.35, 0.3, 0.3, 0.4);

	if ( MI.MenuName != "" ) Title = MI.MenuName;
	else {
		if (GP.ActiveMap.FriendlyName != "") Title = GP.ActiveMap.FriendlyName;
		else Title = GP.ActiveMap.MapName;
	}
	tmp = AddJustifiedText(Title, 1, 0.572, 0.302, 0.1, 0.4, 1);
	tmp.FontName = "GUI2K4.fntUT2k4Header";
	tmp.DrawColor = Class'Canvas'.static.MakeColor(0,0,0,196);
	tmp.bWrapText = false;
	tmp = AddJustifiedText(Title, 1, 0.57, 0.3, 0.1, 0.4, 1);
	tmp.bWrapText = false;
	tmp.FontName = "GUI2K4.fntUT2k4Header";

	tmp = AddJustifiedText(GP.GetMatchDescription(), 1, 0.332, 0.302, 0.1, 0.4, 1);
	tmp.FontName = "GUI2K4.fntUT2k4Header";
	tmp.DrawColor = Class'Canvas'.static.MakeColor(0,0,0,196);
	tmp.bWrapText = false;
	tmp = AddJustifiedText(GP.GetMatchDescription(), 1, 0.33, 0.3, 0.1, 0.4, 1);
	tmp.bWrapText = false;
	tmp.FontName = "GUI2K4.fntUT2k4Header";

	tmp = AddJustifiedText(LoadingMessage, 1, 0.452, 0.302, 0.1, 0.4, 1);
	tmp.FontName = "GUI2K4.fntUT2k4Header";
	tmp.DrawColor = Class'Canvas'.static.MakeColor(0,0,0,64);
	tmp.bWrapText = false;
	tmp = AddJustifiedText(LoadingMessage, 1, 0.452, 0.3, 0.1, 0.4, 1);
	tmp.FontName = "GUI2K4.fntUT2k4Header";
	tmp.DrawColor = Class'Canvas'.static.MakeColor(255,255,255,196);
	tmp.bWrapText = false;
}

/**
	Draw the player portaits in a circle (square)
*/
simulated function AddPlayerCircle()
{
	local int i;
	local float dist, cX, cY, cR, imgW, imgH, bX, bY;
	local float oX, oY;
	local Material Portrait;

	dist = 2 * Pi / (MI.NumBots+1);

	cX = 0.5;
	cY = 0.5;
	cR = 0.03;
	imgW = 0.11;
	imgH = 0.3;
	// border
	bX = (imgH/2)+cR;
	bY = (imgW/2)+cR*(4/3);

	// draw ourself
	Portrait = getPlayerPortrait(GP.PlayerCharacter);
	AddImage(Portrait, cR, cY-(imgW/2), imgH, imgW);
	AddImage(CharFrame, cR, cY-(imgW/2), imgH, imgW);
	// draw the rest
	for (i = 0; i < MI.NumBots; i++)
	{
		if (i > ETI.Roster.length) Portrait = MysteryPlayer;
			else Portrait = getPlayerPortrait(ETI.Roster[i].PlayerName);
		// I'm going to burn in hell
		oX = sin( -1*(i+1)*dist+(Pi/2) );
		oX = fclamp(cX-oX, 0+bX, 1-bX);
		oY = cos( -1*(i+1)*dist+(Pi/2) );
		oY = fclamp(cY-oY, 0+bY, 1-bY);
		AddImage(Portrait, oX-(imgH/2), oY-(imgW/2), imgH, imgW);
		AddImage(CharFrame, oX-(imgH/2), oY-(imgW/2), imgH, imgW);
	}
}

/**
	Add own team symbol and players
*/
simulated function AddTeamInfo()
{
	local int i, numplayers;

	TeamPlayers[0] = GP.PlayerCharacter;
	numplayers = MI.NumBots / 2;  // purposeful integer truncate on odd number of bots
	for (i = 0; i<numplayers; i++)
	{
		TeamPlayers[i+1] = GP.PlayerTeam[GP.PlayerLineup[i]];
	}

	AddTeamBar(0, GP.TeamSymbolName, TeamPlayers, 0.03, class'Canvas'.static.MakeColor(64, 64, 255));
}

/**
	Add enemy team symbol and player
*/
simulated function AddEnemyInfo()
{
	local int i, numplayers;

	numplayers = MI.NumBots /2;
	if ( MI.NumBots % 2 == 1 )
	{
		numplayers++;  // bot team get the extra player
	}
	ETI.Initialize(numplayers);
	for (i = 0; i < numplayers; i++)
	{
		EnemyPlayers[i] = ETI.Roster[i].PlayerName;
	}
	AddTeamBar(1, ETI.TeamSymbolName, EnemyPlayers, 0.7, class'Canvas'.static.MakeColor(255, 0, 0), true);
}

/** The actual drawing of the team info */
simulated function AddTeamBar(int TeamId, string TeamIconName, out array<string> Crew, float top, Color TeamColor, optional bool bNameUp)
{
	local Material TSym, Portrait;
	local float ILeft, ISpace, ImgW, ImgH, IconBoxW, IconBoxH;
	local int i;
	local DrawOpImage dop;

	// Part 1: Get The Team Symbol
	TSym = DLOTexture(TeamIconName);

	// Precompute a couple of sizes
	ImgW = 0.1;
	ImgH = 0.275;
	ISpace = 0.03 + (7-Crew.Length) * 0.01;
	IconBoxW = 0.3;
	IconBoxH = 0.4;

	// Figure out where we will start adding them
	ILeft = (1.0 - (Crew.Length * (ImgW + ISpace) - ISpace)) / 2.0;

	TeamColor.A = 70;

	if (TeamId == 0)
		dop = AddImage(TSym, 0.01, 0.01, IconBoxH, IconBoxW);
	else
		dop = AddImage(TSym, 0.99 - IconBoxH, 0.99 - IconBoxW, IconBoxH, IconBoxW);
	dop.DrawColor = TeamColor;
	dop.RenderStyle = 5; // Alpha

	TeamColor.A = 255;

	// Add Crew Portraits
	for (i=0; i<Crew.Length; i++)
	{
		//Log("Crew member "$Crew[i]$" is "$i$" of "$Crew.Length);
		Portrait = getPlayerPortrait(Crew[i]);
		AddImage(Portrait, top, ILeft, ImgH, ImgW);
		if (i == 0) AddImage(LeaderFrame, top, ILeft, ImgH, ImgW);
			else AddImage(CharFrame, top, ILeft, ImgH, ImgW);
		ILeft = ILeft + ImgW + ISpace;
	}

}

/** Team stats */
simulated function AddTeamCompare()
{
	local array<int> Team1Stat, Team2Stat;
	local string TxtFont, SmallTxtFont, tmp;
	local float TopLine, LineSpc;
	local int i;
	local DrawOpText	Op;

	Team1Stat[0] = class'xUtil'.static.TeamArrayAccuracyRating(TeamPlayers);
	Team1Stat[1] = class'xUtil'.static.TeamArrayAggressivenessRating(TeamPlayers);
	Team1Stat[2] = class'xUtil'.static.TeamArrayAgilityRating(TeamPlayers);
	Team1Stat[3] = class'xUtil'.static.TeamArrayTacticsRating(TeamPlayers);

	Team2Stat[0] = class'xUtil'.static.TeamArrayAccuracyRating(EnemyPlayers);
	Team2Stat[1] = class'xUtil'.static.TeamArrayAggressivenessRating(EnemyPlayers);
	Team2Stat[2] = class'xUtil'.static.TeamArrayAgilityRating(EnemyPlayers);
	Team2Stat[3] = class'xUtil'.static.TeamArrayTacticsRating(EnemyPlayers);

	TopLine = 0.32;
	LineSpc = 0.425/6;
	TxtFont = "XInterface.UT2HeaderFont";
	SmallTxtFont = "GUI2K4.fntUT2K4Medium"; //fntUT2k4MidGame";

	Op = AddJustifiedText(GP.TeamName, 2, TopLine, 0.05, LineSpc, 0.23, 1);
	Op.FontName = TxtFont;
	Op.DrawColor = Blue;

	Op = AddJustifiedText(ETI.TeamName, 0, TopLine, 0.72, LineSpc, 0.23, 1);
	Op.FontName = TxtFont;
	Op.DrawColor = Red;

	for (i = 1; i<5; i++)
	{
		TopLine += LineSpc;
		AddJustifiedText(StatNames[i], 1, TopLine, 0.0, LineSpc, 0.2, 1).FontName = SmallTxtFont;	// Centered
		AddJustifiedText(StatNames[i], 1, TopLine, 0.80, LineSpc, 0.2, 1).FontName = SmallTxtFont;	// Centered

		tmp = string(Team1Stat[i-1]);
		tmp $= "%";
		Op = AddJustifiedText(tmp, 2, TopLine, 0.05, LineSpc, 0.23, 1);
		Op.FontName = TxtFont;
		if (Team1Stat[i-1] >= Team2Stat[i-1])
			Op.DrawColor = Yellow;

		tmp = string(Team2Stat[i-1]);
		tmp $= "%";
		Op = AddJustifiedText(tmp, 0, TopLine, 0.72, LineSpc, 0.23, 1);
		Op.FontName = TxtFont;
		if (Team2Stat[i-1] >= Team1Stat[i-1])
			Op.DrawColor = Yellow;
	}
}

simulated function Material getPlayerPortrait(string playerName)
{
	local int i;

	for ( i=0; i < PlayerList.length; i++ ) {
		if ( PlayerList[i].DefaultName == playername ) {
			return PlayerList[i].Portrait;
		}
	}
	return none;
}

defaultproperties
{
     ImageFrame=Texture'2K4Menus.Controls.sectionback'
     LeaderFrame=FinalBlend'InterfaceContent.Menu.CharFrame_Final'
     CharFrame=FinalBlend'InterfaceContent.Menu.CharFrame_Final'
     MysteryPlayer=Texture'PlayerPictures.cDefault'
     White=(B=255,G=255,R=255,A=255)
     Yellow=(G=255,R=255,A=255)
     Blue=(B=255,G=64,R=64,A=255)
     Red=(R=255,A=255)
     LoadingMessage="loading"
     StatNames(0)="VS"
     StatNames(1)="Accuracy"
     StatNames(2)="Aggressiveness"
     StatNames(3)="Agility"
     StatNames(4)="Tactics"
}

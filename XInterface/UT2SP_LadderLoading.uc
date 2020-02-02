class UT2SP_LadderLoading extends UT2LoadingPageBase;

#exec OBJ LOAD FILE=InterfaceContent.utx

var UT2003GameProfile GameProf;
var MatchInfo myMatchInfo;
var UnrealTeamInfo EnemyTeamInfo;
	
var Color	White, Yellow, Blue, Red;
var Material Box, CharFrame;
var array<xUtil.PlayerRecord> PlayerList;
var localized string StatNames[5];
var localized string LoadingMessage;

// initialize data structures, then call each of the render functions in turn
simulated event init()
{
	local class<UnrealTeamInfo> UTIclass;

	GameProf = UT2003GameProfile(Level.Game.CurrentGameProfile);

	AddBackground();			// Background is the Map Faded FullScreen Shot.

	if ( GameProf == None || GameProf.bInLadderGame == false ) {
		Log("UT2SP_LadderLoading::init() could not find GameProfile or not in a ladder game.");
		AddLoading();				// adds loading screen
		return;
	}

	myMatchInfo = GameProf.GetMatchInfo(GameProf.CurrentLadder, GameProf.CurrentMenuRung);

	if ( myMatchInfo == None ) {
		Log("UT2SP_LadderLoading::init() could not find MatchInfo.");
		AddLoading();				// adds loading screen
		return;
	}

	UTIclass = class<UnrealTeamInfo>(DynamicLoadObject(myMatchInfo.EnemyTeamName,class'Class'));
	EnemyTeamInfo = spawn(UTIClass);

	if ( EnemyTeamInfo == None ) {
		Log("UT2SP_LadderLoading::init() could not find Enemy UnrealTeamInfo data.");
		AddLoading();				// adds loading screen
		return;
	}

	// PreLoad the Player List so we can access Player Portraits
	class'xUtil'.static.GetPlayerList(PlayerList);

	AddTitle();					// Title would be the Ladder type (or GameType).
	AddPlayerRoster();			 
	AddOpponentRoster();
	AddTeamCompare();	
}

simulated function AddLoading()
{
	AddJustifiedText(LoadingMessage, 1, 0.0, 0.0, 1.0, 1.0).FontName = "XInterface.UT2LargeFont";
}

// Todo: Get Background Texture from GameProfile ?
simulated function AddBackground()
{
local Material Tex;

	Tex = DLOTexture("InterfaceContent.Backgrounds.bg10");

	// Fallback texture .. should we choose another one ?
	if (Tex == None)
		Tex = DLOTexture("InterfaceContent.Backgrounds.bg11");

	if (Tex != None)
		AddImage(Tex, 0.0, 0.0, 1.0, 1.0).DrawColor=Class'Canvas'.static.MakeColor(128,128,192);
}


simulated function AddTitle()
{
	local string Title;
	local class<GameInfo> GIClass;

	GIClass = class<GameInfo>(DynamicLoadObject(myMatchInfo.GameType, class'Class'));
	Title = LoadingMessage@GIClass.default.GameName;
	AddJustifiedText(Title, 1, 0.0, 0.0, 0.075, 1.0).FontName = "XInterface.UT2LargeFont";
}

simulated function AddPlayerRoster()
{
local int i, numplayers;
local array<string>	Players;

	Players[0] = GameProf.PlayerCharacter;

	numplayers = myMatchInfo.NumBots / 2;  // purposeful integer truncate on odd number of bots
	for (i = 0; i<numplayers; i++) 
	{
		Players[i+1] = GameProf.PlayerTeam[GameProf.PlayerLineup[i]];
	}

	AddTeamBar(0, GameProf.TeamSymbolName, Players, 0.095, class'Canvas'.static.MakeColor(64, 64, 255));
}

simulated function AddOpponentRoster()
{
local int i, numplayers;
local array<string>	Players;

	numplayers = myMatchInfo.NumBots /2;
	if ( myMatchInfo.NumBots % 2 == 1 ) 
	{
		numplayers++;  // bot team get the extra player
	}

	for (i = 0; i<numplayers; i++) 
	{
		Players[i] = EnemyTeamInfo.RosterNames[i];
	}

	AddTeamBar(1, EnemyTeamInfo.TeamSymbolName, Players, 0.75, class'Canvas'.static.MakeColor(255, 0, 0), true);
}

simulated function AddTeamBar(int TeamId, string TeamIconName, out array<string> Crew, float top, Color TeamColor, optional bool bNameUp)
{
local Material TSym, Portrait;
local float ILeft, ISpace, ImgW, ImgH, IconBoxW, IconBoxH, IconBox2Left;
local int i;
//local DrawOpImage	Opi;

	// Part 1: Get The Team Symbol
	TSym = DLOTexture(TeamIconName);

	// Precompute a couple of sizes
	ImgW = 0.075;
	ImgH = 0.2;
	ISpace = 0.03 + (7-Crew.Length) * 0.01;
	IconBoxW = ImgW * 2;
	IconBoxH = ImgH;
	IconBox2Left = 0.98 - IconBoxW;

	// Figure out where we will start adding them
	ILeft = (1.0 - (Crew.Length * (ImgW + ISpace) - ISpace)) / 2.0;

	TeamColor.A = 70;
	// Add Team Logos, only if not straight deathmatch
	if (myMatchInfo.GameType != "xGame.xDeathmatch") {
		if (TeamId == 0)
			AddImage(TSym, top, 0.02, IconBoxH * 2, IconBoxW * 2).DrawColor = TeamColor;
		else
			AddImage(TSym, top - IconBoxH, IconBox2Left - IconBoxW, IconBoxH * 2, IconBoxW * 2).DrawColor = TeamColor;
	}

	TeamColor.A = 255;

	// Add Crew Portraits
	for (i=0; i<Crew.Length; i++)
	{
		//Log("Crew member "$Crew[i]$" is "$i$" of "$Crew.Length);
		Portrait = FindPlayerInPlayerList(Crew[i]).Portrait;
		AddImage(Portrait, top, ILeft, ImgH, ImgW);
		AddImage(CharFrame, top, ILeft, ImgH, ImgW);
		ILeft = ILeft + ImgW + ISpace;
	}

}

simulated function AddTeamCompare()
{
local array<int> Team1Stat, Team2Stat;
local string TxtFont, tmp;
local float TopLine, LineSpc;
local int i;
local DrawOpText	Op;

	Team1Stat[0] = class'xUtil'.static.TeamAccuracyRating(GameProf);
	Team1Stat[1] = class'xUtil'.static.TeamAggressivenessRating(GameProf);
	Team1Stat[2] = class'xUtil'.static.TeamAgilityRating(GameProf);
	Team1Stat[3] = class'xUtil'.static.TeamTacticsRating(GameProf);

	Team2Stat[0] = class'xUtil'.static.TeamInfoAccuracyRating(EnemyTeamInfo);
	Team2Stat[1] = class'xUtil'.static.TeamInfoAggressivenessRating(EnemyTeamInfo);
	Team2Stat[2] = class'xUtil'.static.TeamInfoAgilityRating(EnemyTeamInfo);
	Team2Stat[3] = class'xUtil'.static.TeamInfoTacticsRating(EnemyTeamInfo);

	TopLine = 0.34;
	LineSpc = 0.425/6;
	TxtFont = "XInterface.UT2HeaderFont";

	Op = AddJustifiedText(StatNames[0], 1, TopLine, 0, LineSpc, 1.0);
	Op.FontName = "XInterface.UT2HeaderFont";  
	Op.DrawColor = Yellow;

	Op = AddJustifiedText(GameProf.TeamName, 1, TopLine, 0.05, LineSpc, 0.40);
	Op.FontName = "Xinterface.UT2HeaderFont";
	Op.DrawColor = Blue;

	Op = AddJustifiedText(EnemyTeamInfo.TeamName, 1, TopLine, 0.55, LineSpc, 0.40);
	Op.FontName = "Xinterface.UT2HeaderFont";
	Op.DrawColor = Red;

	for (i = 1; i<5; i++)
	{
		TopLine += LineSpc;
		AddJustifiedText(StatNames[i], 1, TopLine, 0, LineSpc, 1.0).FontName = "XInterface.UT2HeaderFont";	// Centered
		
		tmp = string(Team1Stat[i-1]);
		tmp = tmp$"%";
		Op = AddJustifiedText(tmp, 1, TopLine, 0.10, LineSpc, 0.30);
		Op.FontName = "Xinterface.UT2HeaderFont";
		if (Team1Stat[i-1] >= Team2Stat[i-1])
			Op.DrawColor = Yellow;

		tmp = string(Team2Stat[i-1]);
		tmp = tmp$"%";
		Op = AddJustifiedText(tmp, 1, TopLine, 0.6, LineSpc, 0.30);
		Op.FontName = "Xinterface.UT2HeaderFont";
		if (Team2Stat[i-1] >= Team1Stat[i-1])
			Op.DrawColor = Yellow;
	}
}

simulated function xUtil.PlayerRecord FindPlayerInPlayerList(string playername) {
	local xUtil.PlayerRecord retval;
	local int i;

	for ( i=0; i< PlayerList.length; i++ ) {
		if ( PlayerList[i].DefaultName == playername ) {
			return PlayerList[i];
		}
	}
	return retval;
}

defaultproperties
{
     White=(B=255,G=255,R=255,A=255)
     Yellow=(G=255,R=255,A=255)
     Blue=(B=255,G=64,R=64,A=255)
     Red=(R=255,A=255)
     Box=Texture'InterfaceContent.Menu.BorderBoxD'
     CharFrame=FinalBlend'InterfaceContent.Menu.CharFrame_Final'
     StatNames(0)="VS"
     StatNames(1)="Accuracy"
     StatNames(2)="Aggressiveness"
     StatNames(3)="Agility"
     StatNames(4)="Tactics"
     LoadingMessage="Loading..."
}

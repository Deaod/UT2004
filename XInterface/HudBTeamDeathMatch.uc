class HudBTeamDeathMatch extends HudBDeathMatch;

var() NumericWidget ScoreTeam[2];
var() NumericWidget totalLinks;

var() NumericWidget Score;

var() SpriteWidget LTeamHud[3];
var() SpriteWidget RTeamHud[3];

var() SpriteWidget TeamSymbols[2];
var() int		Links;

var() Color CarrierTextColor1;
var() Color CarrierTextColor2;
var() Color CarrierTextColor3;
var() String CarriersName, CarriersLocation;
var() float CNPosX, CNPosY;

var localized string LinkEstablishedMessage;

simulated function DrawSpectatingHud (Canvas C)
{
	Super.DrawSpectatingHud(C);

	if ( (PlayerOwner == None) || (PlayerOwner.PlayerReplicationInfo == None)
		|| !PlayerOwner.PlayerReplicationInfo.bOnlySpectator )
		return;

	UpdateRankAndSpread(C);
	ShowTeamScorePassA(C);
	ShowTeamScorePassC(C);
	UpdateTeamHUD();
}

simulated function Tick(float deltaTime)
{
	Super.Tick(deltaTime);

	if (Links >0)
	{
		TeamLinked = true;
		pulseWidget(deltaTime, 255, 0, RHud2[3], TeamIndex, 1, 2000);
	}
	else
	{
		TeamLinked = false;
		RHud2[3].Tints[TeamIndex].A = 255;
	}
}

simulated function showLinks()
{
	local Inventory Inv;
	Inv = PawnOwner.FindInventoryType(class'LinkGun');

    if (Inv != None)
		Links = LinkGun(Inv).Links;
	else
		Links = 0;
}

simulated function drawLinkText(Canvas C)
{
	text = LinkEstablishedMessage;

	C.Font = LoadLevelActionFont();
	C.DrawColor = LevelActionFontColor;

	C.DrawColor = LevelActionFontColor;
	C.Style = ERenderStyle.STY_Alpha;

	C.DrawScreenText (text, 1, 0.81, DP_LowerRight);
}

simulated function UpdateRankAndSpread(Canvas C)
{
	// making sure that the Rank and Spread dont get drawn in other gametypes
}

simulated function DrawHudPassA (Canvas C)
{
    Super.DrawHudPassA (C);
	UpdateRankAndSpread(C);
	ShowTeamScorePassA(C);
	if( bShowWeaponInfo )
	{
		if (Links >0)
	        DrawNumericWidget (C, totalLinks, DigitsBig);
		totalLinks.value = Links;
	}
}

simulated function ShowTeamScorePassA(Canvas C)
{
	if ( bShowPoints )
	{
    	DrawSpriteWidget (C, LTeamHud[2]);
		DrawSpriteWidget (C, LTeamHud[1]);
		DrawSpriteWidget (C, LTeamHud[0]);

		DrawSpriteWidget (C, RTeamHud[2]);
		DrawSpriteWidget (C, RTeamHud[1]);
		DrawSpriteWidget (C, RTeamHud[0]);
	}
}

simulated function ShowTeamScorePassC(Canvas C)
{
	if ( bShowPoints )
	{
		if (TeamSymbols[0].WidgetTexture != None)
			DrawSpriteWidget (C, TeamSymbols[0]);

		if (TeamSymbols[1].WidgetTexture != None)
			DrawSpriteWidget (C, TeamSymbols[1]);

	    TeamScoreOffset();

		DrawNumericWidget (C, ScoreTeam[0], DigitsBig);
		DrawNumericWidget (C, ScoreTeam[1], DigitsBig);
	}
}

simulated function TeamScoreOffset()
{
	ScoreTeam[1].OffsetX = 80;
	if ( ScoreTeam[1].Value < 0 )
		ScoreTeam[1].OffsetX += 90;
	if( abs(ScoreTeam[1].Value) > 9 )
		ScoreTeam[1].OffsetX += 90;
}

simulated function ShowPersonalScore(Canvas C)
{
    DrawNumericWidget (C, Score, DigitsBig);
}
// Alpha Pass ==================================================================================
simulated function DrawHudPassC (Canvas C)
{
    Super.DrawHudPassC (C);

	if (Links >0)
		drawLinkText(C);

    if( bShowPoints )
        ShowPersonalScore(C);
	ShowTeamScorePassC(C);
}

// Alternate Texture Pass ======================================================================

simulated function UpdateTeamHud()
{
    local GameReplicationInfo GRI;
    local int i;

    Score.Value = Min (CurScore, 999);		// drawing limitation

	GRI = PlayerOwner.GameReplicationInfo;

	if (GRI == None)
        return;

    for (i = 0; i < 2; i++)
    {
        if (GRI.Teams[i] == None)
            continue;

        ScoreTeam[i].Value = Min (GRI.Teams[i].Score, 999);  // max space in hud

        if (GRI.TeamSymbols[i] != None)
			TeamSymbols[i].WidgetTexture = GRI.TeamSymbols [i];
    }
}

simulated function UpdateHud()
{
	UpdateTeamHUD();
	showLinks();
    Super.UpdateHud();
}

defaultproperties
{
     ScoreTeam(0)=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.240000,DrawPivot=DP_MiddleRight,PosX=0.500000,PosY=0.010000,OffsetX=-150,OffsetY=80,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ScoreTeam(1)=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.240000,DrawPivot=DP_MiddleLeft,PosX=0.500000,PosY=0.010000,OffsetX=120,OffsetY=80,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     totalLinks=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.200000,DrawPivot=DP_MiddleRight,PosX=1.000000,PosY=0.835000,OffsetX=-30,OffsetY=90,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Score=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.180000,DrawPivot=DP_UpperRight,OffsetX=560,OffsetY=40,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     LTeamHud(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=979,Y1=900,X2=611,Y2=1023),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=0.500000,PosY=0.010000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     LTeamHud(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=979,Y1=777,X2=611,Y2=899),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=0.500000,PosY=0.010000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     LTeamHud(2)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=979,Y1=654,X2=611,Y2=776),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=0.500000,PosY=0.010000,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     RTeamHud(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=611,Y1=900,X2=979,Y2=1023),TextureScale=0.300000,PosX=0.500000,PosY=0.010000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=200),Tints[1]=(G=255,R=255,A=200))
     RTeamHud(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=611,Y1=777,X2=979,Y2=899),TextureScale=0.300000,PosX=0.500000,PosY=0.010000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     RTeamHud(2)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=611,Y1=654,X2=979,Y2=776),TextureScale=0.300000,PosX=0.500000,PosY=0.010000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     TeamSymbols(0)=(RenderStyle=STY_Alpha,TextureCoords=(X2=256,Y2=256),TextureScale=0.100000,DrawPivot=DP_UpperRight,PosX=0.500000,PosY=0.010000,OffsetX=-60,OffsetY=60,Tints[0]=(B=100,G=100,R=255,A=200),Tints[1]=(B=32,G=32,R=255,A=200))
     TeamSymbols(1)=(RenderStyle=STY_Alpha,TextureCoords=(X2=256,Y2=256),TextureScale=0.100000,PosX=0.500000,PosY=0.010000,OffsetX=90,OffsetY=60,Tints[0]=(B=255,G=128,A=200),Tints[1]=(B=255,G=210,R=32,A=200))
     CarrierTextColor1=(G=255,R=255,A=255)
     CarrierTextColor2=(G=255,A=255)
     CarrierTextColor3=(B=200,G=200,R=200,A=255)
     CNPosX=0.010000
     CNPosY=0.010000
     LinkEstablishedMessage="LINK ESTABLISHED"
}

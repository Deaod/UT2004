class HudCTeamDeathMatch extends HudCDeathMatch;

var() NumericWidget ScoreTeam[2];
var() NumericWidget totalLinks;

var() SpriteWidget  VersusSymbol;
var() SpriteWidget  TeamScoreBackGround[2];
var() SpriteWidget  TeamScoreBackGroundDisc[2];
var() SpriteWidget  LinkIcon;
var() SpriteWidget  TeamSymbols[2];
var() int Links;

// Team Colors
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
	}
	else
	{
		TeamLinked = false;
	}
}

simulated function showLinks()
{
	//local Inventory Inv;
	//Inv = PawnOwner.FindInventoryType(class'LinkGun');

    //if (Inv != None)
	//	Links = LinkGun(Inv).Links;
	if ( PawnOwner.Weapon != None && PawnOwner.Weapon.IsA('LinkGun') )
		Links = LinkGun(PawnOwner.Weapon).Links;
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

simulated function DrawTeamOverlay( Canvas C )
{
     // TODO: draw top 5 playersnames and Position on map
}

simulated function DrawMyScore ( Canvas C )
{
     // Dont show MyScore in team games
}
simulated function DrawHudPassA (Canvas C)
{
    Super.DrawHudPassA (C);
	UpdateRankAndSpread(C);
	ShowTeamScorePassA(C);

	if ( Links >0 )
	{
		DrawSpriteWidget (C, LinkIcon);
	    DrawNumericWidget (C, totalLinks, DigitsBigPulse);
	}
	totalLinks.value = Links;
}

simulated function ShowTeamScorePassA(Canvas C)
{
	if ( bShowPoints )
	{
		DrawSpriteWidget (C, TeamScoreBackground[0]);
		DrawSpriteWidget (C, TeamScoreBackground[1]);
		DrawSpriteWidget (C, TeamScoreBackgroundDisc[0]);
		DrawSpriteWidget (C, TeamScoreBackgroundDisc[1]);

        TeamScoreBackground[0].Tints[TeamIndex] = HudColorBlack;
        TeamScoreBackground[0].Tints[TeamIndex].A = 150;
        TeamScoreBackground[1].Tints[TeamIndex] = HudColorBlack;
        TeamScoreBackground[1].Tints[TeamIndex].A = 150;


		if (TeamSymbols[0].WidgetTexture != None)
			DrawSpriteWidget (C, TeamSymbols[0]);

		if (TeamSymbols[1].WidgetTexture != None)
			DrawSpriteWidget (C, TeamSymbols[1]);

        ShowVersusIcon(C);
	 	DrawNumericWidget (C, ScoreTeam[0], DigitsBig);
		DrawNumericWidget (C, ScoreTeam[1], DigitsBig);
	}
}

simulated function ShowVersusIcon(Canvas C)
{
	DrawSpriteWidget (C, VersusSymbol );
}

simulated function ShowTeamScorePassC(Canvas C);
simulated function TeamScoreOffset();

// Alpha Pass ==================================================================================
simulated function DrawHudPassC (Canvas C)
{
    Super.DrawHudPassC (C);
	ShowTeamScorePassC(C);
}

// Alternate Texture Pass ======================================================================

simulated function UpdateTeamHud()
{
    local GameReplicationInfo GRI;
    local int i;

	GRI = PlayerOwner.GameReplicationInfo;

	if (GRI == None)
        return;

    for (i = 0; i < 2; i++)
    {
        if (GRI.Teams[i] == None)
            continue;

		TeamSymbols[i].Tints[i] = HudColorTeam[i];
        ScoreTeam[i].Value =  Min(GRI.Teams[i].Score, 999);  // max space in hud

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

function bool CustomHUDColorAllowed()
{
	return false;
}

defaultproperties
{
     ScoreTeam(0)=(RenderStyle=STY_Alpha,MinDigitCount=1,TextureScale=0.540000,DrawPivot=DP_MiddleRight,PosX=0.500000,OffsetX=-90,OffsetY=32,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ScoreTeam(1)=(RenderStyle=STY_Alpha,MinDigitCount=1,TextureScale=0.540000,DrawPivot=DP_MiddleLeft,PosX=0.500000,OffsetX=90,OffsetY=32,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     totalLinks=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.750000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=0.835000,OffsetX=-65,OffsetY=48,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VersusSymbol=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=435,X2=508,Y2=31),TextureScale=0.400000,DrawPivot=DP_UpperMiddle,PosX=0.500000,OffsetY=30,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TeamScoreBackGround(0)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=168,Y1=211,X2=334,Y2=255),TextureScale=0.530000,DrawPivot=DP_UpperRight,PosX=0.500000,OffsetX=-50,OffsetY=10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TeamScoreBackGround(1)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=168,Y1=211,X2=334,Y2=255),TextureScale=0.530000,PosX=0.500000,OffsetX=50,OffsetY=10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TeamScoreBackGroundDisc(0)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.530000,DrawPivot=DP_UpperRight,PosX=0.500000,OffsetX=-35,OffsetY=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TeamScoreBackGroundDisc(1)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.530000,PosX=0.500000,OffsetX=35,OffsetY=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     LinkIcon=(WidgetTexture=FinalBlend'HUDContent.Generic.fbLinks',RenderStyle=STY_Alpha,TextureCoords=(X2=127,Y2=63),TextureScale=0.800000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,OffsetX=5,OffsetY=-40,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TeamSymbols(0)=(RenderStyle=STY_Alpha,TextureCoords=(X2=256,Y2=256),TextureScale=0.100000,DrawPivot=DP_UpperRight,PosX=0.500000,OffsetX=-200,OffsetY=45,Tints[0]=(B=100,G=100,R=255,A=200),Tints[1]=(B=32,G=32,R=255,A=200))
     TeamSymbols(1)=(RenderStyle=STY_Alpha,TextureCoords=(X2=256,Y2=256),TextureScale=0.100000,PosX=0.500000,OffsetX=200,OffsetY=45,Tints[0]=(B=255,G=128,A=200),Tints[1]=(B=255,G=210,R=32,A=200))
     CarrierTextColor1=(G=255,R=255,A=255)
     CarrierTextColor2=(G=255,A=255)
     CarrierTextColor3=(B=200,G=200,R=200,A=255)
     CNPosX=0.010000
     CNPosY=0.010000
     LinkEstablishedMessage="LINK ESTABLISHED"
}

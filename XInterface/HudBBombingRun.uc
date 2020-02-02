class HudBBombingRun extends HudBTeamDeathMatch;

struct FBombWidget
{
    var EFlagState BombState;
    var SpriteWidget Widgets[4];
};

var() SpriteWidget BombBG;
var() FBombWidget BombWidget;
var() Sound PassTargetLocked;

#exec OBJ LOAD File=IndoorAmbience.uax

var transient xBombFlag BombFlag;
var transient xBombDelivery MyBombDelivery;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
    SetTimer(1.0, True);
}

simulated function TeamScoreOffset()
{
	ScoreTeam[1].OffsetX = 120;
	if ( ScoreTeam[1].Value < 0 )
		ScoreTeam[1].OffsetX += 90;
	if( abs(ScoreTeam[1].Value) > 9 )
		ScoreTeam[1].OffsetX += 90;
}

simulated function ShowPointBarBottom(Canvas C)
{
}
simulated function ShowPointBarTop(Canvas C)
{
}
simulated function ShowPersonalScore(Canvas C)
{
}

// Alpha Pass ==================================================================================
simulated function ShowTeamScorePassA(Canvas C)
{
	local vector Pos;

	Super.ShowTeamScorePassA(C);

	LTeamHud[0].OffsetX=-40;
	LTeamHud[1].OffsetX=-40;
	LTeamHud[2].OffsetX=-40;

	RTeamHud[0].OffsetX=40;
	RTeamHud[1].OffsetX=40;
	RTeamHud[2].OffsetX=40;

	TeamSymbols[0].OffsetX = -290;
	TeamSymbols[1].OffsetX = 290;

	TeamSymbols[0].OffsetY = 80;
	TeamSymbols[1].OffsetY = 80;

	TeamSymbols[0].TextureScale = 0.09;
	TeamSymbols[1].TextureScale = 0.09;

	ScoreTeam[0].OffsetX = -200;
	ScoreTeam[1].OffsetX = 120;

	DrawSpriteWidget (C, BombBG);
    DrawSpriteWidget (C, BombWidget.Widgets[BombWidget.BombState]);

	if ( BombFlag == None )
		ForEach DynamicActors(Class'xBombFlag', BombFlag)
			break;

	if ( (PawnOwner != None) && (BallLauncher(PawnOwner.Weapon) != None) )
	{
		if ( (MyBombDelivery == None) || (MyBombDelivery.Team == PlayerOwner.PlayerReplicationInfo.Team.TeamIndex)  )
			ForEach DynamicActors(Class'xBombDelivery', MyBombDelivery)
				if ( MyBombDelivery.Team != PlayerOwner.PlayerReplicationInfo.Team.TeamIndex )
					break;
		if ( MyBombDelivery == None )
			return;
		Pos = MyBombDelivery.Location;
	}
	else if ( BombFlag != None )
	{
		if ( Pawn(BombFlag.Base) != None )
			Pos = BombFlag.Base.Location;
		else
			Pos = BombFlag.Location;
	}
	else if ( PlayerOwner.GameReplicationInfo != None )
		Pos = PlayerOwner.GameReplicationInfo.FlagPos;
	C.DrawColor = GoldColor;
	Draw2DLocationDot(C, Pos, 0.5 - 0.0075*HUDScale, 0.044*HUDScale, 0.034*HUDScale, 0.046*HUDScale);
}

function Timer()
{
	Super.Timer();

    if ( PawnOwnerPRI == None )
        return;

    // offsets returned in Y can be the same for xBombHUDMessage
    if ( BombFlag != None && BombFlag.HolderPRI != None && BombFlag.HolderPRI.Team != PawnOwnerPRI.Team)
        PlayerOwner.ReceiveLocalizedMessage( class'xBombHUDMessage', 1 );
    else if ( PawnOwnerPRI.HasFlag != None )
		PlayerOwner.ReceiveLocalizedMessage( class'xBombHUDMessage', 0 );
}

simulated function UpdateTeamHud()
{
	local GameReplicationInfo GRI;
	local int i;
    local int TeamOffset;
    local int Index;

	if ((PawnOwnerPRI != none) && (PawnOwnerPRI.Team != None))
        TeamOffset = Clamp (PawnOwnerPRI.Team.TeamIndex, 0, 1);
    else
        TeamOffset = 0;

	GRI = PlayerOwner.GameReplicationInfo;

	if (GRI == None)
        return;

    for (i = 0; i < 2; i++)
    {
        if (GRI.Teams[i] == None)
            continue;

        Index = (i + TeamOffset) % ArrayCount(ScoreTeam);

        ScoreTeam[Index].Value = Min (GRI.Teams[i].Score, 999);  // max display capability

        if (GRI.TeamSymbols[i] == None)
            continue;

        TeamSymbols[Index].WidgetTexture = GRI.TeamSymbols[i];
    }

	if ( PlayerOwner.PlayerReplicationInfo.Team == None )
		BombWidget.BombState = GRI.FlagState[0];
	else
		BombWidget.BombState = GRI.FlagState[PlayerOwner.PlayerReplicationInfo.Team.TeamIndex];
	Super.UpdateTeamHUD();
}

defaultproperties
{
     BombBG=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.350000,DrawPivot=DP_UpperMiddle,PosX=0.500000,PosY=0.010000,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BombWidget=(Widgets[0]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=624,Y1=538,X2=728,Y2=655),TextureScale=0.300000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.008500,OffsetY=70,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)),Widgets[1]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=744,Y1=538,X2=848,Y2=655),TextureScale=0.300000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.008500,OffsetY=70,Scale=1.000000,Tints[0]=(B=60,G=60,R=255,A=255),Tints[1]=(B=255,G=205,R=100,A=255)),Widgets[2]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=744,Y1=538,X2=848,Y2=655),TextureScale=0.300000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.008500,OffsetY=70,Scale=1.000000,Tints[0]=(B=255,G=205,R=100,A=255),Tints[1]=(B=60,G=60,R=255,A=255)),Widgets[3]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=624,Y1=538,X2=728,Y2=655),TextureScale=0.300000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.008500,OffsetY=70,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)))
}

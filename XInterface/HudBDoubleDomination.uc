class HudBDoubleDomination extends HudBTeamDeathMatch;

enum EPointState
{
    PS_Neutral,
    PS_HeldFriendly,
    PS_HeldEnemy,
    PS_Disabled,
};

struct FPointWidget
{
    var EPointState PointState;
    var SpriteWidget Widgets[4];
};
var() SpriteWidget SymbolGB[2];
var() FPointWidget Points[2];

var transient xDomPoint DP1;
var transient xDomPoint DP2;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0, True);
}

// Alpha Pass ==================================================================================
simulated function ShowTeamScorePassA(Canvas C)
{
    Super.ShowTeamScorePassA(C);
	DrawSpriteWidget (C, SymbolGB[0]);
	DrawSpriteWidget (C, SymbolGB[1]);

	LTeamHud[0].OffsetX=-100;
	LTeamHud[1].OffsetX=-100;
	LTeamHud[2].OffsetX=-100;

	RTeamHud[0].OffsetX=100;
	RTeamHud[1].OffsetX=100;
	RTeamHud[2].OffsetX=100;

	TeamSymbols[0].TextureScale = 0.09;
	TeamSymbols[1].TextureScale = 0.09;

	TeamSymbols[0].OffsetX = -480;
	TeamSymbols[1].OffsetX = 480;

	TeamSymbols[0].OffsetY = 90;
	TeamSymbols[1].OffsetY = 90;

	Points[0].Widgets[Points[0].PointState].PosY = 0.045*HUDScale;
	Points[1].Widgets[Points[1].PointState].PosY = 0.045*HUDScale;
	
	DrawSpriteWidget (C, Points[0].Widgets[Points[0].PointState]);
	DrawSpriteWidget (C, Points[1].Widgets[Points[1].PointState]);

	if ( DP1 != None )
	{
		C.DrawColor = GoldColor;
		Draw2DLocationDot(C, DP1.Location,0.5 - 0.04*HUDScale, 0.0365*HUDScale, 0.0305*HUDScale, 0.0405*HUDScale);
	}
	if ( DP2 != None )
	{
		C.DrawColor = GoldColor;
		Draw2DLocationDot(C, DP2.Location,0.5 + 0.026*HUDScale, 0.0365*HUDScale, 0.0305*HUDScale, 0.0405*HUDScale);
	}
}

simulated function ShowTeamScorePassC(Canvas C)
{
	ScoreTeam[0].OffsetX = -270;
    ScoreTeam[0].OffsetY = 75;
	ScoreTeam[1].OffsetY = 75;
    Super.ShowTeamScorePassC(C);
}

simulated function TeamScoreOffset()
{
	ScoreTeam[1].OffsetX = 180;
	if ( ScoreTeam[1].Value < 0 )
		ScoreTeam[1].OffsetX += 90;
	if( abs(ScoreTeam[1].Value) > 9 )
		ScoreTeam[1].OffsetX += 90;
}

simulated function UpdateTeamHud()
{
	local NavigationPoint N;

    if (DP1 == None || DP2 == None)
    {
        for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
        {
	        if (!N.IsA('xDomPoint'))
                continue;

	        if (N.IsA('xDomPointA') && DP1 == None)
                DP1 = xDomPoint(N);
            else
                DP2 = xDomPoint(N);
        }
    }

    // Point A state
    if (!DP1.bControllable)
        Points[0].PointState = PS_Disabled;
    else if (DP1.ControllingTeam == None)
        Points[0].PointState = PS_Neutral;
	else if ( PlayerOwner.PlayerReplicationInfo.Team == None )
	{
		if ( DP1.ControllingTeam.TeamIndex == 0 )
			Points[0].PointState = PS_HeldFriendly; 
		else
			Points[0].PointState = PS_HeldEnemy;
	}
    else if (DP1.ControllingTeam == PawnOwnerPRI.Team)
        Points[0].PointState = PS_HeldFriendly;
	else
        Points[0].PointState = PS_HeldEnemy;
        
    // Point B state
    if (!DP2.bControllable)
        Points[1].PointState = PS_Disabled;
    else if (DP2.ControllingTeam == None)
        Points[1].PointState = PS_Neutral;
	else if ( PlayerOwner.PlayerReplicationInfo.Team == None )
	{
		if ( DP2.ControllingTeam.TeamIndex == 0 )
			Points[1].PointState = PS_HeldFriendly;
		else
			Points[1].PointState = PS_HeldEnemy;
	}
    else if (DP2.ControllingTeam == PawnOwnerPRI.Team)
	    Points[1].PointState = PS_HeldFriendly;
	else
		Points[1].PointState = PS_HeldEnemy;

	Super.UpdateTeamHUD();
}

function Timer()
{
    local NavigationPoint N;

	Super.Timer();

	if ((PlayerOwner == None) || (PawnOwner == None) || (PawnOwnerPRI == None))
		return;

    if (DP1 == None || DP2 == None)
    {
        for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
        {
	        if (!N.IsA ('xDomPoint'))
                continue;

	        if (N.IsA('xDomPointA'))
                DP1 = xDomPoint(N);
            else
                DP2 = xDomPoint(N);
        }
    }

    if (DP1.ControllingTeam == DP2.ControllingTeam)
    {
        if (DP1.ControllingTeam != None)
        {
            if (PawnOwnerPRI.Team.TeamIndex == DP1.ControllingTeam.TeamIndex)
		        PlayerOwner.ReceiveLocalizedMessage (class'xDomMessage', 0);
            else
		        PlayerOwner.ReceiveLocalizedMessage (class'xDomMessage', 1);
        }
    }
}

defaultproperties
{
     SymbolGB(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=0.500000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     SymbolGB(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.300000,PosX=0.500000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     Points(0)=(Widgets[0]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=334,Y1=512,X2=391,Y2=567),TextureScale=0.600000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.045000,OffsetX=-34,Scale=1.000000,Tints[0]=(B=195,G=195,R=195,A=255),Tints[1]=(B=195,G=195,R=195,A=255)),Widgets[1]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=334,Y1=512,X2=391,Y2=567),TextureScale=0.600000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.045000,OffsetX=-34,Scale=1.000000,Tints[0]=(B=60,G=60,R=255,A=255),Tints[1]=(B=255,G=205,R=100,A=255)),Widgets[2]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=334,Y1=512,X2=391,Y2=567),TextureScale=0.600000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.045000,OffsetX=-34,Scale=1.000000,Tints[0]=(B=255,G=205,R=100,A=255),Tints[1]=(B=60,G=60,R=255,A=255)),Widgets[3]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=334,Y1=512,X2=391,Y2=567),TextureScale=0.600000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.045000,OffsetX=-34,Scale=1.000000,Tints[0]=(B=195,G=195,R=195,A=55),Tints[1]=(B=255,G=255,R=255)))
     Points(1)=(Widgets[0]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=392,Y1=512,X2=449,Y2=567),TextureScale=0.600000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.045000,OffsetX=34,Scale=1.000000,Tints[0]=(B=195,G=195,R=195,A=255),Tints[1]=(B=195,G=195,R=195,A=255)),Widgets[1]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=392,Y1=512,X2=449,Y2=567),TextureScale=0.600000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.045000,OffsetX=34,Scale=1.000000,Tints[0]=(B=60,G=60,R=255,A=255),Tints[1]=(B=255,G=205,R=100,A=255)),Widgets[2]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=392,Y1=512,X2=449,Y2=567),TextureScale=0.600000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.045000,OffsetX=34,Scale=1.000000,Tints[0]=(B=255,G=205,R=100,A=255),Tints[1]=(B=60,G=60,R=255,A=255)),Widgets[3]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=392,Y1=512,X2=449,Y2=567),TextureScale=0.600000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.045000,OffsetX=34,Scale=1.000000,Tints[0]=(B=195,G=195,R=195,A=55),Tints[1]=(B=255,G=255,R=255)))
}

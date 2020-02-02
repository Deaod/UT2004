class HudBCaptureTheFlag extends HudBTeamDeathMatch;

#exec Texture Import File=textures\FlagIcons.tga Name=S_FlagIcon Mips=Off Alpha=1 DXT=5

struct FFlagWidget
{
    var EFlagState FlagState;
    var SpriteWidget Widgets[4];
};

var() SpriteWidget SymbolGB[2];
var() FFlagWidget FlagWidgets[2];
var Actor RedBase, BlueBase;
var SpriteWidget NewFlagWidgets[2];
var SpriteWidget FlagDownWidgets[2];
var SpriteWidget FlagHeldWidgets[2];

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0, True);
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


simulated function TeamScoreOffset()
{
	ScoreTeam[1].OffsetX = 180;
	if ( ScoreTeam[1].Value < 0 )
		ScoreTeam[1].OffsetX += 90;
	if( abs(ScoreTeam[1].Value) > 9 )
		ScoreTeam[1].OffsetX += 90;
	//if( abs(ScoreTeam[1].Value) > 99 )
	//	ScoreTeam[1].OffsetX -= 90;
}

// Alpha Pass ==================================================================================
simulated function ShowTeamScorePassA(Canvas C)
{
	local CTFBase B;
	local int i;

	Super.ShowTeamScorePassA(C);
    DrawSpriteWidget (C, SymbolGB[0]);
	DrawSpriteWidget (C, SymbolGB[1]);

	LTeamHud[0].OffsetX=-95;
	LTeamHud[1].OffsetX=-95;
	LTeamHud[2].OffsetX=-95;

	RTeamHud[0].OffsetX=95;
	RTeamHud[1].OffsetX=95;
	RTeamHud[2].OffsetX=95;


	TeamSymbols[0].TextureScale = 0.09;
	TeamSymbols[1].TextureScale = 0.09;

	TeamSymbols[0].OffsetX = -480;
	TeamSymbols[1].OffsetX = 480;

	TeamSymbols[0].OffsetY = 90;
	TeamSymbols[1].OffsetY = 90;

	ScoreTeam[0].OffsetX = -270;
	ScoreTeam[1].OffsetX = 180;

	ScoreTeam[0].OffsetY = 75;
	ScoreTeam[1].OffsetY = 75;
    
	if ( RedBase == None )
	{
		ForEach DynamicActors(Class'CTFBase', B)
		{
			if ( B.IsA('xRedFlagBase') )
				RedBase = B;
			else
				BlueBase = B;
		}
	}
	if ( RedBase != None )
	{
		C.DrawColor = RedColor;
		Draw2DLocationDot(C, RedBase.Location,0.5 - 0.04*HUDScale, 0.0365*HUDScale, 0.0305*HUDScale, 0.0405*HUDScale);
	}
	if ( BlueBase != None )
	{
		C.DrawColor = BlueColor;
		Draw2DLocationDot(C, BlueBase.Location,0.5 + 0.026*HUDScale, 0.0365*HUDScale, 0.0305*HUDScale, 0.0405*HUDScale);
	}

    DrawSpriteWidget (C, NewFlagWidgets[0]);
    DrawSpriteWidget (C, NewFlagWidgets[1]);

	if ( PlayerOwner.GameReplicationInfo == None )
		return;
    for (i = 0; i < 2; i++)
    {
		if ( PlayerOwner.GameReplicationInfo.FlagState[i] == EFlagState.FLAG_HeldEnemy )
		   DrawSpriteWidget (C, FlagHeldWidgets[i]);
		else if ( PlayerOwner.GameReplicationInfo.FlagState[i] == EFlagState.FLAG_Down )
		   DrawSpriteWidget (C, FlagDownWidgets[i]);
    }
}

function Timer()
{
	Super.Timer();

    if ( (PawnOwnerPRI == None) 
		|| (PlayerOwner.IsSpectating() && (PlayerOwner.bBehindView || (PlayerOwner.ViewTarget == PlayerOwner))) )
        return;

	if ( PawnOwnerPRI.HasFlag != None )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFHUDMessage', 0 );

	if ( (PlayerOwner.GameReplicationInfo != None)
		&& (PlayerOwner.GameReplicationInfo.FlagState[PlayerOwner.PlayerReplicationInfo.Team.TeamIndex] == EFlagState.FLAG_HeldEnemy) )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFHUDMessage', 1 );
}

simulated function UpdateTeamHud()
{
    Super.UpdateTeamHUD();
}

defaultproperties
{
     SymbolGB(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=0.500000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     SymbolGB(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.300000,PosX=0.500000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     FlagWidgets(0)=(Widgets[0]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=743,Y1=97,X2=834,Y2=148),TextureScale=0.310000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=-67,OffsetY=70,Scale=1.000000,Tints[0]=(B=60,G=60,R=255,A=255),Tints[1]=(B=60,G=60,R=255,A=255)),Widgets[1]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=926,Y1=97,X2=1017,Y2=148),TextureScale=0.310000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=-67,OffsetY=70,Scale=1.000000,Tints[0]=(B=60,G=60,R=255,A=255),Tints[1]=(B=60,G=60,R=255,A=255)),Widgets[2]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=926,Y1=97,X2=1017,Y2=148),TextureScale=0.310000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=-67,OffsetY=70,Scale=1.000000,Tints[0]=(B=60,G=60,R=255,A=255),Tints[1]=(B=60,G=60,R=255,A=255)),Widgets[3]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=835,Y1=97,X2=925,Y2=148),TextureScale=0.310000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=-67,OffsetY=70,Scale=1.000000,Tints[0]=(B=60,G=60,R=255,A=255),Tints[1]=(B=60,G=60,R=255,A=255)))
     FlagWidgets(1)=(Widgets[0]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=834,Y1=97,X2=743,Y2=147),TextureScale=0.310000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=68,OffsetY=70,Scale=1.000000,Tints[0]=(B=255,G=205,R=100,A=255),Tints[1]=(B=255,G=205,R=100,A=255)),Widgets[1]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=1017,Y1=97,X2=926,Y2=148),TextureScale=0.310000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=68,OffsetY=70,Scale=1.000000,Tints[0]=(B=255,G=205,R=100,A=255),Tints[1]=(B=255,G=205,R=100,A=255)),Widgets[2]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=1017,Y1=97,X2=926,Y2=148),TextureScale=0.310000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=68,OffsetY=70,Scale=1.000000,Tints[0]=(B=255,G=205,R=100,A=255),Tints[1]=(B=255,G=205,R=100,A=255)),Widgets[3]=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=925,Y1=97,X2=835,Y2=148),TextureScale=0.310000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=68,OffsetY=70,Scale=1.000000,Tints[0]=(B=255,G=205,R=100,A=255),Tints[1]=(B=255,G=205,R=100,A=255)))
     NewFlagWidgets(0)=(WidgetTexture=Texture'XInterface.S_FlagIcon',RenderStyle=STY_Alpha,TextureCoords=(X2=90,Y2=64),TextureScale=0.310000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=-68,OffsetY=70,Scale=1.000000,Tints[0]=(B=60,G=60,R=255,A=255),Tints[1]=(B=60,G=60,R=255,A=255))
     NewFlagWidgets(1)=(WidgetTexture=Texture'XInterface.S_FlagIcon',RenderStyle=STY_Alpha,TextureCoords=(X1=90,Y2=64),TextureScale=0.310000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=68,OffsetY=70,Scale=1.000000,Tints[0]=(B=255,G=160,R=32,A=255),Tints[1]=(B=255,G=160,R=32,A=255))
     FlagDownWidgets(0)=(WidgetTexture=Texture'XInterface.S_FlagIcon',RenderStyle=STY_Alpha,TextureCoords=(X1=92,X2=127,Y2=31),TextureScale=0.350000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=-46,OffsetY=72,Scale=1.000000,Tints[0]=(B=32,G=255,R=255,A=255),Tints[1]=(B=32,G=255,R=255,A=255))
     FlagDownWidgets(1)=(WidgetTexture=Texture'XInterface.S_FlagIcon',RenderStyle=STY_Alpha,TextureCoords=(X1=92,X2=127,Y2=31),TextureScale=0.350000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=56,OffsetY=72,Scale=1.000000,Tints[0]=(B=32,G=255,R=255,A=255),Tints[1]=(B=32,G=255,R=255,A=255))
     FlagHeldWidgets(0)=(WidgetTexture=Texture'XInterface.S_FlagIcon',RenderStyle=STY_Alpha,TextureCoords=(X1=92,Y1=32,X2=127,Y2=63),TextureScale=0.450000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=-54,OffsetY=42,Scale=1.000000,Tints[0]=(B=32,G=255,R=255,A=255),Tints[1]=(B=32,G=255,R=255,A=255))
     FlagHeldWidgets(1)=(WidgetTexture=Texture'XInterface.S_FlagIcon',RenderStyle=STY_Alpha,TextureCoords=(X1=92,Y1=32,X2=127,Y2=63),TextureScale=0.450000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,OffsetX=28,OffsetY=42,Scale=1.000000,Tints[0]=(B=32,G=255,R=255,A=255),Tints[1]=(B=32,G=255,R=255,A=255))
     ScoreBg(0)=(TextureCoords=(X1=0,Y1=0,X2=0,Y2=0))
     ScoreBg(1)=(TextureCoords=(X1=0,Y1=0,X2=0,Y2=0))
     ScoreBg(2)=(TextureCoords=(X1=0,Y1=0,X2=0,Y2=0))
     ScoreBg(3)=(TextureCoords=(Y1=0,X2=0,Y2=0))
}

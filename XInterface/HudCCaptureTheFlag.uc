class HudCCaptureTheFlag extends HudCTeamDeathMatch;

var() float REDtmpPosX, REDtmpPosY, REDtmpScaleX, REDtmpScaleY;
var() float BLUEtmpPosX, BLUEtmpPosY, BLUEtmpScaleX, BLUEtmpScaleY;


struct FFlagWidget
{
    var EFlagState FlagState;
    var SpriteWidget Widgets[4];
};

var() SpriteWidget SymbolGB[2];
var Actor RedBase, BlueBase;
var() SpriteWidget NewFlagWidgets[2];
var SpriteWidget FlagDownWidgets[2];
var SpriteWidget FlagHeldWidgets[2];

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0, True);
}

simulated function ShowTeamScorePassA(Canvas C)
{
	local CTFBase B;
	local int i;

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

        DrawSpriteWidget (C, NewFlagWidgets[0]);
        DrawSpriteWidget (C, NewFlagWidgets[1]);

        NewFlagWidgets[0].Tints[0] = HudColorTeam[0];
        NewFlagWidgets[0].Tints[1] = HudColorTeam[0];

        NewFlagWidgets[1].Tints[0] = HudColorTeam[1];
        NewFlagWidgets[1].Tints[1] = HudColorTeam[1];

        DrawSpriteWidget (C, VersusSymbol );
	 	DrawNumericWidget (C, ScoreTeam[0], DigitsBig);
		DrawNumericWidget (C, ScoreTeam[1], DigitsBig);

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
			C.DrawColor = HudColorRed;
			Draw2DLocationDot(C, RedBase.Location,0.5 - REDtmpPosX*HUDScale, REDtmpPosY*HUDScale, REDtmpScaleX*HUDScale, REDtmpScaleY*HUDScale);
		}
		if ( BlueBase != None )
		{
			C.DrawColor = HudColorBlue;
			Draw2DLocationDot(C, BlueBase.Location,0.5 + BLUEtmpPosX*HUDScale, BLUEtmpPosY*HUDScale, BLUEtmpScaleX*HUDScale, BLUEtmpScaleY*HUDScale);
		}

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
}

function Timer()
{
	Super.Timer();

    if ( (PawnOwnerPRI == None) 
		|| (PlayerOwner.IsSpectating() && (PlayerOwner.bBehindView || (PlayerOwner.ViewTarget == PlayerOwner))) )
        return;

	if ( PawnOwnerPRI.HasFlag != None )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFHUDMessage', 0 );
	
	if ( (PlayerOwner.GameReplicationInfo != None) && (PlayerOwner.PlayerReplicationInfo.Team != None) 
		&& (PlayerOwner.GameReplicationInfo.FlagState[PlayerOwner.PlayerReplicationInfo.Team.TeamIndex] == EFlagState.FLAG_HeldEnemy) )
		PlayerOwner.ReceiveLocalizedMessage( class'CTFHUDMessage', 1 );
}

simulated function UpdateTeamHud()
{
    Super.UpdateTeamHUD();
}

defaultproperties
{
     REDtmpPosX=0.058000
     REDtmpPosY=0.026000
     REDtmpScaleX=0.020000
     REDtmpScaleY=0.030000
     BLUEtmpPosX=0.044000
     BLUEtmpPosY=0.026000
     BLUEtmpScaleX=0.020000
     BLUEtmpScaleY=0.030000
     NewFlagWidgets(0)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=336,Y1=129,X2=397,Y2=170),TextureScale=0.450000,DrawPivot=DP_UpperRight,PosX=0.500000,OffsetX=-42,OffsetY=8,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     NewFlagWidgets(1)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=397,Y1=129,X2=339,Y2=170),TextureScale=0.450000,PosX=0.500000,OffsetX=42,OffsetY=8,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     FlagDownWidgets(0)=(WidgetTexture=FinalBlend'HUDContent.Generic.HUDPulse',RenderStyle=STY_Alpha,TextureCoords=(X1=77,Y1=271,X2=116,Y2=311),TextureScale=0.450000,DrawPivot=DP_UpperRight,PosX=0.500000,OffsetX=-53,OffsetY=40,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     FlagDownWidgets(1)=(WidgetTexture=FinalBlend'HUDContent.Generic.HUDPulse',RenderStyle=STY_Alpha,TextureCoords=(X1=77,Y1=271,X2=116,Y2=311),TextureScale=0.450000,PosX=0.500000,OffsetX=53,OffsetY=40,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     FlagHeldWidgets(0)=(WidgetTexture=FinalBlend'HUDContent.Generic.HUDPulse',RenderStyle=STY_Alpha,TextureCoords=(X1=341,Y1=211,X2=366,Y2=271),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=0.500000,OffsetX=-95,OffsetY=25,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     FlagHeldWidgets(1)=(WidgetTexture=FinalBlend'HUDContent.Generic.HUDPulse',RenderStyle=STY_Alpha,TextureCoords=(X1=341,Y1=211,X2=366,Y2=271),TextureScale=0.300000,PosX=0.500000,OffsetX=95,OffsetY=25,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
}

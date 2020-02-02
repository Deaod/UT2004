class HudCBombingRun extends HudCTeamDeathMatch;

struct FBombWidget
{
    var EFlagState BombState;
    var SpriteWidget Widgets[4];
};

var() SpriteWidget BombBG;
var() FBombWidget BombWidget;
var() FBombWidget BombWidgetStatus;
var() bool bPlaying;

#exec OBJ LOAD File=IndoorAmbience.uax

var transient xBombFlag BombFlag;
var transient xBombDelivery MyBombDelivery;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
    SetTimer(1.0, True);
}

// Alpha Pass ==================================================================================
simulated function ShowTeamScorePassA(Canvas C)
{
	local vector Pos;

	Super.ShowTeamScorePassA(C);

	DrawSpriteWidget (C, BombBG);
    DrawSpriteWidget (C, BombWidget.Widgets[BombWidget.BombState]);
    DrawSpriteWidget (C, BombWidgetStatus.Widgets[BombWidget.BombState]);

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

	C.DrawColor = HudColorHighLight;
	Draw2DLocationDot(C, Pos, 0.5 - 0.0075*HUDScale, 0.03*HUDScale, 0.027*HUDScale, 0.035*HUDScale);
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

	if( (PawnOwnerPRI != none) && (GRI.FlagTarget == PawnOwnerPRI) && (BombFlag != None) && (BombFlag.Physics == PHYS_Projectile) )
	{
		PlayerOwner.ReceiveLocalizedMessage(class'BombTargetMessage',0,PawnOwnerPRI);
		if( !bPlaying )
		{
			PlayerOwner.ClientPlaySound(Sound'WeaponSounds.BZoomIn1');
			bPlaying=true;
		}
	}
	else
		bPlaying=false;

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
	{
		BombWidget.BombState = GRI.FlagState[PlayerOwner.PlayerReplicationInfo.Team.TeamIndex];
	}
	Super.UpdateTeamHUD();
}

defaultproperties
{
     BombBG=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.700000,DrawPivot=DP_UpperMiddle,PosX=0.500000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BombWidget=(Widgets[0]=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=79,Y1=223,X2=116,Y2=264),TextureScale=0.700000,DrawPivot=DP_UpperMiddle,PosX=0.500000,OffsetY=5,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=100),Tints[1]=(B=255,G=255,R=255,A=100)),Widgets[1]=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=79,Y1=223,X2=116,Y2=264),TextureScale=0.700000,DrawPivot=DP_UpperMiddle,PosX=0.500000,OffsetY=10,Scale=1.000000,Tints[0]=(R=200,A=255),Tints[1]=(B=200,G=64,R=50,A=255)),Widgets[2]=(WidgetTexture=FinalBlend'HUDContent.Generic.fbHUDAlertSlow',RenderStyle=STY_Alpha,TextureCoords=(X1=79,Y1=223,X2=116,Y2=264),TextureScale=0.700000,DrawPivot=DP_UpperMiddle,PosX=0.500000,OffsetY=10,Scale=1.000000,Tints[0]=(B=200,G=64,R=50,A=255),Tints[1]=(R=200,A=255)),Widgets[3]=(WidgetTexture=FinalBlend'HUDContent.Generic.fbHUDAlertSlow',RenderStyle=STY_Alpha,TextureCoords=(X1=79,Y1=223,X2=116,Y2=264),TextureScale=0.700000,DrawPivot=DP_UpperMiddle,PosX=0.500000,OffsetY=10,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)))
     BombWidgetStatus=(Widgets[2]=(WidgetTexture=FinalBlend'HUDContent.Generic.HUDPulse',RenderStyle=STY_Alpha,TextureCoords=(X1=341,Y1=211,X2=366,Y2=271),TextureScale=0.350000,DrawPivot=DP_UpperMiddle,PosX=0.500000,OffsetY=30,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)),Widgets[3]=(WidgetTexture=FinalBlend'HUDContent.Generic.HUDPulse',RenderStyle=STY_Alpha,TextureCoords=(X1=77,Y1=271,X2=116,Y2=311),TextureScale=0.530000,DrawPivot=DP_UpperMiddle,PosX=0.500000,OffsetY=40,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)))
     TargetMaterial=TexRotator'HUDContent.Reticles.rotReticle001'
     LocationDot=FinalBlend'HUDContent.Generic.HUDPulse'
}

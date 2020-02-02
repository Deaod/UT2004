//=============================================================================
// HUD_Assault
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class HUD_Assault extends HudCTeamDeathMatch
	config;

#EXEC OBJ LOAD FILE=InterfaceContent.utx
#EXEC OBJ LOAD FILE=AS_FX_TX.utx
#exec OBJ LOAD File="MenuSounds.uax"
#EXEC OBJ LOAD FILE=AssaultFilmGrain.utx

// Objective notification
var config	float	ObjectiveScale;					// Size scale of visible objective reticles
var	config	bool	bOnHUDObjectiveNotification;	// Show objectives on screen
var config	bool	bShowInfoPods;					// show InfoPods
var config	bool	bDrawAllObjectives;				// Draw ALL objectives on screen (2D arrows)
var config	bool	bShow3DArrow;					// 3d arrow pointing at current objective.
var config	bool	bObjectiveReminder;				// objective reminder at spawn
var	config	bool	bDrawRadar;						// Show Radar
var config	bool	bDrawRadarCardinalPoints;
var config	bool	bShowWillowWhisp;

var bool			bForceSpawnNotification;
var	bool			bShowObjectiveBoard, bForceObjectiveBoard;

var	Array<GameObjective>			OBJ;		// List of objectives in the level
var Array<InfoPod>					InfoPods;	// List of infopods
var Array<Trigger_ASMessageTrigger>	MTrigger;	// list of message triggers
var Array<TexRotator>				BehindObjectiveArrows;
var	ObjectivePointingArrow			OBJPointingArrow;

var	byte	BehindObjectiveCount;

var float	OBJ_ReAppearTime;
var float	OBJ_FadedOutTime;

var	float	Global_Delta;
var float	fBlink, fPulse;

// Vehicle Radar
var			float	ASRadarScale;
var config	float	ASRadarPosX, ASRadarPosY;			// Radar position
var			float	LastRadarUpdate;
var			Array<Vehicle>	RadarVehicleCache;

// Health Bar
var Material	HealthBarBackMat;
var Material	HealthBarMat;
var float		HealthBarWidth;
var float		HealthBarHeight;

var int		OldRemainingRoundTime;

var localized string	IP_Bracket_Open, IP_Bracket_Close;
var localized string	Cardinal_North, Cardinal_East, Cardinal_South, Cardinal_West;
var localized string	NoGameReplicationInfoString, MetersString, TargetString, NoTargetString, PracticeRoundString;

var			float	AttackerProgressUpdateTime;
var config	float	ObjectiveProgressPulseTime;		// Current objective Color pulse when announced

var	byte	ObjectiveProgress, OldObjectiveProgress;

var	ASGameReplicationInfo	ASGRI;
var ASPlayerReplicationInfo	ASPRI;

var GameObjective			CurrentObjective;

var Vehicle					TrackedVehicle;
var	float					NextTrackedVehicleSearch;

var() SpriteWidget  RoundTimeBackGround, ReinforceBackground, TeleportBackground, VSBackground;
var() SpriteWidget	RoundTimeIcon, ReinforceIcon, TeleportIcon, VSIcon;
var() SpriteWidget	ReinforcePulse, TeleportPulse, VSPulse;
var() SpriteWidget  RoundTimeBackGroundDisc, ReinforceBackGroundDisc, TeleportBackgroundDisc, VSBackgroundDisc;
var() SpriteWidget  RoundTimeSeparator;

var() NumericWidget RoundTimeMinutes, RoundTimeSeconds, ReinforceSprNum, TeleportSprNum;

// Spawn notification
var float			NextSpawnNotification;

var	byte			PrevTeam;

var()	ObjectiveProgressDisplay	ObjectiveBoard;

// intro cinematic
var	float	IntroTitleFade;

// Override
simulated function DrawTimer(Canvas C);
simulated function DrawAdrenaline( Canvas C );


/* toggles displaying objectiveboard */
exec function ShowObjectiveBoard()
{
	 bShowObjectiveBoard = !bShowObjectiveBoard;
}

simulated function PrecacheFonts(Canvas C)
{
	Super.PrecacheFonts(C);

	C.Font = GetFontSizeIndex(C,-1);
	C.SetPos(0,0);
	C.DrawText("Aa1");

	C.Font = GetFontSizeIndex(C,-3);
	C.SetPos(0,0);
	C.DrawText("Aa1");
}

simulated event PostBeginPlay()
{
	local GameObjective				GO;
	local InfoPod					IP;
	local Trigger_ASMessageTrigger	MT;

	super.PostBeginPlay();

	// Caching level objectives
	ForEach AllActors(class'GameObjective', GO )
	{
		if ( GO.bBotOnlyObjective )	// ignore bot only objectives
			continue;
		OBJ[OBJ.Length] = GO;
	}

	// Caching InfoPods
	ForEach AllActors(class'InfoPod', IP )
		InfoPods[InfoPods.Length] = IP;

	ForEach AllActors(class'Trigger_ASMessageTrigger', MT)
		MTrigger[MTrigger.Length] = MT;

	ObjectiveBoard = Spawn(class'ObjectiveProgressDisplay', Owner);
	ObjectiveBoard.Initialize( Self );
}

simulated event Destroyed()
{
	if ( ObjectiveBoard != None )
	{
		ObjectiveBoard.Destroy();
		ObjectiveBoard = None;
	}

	Release_BehindObjectiveArrows();
	Release_ObjectivePointingArrow();

	super.Destroyed();
}

//simulated function DrawHudPassD (Canvas C); // Alternate Texture Pass

simulated function DrawHudPassA (Canvas C) // Alpha Pass
{
	local bool	bOldShowWeaponInfo, bOldShowPersonalInfo;
	local class<Ammunition> AmmoClass;

	// Ammo Count
	bOldShowWeaponInfo = bShowWeaponInfo;
	if ( PawnOwner != None && PawnOwner.Weapon != None )
	{
		AmmoClass = PawnOwner.Weapon.GetAmmoClass(0);
		if ( (AmmoClass == None) || ClassIsChildOf(AmmoClass,class'Ammo_Dummy') )
			bShowWeaponInfo = false;
	}

	// Healh info
	bOldShowPersonalInfo = bShowPersonalInfo;
	if ( (ASVehicle(PawnOwner) != None) && ASVehicle(PawnOwner).bCustomHealthDisplay )
		bShowPersonalInfo = false;

	super.DrawHudPassA( C );

	bShowWeaponInfo		= bOldShowWeaponInfo;
	bShowPersonalInfo	= bOldShowPersonalInfo;

	// Vehicle Radar
	if ( bDrawRadar && Vehicle(PawnOwner) != None && Vehicle(PawnOwner).bHasRadar )
		DrawRadarPassA( C );
}

simulated function DrawHudPassB (Canvas C) // Additive Pass
{
	super.DrawHudPassB( C );

	// Vehicle Radar
	if ( bDrawRadar && Vehicle(PawnOwner) != None && Vehicle(PawnOwner).bHasRadar )
		DrawRadarPassB( C );
}

simulated function DrawHudPassC (Canvas C) // Alpha Pass
{
	local bool	bOldShowWeaponInfo, bOldShowPersonalInfo;
	local class<Ammunition> AmmoClass;

	DrawAssaultHUDLayer( C );

	// Ammo Count
	bOldShowWeaponInfo = bShowWeaponInfo;
	if ( PawnOwner != None && PawnOwner.Weapon != None )
	{
		AmmoClass = PawnOwner.Weapon.GetAmmoClass(0);
		if ( (AmmoClass == None) || ClassIsChildOf(AmmoClass,class'Ammo_Dummy') )
			bShowWeaponInfo = false;
	}

	// Healh info
	bOldShowPersonalInfo = bShowPersonalInfo;
	if ( PawnOwner != None && PawnOwner.IsA('ASVehicle') && ASVehicle(PawnOwner).bCustomHealthDisplay )
		bShowPersonalInfo = false;

	super.DrawHudPassC( C );

	bShowWeaponInfo		= bOldShowWeaponInfo;
	bShowPersonalInfo	= bOldShowPersonalInfo;
}

/* Specific function to use Canvas.DrawActor()
 Clear Z-Buffer once, prior to rendering all actors */
function CanvasDrawActors( Canvas C, bool bClearedZBuffer )
{
	if ( PawnOwner != None && bShow3DArrow && !bHideHUD )
	{
		if ( !bClearedZBuffer )
			C.DrawActor(None, false, true); // Clear the z-buffer here

		Draw3dObjectiveArrow( C );
		super.CanvasDrawActors( C, true );
	}
	else
		super.CanvasDrawActors( C, bClearedZBuffer );
}

simulated function DrawAssaultHUDLayer( Canvas C )
{
	// Draw InfoPods
	if ( bShowInfoPods )
		DrawInfoPods( C );

	// On-HUD objective notification disabled ?
	if ( bOnHUDObjectiveNotification )
		DrawObjectives( C );

	UpdateActorTracking( C );

	if ( ASGRI != None && ASGRI.IsPracticeRound() )
		DrawPracticeRoundInfo( C );

	if ( PawnOwner != None && ObjectiveBoard != None && ASGRI != None )
	{
		ObjectiveBoard.ShowStatus( ShouldShowObjectiveBoard() );
		ObjectiveBoard.PostRender( C, Global_Delta, ASGRI.IsDefender( PawnOwner.GetTeamNum() ) );
	}
}

simulated function bool ShouldShowObjectiveBoard()
{
	if ( ObjectiveBoard == None || ASGRI == None )
		return false;

	if ( ObjectiveBoard.AnyOptionalObjectiveCritical() )
		return true;

	return ( bShowObjectiveBoard || bForceObjectiveBoard || AttackerProgressUpdateTime > 0 );
}


simulated function UpdateTeamHud()
{
	local int	RoundTime, Minutes, Seconds;
	local int	TeleportCount;

	super.UpdateTeamHud();

	if ( ASGRI == None )
		return;

	if ( ASGRI.RoundTimeLimit > 0 ) // freeze time when round is over
	{
		RoundTime = Max(0, ASGRI.RoundTimeLimit-ASGRI.RoundStartTime+ASGRI.RemainingTime);

		if ( ASGRI.RoundWinner != ERW_None )
			RoundTime = ASGRI.RoundOverTime;

		Minutes = RoundTime / 60;
		Seconds = RoundTime - Minutes * 60;

		RoundTimeMinutes.Value =  Minutes;
		RoundTimeSeconds.Value =  Min(Seconds, 60);

		if ( Minutes > 9 )
		{
			RoundTimeSeparator.OffsetX	= default.RoundTimeSeparator.OffsetX + 32; //100
			RoundTimeMinutes.OffsetX	= default.RoundTimeMinutes.OffsetX + 32; //020
			RoundTimeSeconds.OffsetX	= default.RoundTimeSeconds.OffsetX + 32; //110
		}
		else
		{
			RoundTimeSeparator.OffsetX	= default.RoundTimeSeparator.OffsetX; //100
			RoundTimeMinutes.OffsetX	= default.RoundTimeMinutes.OffsetX; //020
			RoundTimeSeconds.OffsetX	= default.RoundTimeSeconds.OffsetX; //110
		}
	}

	ReinforceSprNum.Value =  Min(ASGRI.ReinforcementCountDown, 999);
	if ( ASPRI != None )
	{
		TeleportCount = Min(ASGRI.RoundTimeLimit - ASGRI.RoundStartTime + ASGRI.RemainingTime + ASGRI.MaxTeleportTime - ASPRI.TeleportTime, 999);
		if ( ASPRI.bTeleportToSpawnArea && TeleportCount >= 0 && TeleportCount != TeleportSprNum.Value )
			PlayerOwner.ViewTarget.PlaySound(sound'MenuSounds.J_MouseOver', SLOT_None,,,,,false);
		TeleportSprNum.Value  =  TeleportCount;
	}
}

simulated function ShowTeamScorePassA(Canvas C)
{
	local float	PosY;

	if ( ASGRI == None )
		return;

	//
	// HUDBase texture
	//

	/* Round Time Limit */
	if ( ASGRI.RoundTimeLimit > 0 )
	{
		RoundTimeBackground.Tints[TeamIndex] = HudColorBlack;
		RoundTimeBackground.Tints[TeamIndex].A = 150;
		DrawSpriteWidget (C, RoundTimeBackground);
		DrawSpriteWidget (C, RoundTimeBackgroundDisc);
		DrawSpriteWidget (C, RoundTimeSeparator);
		DrawSpriteWidget (C, RoundTimeIcon);
		PosY += 0.06 * HUDScale;
	}

	if ( Level.Game == None || !ASGameInfo(Level.Game).bDisableReinforcements )
	{
		ReinforceBackground.PosY		= PosY;
		ReinforceBackgroundDisc.PosY	= PosY;
		ReinforcePulse.PosY				= PosY;
		ReinforceIcon.PosY				= PosY;
		ReinforceSprNum.PosY			= PosY;
		PosY += 0.06 * HUDScale;

		/* Reinforcements count down */
		ReinforceBackground.Tints[TeamIndex] = HudColorBlack;
		ReinforceBackground.Tints[TeamIndex].A = 150;
		DrawSpriteWidget (C, ReinforceBackground);
		DrawSpriteWidget (C, ReinforceBackgroundDisc);
		ReinforcePulse.Tints[TeamIndex] = HudColorHighLight;
		if ( ASGRI.ReinforcementCountDown < 1 )	// Pulse when reinforcements arrive
			DrawSpriteWidget( C, ReinforcePulse );
		DrawSpriteWidget (C, ReinforceIcon);
	}

	/* second attack wave comparison */
	if ( ASGRI != None && (ASGRI.CurrentRound % 2 == 0) && !ASGRI.IsPracticeRound() && IsVSRelevant() )
	{
		VSBackground.PosY		= PosY;
		VSBackgroundDisc.PosY	= PosY;
		VSIcon.PosY				= PosY;
		PosY += 0.06 * HUDScale;

		VSBackground.Tints[TeamIndex] = HudColorBlack;
		VSBackground.Tints[TeamIndex].A = 150;
		DrawSpriteWidget (C, VSBackground);
		DrawSpriteWidget (C, VSBackgroundDisc);
		DrawSpriteWidget (C, VSIcon);	
	}

	/* Teleport */
	if ( ASPRI !=None && ASPRI.bTeleportToSpawnArea && TeleportSprNum.Value >= 0 )
	{
		TeleportBackground.PosY		= PosY;
		TeleportBackgroundDisc.PosY	= PosY;
		TeleportPulse.PosY			= PosY;
		TeleportIcon.PosY			= PosY;
		TeleportSprNum.PosY			= PosY;
		PosY += 0.06 * HUDScale;

		TeleportBackground.Tints[TeamIndex] = HudColorBlack;
		TeleportBackground.Tints[TeamIndex].A = 150;
		DrawSpriteWidget (C, TeleportBackground);
		DrawSpriteWidget (C, TeleportBackgroundDisc);
		TeleportPulse.Tints[TeamIndex] = HudColorHighLight;
		DrawSpriteWidget( C, TeleportPulse );
		DrawSpriteWidget (C, TeleportIcon);
	}

	//
	// Numeric
	//

	/* Round Time Limit */
	if ( ASGRI.RoundTimeLimit > 0 )
	{
		DrawNumericWidget (C, RoundTimeMinutes, DigitsBig);
		DrawNumericWidget (C, RoundTimeSeconds, DigitsBig);
	}

	/* reinforcements */
	if ( Level.Game == None || !ASGameInfo(Level.Game).bDisableReinforcements )
		DrawNumericWidget (C, ReinforceSprNum, DigitsBig);

	/* second attack wave comparison */
	if ( ASGRI != None && (ASGRI.CurrentRound % 2 == 0) && !ASGRI.IsPracticeRound() && IsVSRelevant() )
		DrawTeamVS( C );

	/* Teleport */
	if ( ASPRI !=None && ASPRI.bTeleportToSpawnArea && TeleportSprNum.Value >= 0 )
		DrawNumericWidget (C, TeleportSprNum, DigitsBig);
}

/* give ref on 2nd attacking team to beat 1st team (is the team on par for current objective?) */
simulated function DrawTeamVS( Canvas C )
{
	local bool		bIsBehindOtherTeam;
	local int		RelativeTime, hours, minutes, seconds, playerteam;;
	local string	output;
	local float		ScreenX, ScreenY, TotalScaleX, TotalScaleY, TextureDX, TextureDY, XL, YL, Progress;

	// ref. previous team objective completed time
	if ( CurrentObjective.ObjectiveDisabledTime > 0 )
	{
		RelativeTime		= CurrentObjective.ObjectiveDisabledTime - (ASGRI.RoundStartTime-ASGRI.RemainingTime);
		bIsBehindOtherTeam	= RelativeTime < 0;
		hours				= Abs(RelativeTime) / 3600;
		minutes				= (Abs(RelativeTime) - hours*3600) / 60;
		seconds				= Abs(RelativeTime) - hours*3600 - minutes*60;
		
		if ( hours > 0 )
			output = hours $ ":";

		if ( minutes > 9 )
			output = output $ minutes $ ":";
		else
			output = output $ "0" $ minutes $ ":";
		
		if ( seconds > 9 )
			output = output $ seconds;
		else
			output = output $ "0" $ seconds;
	}
	else // ref on progress on the same objective
	{
		Progress = CurrentObjective.SavedObjectiveProgress - CurrentObjective.GetObjectiveProgress();
		bIsBehindOtherTeam	= Progress < 0;
		output = int(Abs(Progress*100)) $ "%";
	}

	// match up widget position voodoo magic crap...
	TotalScaleX = HudCanvasScale * ResScaleX * HudScale;
	TotalScaleY = HudCanvasScale * ResScaleY * HudScale;

	TextureDX = Abs(VSBackgroundDisc.TextureCoords.X2 - VSBackgroundDisc.TextureCoords.X1 + 1.0f) * TotalScaleX * VSBackgroundDisc.TextureScale;
    TextureDY = Abs(VSBackground.TextureCoords.Y2 - VSBackground.TextureCoords.Y1 + 1.0f) * TotalScaleY * VSBackground.TextureScale;

	ScreenX = (VSBackgroundDisc.PosX * HudCanvasScale * C.SizeX) + (((1.0f - HudCanvasScale) * 0.5f) * C.SizeX);
	ScreenY = (VSBackground.PosY * HudCanvasScale * C.SizeY) + (((1.0f - HudCanvasScale) * 0.5f) * C.SizeY);
	ScreenX += VSBackgroundDisc.OffsetX * TotalScaleX + TextureDX*1;
	ScreenY += VSBackground.OffsetY * TotalScaleY + TextureDY*0.45;

	// And finally... we can draw!
	C.Font = GetMediumFont( C.ClipX * HUDScale );
	C.TextSize( output, XL, YL );
	C.Style = ERenderStyle.STY_Alpha;

	// defender version
	if ( PawnOwner == None )
		playerteam = PlayerOwner.GetTeamNum();
	else
		playerteam = PawnOwner.GetTeamNum();
	if ( ASGRI.IsDefender(playerteam) )
		bIsBehindOtherTeam = !bIsBehindOtherTeam;

	if ( bIsBehindOtherTeam )
	{	
		output = "-" $ output;
		C.DrawColor = C.MakeColor( 255, 0, 0, 255 );
	}
	else 
		C.DrawColor = C.MakeColor( 0, 255, 0, 255 );

	C.SetPos( ScreenX, ScreenY - YL/2);
	C.DrawText( output, false );
}

/* Can we compare progress of second attacking team, with the first one ? */
simulated function bool IsVSRelevant()
{
	if ( ASGRI.RoundWinner != ERW_None || CurrentObjective == None 
		|| (CurrentObjective.ObjectiveDisabledTime == 0 && (CurrentObjective.SavedObjectiveProgress == 0 || CurrentObjective.SavedObjectiveProgress == 1
		|| (CurrentObjective.SavedObjectiveProgress - CurrentObjective.GetObjectiveProgress() > 0) )) )
		return false;

	return true;
}

simulated function ShowTeamScorePassC(Canvas C);

simulated function DrawSpectatingHud (Canvas C)
{
	super.DrawSpectatingHud( C );

	UpdateTeamHud();
	ShowTeamScorePassA( C );
	DrawAssaultHUDLayer( C );
}

//
// Radar
//

function DrawRadarPassA( Canvas C )
{
	local float			Dist, RadarWidth, DotSize, OffsetY, XL, YL, OffsetScale;
	local vector		Start, DotPos, ViewX, ViewY, Z;

	if ( PawnOwner == None )
		return;

	ASRadarScale	= default.ASRadarScale * HUDScale;
	RadarWidth		= 0.5 * ASRadarScale * C.ClipX;
	C.Style			= ERenderStyle.STY_Alpha;

	// Radar background
	C.DrawColor = GetTeamColor( PawnOwner.GetTeamNum() );
	C.SetPos(ASRadarPosX*C.ClipX - RadarWidth, ASRadarPosY*C.ClipY+RadarWidth);
	C.DrawTile( Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 0, 512, 512, -512);
	C.SetPos(ASRadarPosX*C.ClipX, ASRadarPosY*C.ClipY+RadarWidth);
	C.DrawTile( Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 512, 512, -512, -512);
	C.SetPos(ASRadarPosX*C.ClipX - RadarWidth, ASRadarPosY*C.ClipY);
	C.DrawTile( Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 0, 0, 512, 512);
	C.SetPos(ASRadarPosX*C.ClipX, ASRadarPosY*C.ClipY);
	C.DrawTile( Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 512, 0, -512, 512);

	Start		= PawnOwner.Location;
	OffsetY		= ASRadarPosY + RadarWidth/C.ClipY;
	C.DrawColor = WhiteColor;
	OffsetScale	= ASRadarScale*0.0000835;

	GetAxes( PawnOwner.GetViewRotation(), ViewX, ViewY, Z );

	// Cardinal Points display
	if ( bDrawRadarCardinalPoints )
	{
		Dist		= 5500;
		C.Font		= GetConsoleFont( C );

		C.StrLen(Cardinal_North, XL, YL);
		DotPos = GetRadarDotPosition( C, Vect(0,-100,0), ViewX, ViewY, Dist*OffsetScale, OffsetY );
		C.SetPos( DotPos.X - 0.5*XL, DotPos.Y - 0.5*YL );
		C.DrawText( Cardinal_North, false );

		C.StrLen(Cardinal_East, XL, YL);
		DotPos = GetRadarDotPosition( C, Vect(100,0,0), ViewX, ViewY, Dist*OffsetScale, OffsetY );
		C.SetPos( DotPos.X - 0.5*XL, DotPos.Y - 0.5*YL );
		C.DrawText( Cardinal_East, false );

		C.StrLen(Cardinal_South, XL, YL);
		DotPos = GetRadarDotPosition( C, Vect(0,100,0), ViewX, ViewY, Dist*OffsetScale, OffsetY );
		C.SetPos( DotPos.X - 0.5*XL, DotPos.Y - 0.5*YL );
		C.DrawText( Cardinal_South, false );

		C.StrLen(Cardinal_West, XL, YL);
		DotPos = GetRadarDotPosition( C, Vect(-100,0,0), ViewX, ViewY, Dist*OffsetScale, OffsetY );
		C.SetPos( DotPos.X - 0.5*XL, DotPos.Y - 0.5*YL );
		C.DrawText( Cardinal_West, false );
	}

	// Draw Center
	C.DrawColor = WhiteColor;
	DotSize		= 12*C.ClipX*HUDScale/1600;
	DotPos		= GetRadarDotPosition( C, PawnOwner.Location-Start, ViewX, ViewY, 0.f, OffsetY);
	C.SetPos( DotPos.X - 0.5*DotSize, DotPos.Y - 0.5*DotSize );
	C.DrawTile(Material'HudContent.Generic.HUD', DotSize, DotSize,340,432,78,78);
}

simulated function DrawRadarPassB( Canvas C )
{
	local Vehicle		P;
	local float			Dist, RadarWidth, DotSize, OffsetY;
	local vector		Start, DotPos, ViewX, ViewY, Z;
	local float			MaxSmartRange, OffsetScale;
	local int			i;

	if ( PawnOwner == None )
		return;

	Start			= PawnOwner.Location;
	ASRadarScale	= default.ASRadarScale * HUDScale;
	RadarWidth		= 0.5 * ASRadarScale * C.ClipX;
	OffsetY			= ASRadarPosY + RadarWidth/C.ClipY;
	MaxSmartRange	= 30000;
	DotSize			= 20*C.ClipX*HUDScale/1600;
	C.Style			= ERenderStyle.STY_Additive;
	OffsetScale		= ASRadarScale*0.0000835;

	GetAxes( PawnOwner.GetViewRotation(), ViewX, ViewY, Z );

	// Draw nearby vehicles
	if ( Level.TimeSeconds > LastRadarUpdate+1 )
	{
		LastRadarUpdate = Level.TimeSeconds;
		RadarVehicleCache.Length = 0; // Clear cache

		ForEach DynamicActors(class'Vehicle', P)
		{
			if ( (P!=PawnOwner) && (P.GetTeamNum() != PawnOwner.GetTeamNum()) && (P!=TrackedVehicle) && (P.Health > 0) && !P.bDeleteMe && P.IndependentVehicle() )
			{
				RadarVehicleCache[RadarVehicleCache.Length] = P;
				Dist = GetRadarDotDist( P.Location-Start, ViewX, ViewY );
				if ( Dist < MaxSmartRange )
				{
					Dist = ApplySmartRangeDist( Dist*0.5 );

					// Show current Target on radar
					if ( PawnOwner.IsA('ASVehicle_SpaceFighter')
						&& ASVehicle_SpaceFighter(PawnOwner).CurrentTarget == P )
						C.DrawColor = GetTeamColor(P.GetTeamNum())*(1.f-fPulse) + C.MakeColor(64,200,64)*fPulse;
					else
						C.DrawColor = GetTeamColor( P.GetTeamNum() );

					DotPos = GetRadarDotPosition( C, P.Location-Start, ViewX, ViewY, Dist*OffsetScale, OffsetY );
					C.SetPos( DotPos.X - 0.5*DotSize, DotPos.Y - 0.5*DotSize );
					C.DrawTile(Material'HudContent.Generic.HUD', DotSize, DotSize,340,432,78,78);
				}
			}
		}
	}
	else // Use cached vehicles, to minize use of expensive DynamicActors iterator.
	{
		for (i=0; i<RadarVehicleCache.Length; i++)
		{
			P = RadarVehicleCache[i];
			if ( (P!=None) && (P!=PawnOwner) && (P.GetTeamNum() != PawnOwner.GetTeamNum()) && (P!=TrackedVehicle) && (P.Health > 0) && !P.bDeleteMe && P.IndependentVehicle() )
			{
				Dist = GetRadarDotDist( P.Location - Start, ViewX, ViewY );
				if ( Dist < MaxSmartRange )
				{
					Dist = ApplySmartRangeDist( Dist*0.5 );

					// Show current Target on radar
					if ( PawnOwner.IsA('ASVehicle_SpaceFighter')
						&& ASVehicle_SpaceFighter(PawnOwner).CurrentTarget == P )
						C.DrawColor = GetTeamColor(P.GetTeamNum())*(1.f-fPulse) + C.MakeColor(64,200,64)*fPulse;
					else
						C.DrawColor = GetTeamColor( P.GetTeamNum() );

					DotPos = GetRadarDotPosition( C, P.Location-Start, ViewX, ViewY, Dist*OffsetScale, OffsetY );
					C.SetPos( DotPos.X - 0.5*DotSize, DotPos.Y - 0.5*DotSize );
					C.DrawTile(Material'HudContent.Generic.HUD', DotSize, DotSize,340,432,78,78);
				}
			}
		}
	}
}

function float ApplySmartRangeDist( float Dist )
{
	// "Smart Range"
	if ( Dist > 3000 )
		Dist = (Dist-3000)*0.25 + 2000;
	else if ( Dist > 1000 )
		Dist = (Dist-1000)*0.5 + 1000;

	return FMin(Dist, 5500);	// Small hack so dots stay inside the Radar...
}

function float GetRadarDotDist( Vector Dist, Vector ViewX, Vector ViewY )
{
	local vector	DotProjected;

	// Top view 2D projection relatively to player's rotation coordinate system
	DotProjected.X	= Dist Dot Normal(ViewX);
	DotProjected.Y	= Dist Dot Normal(ViewY);

	return VSize( DotProjected );
}

function vector GetRadarDotPosition( Canvas C, Vector Dist, Vector ViewX, Vector ViewY, float OffsetScale, float OffsetY )
{
	local vector	ScreenPosition, DotProjected;

	// Top view 2D projection relatively to player's rotation coordinate system
	DotProjected.X	= Normal(Dist) Dot Normal(ViewX);
	DotProjected.Y	= Normal(Dist) Dot Normal(ViewY);

	ScreenPosition.X = ASRadarPosX * C.ClipX	+ OffsetScale*C.ClipX * DotProjected.Y;
	ScreenPosition.Y = OffsetY * C.ClipY		- OffsetScale*C.ClipX * DotProjected.X;

	return ScreenPosition;
}


//
// Actor Tracking
//

/* Tracked Actors indicators */
simulated function UpdateActorTracking( Canvas C )
{
	local Vehicle				V;
	local vector				ScreenPos;

	// Tracked Vehicle (Assumes only 1 per Assault Level) (eg. JunkYard's PRV or Glacier's Ion Plasma Tank)
	if ( TrackedVehicle == None && NextTrackedVehicleSearch < Level.TimeSeconds )
	{
		NextTrackedVehicleSearch = Level.TimeSeconds + 1;
		ForEach DynamicActors(class'Vehicle', V)
			if ( V.bHUDTrackVehicle )
			{
				TrackedVehicle = V;
				break;
			}
	}

		// FIXME -- Check that PlayerOwner.Pawn != WeaponPawn attached to TrackedVehicle
	//if ( TrackedVehicle != None && TrackedVehicle != PlayerOwner.Pawn )

	if ( TrackedVehicle != None && (TrackedVehicle!=PawnOwner) && TrackedVehicle.Health > 0
		&& !TrackedVehicle.bDeleteMe )
	{
		C.DrawColor		= GetTeamColor( TrackedVehicle.Team );
		C.DrawColor.A	= 128;
		if ( DrawActorTracking( C, TrackedVehicle, false, ScreenPos ) )
			DrawTrackedVehicleIcon( C, TrackedVehicle, ScreenPos.X, ScreenPos.Y, 1.f );
	}

	// Tracked GameObject (eg. JunkYard Energy Core)
	if ( ASGRI != None && ASGRI.GameObject != None && PawnOwner != None
		&& ASGRI.GameObject.HolderPRI != PawnOwner.PlayerReplicationInfo )
	{
		C.DrawColor		= GoldColor;
		C.DrawColor.A	= 128;
		if ( DrawActorTracking( C, ASGRI.GameObject, false, ScreenPos ) )
			DrawTrackedGameObjectIcon( C, ScreenPos.X, ScreenPos.Y, 1.f );
	}
}

simulated function DrawTrackedVehicleIcon( Canvas C, Vehicle TrackedVehicle, float X, float Y, float Scale )
{
	local float	SizeScale, SizeX, SizeY, Ratio;

	if ( TrackedVehicle.VehicleIcon.Material == None )
		return;

	SizeScale	= ObjectiveScale * HUDScale * Scale;
	Ratio		= TrackedVehicle.VehicleIcon.SizeX / TrackedVehicle.VehicleIcon.SizeY;
	SizeX		= 32*SizeScale*ResScaleX;
	SizeY		= (32/Ratio)*SizeScale*ResScaleY;
	
	if ( TrackedVehicle.VehicleIcon.bIsGreyScale )
		C.DrawColor = GetTeamColor( 1 - TrackedVehicle.Team );
	else
		C.DrawColor = WhiteColor;
	
	C.DrawColor.A = 127 + 128*fPulse;
	C.Style		= ERenderStyle.STY_Alpha;

	C.SetPos(X - SizeX*0.5, Y - SizeY*0.5);
	C.DrawTile( TrackedVehicle.VehicleIcon.Material , SizeX, SizeY, 
		TrackedVehicle.VehicleIcon.X, TrackedVehicle.VehicleIcon.Y, TrackedVehicle.VehicleIcon.SizeX, TrackedVehicle.VehicleIcon.SizeY);
}

simulated function DrawTrackedGameObjectIcon( Canvas C, float X, float Y, float Scale )
{
	local float	Size;

	Size = 16.f * ResScaleX * ObjectiveScale * HUDScale * Scale;

	C.DrawColor = WhiteColor;
	C.DrawColor.A = 127 + 128*fPulse;
	C.Style		= ERenderStyle.STY_Alpha;
	C.SetPos(X - Size * 0.5, Y - Size * 1.f);
	C.DrawTile( Material'HudContent.Generic.HUD', Size, Size, 79, 223, 37, 41);
}

simulated function bool DrawActorTracking( Canvas C, Actor A, bool bOptionalIndicator, out vector ScreenPos )
{
	local Vector	CamLoc;
	local Rotator	CamRot;
	local float		ProgressPct;

	C.GetCameraLocation( CamLoc, CamRot );

	if ( A.IsA('Pawn') )
		ProgressPct = float(Pawn(A).Health) / Pawn(A).HealthMax;

	if ( !IsTargetInFrontOfPlayer( C, A, ScreenPos, CamLoc, CamRot ) )
	{
		if ( !A.IsA('GameObjective') || bDrawAllObjectives )
		{
			DrawActorTracking_Behind( C, A, bOptionalIndicator, CamLoc, CamRot, ScreenPos );
			if ( ProgressPct > 0 )
				DrawObjectiveStatusOverlay( C, ProgressPct, false, ScreenPos, ObjectiveScale*0.67 );
			return true;
		}

		return false;
	}
	else if ( VSize(A.Location - CamLoc) > 2048 || !FastTrace( A.Location, CamLoc) )
	{
		DrawActorTracking_Obstructed( C, A, bOptionalIndicator, CamLoc, ScreenPos );
		if ( ProgressPct > 0 )
			DrawObjectiveStatusOverlay( C, ProgressPct, false, ScreenPos, ObjectiveScale*0.67 );
		return true;
	}

	if ( ProgressPct > 0 )
	{
		ScreenPos.Y -= 48 * ResScaleX;
		DrawHealthBar( C, ScreenPos, ProgressPct, 1.f, C.DrawColor );
	}
	return false;
}

simulated function DrawActorTracking_Obstructed( Canvas C, Actor A, bool bOptionalIndicator, vector CamLoc, out vector ScreenPos )
{
	local String	DistanceText;
	local float		XL, YL, tileX, tileY, width, height;
	local vector	IndicatorPos;

	C.Style			= ERenderStyle.STY_Alpha;
	DistanceText	= IP_Bracket_Open $ int(VSize(A.Location-CamLoc)*0.01875.f) $ MetersString $ IP_Bracket_Close;
	C.Font			= GetConsoleFont( C );

	C.StrLen(DistanceText, XL, YL);
	XL = XL*0.5;
	YL = YL*0.5;

	tileX	= 64.f * 0.45 * ResScaleX * ObjectiveScale * HUDScale;
	tileY	= 64.f * 0.45 * ResScaleY * ObjectiveScale * HUDScale;

	width	= FMax(tileX*0.5, XL);
	height	= tileY*0.5 + YL*2;
	ClipScreenCoords( C, ScreenPos.X, ScreenPos.Y, width, height );

	// Objective Icon
	IndicatorPos.X = ScreenPos.X;
	IndicatorPos.Y = ScreenPos.Y - height + YL + tileY*0.5;
	DrawObjectiveIcon( C, bOptionalIndicator, IndicatorPos.X - tileX*0.5, IndicatorPos.Y - tileY*0.5, tileX, tileY );

	// Distance reading
	C.SetPos(IndicatorPos.X - XL, IndicatorPos.Y + tileY*0.5 );
	C.DrawText(DistanceText, false);

	ScreenPos = IndicatorPos;
}

simulated function DrawActorTracking_Behind( Canvas C, Actor A, bool bOptionalIndicator, vector CamLoc, rotator CamRot, out vector ScreenPos )
{
	local vector		Orientation;
	local float			tileX, tileY;
	local TexRotator	Arrow;

	C.Style			= ERenderStyle.STY_Alpha;

	Orientation = GetTargetOrientation( A, CamLoc, CamRot );
	Orientation = ExpandTargetOrientationToCanvas( C, Orientation );

	ScreenPos.X = C.ClipX * 0.5 + C.ClipX * Orientation.X * 0.5;
	ScreenPos.Y = C.ClipY * 0.5 - C.ClipY * Orientation.Y * 0.5;

	// Setup texture
	Arrow = Get_BehindObjectiveArrow();

	tileX	= 128.f * 0.45 * ResScaleX * ObjectiveScale * HUDScale;
	tileY	= 128.f * 0.45 * ResScaleY * ObjectiveScale * HUDScale;

	ClipScreenCoords( C, ScreenPos.X, ScreenPos.Y, tileX*0.5, tileY*0.5 );

	// Setup Texture properly
	Arrow.Rotation.Yaw	= Atan( Orientation.Y, Orientation.X ) * 32768 / PI;

	if ( bOptionalIndicator )
		Arrow.Material = Texture'AS_FX_TX.HUD.Objective_Optional_Indicator';
	else
		Arrow.Material = Texture'AS_FX_TX.HUD.Objective_Primary_Indicator';

	C.SetPos(ScreenPos.X - tileX*0.5, ScreenPos.Y - tileY*0.5);
	C.DrawTile( Arrow, tileX, tileY, 0.0, 0.0, 128, 128);

	BehindObjectiveCount++;
}


//
// Objectives
//

/* On-HUD Objective notification */
simulated function DrawObjectives(Canvas C)
{
	local int			i;
	local GameObjective	GO;
	local vector		ScreenPos;
	local vector		CamLoc;
	local rotator		CamRot;

	BehindObjectiveCount = 0;	// Keep track of number of required materials

	// On Screen objective notification
	for (i=0; i<OBJ.Length; i++)
	{
		GO = OBJ[i];

		if ( GO.IsActive() && GO.bUsePriorityOnHUD && CheckObjectivePriority( GO ) )
		{
			C.DrawColor = GetObjectiveColor( GO );
			C.Style		= ERenderStyle.STY_Alpha;
			C.GetCameraLocation( CamLoc, CamRot );

			if ( IsObjectiveVisible( C, GO, ScreenPos, CamLoc, CamRot ) )
			{
				DrawVisibleObjective( C, GO, ScreenPos, CamRot );
			}
			else if ( IsTargetInFrontOfPlayer( C, GO, ScreenPos, CamLoc, CamRot ) )
			{
				C.DrawColor.A = 128;
				DrawActorTracking_Obstructed( C, GO, GO.bOptionalObjective, CamLoc, ScreenPos );
				DrawObjectiveStatusOverlay( C, GO.GetObjectiveProgress(), false, ScreenPos, ObjectiveScale*0.67 );
				if ( GO.IsCritical() )
					DrawCriticalObjectiveOverlay( C, ScreenPos, ObjectiveScale );
			}
			else if ( bDrawAllObjectives )	// Draw 'objective behind player' indicatorsobject
			{
				DrawActorTracking_Behind( C, GO, GO.bOptionalObjective, CamLoc, CamRot, ScreenPos );
				DrawObjectiveStatusOverlay( C, GO.GetObjectiveProgress(), false, ScreenPos, ObjectiveScale*0.67 );
				if ( GO.IsCritical() )
					DrawCriticalObjectiveOverlay( C, ScreenPos, ObjectiveScale*0.60 );
			}
		}
	}
}

/* Draw Visible Objectives */
simulated function DrawVisibleObjective( Canvas C, GameObjective GO, vector ScreenPos, Rotator CamRot )
{
	local float			tileX, tileY;
	local float			AppearEffect;
	local String		UseString;
	local color			ObjColor;
	local bool			bFadeOut;
	local byte			bProgressPulsing;
	local float			FadeOutEffect, ProgressPct;

	ObjColor = GetObjectiveColor( GO, bProgressPulsing );

	// UseObjective doesn't fadeout...
	bFadeOut = !GO.IsA('UseObjective');

	// restart "appear" fx if target not drawn for a few frames, or after OBJ_ReAppearTime seconds
	if ( bFadeOut && ((Level.TimeSeconds-GO.LastDrawTime) > Global_Delta*6.f
		|| (GO.DrawTime > OBJ_ReAppearTime)) )
			GO.DrawTime = 0.f;

	GO.DrawTime		+= Global_Delta;
	GO.LastDrawTime  = Level.TimeSeconds;

	// If not faded out, draw objective HUD icon
	if ( !bFadeOut || (GO.DrawTime <= OBJ_FadedOutTime) )
	{
		if ( bFadeOut && (GO.DrawTime > (OBJ_FadedOutTime - 1.f)) )
			FadeOutEffect =  OBJ_FadedOutTime - GO.DrawTime;
		else
			FadeOutEffect = 1.f;

		C.DrawColor = ObjColor * FadeOutEffect;

		if ( bProgressPulsing == 0 )
			C.DrawColor.A = 63 + 128 * fPulse * FadeOutEffect;
		else
			C.DrawColor.A = 127 * FadeOutEffect;

		AppearEffect	= 0.5 / FMin(GO.DrawTime, 0.5);
		tileX			= 64.f * ResScaleX * AppearEffect * ObjectiveScale * HUDScale;
		tileY			= 64.f * ResScaleY * AppearEffect * ObjectiveScale * HUDScale;

		C.Style = ERenderStyle.STY_Alpha;
		C.SetPos(ScreenPos.X - tileX*0.5, ScreenPos.Y - tileY*0.5);

		if ( GO.IsA('UseObjective') )
		{
			if ( GO.UseDescription != "" )
			{
				UseString	= IP_Bracket_Open @ GO.UseDescription @ IP_Bracket_Close;
				C.Font		= GetConsoleFont( C );
			}

			Draw_2DCollisionBox( C, GO, ScreenPos, UseString, GO.DrawScale, false );
		}
		else if ( GO.ObjectiveTypeIcon != None )
			C.DrawTile( GO.ObjectiveTypeIcon, tileX, tileY, 0.0, 0.0, 64, 64);

		// Defense Shield Overlay
		if ( PawnOwner != None && ASGRI.IsDefender( PawnOwner.GetTeamNum() ) )
		{
			if ( GO.IsCritical() )
				C.DrawColor = GreenColor*fPulse + GoldColor*(1-fPulse);
			else
				C.DrawColor = GreenColor;

			if ( bProgressPulsing == 0 )
				C.DrawColor.A = (63 + 128 * fPulse) * FadeOutEffect;
			else
				C.DrawColor.A = 127 * FadeOutEffect;

			tileX = 1.25*ObjectiveScale*HUDScale*ResScaleX;
			tileY = 1.25*ObjectiveScale*HUDScale*ResScaleY;
			C.SetPos(ScreenPos.X - tileX * 32, ScreenPos.Y - tileY * 32);
			C.DrawTile( Texture'AS_FX_TX.HUD.OBJ_Status', 64*tileX, 64*tileY, 191.0, 191.0, 64, 64);
		}
	}

	// Draw Objective Progress
	ProgressPct = GO.GetObjectiveProgress();
	if ( ProgressPct > 0 )
	{
		ScreenPos.Y -= 48 * ResScaleX;
		DrawHealthBar( C, ScreenPos, ProgressPct, 1.f, ObjColor );
	}
}

simulated function DrawCriticalObjectiveOverlay( Canvas C, vector ScreenPos, float Scale )
{
	local float SizeScale, SizeX, SizeY;

	SizeScale = 0.33 * HUDScale * Scale;
	SizeX = 24 * SizeScale * ResScaleX;
	SizeY = 62 * SizeScale * ResScaleY;

	C.DrawColor = WhiteColor;
	C.SetPos(ScreenPos.X - SizeX * 0.5, ScreenPos.Y - SizeY * 0.5);
	C.DrawTile( FinalBlend'HudContent.Generic.HUDPulse', SizeX, SizeY, 344, 210, 20, 62);
}


/* Draw Objective status overlay
(health or completion progress) */
simulated function DrawObjectiveStatusOverlay( Canvas C, float Progress, bool bCriticalFlash, vector ScreenPos, float Scale )
{
	local float SizeScale, SizeX, SizeY, PosX, PosY;

	if ( Progress <= 0 )
		return;

	SizeScale = 0.5 * HUDScale * Scale;
	SizeX = 64 * SizeScale * ResScaleX;
	SizeY = 64 * SizeScale * ResScaleY;

	C.DrawColor		= GetGYRColorRamp( Progress );
	if ( bCriticalFlash )
		C.DrawColor = C.DrawColor*fPulse + GoldColor*(1-fPulse);
	C.DrawColor.A	= 128;
	C.SetPos(ScreenPos.X - SizeX * 0.5, ScreenPos.Y - SizeY * 0.5);

	// texture coords
	if ( Progress > 0.6 )
	{
		PosX = 64 * (10 - Ceil(Progress*10));
		PosY = 0;
	}
	else if ( Progress > 0.2 )
	{
		PosX = 64 * (6 - Ceil(Progress*10));
		PosY = 64;
	}
	else
	{
		PosX = 64 * (2 - Ceil(Progress*10));
		PosY = 128;
	}

	C.DrawTile( Texture'AS_FX_TX.HUD.OBJ_Status', SizeX, SizeY, PosX, PosY, 64, 64);
}

simulated function DrawObjectiveIcon( Canvas C, bool bOptionalObjective, float posX, float posY, float tileX, float tileY )
{
	C.SetPos(posX, posY);

	if ( bOptionalObjective )
		C.DrawTile( Texture'AS_FX_TX.HUD.OBJ_Status', tileX, tileY, 191.0, 127.0, 64, 64);
	else
		C.DrawTile( Texture'AS_FX_TX.HUD.OBJ_Status', tileX, tileY, 127.0, 127.0, 64, 64);
}

/* Allocate new "Behind Objective Arrow" material when necessary */
simulated function TexRotator Get_BehindObjectiveArrow()
{
	Local TexRotator	Arrow;

	if ( BehindObjectiveArrows.Length <= BehindObjectiveCount || BehindObjectiveArrows[BehindObjectiveCount] == None )
	{
		Arrow = TexRotator(Level.ObjectPool.AllocateObject(class'TexRotator'));
		Arrow.UOffset	= 64;
		Arrow.VOffset	= 64;
		BehindObjectiveArrows[BehindObjectiveCount] = Arrow;
	}

	return BehindObjectiveArrows[BehindObjectiveCount];
}

simulated function Release_BehindObjectiveArrows()
{
	local int i;

	for (i=0; i<BehindObjectiveArrows.Length; i++)
		Level.ObjectPool.FreeObject( BehindObjectiveArrows[i] );
}

/* Draw Objective Pointing Arrow */
simulated function Draw3dObjectiveArrow( Canvas C )
{
	local Actor	TrackedActor;

	if ( PlayerOwner == None || ASGRI == None )
		return;

	if ( OBJPointingArrow == None )
	{
		OBJPointingArrow = Spawn(class'ObjectivePointingArrow', PlayerOwner );

		if ( OBJPointingArrow == None )
			return;
	}

	if (  ASGRI.GameObject != None && ASGRI.GameObject.HolderPRI != PawnOwner.PlayerReplicationInfo )
	{
		TrackedActor = ASGRI.GameObject;
		OBJPointingArrow.SetYellowColor( AttackerProgressUpdateTime > 0 );
	}
	else if ( CurrentObjective != None )
	{
		TrackedActor = CurrentObjective;
		if ( ObjectiveBoard != None && ObjectiveBoard.AnyPrimaryObjectivesCritical() )
			OBJPointingArrow.SetYellowColor( true );
		else
			OBJPointingArrow.SetTeamSkin( CurrentObjective.DefenderTeamIndex, AttackerProgressUpdateTime > 0 );
	}

	if ( TrackedActor != None )
		OBJPointingArrow.Render( C, PlayerOwner, TrackedActor );
}

simulated function Release_ObjectivePointingArrow()
{
	if ( OBJPointingArrow != None )
		OBJPointingArrow.Destroy();
}

/* Draws little health bar... */
simulated function DrawHealthBar(Canvas C, vector HBScreenPos, float Health, float MaxHealth, Color ObjColor)
{
	local float		HealthPct;

    C.DrawColor		= ObjColor;
    C.Style			= ERenderStyle.STY_Alpha;
	HealthBarWidth	= default.HealthBarWidth * ResScaleX * HUDScale;
	HealthBarHeight = default.HealthBarHeight * ResScaleY * HUDScale;

    C.SetPos(HBScreenPos.X - HealthBarWidth*0.5, HBScreenPos.Y - HealthBarHeight*0.5);
    C.DrawTileStretched(HealthBarBackMat, HealthBarWidth, HealthBarHeight);

    HealthPct		= Health / MaxHealth;
	C.DrawColor		= GetGYRColorRamp( HealthPct );
	C.DrawColor.A	= 200;

	C.SetPos(HBScreenPos.X - HealthBarWidth*0.49, HBScreenPos.Y - HealthBarHeight*0.3 );
    C.DrawTileStretched(HealthBarMat, HealthBarWidth*HealthPct*0.98, HealthBarHeight*0.6);
}

/* returns true if Objective can be displayed */
simulated function bool	CheckObjectivePriority(GameObjective GO)
{
   	if ( GO.ObjectivePriority <= ObjectiveProgress )
		return true;

	return false;
}

/* Return true if GameObjective is visible */
simulated final function bool IsObjectiveVisible( Canvas C, GameObjective Target, out vector ScreenPos,
												 Vector CamLoc, Rotator CamRot )
{
	local vector		TargetLocation, TargetDir;
	local float			Dist;

	// Check if in same Zone
	if ( !Target.bOverrideZoneCheck && PawnOwner != None
		&& PawnOwner.Region.Zone != Target.Region.Zone )
		return false;

	Dist = VSize(Target.Location - CamLoc);

	// Check Distance Threshold
	if ( (Target.DrawDistThresHold > 0) && ( Dist > Target.DrawDistThresHold) )
		return false;

	// Target is located behind camera
	if ( !IsTargetInFrontOfPlayer( C, Target, ScreenPos, CamLoc, CamRot ) )
		return false;

	if ( !Target.bOverrideVisibilityCheck )
	{
		// Simple Line check to see if we hit geometry
		TargetDir		= Target.Location - CamLoc;
		TargetDir.Z		= 0;
		TargetLocation	= Target.Location - 2.f * Target.CollisionRadius * vector(rotator(TargetDir));

		if ( !FastTrace( TargetLocation, CamLoc ) )
			return false;
	}

	return true;
}


//
// Objective Progress
//

event AnnouncementPlayed( Name AnnouncerSound, byte Switch )
{
	local int i;

	if ( Switch == 200 )					// Highlight current objective + waypoint
		HighlightCurrentObjective( true );
	else if ( Switch == 201 )				// Highlight current objective
		HighlightCurrentObjective( false );

	else if ( Switch == 210 )				// ASMessageTrigger
	{
		for (i=0; i<MTrigger.Length; i++)
		{
			if ( (MTrigger[i].AnnouncerSound != None) && (MTrigger[i].AnnouncerSound.Name == AnnouncerSound) )
			{
				if ( MTrigger[i].Message != "" )
					PlayerOwner.TeamMessage(PlayerOwner.PlayerReplicationInfo, MTrigger[i].Message, 'CriticalEvent');

				if ( CurrentObjective != None )
				{
					// When trigger is used to announce current objective, force highlight!
					if ( (CurrentObjective.Announcer_ObjectiveInfo != None) && (CurrentObjective.Announcer_ObjectiveInfo.Name == AnnouncerSound) )
						HighlightCurrentObjective( true );

					// When trigger is used to announce current objective, force highlight!
					if ( (CurrentObjective.Announcer_DefendObjective != None) && (CurrentObjective.Announcer_DefendObjective.Name == AnnouncerSound) )
						HighlightCurrentObjective( true );
				}
				break;
			}
		}
	}
}

/* Blink HUD indicators on current objective */
simulated function HighlightCurrentObjective( bool bShowWayPoint )
{
	// Pulse current objective
	AttackerProgressUpdateTime = ObjectiveProgressPulseTime;

	// Show waypoint towards current objective
	if ( bShowWillowWhisp && bShowWayPoint && PlayerOwner != None && UnrealPlayer(PlayerOwner) != None )
		UnrealPlayer(PlayerOwner).ServerShowPathToBase( 255 );
}

/* Update CurrentObjective */
simulated function NotifyUpdatedObjective()
{
	local GameObjective OldObjective;

	OldObjective = CurrentObjective;
	CurrentObjective = None;	// force update
	CurrentObjective = GetCurrentObjective();

	if ( OldObjective != CurrentObjective && CurrentObjective != None )
		HighlightCurrentObjective( false );
}

simulated function GameObjective GetCurrentObjective()
{
	local GameObjective GO;
	local int			i;

	// Try to find currently active objective...
	if ( CurrentObjective == None && ASGRI != None )

		for (i=0; i<OBJ.Length; i++)
		{
			GO = OBJ[i];
			if ( (ASGRI.ObjectiveProgress == GO.ObjectivePriority)
				&& GO.IsActive() && ( !GO.bOptionalObjective || CurrentObjective == None ) )
				CurrentObjective = GO;
		}

	return CurrentObjective;
}

/* Return Spawn Notification (Team Role + Current Objective Announcer) */
simulated function bool CanSpawnNotify()
{
	if ( bForceSpawnNotification || (bObjectiveReminder && Level.TimeSeconds > NextSpawnNotification) )
	{
		NextSpawnNotification	= Level.TimeSeconds + 30;
		bForceSpawnNotification	= false;
		return true;
	}

	return false;
}


//
// InfoPods
//

/* main InfoPod drawing routine */
simulated function DrawInfoPods( Canvas C )
{
	local InfoPod	IP;
	local vector	IPScreenPos, CamLoc;
	local int		i;
	local rotator	CamRot;

	if ( ASGRI == None || PawnOwner == None || PlayerOwner == None )
		return;

	C.GetCameraLocation( CamLoc, CamRot );

	for (i=0; i<InfoPods.Length; i++)
	{
		IP = InfoPods[i];

		if ( IP == None || IP.bDisabled )
			continue;

		// Team check
		if ( IP.Team != EIP_All )
		{
			if ( IP.Team == EIP_Attackers && ASGRI.IsDefender(PawnOwner.GetTeamNum()) )
				continue;
			if ( IP.Team == EIP_Defenders && !ASGRI.IsDefender(PawnOwner.GetTeamNum()) )
				continue;
		}

		// skip if InfoPod is not visible
		if ( !IP.IsInfoPodVisible(C, PawnOwner, CamLoc, CamRot) )
			continue;

		// Don't draw if target is located outside of the canvas
		IPScreenPos = C.WorldToScreen( IP.Location );
		if ( IPScreenPos.X <= 0 || IPScreenPos.X >= C.ClipX ) continue;
		if ( IPScreenPos.Y <= 0 || IPScreenPos.Y >= C.ClipY ) continue;

		// Color
		if ( IP.Team == EIP_All )
			C.DrawColor = WhiteColor;
		else
			C.DrawColor = GetTeamColor( PawnOwner.GetTeamNum() );

		// Opacity effect
		switch ( IP.InfoEffect )
		{
			case EIPE_Blink : C.DrawColor.A = (IP.DrawOpacity*0.5 + IP.DrawOpacity*2*fBlink); break;
			case EIPE_Pulse : C.DrawColor.A = (IP.DrawOpacity*0.5 + IP.DrawOpacity*0.5*fPulse); break;
			default			: C.DrawColor.A = IP.DrawOpacity;
		}

		IP.Render( C, IPScreenPos, PlayerOwner );
	}
}


//
// Custom HUDs
//

static function DrawCustomHealthInfo( Canvas C, PlayerController PC, bool bSkaarj )
{
	local float		XL, YL;
	local float		XO, YO;
	local float		HealthPct;
	local float		ScaleX, ScaleY;
	local float		myfPulse;

	if ( PC.Pawn != None )
		HealthPct = FClamp( float(PC.Pawn.Health) / PC.Pawn.HealthMax, 0.f, 1.f );
	else
		HealthPct = 0.f;

	ScaleX		= PC.myHUD.ResScaleX * PC.myHUD.HUDScale;
	ScaleY		= PC.myHUD.ResScaleY * PC.myHUD.HUDScale;

	// Ugly hack FIXME
	if ( HUD_Assault(PC.myHUD) != None )
		myfPulse = HUD_Assault(PC.myHUD).fPulse;
	else
		myfPulse = 1.f;

	C.Style	= ERenderStyle.STY_Alpha;
	XL = 256 * 0.5 * ScaleX;
	YL = 128 * 0.5 * ScaleY;

	// Team color overlay
	C.DrawColor = GetTeamColor( PC.GetTeamNum() );
	C.SetPos( 0, C.ClipY - YL );
	C.DrawTile(Texture'AS_FX_TX.HUD.SpaceHUD_Health_Grey', XL, YL, 0, 0, 256, 128);

	// Solid Background
	C.DrawColor = C.MakeColor(255, 255, 255);
	C.SetPos( 0, C.ClipY - YL );
	if ( bSkaarj )
		C.DrawTile(Texture'AS_FX_TX.HUD.SpaceHUD_Health_Solid_Skaarj', XL, YL, 0, 0, 256, 128);
	else
		C.DrawTile(Texture'AS_FX_TX.HUD.SpaceHUD_Health_Solid', XL, YL, 0, 0, 256, 128);

	// Health Bar
	XL	=			80 * 0.5 * ScaleX;
	YL	=			10 * 0.5 * ScaleY;
	XO	=		   147 * 0.5 * ScaleX;
	YO	= C.ClipY - 20 * 0.5 * ScaleY;

	C.DrawColor		= GetGYRColorRamp( HealthPct );
	C.DrawColor.A	= 96;

	C.SetPos( XO - XL*0.5, YO - YL*0.5 );
	C.DrawTile(Texture'InterfaceContent.WhileSquare', XL*HealthPct, YL, 0, 0, 8, 8);

	// Health Icon
	XL	=			64 * 0.5 * ScaleX;
	YL	=			64 * 0.5 * ScaleY;
	XO	=		   114 * 0.5 * ScaleX;
	YO	= C.ClipY - 62 * 0.5 * ScaleY;

	if ( HealthPct < 0.34 )
	{
		C.DrawColor = C.DrawColor * myfPulse + C.MakeColor(255, 255, 255) * (1.f-myfPulse);
		C.DrawColor.A = 96;
	}

	C.SetPos( XO - XL*0.5, YO - YL*0.5 );
	C.DrawTile(Texture'AS_FX_TX.HUD.SpaceHUD_HealthIcon', XL, YL, 0, 0, 64, 64);
}


function bool CustomHUDColorAllowed()
{
	return false;
}

//
// Helper
//

static function Color GetTeamColor( byte Team )
{
	if ( Team == 0 )
		return default.HudColorRed;
	else if ( Team == 1 )
		return default.HudColorBlue;
	else
		return default.GreenColor;
}

simulated function Color GetObjectiveColor( GameObjective GO, optional out byte bProgressPulsing )
{
	local Color	ObjColor;

	ObjColor = GetTeamColor( GO.DefenderTeamIndex );

	if ( GO.IsCritical() )
	{
		ObjColor = ObjColor * (1-fPulse) + GoldColor * fPulse;
	}
	else if ( !GO.bOptionalObjective ) // Objective Progress Pulsing
	{
		if ( AttackerProgressUpdateTime > 0 )
		{
			ObjColor = ObjColor * (1-fPulse) + WhiteColor * fPulse;
			bProgressPulsing = 1;
		}
	}

	return ObjColor;
}

/* returns Green (1.f) -> Yellow -> Red (0.f) Color Ramp */
static function Color GetGYRColorRamp( float Pct )
{
	local Color GYRColor;

	GYRColor.A = 255;

	if ( Pct < 0.34 )
	{
    	GYRColor.R = 128 + 127 * FClamp(3.f*Pct, 0.f, 1.f);
		GYRColor.G = 0;
		GYRColor.B = 0;
	}
    else if ( Pct < 0.67 )
	{
    	GYRColor.R = 255;
		GYRColor.G = 255 * FClamp(3.f*(Pct-0.33), 0.f, 1.f);
		GYRColor.B = 0;
	}
    else
	{
		GYRColor.R = 255 * FClamp(3.f*(1.f-Pct), 0.f, 1.f);
		GYRColor.G = 255;
		GYRColor.B = 0;
	}

	return GYRColor;
}

/* returns true if target is projected on visible canvas area */
static function bool IsTargetInFrontOfPlayer( Canvas C, Actor Target, out Vector ScreenPos,
											 Vector CamLoc, Rotator CamRot )
{
	// Is Target located behind camera ?
	if ( (Target.Location - CamLoc) Dot vector(CamRot) < 0)
		return false;

	// Is Target on visible canvas area ?
	ScreenPos = C.WorldToScreen( Target.Location );
	if ( ScreenPos.X <= 0 || ScreenPos.X >= C.ClipX ) return false;
	if ( ScreenPos.Y <= 0 || ScreenPos.Y >= C.ClipY ) return false;

	return true;
}

/* Clip Screen Coordinates to fit Canvas visible area */
static function ClipScreenCoords( Canvas C, out float X, out float Y, optional float XL, optional float YL )
{
	if ( X < XL ) X = XL;
	if ( Y < YL ) Y = YL;
	if ( X > C.ClipX - XL ) X = C.ClipX - XL;
	if ( Y > C.ClipY - YL ) Y = C.ClipY - YL;
}

/* Draws Brackets around an Actor's collision cylinder */
static function Draw_2DCollisionBox( Canvas C, Actor A, Vector ScrPos, String Description, float ColExpand, bool bSizeOverride )
{
	local vector	TmpScrCorner[2], ScrCornerY[2], ScrCornerX[2];
	local float		XL, YL, X, Y, BXL, BYL;
	local vector	CameraLocation;
	local rotator	CameraRotation;

	C.GetCameraLocation( CameraLocation, CameraRotation );
	C.Style = ERenderStyle.STY_Alpha;

	// Get Box Height...
	if ( CameraLocation.Z < A.Location.Z )
	{
		ScrCornerY[0] = GetScreenCorner( C, A, Vect( 1, 0, 1), ScrPos, CameraRotation, ColExpand );	// Top Front
		ScrCornerY[1] = GetScreenCorner( C, A, Vect(-1, 0,-1), ScrPos, CameraRotation, ColExpand );	// Bottom Back
	}
	else
	{
		ScrCornerY[0] = GetScreenCorner( C, A, Vect(-1, 0, 1), ScrPos, CameraRotation, ColExpand );	// Top Back
		ScrCornerY[1] = GetScreenCorner( C, A, Vect( 1, 0,-1), ScrPos, CameraRotation, ColExpand );	// Bottom Front
	}

	// Get Width of box...
	TmpScrCorner[0] = GetScreenCorner( C, A, Vect( 0, 1, 1), ScrPos, CameraRotation, ColExpand ); // Left Top
	TmpScrCorner[1] = GetScreenCorner( C, A, Vect( 0, 1,-1), ScrPos, CameraRotation, ColExpand ); // Left Bottom
	ScrCornerX[0].X	= Max( TmpScrCorner[0].X, TmpScrCorner[1].X );

	TmpScrCorner[0] = GetScreenCorner( C, A, Vect( 0,-1, 1), ScrPos, CameraRotation, ColExpand ); // Right Top
	TmpScrCorner[1] = GetScreenCorner( C, A, Vect( 0,-1,-1), ScrPos, CameraRotation, ColExpand ); // Right Bottom
	ScrCornerX[1].X	= Max( TmpScrCorner[0].X, TmpScrCorner[1].X );

	// Description Text
	if ( Description != "" )
	{
		C.StrLen(Description, XL, YL);

		// Description Clipping
		TmpScrCorner[0].X = ScrPos.X - ScrCornerX[0].X;
		TmpScrCorner[0].Y = ScrPos.Y - ScrCornerY[0].Y - YL;
		if ( TmpScrCorner[0].X < 0 )
			TmpScrCorner[0].X = 0;
		if ( TmpScrCorner[0].X + XL > C.ClipX )
			TmpScrCorner[0].X = C.ClipX - XL;
		if ( TmpScrCorner[0].Y < 0 )
			TmpScrCorner[0].Y = 0;

		// Drawing Description
		C.SetPos(TmpScrCorner[0].X, TmpScrCorner[0].Y);
		C.DrawText(Description, false);
	}

	BXL = 16.f * C.SizeX / 640.f;
	BYL = 16.f * C.SizeY / 480.f;

	// Maximum BOX overlapping (skip drawing when too small)
	if ( ScrCornerX[0].X + ScrCornerX[1].X < BXL )
	{
		if ( !bSizeOverride )
			return;

		ScrCornerX[0].X = BXL*0.5;
		ScrCornerX[1].X = BXL*0.5;
	}
	if ( ScrCornerY[0].Y + ScrCornerY[1].Y < BYL )
	{
		if ( !bSizeOverride )
			return;

		ScrCornerY[0].Y = BYL*0.5;
		ScrCornerY[1].Y = BYL*0.5;
	}

	// Top left corner
	X = FMax( ScrPos.X - ScrCornerX[0].X, 0 );
	Y = FMax( ScrPos.Y - ScrCornerY[0].Y, YL );
	C.SetPos(X, Y);
	C.DrawTile(Material'AS_FX_TX.Icons.InfoBracket_FB', BXL, BYL, 0.f, 0.f, 32.f, 32.f);

	// Top right corner
	X = FMin( ScrPos.X + ScrCornerX[1].X - BXL, C.ClipX - BXL );
	Y = FMax( ScrPos.Y - ScrCornerY[0].Y, YL );
	C.SetPos(X, Y);
	C.DrawTile(Material'AS_FX_TX.Icons.InfoBracket_FB', BXL, BYL, 0.f, 0.f, -32.f, 32.f);

	// Bottom left corner
	X = FMax( ScrPos.X - ScrCornerX[0].X, 0 );
	Y = FMin( ScrPos.Y + ScrCornerY[1].Y - BYL, C.ClipY - BYL );
	C.SetPos(X, Y);
	C.DrawTile(Material'AS_FX_TX.Icons.InfoBracket_FB', BXL, BYL, 0.f, 0.f, 32.f, -32.f);

	// Bottom right corner
	X = FMin( ScrPos.X + ScrCornerX[1].X - BXL, C.ClipX - BXL );
	Y = FMin( ScrPos.Y + ScrCornerY[1].Y - BYL, C.ClipY - BYL );
	C.SetPos(X, Y);
	C.DrawTile(Material'AS_FX_TX.Icons.InfoBracket_FB', BXL, BYL, 0.f, 0.f, -32.f, -32.f);
}

/* Helper to get cylinder's "corners" (edges on projected canvas) */
static function vector GetScreenCorner( Canvas C, Actor A, Vector CornerVect, Vector IPScrO, Rotator CameraRotation, float ColExpand )
{
	local vector	IPDir, IPCorner, IPScreenCorner;

	// Finding "corner's" 3D location...
	IPDir		= -1 * Vector(CameraRotation);
	IPDir.Z		= 0;											// we just need the horizontal direction..
	IPCorner	= CornerVect >> Normalize( Rotator(IPDir) );	// Rotate vector to point to specified "corner"...

	// Expand by collision radius...
	IPCorner.X *= A.CollisionRadius * ColExpand;
	IPCorner.Y *= A.CollisionRadius * ColExpand;
	IPCorner.Z *= A.CollisionHeight * ColExpand;

	// Screen coordinates of IP's "corner"
	IPScreenCorner		= C.WorldToScreen( A.Location + IPCorner );
	IPScreenCorner.X	= Abs( IPScreenCorner.X - IPScrO.X );
	IPScreenCorner.Y	= Abs( IPScreenCorner.Y - IPScrO.Y );

	return IPScreenCorner;
}

/* return vector X, Y components of target orientation (on a 1 unit circle) */
final static function vector GetTargetOrientation( Actor Target, vector CamLoc, rotator CamRot )
{
	local vector	X, Y, Z;
	local vector	Orientation;
	local float		Dist, DirY, DirZ;

	// Project onto Camera Y/Z plane
	GetAxes( CamRot, X, Y, Z );
	DirY = Normal(Target.Location - CamLoc) Dot Normal(Y);
	DirZ = Normal(Target.Location - CamLoc) Dot Normal(Z);

	// Normalize vector (so it describes a 1 unit circle)
	Dist = Sqrt(DirY*DirY + DirZ*DirZ);

	Orientation.X = DirY / Dist;
	Orientation.Y = DirZ / Dist;

	return Orientation;
}

/* Expand normalized orientation to canvas' edges */
final static function vector ExpandTargetOrientationToCanvas( Canvas C, vector Orientation )
{
	local float Edge;

	// Find Canvas' edge
	if ( Abs(Orientation.X) > Abs(Orientation.Y) )
		Edge = 1.f / Abs(Orientation.X);
	else if ( Abs(Orientation.X) < Abs(Orientation.Y) )
		Edge = 1.f / Abs(Orientation.Y);

	Orientation.X = Orientation.X * Edge;
	Orientation.Y = Orientation.Y * Edge;

	return Orientation;
}

simulated function DrawTextWithBackground( Canvas C, String Text, Color TextColor, float XO, float YO )
{
	local float	XL, YL, XL2, YL2;

	C.StrLen( Text, XL, YL );

	XL2	= XL + 64 * ResScaleX;
	YL2	= YL +  8 * ResScaleY;

	C.DrawColor = C.MakeColor(0, 0, 0, 150);
	C.SetPos( XO - XL2*0.5, YO - YL2*0.5 );
	C.DrawTile(Texture'HudContent.Generic.HUD', XL2, YL2, 168, 211, 166, 44);

	C.DrawColor = TextColor;
	C.SetPos( XO - XL*0.5, YO - YL*0.5 );
	C.DrawText( Text, false );
}

//
// Misc HUD stuffs
//

simulated function Tick(float DeltaTime)
{
	super.Tick( DeltaTime );

	Global_Delta = DeltaTime;

	fBlink += DeltaTime;
	while ( fBlink > 0.5 )
		fBlink -= 0.5;

	fPulse = Abs(1.f - 4*fBlink);

	if ( ASGRI == None && PlayerOwner.GameReplicationInfo != None )
		ASGRI = ASGameReplicationInfo(PlayerOwner.GameReplicationInfo);

	if ( PawnOwner != None && PawnOwner.PlayerReplicationInfo != None )
		ASPRI = ASPlayerReplicationInfo(PawnOwner.PlayerReplicationInfo);

	AttackerProgressUpdateTime = FMax(AttackerProgressUpdateTime - Global_Delta, 0);

	if ( ASGRI != None )
	{
		ObjectiveProgress = ASGRI.ObjectiveProgress;
		if ( OldObjectiveProgress != ObjectiveProgress || CurrentObjective == None || !CurrentObjective.IsActive() )
		{
			NotifyUpdatedObjective();
			if ( OldObjectiveProgress != ObjectiveProgress )
				OldObjectiveProgress = ObjectiveProgress;
		}
	}

	if ( PrevTeam != PlayerOwner.GetTeamNum() )
	{
		TeamChanged();
		PrevTeam = PlayerOwner.GetTeamNum();
	}
}

simulated event TeamChanged()
{
	bForceSpawnNotification = true;
}

simulated function DrawPracticeRoundInfo( Canvas C )
{
	local Color	myColor;
	local float	Seconds;

	if ( PlayerOwner == None || ASGRI == None || ScoreBoard == None || ASGRI.RoundTimeLimit == 0)
		return;

	C.Font	= GetFontSizeIndex( C, 0 );
	C.Style = ERenderStyle.STY_Alpha;
	myColor = GoldColor*(1.f-fPulse) + WhiteColor * fPulse;
	Seconds = Max(0, ASGRI.RoundTimeLimit-ASGRI.RoundStartTime+ASGRI.RemainingTime);

	if ( ASGRI.RoundWinner != ERW_None )
		Seconds = ASGRI.RoundOverTime;

	DrawTextWithBackground( C, PracticeRoundString @ ScoreBoard.FormatTime(Seconds), myColor, C.ClipX*0.5, C.ClipY*0.67 );
}

function CheckCountdown(GameReplicationInfo GRI)
{
	local int					RemainingRoundTime;

	if ( ASGRI == None )
	{
		super.CheckCountdown( GRI );
		return;
	}

	// Don't play time notifications when round has ended.
	if ( ASGRI.RoundWinner != ERW_None )
		return;

	RemainingRoundTime = ASGRI.RoundTimeLimit - ASGRI.RoundStartTime + ASGRI.RemainingTime;

	if ( ASGRI.RoundTimeLimit == 0 )	// if RoundTimeLimit disabled, then announce global time limit
		super.CheckCountdown( ASGRI );

	if ( (RemainingRoundTime < 1) || (RemainingRoundTime == OldRemainingRoundTime) || (ASGRI.RoundWinner != ERW_None) )
		return;

	OldRemainingRoundTime = RemainingRoundTime;
	if ( OldRemainingRoundTime > 300 )
		return;
	if ( OldRemainingRoundTime > 30 )
	{
		if ( OldRemainingRoundTime == 300 )
			PlayerOwner.QueueAnnouncement(LongCountName[0], 1);
		else if ( OldRemainingRoundTime == 180 )
			PlayerOwner.QueueAnnouncement(LongCountName[1], 1);
		else if ( OldRemainingRoundTime == 120 )
			PlayerOwner.QueueAnnouncement(LongCountName[2], 1);
		else if ( OldRemainingRoundTime == 60 )
			PlayerOwner.QueueAnnouncement(LongCountName[3], 1);
		return;
	}
	if ( OldRemainingRoundTime == 30 )
		PlayerOwner.QueueAnnouncement( LongCountName[4], 1 );
	else if ( OldRemainingRoundTime == 20 )
		PlayerOwner.QueueAnnouncement( LongCountName[5], 1, AP_InstantPlay );
	else if ( (OldRemainingRoundTime <= 10) && (OldRemainingRoundTime > 0) )
		PlayerOwner.QueueAnnouncement( CountDownName[OldRemainingRoundTime - 1], 1, AP_InstantOrQueueSwitch, 1 );
}


simulated function String GetInfoString()
{
	local string InfoString;
	//local int	 PTeam;

	if ( ASGRI == None )
		return NoGameReplicationInfoString;

	if ( ASGRI.RoundWinner != ERW_None )
	{
		return ASGRI.GetRoundWinnerString();
		/*
		if ( ASGRI.IsPracticeRound() )
			return 	class'ScoreBoard_Assault'.default.PracticeRoundOver;

		if ( PawnOwner == None )
			PTeam = PlayerOwner.GetTeamNum();
		else
			PTeam = PawnOwner.GetTeamNum();

		if ( PTeam == ASGRI.RoundWinner )
			InfoString = class'ScoreBoard_Assault'.default.YouWonRound;
		else
			InfoString = class'ScoreBoard_Assault'.default.YouLostRound;

		return InfoString;
		*/
	}

    if ( GUIController(PlayerOwner.Player.GUIController).ActivePage!=None)
   		return AtMenus;

	if ( ASPRI != None && ASPRI.bAutoRespawn )
	{
		InfoString = class'ScoreBoard_Assault'.default.AutoRespawn;
		InfoString = InfoString @ ASGRI.ReinforcementCountDown;
		return InfoString;
	}

	if ( ASGRI.ReinforcementCountDown > 0 && !PlayerOwner.IsInState('PlayerWaiting') )
	{

		if ( PlayerOwner.IsDead() )
			InfoString = class'ScoreBoard_Assault'.default.WaitForReinforcements;
		else
			InfoString = class'ScoreBoard_Assault'.default.WaitingToSpawnReinforcements;

		InfoString = InfoString @ ASGRI.ReinforcementCountDown;
	}
	else
		InfoString = super.GetInfoString();

	return InfoString;
}

// debug to show current valid playerstarts
exec function ShowSpawnAreas()
{
	local NavigationPoint		N;
	local PlayerStart			PS;
	local PlayerSpawnManager	PSM;

	log("==============");
	log("ShowSpawnAreas");
	log("==============");

	// Log PlayerSpawmManagers
	foreach AllActors(class'PlayerSpawnManager', PSM)
	{
		log("PlayerSpawnManager:" @ PSM @ "bEnabled:" @ PSM.bEnabled @ "Tag:" @ PSM.Tag );

		// log PlayerStarts
		if ( PSM.bEnabled )
			for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			{
				PS = PlayerStart(N);
				if ( PS == None ) continue;

				if ( PS.TeamNumber == PSM.PlayerStartTeam )
					log( " " @ PS );
			}
	}

	log("==============");
	log("End...........");
	log("==============");
}

simulated function UpdatePrecacheStaticMeshes()
{
	super.UpdatePrecacheStaticMeshes();
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.fX.ObjectiveArrow' );
}

simulated function UpdatePrecacheMaterials()
{
	super.UpdatePrecacheMaterials();
    Level.AddPrecacheMaterial(Material'AS_FX_TX.Skins.Obj_3dArrow_Blue');
	Level.AddPrecacheMaterial(Material'AS_FX_TX.Skins.Obj_3dArrow_Yellow');
	Level.AddPrecacheMaterial(Material'AS_FX_TX.Skins.Obj_3dArrow_Red');

    Level.AddPrecacheMaterial(Material'AS_FX_TX.HUD.OBJ_Status');

	Level.AddPrecacheMaterial(Material'InterfaceContent.Menu.BorderBoxD');
	Level.AddPrecacheMaterial(Material'ONSInterface-TX.HealthBar');
	Level.AddPrecacheMaterial(Material'AS_FX_TX.Icons.ScoreBoard_Objective_Final');
	Level.AddPrecacheMaterial(Material'AS_FX_TX.Icons.ScoreBoard_Objective_Single');
	Level.AddPrecacheMaterial(Material'AS_FX_TX.Icons.InfoBracket');
	Level.AddPrecacheMaterial(Material'AS_FX_TX.HUD.Objective_Primary_Indicator');
	Level.AddPrecacheMaterial(Material'AS_FX_TX.HUD.Objective_Optional_Indicator');
}


/* Called when viewing a Matinee cinematic */
simulated function DrawCinematicHUD( Canvas C )
{
	IntroTitleFade += Global_Delta;

	// Draw level title
	if ( IntroTitleFade < 10 )
		DrawIntroTitle( C );

	super.DrawCinematicHUD( C );

	// Film Grain Overlay
	if ( !Level.IsSoftwareRendering() && Level.DetailMode > DM_LOW )
	{
		C.SetPos(0,0);
		C.Style	= ERenderStyle.STY_Alpha;
		C.DrawTile( Material'AssaultFilmGrain.FGfb', C.ClipX, C.ClipY, 0, 0, C.ClipX*0.67, C.ClipY*0.67);
	}
}

simulated function DrawIntroTitle( Canvas C )
{
	local int		FontIndex;
	local String	LevelTitle;
	local float		XL, YL;

	C.DrawColor = WhiteColor;
	C.Style		= ERenderStyle.STY_Alpha;
	FontIndex	= 8;
	LevelTitle	= Level.Title;

	do	// make sure name is not too big
	{
		C.Font = GetFontSizeIndex( C, FontIndex-- );
		C.TextSize( LevelTitle, XL, YL );
	} until ( (XL < C.ClipX*0.67) && (YL < C.ClipY*0.67) )

	if ( IntroTitleFade < 1 )									// Hidden
		C.DrawColor.A = 0;				
	else if ( IntroTitleFade < 3 )								// fade in
		C.DrawColor.A = 255 * ((IntroTitleFade-1)*0.5);
	else if ( IntroTitleFade > 6 )								// fade out
		C.DrawColor.A = 255 * (1.f - ((IntroTitleFade-6)/4));
	else
		C.DrawColor.A = 255;									// normal
	C.SetPos( (C.ClipX-XL)*0.5, (C.ClipY-YL)*0.5 );
	C.DrawText( LevelTitle, false );
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     ObjectiveScale=1.000000
     bOnHUDObjectiveNotification=True
     bShowInfoPods=True
     bShow3DArrow=True
     bObjectiveReminder=True
     bDrawRadar=True
     bDrawRadarCardinalPoints=True
     bShowWillowWhisp=True
     OBJ_ReAppearTime=7.000000
     OBJ_FadedOutTime=6.000000
     ASRadarScale=0.200000
     ASRadarPosX=0.900000
     ASRadarPosY=0.200000
     HealthBarBackMat=Texture'InterfaceContent.Menu.BorderBoxD'
     HealthBarMat=Texture'ONSInterface-TX.HealthBar'
     HealthBarWidth=80.000000
     HealthBarHeight=8.000000
     IP_Bracket_Open="["
     IP_Bracket_Close="]"
     Cardinal_North="N"
     Cardinal_East="E"
     Cardinal_South="S"
     Cardinal_West="W"
     NoGameReplicationInfoString="Receiving Server State..."
     MetersString="m"
     TargetString="Target:"
     NoTargetString="No Target"
     PracticeRoundString="Practice Round"
     ObjectiveProgressPulseTime=7.000000
     ObjectiveProgress=255
     OldObjectiveProgress=255
     RoundTimeBackGround=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=168,Y1=211,X2=334,Y2=255),TextureScale=0.530000,OffsetY=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ReinforceBackground=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=168,Y1=211,X2=334,Y2=255),TextureScale=0.530000,PosY=0.060000,OffsetY=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TeleportBackground=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=168,Y1=211,X2=334,Y2=255),TextureScale=0.530000,PosY=0.180000,OffsetY=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VSBackground=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=168,Y1=211,X2=334,Y2=255),TextureScale=0.530000,PosY=0.120000,OffsetY=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RoundTimeIcon=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=150,Y1=356,X2=184,Y2=389),TextureScale=0.530000,DrawPivot=DP_MiddleLeft,OffsetX=15,OffsetY=28,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ReinforceIcon=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=111,Y1=355,X2=144,Y2=390),TextureScale=0.530000,DrawPivot=DP_MiddleLeft,PosY=0.060000,OffsetX=15,OffsetY=28,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TeleportIcon=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=429,Y1=136,X2=489,Y2=173),TextureScale=0.400000,DrawPivot=DP_MiddleLeft,PosY=0.180000,OffsetX=9,OffsetY=37,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VSIcon=(WidgetTexture=Texture'AS_FX_TX.Icons.ScoreBoard_Objective_Final',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=128),TextureScale=0.170000,DrawPivot=DP_MiddleLeft,PosY=0.120000,OffsetX=37,OffsetY=90,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ReinforcePulse=(WidgetTexture=FinalBlend'HUDContent.Generic.HUDPulse',RenderStyle=STY_Alpha,TextureCoords=(X1=342,Y1=438,X2=406,Y2=502),TextureScale=0.500000,DrawPivot=DP_MiddleLeft,PosY=0.060000,OffsetX=1,OffsetY=28,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TeleportPulse=(WidgetTexture=FinalBlend'HUDContent.Generic.HUDPulse',RenderStyle=STY_Alpha,TextureCoords=(X1=342,Y1=438,X2=406,Y2=502),TextureScale=0.500000,DrawPivot=DP_MiddleLeft,PosY=0.180000,OffsetX=1,OffsetY=28,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VSPulse=(WidgetTexture=FinalBlend'HUDContent.Generic.HUDPulse',RenderStyle=STY_Alpha,TextureCoords=(X1=342,Y1=438,X2=406,Y2=502),TextureScale=0.500000,DrawPivot=DP_MiddleLeft,PosY=0.120000,OffsetX=1,OffsetY=28,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RoundTimeBackGroundDisc=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.530000,OffsetX=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ReinforceBackGroundDisc=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.530000,PosY=0.060000,OffsetX=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TeleportBackgroundDisc=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.530000,PosY=0.180000,OffsetX=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VSBackgroundDisc=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.530000,PosY=0.120000,OffsetX=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RoundTimeSeparator=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=495,Y1=91,X2=503,Y2=112),TextureScale=0.540000,DrawPivot=DP_MiddleLeft,OffsetX=100,OffsetY=28,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RoundTimeMinutes=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.540000,DrawPivot=DP_MiddleLeft,OffsetX=20,OffsetY=27,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     RoundTimeSeconds=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.540000,DrawPivot=DP_MiddleLeft,OffsetX=110,OffsetY=27,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255),bPadWithZeroes=1)
     ReinforceSprNum=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.540000,DrawPivot=DP_MiddleLeft,PosY=0.060000,OffsetX=60,OffsetY=27,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255),bPadWithZeroes=1)
     TeleportSprNum=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.540000,DrawPivot=DP_MiddleLeft,PosY=0.180000,OffsetX=60,OffsetY=27,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255),bPadWithZeroes=1)
     HudColorHighLight=(B=32,G=192)
}

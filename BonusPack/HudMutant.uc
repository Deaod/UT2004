// ====================================================================
//  Class: BonusPack.HudMutant
//
//  HUD for Mutant game-type. Adds things like the mutant-detecting radar
//
//  Written by James Golding
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class HudMutant extends HudCDeathMatch;

var()	SpriteWidget		TopRadarBG;
var()	SpriteWidget		CenterRadarBG;

//var()	localized String	CurrentMutantFontName;
//var()	Font				CurrentMutantFontFont;
var()   Color				CurrentMutantColor;
var()   Color				MutantHudTint;

var()	localized String	MutantRangeFontName;
var()	Font				MutantRangeFontFont;
var()   Color				MutantRangeColor;

var()	localized String	BottomFeederText;
var()   Color				BottomFeederTextColor;

var()   Color				AboveMutantColor;
var()   Color				LevelMutantColor;
var()   Color				BelowMutantColor;
var()   Color				RangeDotColor;
var()	float				LevelRampRegion;
var()	bool				bCenterRadar;
var()   bool				bTestHud;

var()	float				RangeRampRegion;
var()	float				MaxAngleDelta;
var()	float				BigDotSize;
var()	float				SmallDotSize;

var()   float				XCen, XRad, YCen, YRad; // Center radar tweaking
var()	float				MNOriginX, MNOriginY, MNSizeX, MNSizeY;
var()	float				BFIOriginX, BFIOriginY, BFISizeX, BFISizeY, BFIMargin, BFIPulseRate;
var()	Material			BottomFeederIcon;

var()	Texture				BottomFeederBeaconMat;

var		transient bool		bMutantHudColor;

function color LerpColor(float Alpha, color A, color B)
{
	local color output;

	output.R = lerp(Alpha, A.R, B.R);
	output.G = lerp(Alpha, A.G, B.G);
	output.B = lerp(Alpha, A.B, B.B);
	output.A = lerp(Alpha, A.A, B.A);

	return output;
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Material'InterfaceContent.HUD.SkinA');
	Super.UpdatePrecacheMaterials();
}

simulated function font LoadMutantRangeFont()
{
	if( MutantRangeFontFont == None )
	{
		MutantRangeFontFont = Font(DynamicLoadObject(MutantRangeFontName, class'Font'));
		if( MutantRangeFontFont == None )
			Log("Warning: "$Self$" Couldn't dynamically load font "$MutantRangeFontName);
	}
	return MutantRangeFontFont;
}

// Alpha Pass ==================================================================================
// Draw radar showing 

simulated function bool PRIIsBottomFeeder(PlayerReplicationInfo PRI)
{
	local MutantGameReplicationInfo mutantInfo;

	mutantInfo = MutantGameReplicationInfo( PlayerOwner.GameReplicationInfo );

	// Check this players PRI against the current BF PRI to see...
	if(PRI == mutantInfo.BottomFeederPRI)
		return true;
	else
		return false;
}

simulated function bool PRIIsMutant(PlayerReplicationInfo PRI)
{
	local MutantGameReplicationInfo mutantInfo;

	mutantInfo = MutantGameReplicationInfo( PlayerOwner.GameReplicationInfo );


	// Check this players PRI against the current Mutant PRI to see...
	if(PRI == mutantInfo.MutantPRI)
		return true;
	else
		return false;
}

// Copy from HudCDeathMatch - need to hack it to change HUD color.
simulated function DrawWeaponBar( Canvas C )
{
	local color RealRedColor, RealBlueColor;
	
	if ( !bMutantHUDColor )
	{
		Super.DrawWeaponBar(C);
		return;
	}
	
	RealRedColor = HudColorRed;
	RealBlueColor = HudColorBlue;
	
	HudColorRed = MutantHUDTint;
	HudColorBlue = MutantHUDTint;

	Super.DrawWeaponBar(C);
	
	HudColorRed = RealRedColor;
	HudColorBlue = RealBlueColor;
}

simulated function DrawHud(Canvas C)
{
	local color RealRedColor, RealBlueColor;

	bMutantHudColor = PRIIsMutant(PlayerOwner.PlayerReplicationInfo);
	
	if ( !bMutantHUDColor )
	{
		Super.DrawHud(C);
		return;
	}
	
	RealRedColor = HudColorRed;
	RealBlueColor = HudColorBlue;
	
	HudColorRed = MutantHUDTint;
	HudColorBlue = MutantHUDTint;

	Super.DrawHud(C);
	
	HudColorRed = RealRedColor;
	HudColorBlue = RealBlueColor;
}

simulated function bool PawnIsVisible(vector vecPawnView, vector X, pawn P)
{
	local vector StartTrace, EndTrace;

    if ( (PawnOwner == None) || (PlayerOwner==None) )
		return false;

	if ( PawnOwner != PlayerOwner.Pawn )
		return false;

	if ( (vecPawnView Dot X) <= 0.70 )
		return false;
		
	StartTrace = PawnOwner.Location;
	StartTrace.Z += PawnOwner.BaseEyeHeight;

	EndTrace = P.Location;
	EndTrace.Z += P.BaseEyeHeight;

	if ( !FastTrace(EndTrace, StartTrace) )
		return false;

	return true;		
}

function DrawCustomBeacon(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
	if ( P.PlayerReplicationInfo != MutantGameReplicationInfo(PlayerOwner.GameReplicationInfo).BottomFeederPRI )
		return;

	C.DrawColor = BottomFeederTextColor;
	C.SetPos(ScreenLocX - 0.125 * BottomFeederBeaconMat.USize, ScreenLocY - 0.125 * BottomFeederBeaconMat.VSize);
	C.DrawTile(BottomFeederBeaconMat, 
		0.25 * BottomFeederBeaconMat.USize, 
		0.25 * BottomFeederBeaconMat.VSize, 
		0.0,
		0.0,
		BottomFeederBeaconMat.USize,
		BottomFeederBeaconMat.VSize);
}

simulated function DrawBottomFeederIndicator(Canvas C); //OBSOLETE

simulated function DrawHudPassA(Canvas C)
{
    local rotator Dir;
    local float Angle, VertDiff, Range, AngleDelta;
	local MutantGameReplicationInfo mutantInfo;
	local xMutantPawn x;

    Super.DrawHudPassA (C);

	mutantInfo = MutantGameReplicationInfo(PlayerOwner.GameReplicationInfo);
	x = xMutantPawn(PawnOwner);

	// If there is a mutant, and we are not it - draw radar indicating mutant location.
	if( bTestHud || (mutantInfo.MutantPRI != None && mutantInfo.MutantPRI != PlayerOwner.PlayerReplicationInfo) )
	{
		// Draw radar outline
		if(bCenterRadar)
		{
			PassStyle=STY_None;
			DrawSpriteWidget (C, CenterRadarBG);
			PassStyle=STY_Alpha;
		}
		else
		{
			DrawSpriteWidget(C, TopRadarBG);
		}

		if(bTestHud)
		{
			Dir = rotator(vect(0, 0, 0) - PawnOwner.Location);
			VertDiff = 0.0 - PawnOwner.Location.Z;
			Range = VSize(vect(0, 0, 0) - PawnOwner.Location) - class'xPawn'.default.CollisionRadius;
		}
		else
		{
			Dir = rotator(mutantInfo.MutantLocation - PawnOwner.Location);
			VertDiff = mutantInfo.MutantLocation.Z - PawnOwner.Location.Z;

			// Remove player radiii from range (so when you are standing next to the mutant range is zero)
			Range = VSize(mutantInfo.MutantLocation - PawnOwner.Location) - (2 * class'xPawn'.default.CollisionRadius);
		}

		Angle = ((Dir.Yaw - PawnOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
	
		if(VertDiff > LevelRampRegion)
			C.DrawColor = AboveMutantColor;
		else if(VertDiff > 0)
			C.DrawColor = LerpColor(VertDiff/LevelRampRegion, LevelMutantColor, AboveMutantColor);
		else if(VertDiff > -LevelRampRegion)
			C.DrawColor = LerpColor(-VertDiff/LevelRampRegion, LevelMutantColor, BelowMutantColor);
		else
			C.DrawColor = BelowMutantColor;

		C.Style = ERenderStyle.STY_Alpha;

		if(bCenterRadar)
		{
			C.SetPos(XCen * C.ClipX + HudScale * XRad * C.ClipX * sin(Angle) - 0.5*BigDotSize*C.ClipX,
				YCen * C.ClipY - HudScale * YRad * C.ClipY * cos(Angle) - 0.5*BigDotSize*C.ClipX );
		}
		else
		{
			C.SetPos(0.492 * C.ClipX + HudScale * 0.034 * C.ClipX * sin(Angle),
				0.042 * C.ClipY - HudScale * 0.045 * C.ClipY * cos(Angle));
		}

		C.DrawTile(Material'InterfaceContent.Hud.SkinA', BigDotSize*C.ClipX, BigDotSize*C.ClipX,838,238,144,144);

		if(bCenterRadar)
		{
			//  Draw dots to indicate mutant range
			AngleDelta = (FMin(RangeRampRegion, Range)/RangeRampRegion) * MaxAngleDelta;

			C.DrawColor = RangeDotColor;

			C.SetPos(XCen * C.ClipX + HudScale * XRad * C.ClipX * sin(Angle + AngleDelta) - 0.5*SmallDotSize*C.ClipX,
				YCen * C.ClipY - HudScale * YRad * C.ClipY * cos(Angle + AngleDelta) - 0.5*SmallDotSize*C.ClipX );

			C.DrawTile(Material'InterfaceContent.Hud.SkinA', SmallDotSize*C.ClipX, SmallDotSize*C.ClipX, 838, 238, 144, 144);

			C.SetPos(XCen * C.ClipX + HudScale * XRad * C.ClipX * sin(Angle - AngleDelta) - 0.5*SmallDotSize*C.ClipX,
				YCen * C.ClipY - HudScale * YRad * C.ClipY * cos(Angle - AngleDelta) - 0.5*SmallDotSize*C.ClipX);

			C.DrawTile(Material'InterfaceContent.Hud.SkinA', SmallDotSize*C.ClipX, SmallDotSize*C.ClipX, 838, 238, 144, 144);
		}
		else
		{
			// Draw on Mutant range in middle of dial
			C.DrawColor = MutantRangeColor;
			C.Font = LoadMutantRangeFont();
			C.DrawTextJustified( Min(int(Range),9999) , 1, 0.4 * C.ClipX, 0.03 * C.ClipY, 0.6 * C.ClipX, 0.08 * C.ClipY);
		}

		// Draw on Mutant name

		C.DrawColor = WhiteColor;
		C.SetPos(C.ClipX * MNOriginX, C.ClipY * MNOriginY);
		C.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', MNSizeX * C.ClipX, MNSizeY * C.ClipY);

		C.DrawColor = CurrentMutantColor;
		C.Font = LoadLevelActionFont();

		
		if( bTestHud)
			C.DrawTextJustified("DefLoc", 1, 0.3 * C.ClipX, 0.015 * C.ClipY, 0.7 * C.ClipX, 0.065 * C.ClipY);
		else
			C.DrawTextJustified(mutantInfo.MutantPRI.PlayerName, 1, 0.3 * C.ClipX, 0.015 * C.ClipY, 0.7 * C.ClipX, 0.065 * C.ClipY);
	}
		
	// If there is no bottom feeder - no more HUD to do.
	if( mutantInfo.BottomFeederPRI == None)
		return;

	// If we are a bottom feeder - indicate on the screen
	if( PRIIsBottomFeeder(PlayerOwner.PlayerReplicationInfo) )
	{
		C.DrawColor = WhiteColor;
		C.SetPos(C.ClipX * BFIOriginX, C.ClipY * BFIOriginY);
		C.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxD', BFISizeX * C.ClipX, BFISizeY * C.ClipY);

		C.DrawColor.R = 255 * (0.5 + 0.5 * Cos(Level.TimeSeconds * Pi * BFIPulseRate));
		C.SetPos(C.ClipX * (BFIOriginX + BFIMargin), C.ClipY * (BFIOriginY + BFIMargin));
		C.DrawTile( BottomFeederIcon, C.ClipX * (BFISizeX - 2*BFIMargin), C.ClipY * (BFISizeY - 2*BFIMargin), 0, 0, 256, 256);
	}
}

// Draw enemy name. Also indicate bottom feeders.
function DisplayEnemyName(Canvas C, PlayerReplicationInfo PRI)
{
	// Send 'bottom feeder' indication
	if( PRIIsBottomFeeder( PRI ) )
		PlayerOwner.ReceiveLocalizedMessage(class'MutantNameMessage',1,PRI);
	else //send blank bottomfeeder message
		PlayerOwner.ReceiveLocalizedMessage(class'MutantNameMessage',0,PRI);
}

simulated function DrawCrosshair (Canvas C)
{
	Super.DrawCrosshair(C);
}

defaultproperties
{
     TopRadarBG=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.350000,DrawPivot=DP_UpperMiddle,PosX=0.500000,PosY=0.010000,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CenterRadarBG=(WidgetTexture=Texture'MutantSkins.HUD.big_circle',RenderStyle=STY_Translucent,TextureCoords=(X1=255,Y2=255),TextureScale=0.800000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     CurrentMutantColor=(B=128,R=255,A=255)
     MutantHudTint=(B=128,R=200,A=100)
     MutantRangeFontName="UT2003Fonts.FontMono"
     MutantRangeColor=(B=200,G=200,R=200,A=255)
     BottomFeederText="BOTTOM FEEDER"
     BottomFeederTextColor=(B=255,G=255,A=255)
     AboveMutantColor=(B=255,A=255)
     LevelMutantColor=(B=255,G=255,R=255,A=255)
     BelowMutantColor=(R=255,A=255)
     RangeDotColor=(B=50,G=200,R=200,A=255)
     LevelRampRegion=500.000000
     bCenterRadar=True
     RangeRampRegion=2500.000000
     MaxAngleDelta=1.000000
     BigDotSize=0.018750
     SmallDotSize=0.011250
     XCen=0.500000
     XRad=0.150000
     YCen=0.500000
     YRad=0.200000
     MNOriginX=0.280000
     MNOriginY=0.008000
     MNSizeX=0.450000
     MNSizeY=0.060000
     BFIOriginX=0.900000
     BFIOriginY=0.640000
     BFISizeX=0.090000
     BFISizeY=0.100000
     BFIMargin=0.010000
     BFIPulseRate=1.000000
     BottomFeederIcon=Texture'MutantSkins.HUD.BFeeder_icon'
     BottomFeederBeaconMat=Texture'TeamSymbols.TeamBeaconT'
}

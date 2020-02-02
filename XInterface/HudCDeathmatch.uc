#exec OBJ LOAD FILE=HudContent.utx

class HudCDeathMatch extends HudBase
    config(User);

var() DigitSet DigitsBig;
var() DigitSet DigitsBigPulse;

var() SpriteWidget AmmoIcon;

var() NumericWidget AdrenalineCount;

// Rank and Spread
var() NumericWidget mySpread;
var() NumericWidget myRank;
var() NumericWidget myScore;

// Timer
var() NumericWidget TimerHours;
var() NumericWidget TimerMinutes;
var() NumericWidget TimerSeconds;
var() SpriteWidget TimerDigitSpacer[2];
var() SpriteWidget TimerIcon;
var() SpriteWidget TimerBackground;
var() SpriteWidget TimerBackgroundDisc;

var() Font LevelActionFontFont;
var() Color LevelActionFontColor;
var() float LevelActionPositionX, LevelActionPositionY;

// Hud Digits
var() NumericWidget DigitsHealth, DigitsVehicleHealth;
var() NumericWidget DigitsAmmo;
var() NumericWidget DigitsShield;

// UDamage
var() NumericWidget UDamageTime;
var() SpriteWidget UDamageIcon;

// Adrenaline Meter
var() SpriteWidget AdrenalineIcon;
var() SpriteWidget AdrenalineBackground;
var() SpriteWidget AdrenalineBackgroundDisc;
var() SpriteWidget AdrenalineAlert;

// Personal Score
var() SpriteWidget MyScoreIcon;
var() SpriteWidget MyScoreBackground;

// Borders
var() SpriteWidget HudHealthALERT, HudVehicleHealthALERT;
var() SpriteWidget HudAmmoALERT;
var() SpriteWidget HudBorderShield;
var() SpriteWidget HudBorderHealth, HudBorderVehicleHealth;
var() SpriteWidget HudBorderAmmo;
var() SpriteWidget HudBorderShieldIcon;
var() SpriteWidget HudBorderHealthIcon, HudBorderVehicleHealthIcon;

// WeaponBar
const WEAPON_BAR_SIZE = 9;

struct WeaponState
{
	var float	PickupTimer;	// set this to > 0 to begin animating
	var bool	HasWeapon;		// did I have this weapon last frame?
};


var() class<Weapon> BaseWeapons[WEAPON_BAR_SIZE];
var() SpriteWidget	BarWeaponIcon[WEAPON_BAR_SIZE];
var() SpriteWidget	BarAmmoIcon[WEAPON_BAR_SIZE];
var() SpriteWidget	BarBorder[WEAPON_BAR_SIZE];
var() SpriteWidget	BarBorderAmmoIndicator[WEAPON_BAR_SIZE];
var float			BarBorderScaledPosition[WEAPON_BAR_SIZE];
var WeaponState		BarWeaponStates[WEAPON_BAR_SIZE];

// RechargeBar
var() SpriteWidget  RechargeBar;

var bool bDrawTimer;
var bool TeamLinked;
var globalconfig bool bShowMissingWeaponInfo;

//------------------------------------------------------------------------------
// Vars for Items
//------------------------------------------------------------------------------

var int CurHealth, LastHealth, CurVehicleHealth, LastVehicleHealth, CurShield, LastShield, MaxShield, CurEnergy, MaxEnergy, LastEnergy;
var float LastDamagedHealth, LastDamagedVehicleHealth, ZoomToggleTime, FadeTime;

// Ammo
var() float MaxAmmoPrimary, CurAmmoPrimary, LastAdrenalineTime;

var transient int CurScore, CurRank, ScoreDiff;

var int OldRemainingTime;
var name CountDownName[10];
var name LongCountName[10];

// WeaponIcons
var() int BarWeaponIconAnim[WEAPON_BAR_SIZE];

// HudColors
var() color HudColorRed, HudColorBlue, HudColorBlack, HudColorHighLight, HudColorNormal, HudColorTeam[2];
var globalconfig color CustomHUDHighlightColor;

// PlayerNames
var PlayerReplicationInfo NamedPlayer;
var float NameTime;

// Player portraits
var Material Portrait;
var float PortraitTime;
var float PortraitX;

var array<SceneManager> MySceneManagers;

var float VehicleDrawTimer;
var Pawn OldPawn;
var string VehicleName;

exec function GrowHUD()
{
	if( !bShowWeaponInfo )
        bShowWeaponInfo = true;
    else if( !bShowPersonalInfo )
        bShowPersonalInfo = true;
    else if( !bShowPoints )
        bShowPoints = true;
    else if ( !bDrawTimer && Default.bDrawTimer )
		bDrawTimer = true;
    else if ( !bShowWeaponBar )
		bShowWeaponBar = true;
	else if ( !bShowMissingWeaponInfo )
		bShowMissingWeaponInfo = true;

	SaveConfig();
}

exec function ShrinkHUD()
{
	if ( bShowMissingWeaponInfo )
		bShowMissingWeaponInfo = false;
	else if ( bShowWeaponBar )
		bShowWeaponBar = false;
	else if ( bDrawTimer )
		bDrawTimer = false;
    else if( bShowPoints )
        bShowPoints = false;
    else if( bShowPersonalInfo )
        bShowPersonalInfo = false;
    else if( bShowWeaponInfo )
        bShowWeaponInfo = false;
	SaveConfig();
}

simulated function UpdatePrecacheMaterials()
{
	local int i;

    Level.AddPrecacheMaterial(Material'HudContent.Generic.HUD');
    Level.AddPrecacheMaterial(Material'HudContent.Generic.HUDPulse');
    Level.AddPrecacheMaterial(Material'XGameShaders.ScreenNoise');
    Level.AddPrecacheMaterial(Material'InterfaceContent.BorderBoxA1');
    Level.AddPrecacheMaterial(Material'Engine.BlackTexture');
    Level.AddPrecacheMaterial(Material'InterfaceContent.ScoreBoxA');

    if ( !bUseCustomWeaponCrosshairs )
		return;

    for ( i=0; i<Crosshairs.Length; i++ )
		Level.AddPrecacheMaterial(Crosshairs[i].WidgetTexture);
}

function PostBeginPlay()
{
	local SceneManager SM;

	Super.PostBeginPlay();

    foreach AllActors(class'SceneManager',SM)
    {
    	MySceneManagers.Length = MySceneManagers.Length+1;
    	MySceneManagers[MySceneManagers.Length-1] = SM;
    }

	if ( CustomCrosshairsAllowed() )
		SetCustomCrosshairs();
}

function bool CustomCrosshairsAllowed()
{
	return true;
}

function bool CustomCrosshairColorAllowed()
{
	return true;
}

function bool CustomHUDColorAllowed()
{
	return true;
}

function SetCustomCrosshairs()
{
	local int i;
	local array<CacheManager.CrosshairRecord> CustomCrosshairs;

	class'CacheManager'.static.GetCrosshairList(CustomCrosshairs);
	Crosshairs.Length = CustomCrosshairs.Length;
	for (i = 0; i < CustomCrosshairs.Length; i++)
	{
		Crosshairs[i].WidgetTexture = CustomCrosshairs[i].CrosshairTexture;

		Crosshairs[i].TextureCoords.X1 = 0;
		Crosshairs[i].TextureCoords.X2 = 64;
		Crosshairs[i].TextureCoords.Y1 = 0;
		Crosshairs[i].TextureCoords.Y2 = 64;

		Crosshairs[i].TextureScale = 0.75;
		Crosshairs[i].DrawPivot = DP_MiddleMiddle;
		Crosshairs[i].PosX = 0.5;
		Crosshairs[i].PosY = 0.5;
		Crosshairs[i].OffsetX = 0;
		Crosshairs[i].OffsetY = 0;
		Crosshairs[i].ScaleMode = SM_None;
		Crosshairs[i].Scale = 1.0;
		Crosshairs[i].RenderStyle = STY_Alpha;
	}

	if ( CustomCrosshairColorAllowed() )
		SetCustomCrosshairColors();
}

function SetCustomCrosshairColors()
{
	local int i, j;

	for (i = 0; i < Crosshairs.Length; i++)
		for (j = 0; j < 2; j++)
			Crosshairs[i].Tints[j] = CrosshairColor;
}

function SetCustomHUDColor()
{
	if ( !CustomHUDColorAllowed() || ((CustomHUDColor.R == 0) && (CustomHUDColor.G == 0) && (CustomHUDColor.B == 0) && (CustomHUDColor.A == 0)) )
	{
		CustomHUDColor = HudColorBlack;
		CustomHUDColor.A = 0;
		HudColorRed = HudColorTeam[0];
		HudColorBlue = HudColorTeam[1];
		bUsingCustomHUDColor = false;
		return;
	}

	bUsingCustomHUDColor = true;

	HudColorRed = CustomHUDColor;
	HudColorBlue = CustomHUDColor;
}

function CheckCountdown(GameReplicationInfo GRI)
{
	if ( (GRI == None) || (GRI.RemainingTime == 0) || (GRI.RemainingTime == OldRemainingTime) || (GRI.Winner != None) )
		return;

	OldRemainingTime = GRI.RemainingTime;
	if ( OldRemainingTime > 300 )
		return;
	if ( OldRemainingTime > 30 )
	{
		if ( OldRemainingTime == 300 )
			PlayerOwner.PlayStatusAnnouncement(LongCountName[0],1,true);
		else if ( OldRemainingTime == 180 )
			PlayerOwner.PlayStatusAnnouncement(LongCountName[1],1,true);
		else if ( OldRemainingTime == 120 )
			PlayerOwner.PlayStatusAnnouncement(LongCountName[2],1,true);
		else if ( OldRemainingTime == 60 )
			PlayerOwner.PlayStatusAnnouncement(LongCountName[3],1,true);
		return;
	}
	if ( OldRemainingTime == 30 )
		PlayerOwner.PlayStatusAnnouncement(LongCountName[4],1,true);
	else if ( OldRemainingTime == 20 )
		PlayerOwner.PlayStatusAnnouncement(LongCountName[5],1,true);
	else if ( (OldRemainingTime <= 10) && (OldRemainingTime > 0) )
		PlayerOwner.PlayStatusAnnouncement(CountDownName[OldRemainingTime - 1],1,true);
}

simulated function Tick(float deltaTime)
{
	local Material NewPortrait;

    Super.Tick(deltaTime);

	// Setup the player portrait to display an incoming voice chat message
	if ( (Level.TimeSeconds - LastPlayerIDTalkingTime < 0.1) && (PlayerOwner.GameReplicationInfo != None) )
	{
		if ( (PortraitPRI == None) || (PortraitPRI.PlayerID != LastPlayerIDTalking) )
		{
			PortraitPRI = PlayerOwner.GameReplicationInfo.FindPlayerByID(LastPlayerIDTalking);
			if ( PortraitPRI != None )
			{
				NewPortrait = PortraitPRI.GetPortrait();
				if ( NewPortrait != None )
				{
					if ( Portrait == None )
						PortraitX = 1;
					Portrait = NewPortrait;
					PortraitTime = Level.TimeSeconds + 3;
				}
			}
		}
		else
			PortraitTime = Level.TimeSeconds + 0.2;
	}
	else
		LastPlayerIDTalking = 0;

	if ( PortraitTime - Level.TimeSeconds > 0 )
		PortraitX = FMax(0,PortraitX-3*deltaTime);
	else if ( Portrait != None )
	{
		PortraitX = FMin(1,PortraitX+3*deltaTime);
		if ( PortraitX == 1 )
		{
			Portrait = None;
			PortraitPRI = None;
		}
	}
}

simulated function UpdateHud()
{
    if ((PawnOwnerPRI != none) && (PawnOwnerPRI.Team != None))
        TeamIndex = Clamp (PawnOwnerPRI.Team.TeamIndex, 0, 1);
    else
        TeamIndex = 1; // default to the blue HUD because it's sexier

    CalculateHealth();
    CalculateAmmo();
    CalculateShield();
    CalculateEnergy();
    CalculateScore();

    DigitsHealth.Value    = CurHealth;
    DigitsVehicleHealth.Value = CurVehicleHealth;
    DigitsAmmo.Value      = CurAmmoPrimary;
    DigitsShield.Value    = CurShield;
    AdrenalineCount.Value = CurEnergy;
    MyScore.Value    = CurScore;

    Super.UpdateHud ();
}

function DrawVehicleName(Canvas C)
{
    local float XL,YL, Fade;

	if (bHideWeaponName)
    	return;

	if (VehicleDrawTimer>Level.TimeSeconds)
    {
	    C.Font = GetMediumFontFor(C);
        C.DrawColor = WhiteColor;

		Fade = VehicleDrawTimer - Level.TimeSeconds;

        if (Fade<=1)
        	C.DrawColor.A = 255 * Fade;

		C.Strlen(VehicleName,XL,YL);
        C.SetPos( (C.ClipX/2) - (XL/2), C.ClipY*0.8-YL);
        C.DrawText(VehicleName);
    }

	if ( (PawnOwner != PlayerOwner.Pawn) || (PawnOwner == OldPawn) )
		return;

	OldPawn = PawnOwner;
	if ( Vehicle(PawnOwner) == None )
		VehicleDrawTimer = FMin(VehicleDrawTimer,Level.TimeSeconds + 1);
	else
	{
		VehicleName = Vehicle(PawnOwner).VehicleNameString;
		VehicleDrawTimer = Level.TimeSeconds+1.5;
	}
}

simulated function DrawAdrenaline( Canvas C )
{
	if ( !PlayerOwner.bAdrenalineEnabled )
		return;

	DrawSpriteWidget( C, AdrenalineBackground );
	DrawSpriteWidget( C, AdrenalineBackgroundDisc );

	if( CurEnergy == MaxEnergy )
	{
		DrawSpriteWidget( C, AdrenalineAlert );
		AdrenalineAlert.Tints[TeamIndex] = HudColorHighLight;
	}

	DrawSpriteWidget( C, AdrenalineIcon );
	DrawNumericWidget( C, AdrenalineCount, DigitsBig);

	if(CurEnergy > LastEnergy)
		LastAdrenalineTime = Level.TimeSeconds;

	LastEnergy = CurEnergy;
	DrawHUDAnimWidget( AdrenalineIcon, default.AdrenalineIcon.TextureScale, LastAdrenalineTime, 0.6, 0.6);
	AdrenalineBackground.Tints[TeamIndex] = HudColorBlack;
	AdrenalineBackground.Tints[TeamIndex].A = 150;

}

simulated function DrawTimer(Canvas C)
{
	local GameReplicationInfo GRI;
	local int Minutes, Hours, Seconds;

	GRI = PlayerOwner.GameReplicationInfo;

	if ( GRI.TimeLimit != 0 )
		Seconds = GRI.RemainingTime;
	else
		Seconds = GRI.ElapsedTime;

	TimerBackground.Tints[TeamIndex] = HudColorBlack;
    TimerBackground.Tints[TeamIndex].A = 150;

	DrawSpriteWidget( C, TimerBackground);
	DrawSpriteWidget( C, TimerBackgroundDisc);
	DrawSpriteWidget( C, TimerIcon);

	TimerMinutes.OffsetX = default.TimerMinutes.OffsetX - 80;
	TimerSeconds.OffsetX = default.TimerSeconds.OffsetX - 80;
	TimerDigitSpacer[0].OffsetX = Default.TimerDigitSpacer[0].OffsetX;
	TimerDigitSpacer[1].OffsetX = Default.TimerDigitSpacer[1].OffsetX;

	if( Seconds > 3600 )
    {
        Hours = Seconds / 3600;
        Seconds -= Hours * 3600;

		DrawNumericWidget( C, TimerHours, DigitsBig);
        TimerHours.Value = Hours;

		if(Hours>9)
		{
			TimerMinutes.OffsetX = default.TimerMinutes.OffsetX;
			TimerSeconds.OffsetX = default.TimerSeconds.OffsetX;
		}
		else
		{
			TimerMinutes.OffsetX = default.TimerMinutes.OffsetX -40;
			TimerSeconds.OffsetX = default.TimerSeconds.OffsetX -40;
			TimerDigitSpacer[0].OffsetX = Default.TimerDigitSpacer[0].OffsetX - 32;
			TimerDigitSpacer[1].OffsetX = Default.TimerDigitSpacer[1].OffsetX - 32;
		}
		DrawSpriteWidget( C, TimerDigitSpacer[0]);
	}
	DrawSpriteWidget( C, TimerDigitSpacer[1]);

	Minutes = Seconds / 60;
    Seconds -= Minutes * 60;

    TimerMinutes.Value = Min(Minutes, 60);
	TimerSeconds.Value = Min(Seconds, 60);

	DrawNumericWidget( C, TimerMinutes, DigitsBig);
	DrawNumericWidget( C, TimerSeconds, DigitsBig);
}


simulated function DrawUDamage( Canvas C )
{
	local xPawn P;

	if (Vehicle(PawnOwner) != None)
		P = xPawn(Vehicle(PawnOwner).Driver);
	else
		P = xPawn(PawnOwner);

	if (P != None && P.UDamageTime > Level.TimeSeconds)
	{
         if (P.UDamageTime > Level.TimeSeconds + 15 )
			UDamageIcon.TextureScale = default.UDamageIcon.TextureScale * FMin((P.UDamageTime - Level.TimeSeconds)* 0.0333,1);

         DrawSpriteWidget(C, UDamageIcon);
         UDamageTime.Value = P.UDamageTime - Level.TimeSeconds ;
         DrawNumericWidget(C, UDamageTime, DigitsBig);
    }
}

simulated function UpdateRankAndSpread(Canvas C)
{
    local int i;

	if ( (Scoreboard == None) || !Scoreboard.UpdateGRI() )
		return;

    for( i=0 ; i<PlayerOwner.GameReplicationInfo.PRIArray.Length ; i++ )
         if(PawnOwnerPRI == PlayerOwner.GameReplicationInfo.PRIArray[i])
         {
            myRank.Value = (i+1);
            break;
         }

	myScore.Value = Min (PawnOwnerPRI.Score, 999);  // max display space
	if ( PawnOwnerPRI == PlayerOwner.GameReplicationInfo.PRIArray[0] )
	{
		if ( PlayerOwner.GameReplicationInfo.PRIArray.Length > 1 )
			mySpread.Value = Min (PawnOwnerPRI.Score - PlayerOwner.GameReplicationInfo.PRIArray[1].Score, 999);
		else
			mySpread.Value = 0;
	}
	else
		mySpread.Value = Min (PawnOwnerPRI.Score - PlayerOwner.GameReplicationInfo.PRIArray[0].Score, 999);

    if( bShowPoints )
    {
		DrawSpriteWidget( C, MyScoreBackground );
		MyScoreBackground.Tints[TeamIndex] = HudColorBlack;
		MyScoreBackground.Tints[TeamIndex].A = 150;

        DrawNumericWidget (C, myScore, DigitsBig);
        if ( C.ClipX >= 640 )
			DrawNumericWidget (C, mySpread, DigitsBig);
        DrawNumericWidget (C, myRank, DigitsBig);
    }
}

simulated function CalculateHealth()
{
    LastHealth = CurHealth;

    if (Vehicle(PawnOwner) != None)
    {
		if ( Vehicle(PawnOwner).Driver != None )
    		CurHealth = Vehicle(PawnOwner).Driver.Health;
    	LastVehicleHealth = CurVehicleHealth;
    	CurVehicleHealth = PawnOwner.Health;
    }
    else
    {
		CurHealth = PawnOwner.Health;
		CurVehicleHealth = 0;
    }
}

simulated function CalculateShield()
{
	local xPawn P;

    LastShield = CurShield;
    if (Vehicle(PawnOwner) != None)
    	P = xPawn(Vehicle(PawnOwner).Driver);
    else
    	P = xPawn(PawnOwner);

    if( P != None )
    {
        MaxShield = P.ShieldStrengthMax;
        CurShield = Clamp(P.ShieldStrength, 0, MaxShield);
    }
    else
    {
        MaxShield = 100;
        CurShield = 0;
    }
}

simulated function CalculateEnergy()
{
	if ( PawnOwner.Controller == None )
	{
		MaxEnergy = PlayerOwner.AdrenalineMax;
		CurEnergy = Clamp (PlayerOwner.Adrenaline, 0, MaxEnergy);
	}
	else
	{
		MaxEnergy = PawnOwner.Controller.AdrenalineMax;
		CurEnergy = Clamp (PawnOwner.Controller.Adrenaline, 0, MaxEnergy);
	}
}

simulated function CalculateAmmo()
{
    MaxAmmoPrimary = 1;
    CurAmmoPrimary = 1;

    if ( (PawnOwner != none) && (PawnOwner.Weapon != none) )
		PawnOwner.Weapon.GetAmmoCount(MaxAmmoPrimary,CurAmmoPrimary);
}

simulated function CalculateScore()
{
    ScoreDiff = CurScore;
    CurScore = PawnOwnerPRI.Score;
}

simulated function string GetScoreText()
{
	return ScoreText;
}

simulated function string GetScoreValue(PlayerReplicationInfo PRI)
{
	return ""$int(PRI.Score);
}

simulated function string GetScoreTagLine()
{
	return InitialViewingString;
}

static function color GetTeamColor( byte TeamNum )
{
	if ( TeamNum == 1 )
		return default.HudColorTeam[1];
	else return default.HudColorTeam[0];
}

function bool IsInCinematic()
{
    local int i;

	if ( MySceneManagers.Length > 0 )
    {
    	for ( i=0; i<MySceneManagers.Length; i++ )
        	if ( MySceneManagers[i].bIsRunning )
        		return true;
    }
    return false;
}

simulated function DrawSpectatingHud (Canvas C)
{
	local string InfoString;
    local plane OldModulate;
    local float xl,yl,Full, Height, Top, TextTop, MedH, SmallH,Scale;
    local GameReplicationInfo GRI;

	// Hack for tutorials.
	bIsCinematic = IsInCinematic();

    DisplayLocalMessages (C);
 
	if ( bIsCinematic )
		return;
		
    OldModulate = C.ColorModulate;

    C.Font = GetMediumFontFor(C);
    C.StrLen("W",xl,MedH);
	Height = MedH;
	C.Font = GetConsoleFont(C);
    C.StrLen("W",xl,SmallH);
    Height += SmallH;

	Full = Height;
    Top  = C.ClipY-8-Full;

	Scale = (Full+16)/128;

	// I like Yellow

    C.ColorModulate.X=255;
    C.ColorModulate.Y=255;
    C.ColorModulate.Z=0;
    C.ColorModulate.W=255;

	// Draw Border

	C.SetPos(0,Top);
    C.SetDrawColor(255,255,255,255);
    C.DrawTileStretched(material'InterfaceContent.SquareBoxA',C.ClipX,Full);
    C.ColorModulate.Z=255;

    TextTop = Top + 4;
    GRI = PlayerOwner.GameReplicationInfo;

    C.SetPos(0,Top-8);
    C.Style=5;
    C.DrawTile(material'LMSLogoSmall',256*Scale,128*Scale,0,0,256,128);
    C.Style=1;

	if ( UnrealPlayer(Owner).bDisplayWinner ||  UnrealPlayer(Owner).bDisplayLoser )
	{
		if ( UnrealPlayer(Owner).bDisplayWinner )
			InfoString = YouveWonTheMatch;
		else
		{
			if ( PlayerReplicationInfo(PlayerOwner.GameReplicationInfo.Winner) != None )
				InfoString = WonMatchPrefix$PlayerReplicationInfo(PlayerOwner.GameReplicationInfo.Winner).PlayerName$WonMatchPostFix;
			else
				InfoString = YouveLostTheMatch;
		}

        C.SetDrawColor(255,255,255,255);
        C.Font = GetMediumFontFor(C);
        C.StrLen(InfoString,XL,YL);
        C.SetPos( (C.ClipX/2) - (XL/2), Top + (Full/2) - (YL/2));
        C.DrawText(InfoString,false);
    }

	else if ( Pawn(PlayerOwner.ViewTarget) != None && Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo != None )
    {
    	// Draw View Target info

		C.SetDrawColor(32,255,32,255);

		if ( C.ClipX < 640 )
			SmallH = 0;
		else
		{
			// Draw "Now Viewing"

			C.SetPos((256*Scale*0.75),TextTop);
			C.DrawText(NowViewing,false);

    		// Draw "Score"

			InfoString = GetScoreText();
			C.StrLen(InfoString,Xl,Yl);
			C.SetPos(C.ClipX-5-XL,TextTop);
			C.DrawText(InfoString);
		}

        // Draw Player Name

        C.SetDrawColor(255,255,0,255);
        C.Font = GetMediumFontFor(C);
        C.SetPos((256*Scale*0.75),TextTop+SmallH);
        C.DrawText(Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo.PlayerName,false);

        // Draw Score

	    InfoString = GetScoreValue(Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo);
	    C.StrLen(InfoString,xl,yl);
	    C.SetPos(C.ClipX-5-XL,TextTop+SmallH);
	    C.DrawText(InfoString,false);

        // Draw Tag Line

	    C.Font = GetConsoleFont(C);
	    InfoString = GetScoreTagLine();
	    C.StrLen(InfoString,xl,yl);
	    C.SetPos( (C.ClipX/2) - (XL/2),Top-3-YL);
	    C.DrawText(InfoString);
    }
    else
    {
		InfoString = GetInfoString();

    	// Draw
    	C.SetDrawColor(255,255,255,255);
        C.Font = GetMediumFontFor(C);
        C.StrLen(InfoString,XL,YL);
        C.SetPos( (C.ClipX/2) - (XL/2), Top + (Full/2) - (YL/2));
        C.DrawText(InfoString,false);
    }

    C.ColorModulate = OldModulate;

}

simulated function String GetInfoString()
{
	local string InfoString;

	if ( PlayerOwner.IsDead() )
	{
	    if ( PlayerOwner.PlayerReplicationInfo.bOutOfLives )
	        InfoString = class'ScoreboardDeathMatch'.default.OutFireText;
	    else if ( Level.TimeSeconds - UnrealPlayer(PlayerOwner).LastKickWarningTime < 2 )
    		InfoString = class'GameMessage'.Default.KickWarning;
	    else
	        InfoString = class'ScoreboardDeathMatch'.default.Restart;
	}
	else if ( Level.TimeSeconds - UnrealPlayer(PlayerOwner).LastKickWarningTime < 2 )
    	InfoString = class'GameMessage'.Default.KickWarning;
    else if ( GUIController(PlayerOwner.Player.GUIController).ActivePage!=None)
    	InfoString = AtMenus;
	else if ( (PlayerOwner.PlayerReplicationInfo != None) && PlayerOwner.PlayerReplicationInfo.bWaitingPlayer )
	    InfoString = WaitingToSpawn;
    else
		InfoString = InitialViewingString;

	return InfoString;
}

// ====================


simulated function DrawHUDAnimDigit( out NumericWidget HUDPiece, float DefaultScale, float PickUPTime, float AnimTime, color defaultColor, color colorHighlight)
{
	if ( PickUPTime > Level.TimeSeconds - AnimTime)
	{
		HUDPiece.Tints[TeamIndex].R = colorHighlight.R + ((  defaultColor.R  - colorHighlight.R) * (Level.TimeSeconds - PickUPTime));
		HUDPiece.Tints[TeamIndex].B = colorHighlight.B + ((  defaultColor.B  - colorHighlight.B) * (Level.TimeSeconds - PickUPTime));
		HUDPiece.Tints[TeamIndex].G = colorHighlight.G + ((  defaultColor.G  - colorHighlight.G) * (Level.TimeSeconds - PickUPTime));
	}
    else
	{
		HUDPiece.Tints[TeamIndex] = defaultColor;
	}
}

simulated function DrawHUDAnimWidget( out SpriteWidget HUDPiece, float DefaultScale, float PickUPTime, float AnimTime, float AnimScale)
{
	if ( PickUPTime > Level.TimeSeconds - AnimTime)
	{
		if ( PickUPTime > Level.TimeSeconds - AnimTime/2 )
		    HUDPiece.TextureScale = DefaultScale * (1 + AnimScale * (Level.TimeSeconds - PickUPTime));
        else
		   HUDPiece.TextureScale = DefaultScale * (1 + AnimScale * (PickUPTime + AnimTime - Level.TimeSeconds));
    }
    else
        HUDPiece.TextureScale = DefaultScale;
}

simulated function DrawCrosshair (Canvas C)
{
    local float NormalScale;
    local int i, CurrentCrosshair;
    local float OldScale,OldW, CurrentCrosshairScale;
    local color CurrentCrosshairColor;
	local SpriteWidget CHtexture;

	if ( PawnOwner.bSpecialCrosshair )
	{
		PawnOwner.SpecialDrawCrosshair( C );
		return;
	}

	if (!bCrosshairShow)
        return;

	if ( bUseCustomWeaponCrosshairs && (PawnOwner != None) && (PawnOwner.Weapon != None) )
	{
		CurrentCrosshair = PawnOwner.Weapon.CustomCrosshair;
		if (CurrentCrosshair == -1 || CurrentCrosshair == Crosshairs.Length)
		{
			CurrentCrosshair = CrosshairStyle;
			CurrentCrosshairColor = CrosshairColor;
			CurrentCrosshairScale = CrosshairScale;
		}
		else
		{
			CurrentCrosshairColor = PawnOwner.Weapon.CustomCrosshairColor;
			CurrentCrosshairScale = PawnOwner.Weapon.CustomCrosshairScale;
			if ( PawnOwner.Weapon.CustomCrosshairTextureName != "" )
			{
				if ( PawnOwner.Weapon.CustomCrosshairTexture == None )
				{
					PawnOwner.Weapon.CustomCrosshairTexture = Texture(DynamicLoadObject(PawnOwner.Weapon.CustomCrosshairTextureName,class'Texture'));
					if ( PawnOwner.Weapon.CustomCrosshairTexture == None )
					{
						log(PawnOwner.Weapon$" custom crosshair texture not found!");
						PawnOwner.Weapon.CustomCrosshairTextureName = "";
					}
				}
				CHTexture = Crosshairs[0];
				CHTexture.WidgetTexture = PawnOwner.Weapon.CustomCrosshairTexture;
			}
		}
	}
	else
	{
		CurrentCrosshair = CrosshairStyle;
		CurrentCrosshairColor = CrosshairColor;
		CurrentCrosshairScale = CrosshairScale;
	}

	CurrentCrosshair = Clamp(CurrentCrosshair, 0, Crosshairs.Length - 1);

    NormalScale = Crosshairs[CurrentCrosshair].TextureScale;
	if ( CHTexture.WidgetTexture == None )
		CHTexture = Crosshairs[CurrentCrosshair];
    CHTexture.TextureScale *= 0.5 * CurrentCrosshairScale;

    for( i = 0; i < ArrayCount(CHTexture.Tints); i++ )
        CHTexture.Tints[i] = CurrentCrossHairColor;

	if ( LastPickupTime > Level.TimeSeconds - 0.4 )
	{
		if ( LastPickupTime > Level.TimeSeconds - 0.2 )
			CHTexture.TextureScale *= (1 + 5 * (Level.TimeSeconds - LastPickupTime));
		else
			CHTexture.TextureScale *= (1 + 5 * (LastPickupTime + 0.4 - Level.TimeSeconds));
	}
    OldScale = HudScale;
    HudScale=1;
    OldW = C.ColorModulate.W;
    C.ColorModulate.W = 1;
    DrawSpriteWidget (C, CHTexture);
    C.ColorModulate.W = OldW;
	HudScale=OldScale;
    CHTexture.TextureScale = NormalScale;

	DrawEnemyName(C);
}

function DrawEnemyName(Canvas C)
{
	local actor HitActor;
	local vector HitLocation,HitNormal,ViewPos;

	if ( PlayerOwner.bBehindView || bNoEnemyNames || (PawnOwner.Controller == None) )
		return;
	ViewPos = PawnOwner.Location + PawnOwner.BaseEyeHeight * vect(0,0,1);
	HitActor = trace(HitLocation,HitNormal,ViewPos+1200*vector(PawnOwner.Controller.Rotation),ViewPos,true);
	if ( (Pawn(HitActor) != None) && (Pawn(HitActor).PlayerReplicationInfo != None)
		&& (HitActor != PawnOwner)
		&& ( (PawnOwner.PlayerReplicationInfo.Team == None) || (PawnOwner.PlayerReplicationInfo.Team != Pawn(HitActor).PlayerReplicationInfo.Team)) )
	{
		if ( (NamedPlayer != Pawn(HitActor).PlayerReplicationInfo) || (Level.TimeSeconds - NameTime > 0.5) )
		{
			DisplayEnemyName(C, Pawn(HitActor).PlayerReplicationInfo);
			NameTime = Level.TimeSeconds;
		}
		NamedPlayer = Pawn(HitActor).PlayerReplicationInfo;
	}
}

function DisplayEnemyName(Canvas C, PlayerReplicationInfo PRI)
{
	PlayerOwner.ReceiveLocalizedMessage(class'PlayerNameMessage',0,PRI);
}

function FadeZoom()
{
	if ( (PawnOwner != None) && (PawnOwner.Weapon != None)
		&& PawnOwner.Weapon.WantsZoomFade() )
		ZoomToggleTime = Level.TimeSeconds;
}

function ZoomFadeOut(Canvas C)
{
	local float FadeValue;

	if ( Level.TimeSeconds - ZoomToggleTime >= FadeTime )
		return;
	if ( ZoomToggleTime > Level.TimeSeconds )
		ZoomToggleTime = Level.TimeSeconds;

	FadeValue = 255 * ( 1.0 - (Level.TimeSeconds - ZoomToggleTime)/FadeTime);
	C.DrawColor.A = FadeValue;
	C.Style = ERenderStyle.STY_Alpha;
	C.SetPos(0,0);
	C.DrawTile( Texture'Engine.BlackTexture', C.SizeX, C.SizeY, 0.0, 0.0, 16, 16);
}

function DisplayVoiceGain(Canvas C)
{
	local Texture Tex;
	local float VoiceGain;
	local float PosY, BlockSize, XL, YL;
	local int i;
	local string ActiveName;

	BlockSize = 8192/C.ClipX * HUDScale;
	Tex = Texture'engine.WhiteSquareTexture';
	PosY = C.ClipY * 0.375;
	VoiceGain = (1 - 3 * Min( Level.TimeSeconds - LastVoiceGainTime, 0.3333 )) * LastVoiceGain;

	for( i=0; i<10; i++ )
	{
		if( VoiceGain > (0.1 * i) )
		{
			C.SetPos( 0.5 * BlockSize, PosY );
			C.SetDrawColor( 28.3 * i, 255 - 28.3 * i, 0, 255 );
			C.DrawTile( Tex, BlockSize, BlockSize, 0, 0, Tex.USize, Tex.VSize );
			PosY -= 1.2 * BlockSize;
		}
	}

	// Display name of currently active channel
	if ( PlayerOwner != None && PlayerOwner.ActiveRoom != None )
		ActiveName = PlayerOwner.ActiveRoom.GetTitle();

	if ( ActiveName != "" )
	{
		ActiveName = "(" @ ActiveName @ ")";
		C.Font = GetFontSizeIndex(C,-2);
		C.StrLen(ActiveName,XL,YL);

		if ( XL > 0.125 * C.ClipY )
		{
			C.Font = GetFontSizeIndex(C,-4);
			C.StrLen(ActiveName,XL,YL);
		}

		C.SetPos( BlockSize * 2, (C.ClipY * 0.375 + BlockSize) - YL );
		C.DrawColor = C.MakeColor(160,160,160);
		if ( PlayerOwner != None && PlayerOwner.PlayerReplicationInfo != None )
		{
			if ( PlayerOwner.PlayerReplicationInfo.Team != None )
			{
				if ( PlayerOwner.PlayerReplicationInfo.Team.TeamIndex == 0 )
					C.DrawColor = RedColor;
				else
					C.DrawColor = TurqColor;
			}
		}

		C.DrawText( ActiveName );
	}
}

// Alpha Pass ==================================================================================
simulated function DrawHudPassA (Canvas C)
{
	local Pawn RealPawnOwner;
	local class<Ammunition> AmmoClass;

	ZoomFadeOut(C);

	if ( PawnOwner != None )
	{
		if( bShowWeaponInfo && (PawnOwner.Weapon != None) )
		{
			if ( PawnOwner.Weapon.bShowChargingBar )
    			DrawChargeBar(C);

			DrawSpriteWidget( C, HudBorderAmmo );

			if( PawnOwner.Weapon != None )
			{
				AmmoClass = PawnOwner.Weapon.GetAmmoClass(0);
				if ( (AmmoClass != None) && (AmmoClass.Default.IconMaterial != None) )
				{
					if( (CurAmmoPrimary/MaxAmmoPrimary) < 0.15)
					{
						DrawSpriteWidget(C, HudAmmoALERT);
						HudAmmoALERT.Tints[TeamIndex] = HudColorTeam[TeamIndex];
						if ( AmmoClass.Default.IconFlashMaterial == None )
							AmmoIcon.WidgetTexture = Material'HudContent.Generic.HUDPulse';
						else
							AmmoIcon.WidgetTexture = AmmoClass.Default.IconFlashMaterial;
					}
					else
					{
						AmmoIcon.WidgetTexture = AmmoClass.default.IconMaterial;
					}

					AmmoIcon.TextureCoords = AmmoClass.Default.IconCoords;
					DrawSpriteWidget (C, AmmoIcon);
				}
			}
			DrawNumericWidget( C, DigitsAmmo, DigitsBig);
		}

		if ( bShowWeaponBar && (PawnOwner.Weapon != None) )
			DrawWeaponBar(C);

		if( bShowPersonalInfo )
		{
    		if ( Vehicle(PawnOwner) != None && Vehicle(PawnOwner).Driver != None )
    		{
    			if (Vehicle(PawnOwner).bShowChargingBar)
    				DrawVehicleChargeBar(C);
    			RealPawnOwner = PawnOwner;
    			PawnOwner = Vehicle(PawnOwner).Driver;
    		}

			DrawHUDAnimWidget( HudBorderHealthIcon, default.HudBorderHealthIcon.TextureScale, LastHealthPickupTime, 0.6, 0.6);
			DrawSpriteWidget( C, HudBorderHealth );

			if(CurHealth/PawnOwner.HealthMax < 0.26)
			{
				HudHealthALERT.Tints[TeamIndex] = HudColorTeam[TeamIndex];
				DrawSpriteWidget( C, HudHealthALERT);
				HudBorderHealthIcon.WidgetTexture = Material'HudContent.Generic.HUDPulse';
			}
			else
				HudBorderHealthIcon.WidgetTexture = default.HudBorderHealth.WidgetTexture;

			DrawSpriteWidget( C, HudBorderHealthIcon);

			if( CurHealth < LastHealth )
				LastDamagedHealth = Level.TimeSeconds;

			DrawHUDAnimDigit( DigitsHealth, default.DigitsHealth.TextureScale, LastDamagedHealth, 0.8, default.DigitsHealth.Tints[TeamIndex], HudColorHighLight);
			DrawNumericWidget( C, DigitsHealth, DigitsBig);

			if(CurHealth > 999)
			{
				DigitsHealth.OffsetX=220;
				DigitsHealth.OffsetY=-35;
				DigitsHealth.TextureScale=0.39;
			}
			else
			{
				DigitsHealth.OffsetX = default.DigitsHealth.OffsetX;
				DigitsHealth.OffsetY = default.DigitsHealth.OffsetY;
				DigitsHealth.TextureScale = default.DigitsHealth.TextureScale;
			}

			if (RealPawnOwner != None)
			{
				PawnOwner = RealPawnOwner;

				DrawSpriteWidget( C, HudBorderVehicleHealth );

				if (CurVehicleHealth/PawnOwner.HealthMax < 0.26)
				{
					HudVehicleHealthALERT.Tints[TeamIndex] = HudColorTeam[TeamIndex];
					DrawSpriteWidget(C, HudVehicleHealthALERT);
					HudBorderVehicleHealthIcon.WidgetTexture = Material'HudContent.Generic.HUDPulse';
				}
				else
					HudBorderVehicleHealthIcon.WidgetTexture = default.HudBorderVehicleHealth.WidgetTexture;

				DrawSpriteWidget(C, HudBorderVehicleHealthIcon);

				if (CurVehicleHealth < LastVehicleHealth )
					LastDamagedVehicleHealth = Level.TimeSeconds;

				DrawHUDAnimDigit(DigitsVehicleHealth, default.DigitsVehicleHealth.TextureScale, LastDamagedVehicleHealth, 0.8, default.DigitsVehicleHealth.Tints[TeamIndex], HudColorHighLight);
				DrawNumericWidget(C, DigitsVehicleHealth, DigitsBig);

				if (CurVehicleHealth > 999)
				{
					DigitsVehicleHealth.OffsetX = 220;
					DigitsVehicleHealth.OffsetY = -35;
					DigitsVehicleHealth.TextureScale = 0.39;
				}
				else
				{
					DigitsVehicleHealth.OffsetX = default.DigitsVehicleHealth.OffsetX;
					DigitsVehicleHealth.OffsetY = default.DigitsVehicleHealth.OffsetY;
					DigitsVehicleHealth.TextureScale = default.DigitsVehicleHealth.TextureScale;
				}
			}

			DrawAdrenaline(C);
		}
	}

	UpdateRankAndSpread(C);
    DrawUDamage(C);

    if(bDrawTimer)
		DrawTimer(C);

    // Temp Drawwwith Hud Colors
    HudBorderShield.Tints[0] = HudColorRed;
    HudBorderShield.Tints[1] = HudColorBlue;
    HudBorderHealth.Tints[0] = HudColorRed;
    HudBorderHealth.Tints[1] = HudColorBlue;
    HudBorderVehicleHealth.Tints[0] = HudColorRed;
    HudBorderVehicleHealth.Tints[1] = HudColorBlue;
    HudBorderAmmo.Tints[0] = HudColorRed;
    HudBorderAmmo.Tints[1] = HudColorBlue;

    if( bShowPersonalInfo && (CurShield > 0) )
    {
	    DrawSpriteWidget( C, HudBorderShield );
		DrawSpriteWidget( C, HudBorderShieldIcon);
		DrawNumericWidget( C, DigitsShield, DigitsBig);
		DrawHUDAnimWidget( HudBorderShieldIcon, default.HudBorderShieldIcon.TextureScale, LastArmorPickupTime, 0.6, 0.6);
    }

	if( Level.TimeSeconds - LastVoiceGainTime < 0.333 )
		DisplayVoiceGain(C);

    DisplayLocalMessages (C);
}

simulated function DrawHudPassC (Canvas C)
{
	local VoiceChatRoom VCR;
	local float PortraitWidth,PortraitHeight, X, Y, XL, YL, Abbrev, SmallH, NameWidth;
	local string PortraitString;

	// portrait
	if ( (bShowPortrait || (bShowPortraitVC && Level.TimeSeconds - LastPlayerIDTalkingTime < 2.0)) && (Portrait != None) )
	{
		PortraitWidth = 0.125 * C.ClipY;
		PortraitHeight = 1.5 * PortraitWidth;
		C.DrawColor = WhiteColor;

		C.SetPos(-PortraitWidth*PortraitX + 0.025*PortraitWidth,0.5*(C.ClipY-PortraitHeight) + 0.025*PortraitHeight);
		C.DrawTile( Portrait, PortraitWidth, PortraitHeight, 0, 0, 256, 384);

		C.SetPos(-PortraitWidth*PortraitX,0.5*(C.ClipY-PortraitHeight));
		C.Font = GetFontSizeIndex(C,-2);
		
		if ( PortraitPRI != None )
		{
			PortraitString = PortraitPRI.PlayerName;
			C.StrLen(PortraitString,XL,YL);
			if ( XL > PortraitWidth )
			{
				C.Font = GetFontSizeIndex(C,-4);
				C.StrLen(PortraitString,XL,YL);
				if ( XL > PortraitWidth )
				{
					Abbrev = float(len(PortraitString)) * PortraitWidth/XL;
					PortraitString = left(PortraitString,Abbrev);
					C.StrLen(PortraitString,XL,YL);
				}
			}
		}
		C.DrawColor = C.static.MakeColor(160,160,160);
		C.SetPos(-PortraitWidth*PortraitX + 0.025*PortraitWidth,0.5*(C.ClipY-PortraitHeight) + 0.025*PortraitHeight);
		C.DrawTile( Material'XGameShaders.ModuNoise', PortraitWidth, PortraitHeight, 0.0, 0.0, 512, 512 );

		C.DrawColor = WhiteColor;
		C.SetPos(-PortraitWidth*PortraitX,0.5*(C.ClipY-PortraitHeight));
		C.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxA1', 1.05 * PortraitWidth, 1.05*PortraitHeight);

		C.DrawColor = WhiteColor;

		X = C.ClipY/256-PortraitWidth*PortraitX;
		Y = 0.5*(C.ClipY+PortraitHeight) + 0.06*PortraitHeight;
		C.SetPos( X + 0.5 * (PortraitWidth - XL), Y );

		if ( PortraitPRI != None )
		{
			if ( PortraitPRI.Team != None )
			{
				if ( PortraitPRI.Team.TeamIndex == 0 )
					C.DrawColor = RedColor;
				else
					C.DrawColor = TurqColor;
			}

			C.DrawText(PortraitString,true);

			if ( Level.TimeSeconds - LastPlayerIDTalkingTime < 2.0
				&& PortraitPRI.ActiveChannel != -1
				&& PlayerOwner.VoiceReplicationInfo != None )
			{
				VCR = PlayerOwner.VoiceReplicationInfo.GetChannelAt(PortraitPRI.ActiveChannel);
				if ( VCR != None )
				{
					PortraitString = "(" @ VCR.GetTitle() @ ")";
					C.StrLen( PortraitString, XL, YL );
					if ( PortraitX == 0 )
						C.SetPos( Max(0, X + 0.5 * (PortraitWidth - XL)), Y + YL );
					else C.SetPos( X + 0.5 * (PortraitWidth - XL), Y + YL );
					C.DrawText( PortraitString );
				}
			}
		}
	}

    if( bShowWeaponInfo && (PawnOwner != None) && (PawnOwner.Weapon != None) )
		PawnOwner.Weapon.NewDrawWeaponInfo(C, 0.86 * C.ClipY);

	if ( (PawnOwner != PlayerOwner.Pawn) && (PawnOwner != None)
		&& (PawnOwner.PlayerReplicationInfo != None) )
	{
		// draw viewed player name
	    C.Font = GetMediumFontFor(C);
        C.SetDrawColor(255,255,0,255);
		C.StrLen(PawnOwner.PlayerReplicationInfo.PlayerName,NameWidth,SmallH);
		NameWidth = FMax(NameWidth, 0.15 * C.ClipX);
		if ( C.ClipX >= 640 )
		{
			C.Font = GetConsoleFont(C);
			C.StrLen("W",XL,SmallH);
			C.SetPos(79*C.ClipX/80 - NameWidth,C.ClipY * 0.68);
			C.DrawText(NowViewing,false);
		}

        C.Font = GetMediumFontFor(C);
        C.SetPos(79*C.ClipX/80 - NameWidth,C.ClipY * 0.68 + SmallH);
        C.DrawText(PawnOwner.PlayerReplicationInfo.PlayerName,false);
	}

     DrawCrosshair(C);
}

simulated function ShowReloadingPulse( float hold )
{
	if( hold==1.0 )
		RechargeBar.WidgetTexture=Material'HudContent.Generic.HUDPulse';
	else
		RechargeBar.WidgetTexture = default.RechargeBar.WidgetTexture;

}
simulated function DrawChargeBar( Canvas C)
{
	local float ScaleFactor;

	ScaleFactor = HUDScale * 0.135 * C.ClipX;
	C.Style = ERenderStyle.STY_Alpha;
	if ( (PawnOwner.PlayerReplicationInfo == None) || (PawnOwner.PlayerReplicationInfo.Team == None)
		|| (PawnOwner.PlayerReplicationInfo.Team.TeamIndex == 1) )
		C.DrawColor = HudColorBlue;
	else
		C.DrawColor = HudColorRed;

	C.SetPos(C.ClipX - ScaleFactor - 0.0011*HUDScale*C.ClipX, (1 - 0.0975*HUDScale)*C.ClipY);
	C.DrawTile( Material'HudContent.HUD', ScaleFactor, 0.223*ScaleFactor, 0, 110, 166, 53 );

    RechargeBar.Scale = PawnOwner.Weapon.ChargeBar();
	if ( RechargeBar.Scale > 0 )
	{
		DrawSpriteWidget( C, RechargeBar );
		ShowReloadingPulse(RechargeBar.Scale);
	}
}

simulated function DrawVehicleChargeBar(Canvas C)
{
	local float ScaleFactor;

	ScaleFactor = HUDScale * 0.135 * C.ClipX;
	C.Style = ERenderStyle.STY_Alpha;
	if ( (PawnOwner.PlayerReplicationInfo == None) || (PawnOwner.PlayerReplicationInfo.Team == None)
		|| (PawnOwner.PlayerReplicationInfo.Team.TeamIndex == 1) )
		C.DrawColor = HudColorBlue;
	else
		C.DrawColor = HudColorRed;

	C.SetPos(C.ClipX - ScaleFactor - 0.0011*HUDScale*C.ClipX, (1 - 0.0975*HUDScale)*C.ClipY);
	C.DrawTile( Material'HudContent.HUD', ScaleFactor, 0.223*ScaleFactor, 0, 110, 166, 53 );

	DrawSpriteWidget(C, RechargeBar);
	RechargeBar.Scale = Vehicle(PawnOwner).ChargeBar();
	ShowReloadingPulse(RechargeBar.Scale);
}

simulated function DrawWeaponBar( Canvas C )
{
    local int i, Count, Pos;
    local float IconOffset;
	local float HudScaleOffset, HudMinScale;

    local Weapon Weapons[WEAPON_BAR_SIZE];
    local byte ExtraWeapon[WEAPON_BAR_SIZE];
    local Inventory Inv;
    local Weapon W, PendingWeapon;

	HudMinScale=0.5;
	// CurHudScale = HudScale;
    //no weaponbar for vehicles
    if (Vehicle(PawnOwner) != None)
	return;

    if (PawnOwner.PendingWeapon != None)
        PendingWeapon = PawnOwner.PendingWeapon;
    else
        PendingWeapon = PawnOwner.Weapon;

	// fill:
    for( Inv=PawnOwner.Inventory; Inv!=None; Inv=Inv.Inventory )
    {
        W = Weapon( Inv );
		Count++;
		if ( Count > 100 )
			break;

        if( (W == None) || (W.IconMaterial == None) )
            continue;

		if ( W.InventoryGroup == 0 )
			Pos = 8;
		else if ( W.InventoryGroup < 10 )
			Pos = W.InventoryGroup-1;
		else
			continue;

		if ( Weapons[Pos] != None )
			ExtraWeapon[Pos] = 1;
		else
			Weapons[Pos] = W;
    }

	if ( PendingWeapon != None )
	{
		if ( PendingWeapon.InventoryGroup == 0 )
			Weapons[8] = PendingWeapon;
		else if ( PendingWeapon.InventoryGroup < 10 )
			Weapons[PendingWeapon.InventoryGroup-1] = PendingWeapon;
	}

    // Draw:
    for( i=0; i<WEAPON_BAR_SIZE; i++ )
    {
        W = Weapons[i];

		// Keep weaponbar organized when scaled
		HudScaleOffset= 1-(HudScale-HudMinScale)/HudMinScale;
    	BarBorder[i].PosX =  default.BarBorder[i].PosX+( BarBorderScaledPosition[i] - default.BarBorder[i].PosX) *HudScaleOffset;
		BarWeaponIcon[i].PosX = BarBorder[i].PosX;

		IconOffset = (default.BarBorder[i].TextureCoords.X2 - default.BarBorder[i].TextureCoords.X1) *0.5 ;
	    BarWeaponIcon[i].OffsetX =  IconOffset;

        BarBorder[i].Tints[0] = HudColorRed;
        BarBorder[i].Tints[1] = HudColorBlue;
        BarBorder[i].OffsetY = 0;
		BarWeaponIcon[i].OffsetY = default.BarWeaponIcon[i].OffsetY;

		if( W == none )
        {
			BarWeaponStates[i].HasWeapon = false;
			if ( bShowMissingWeaponInfo )
			{
				if ( BarWeaponIcon[i].Tints[TeamIndex] != HudColorBlack )
				{
					BarWeaponIcon[i].WidgetTexture = default.BarWeaponIcon[i].WidgetTexture;
					BarWeaponIcon[i].TextureCoords = default.BarWeaponIcon[i].TextureCoords;
					BarWeaponIcon[i].TextureScale = default.BarWeaponIcon[i].TextureScale;
					BarWeaponIcon[i].Tints[TeamIndex] = HudColorBlack;
					BarWeaponIconAnim[i] = 0;
				}
				DrawSpriteWidget( C, BarBorder[i] );
				DrawSpriteWidget( C, BarWeaponIcon[i] ); // FIXME- have combined version
			}
       }
        else
        {
			if( !BarWeaponStates[i].HasWeapon )
			{
				// just picked this weapon up!
				BarWeaponStates[i].PickupTimer = Level.TimeSeconds;
				BarWeaponStates[i].HasWeapon = true;
			}

	    	BarBorderAmmoIndicator[i].PosX = BarBorder[i].PosX;
			BarBorderAmmoIndicator[i].OffsetY = 0;
			BarWeaponIcon[i].WidgetTexture = W.IconMaterial;
			BarWeaponIcon[i].TextureCoords = W.IconCoords;

            BarBorderAmmoIndicator[i].Scale = W.AmmoStatus();
            BarWeaponIcon[i].Tints[TeamIndex] = HudColorNormal;

			if( BarWeaponIconAnim[i] == 0 )
            {
                if ( BarWeaponStates[i].PickupTimer > Level.TimeSeconds - 0.6 )
	            {
		           if ( BarWeaponStates[i].PickupTimer > Level.TimeSeconds - 0.3 )
	               {
					   	BarWeaponIcon[i].TextureScale = default.BarWeaponIcon[i].TextureScale * (1 + 1.3 * (Level.TimeSeconds - BarWeaponStates[i].PickupTimer));
                        BarWeaponIcon[i].OffsetX =  IconOffset - IconOffset * ( Level.TimeSeconds - BarWeaponStates[i].PickupTimer );
                   }
                   else
                   {
					    BarWeaponIcon[i].TextureScale = default.BarWeaponIcon[i].TextureScale * (1 + 1.3 * (BarWeaponStates[i].PickupTimer + 0.6 - Level.TimeSeconds));
                        BarWeaponIcon[i].OffsetX = IconOffset - IconOffset * (BarWeaponStates[i].PickupTimer + 0.6 - Level.TimeSeconds);
                   }
                }
                else
                {
                    BarWeaponIconAnim[i] = 1;
                    BarWeaponIcon[i].TextureScale = default.BarWeaponIcon[i].TextureScale;
				}
			}

            if (W == PendingWeapon)
            {
				// Change color to highlight and possibly changeTexture or animate it
				BarBorder[i].Tints[TeamIndex] = HudColorHighLight;
				BarBorder[i].OffsetY = -10;
				BarBorderAmmoIndicator[i].OffsetY = -10;
				BarWeaponIcon[i].OffsetY += -10;
			}
		    if ( ExtraWeapon[i] == 1 )
		    {
			    if ( W == PendingWeapon )
			    {
                    BarBorder[i].Tints[0] = HudColorRed;
                    BarBorder[i].Tints[1] = HudColorBlue;
				    BarBorder[i].OffsetY = 0;
				    BarBorder[i].TextureCoords.Y1 = 80;
				    DrawSpriteWidget( C, BarBorder[i] );
				    BarBorder[i].TextureCoords.Y1 = 39;
				    BarBorder[i].OffsetY = -10;
				    BarBorder[i].Tints[TeamIndex] = HudColorHighLight;
			    }
			    else
			    {
				    BarBorder[i].OffsetY = -52;
				    BarBorder[i].TextureCoords.Y2 = 48;
		            DrawSpriteWidget( C, BarBorder[i] );
				    BarBorder[i].TextureCoords.Y2 = 93;
				    BarBorder[i].OffsetY = 0;
			    }
		    }
	        DrawSpriteWidget( C, BarBorder[i] );
            DrawSpriteWidget( C, BarBorderAmmoIndicator[i] );
            DrawSpriteWidget( C, BarWeaponIcon[i] );
       }
    }
}

function bool DrawLevelAction (Canvas C)
{
    local String LevelActionText;
    local Plane OldModulate;

    if ((Level.LevelAction == LEVACT_None) && (Level.Pauser != none))
    {
        LevelActionText = LevelActionPaused;
    }
    else if ((Level.LevelAction == LEVACT_Loading) || (Level.LevelAction == LEVACT_Precaching))
        LevelActionText = LevelActionLoading;
    else
        LevelActionText = "";

    if (LevelActionText == "")
        return (false);

    C.Font = LoadLevelActionFont();
    C.DrawColor = LevelActionFontColor;
    C.Style = ERenderStyle.STY_Alpha;

    OldModulate = C.ColorModulate;
    C.ColorModulate = C.default.ColorModulate;
    C.DrawScreenText (LevelActionText, LevelActionPositionX, LevelActionPositionY, DP_MiddleMiddle);
    C.ColorModulate = OldModulate;

    return (true);
}

function DisplayPortrait(PlayerReplicationInfo PRI)
{
	local Material NewPortrait;

    if ( LastPlayerIDTalking > 0 )
        return;

	NewPortrait = PRI.GetPortrait();
	if ( NewPortrait == None )
		return;
	if ( Portrait == None )
		PortraitX = 1;
	Portrait = NewPortrait;
	PortraitTime = Level.TimeSeconds + 3;
	PortraitPRI = PRI;
}

simulated function font LoadLevelActionFont()
{
	if( LevelActionFontFont == None )
	{
		LevelActionFontFont = Font(DynamicLoadObject(LevelActionFontName, class'Font'));
		if( LevelActionFontFont == None )
			Log("Warning: "$Self$" Couldn't dynamically load font "$LevelActionFontName);
	}
	return LevelActionFontFont;
}

defaultproperties
{
     DigitsBig=(DigitTexture=Texture'HUDContent.Generic.HUD',TextureCoords[0]=(X2=38,Y2=38),TextureCoords[1]=(X1=39,X2=77,Y2=38),TextureCoords[2]=(X1=78,X2=116,Y2=38),TextureCoords[3]=(X1=117,X2=155,Y2=38),TextureCoords[4]=(X1=156,X2=194,Y2=38),TextureCoords[5]=(X1=195,X2=233,Y2=38),TextureCoords[6]=(X1=234,X2=272,Y2=38),TextureCoords[7]=(X1=273,X2=311,Y2=38),TextureCoords[8]=(X1=312,X2=350,Y2=38),TextureCoords[9]=(X1=351,X2=389,Y2=38),TextureCoords[10]=(X1=390,X2=428,Y2=38))
     DigitsBigPulse=(DigitTexture=FinalBlend'HUDContent.Generic.fbHUDAlertSlow',TextureCoords[0]=(X2=38,Y2=38),TextureCoords[1]=(X1=39,X2=77,Y2=38),TextureCoords[2]=(X1=78,X2=116,Y2=38),TextureCoords[3]=(X1=117,X2=155,Y2=38),TextureCoords[4]=(X1=156,X2=194,Y2=38),TextureCoords[5]=(X1=195,X2=233,Y2=38),TextureCoords[6]=(X1=234,X2=272,Y2=38),TextureCoords[7]=(X1=273,X2=311,Y2=38),TextureCoords[8]=(X1=312,X2=350,Y2=38),TextureCoords[9]=(X1=351,X2=389,Y2=38),TextureCoords[10]=(X1=390,X2=428,Y2=38))
     AmmoIcon=(RenderStyle=STY_Alpha,TextureScale=0.530000,DrawPivot=DP_MiddleMiddle,PosX=1.000000,PosY=1.000000,OffsetX=-28,OffsetY=-30,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     AdrenalineCount=(RenderStyle=STY_Alpha,TextureScale=0.490000,DrawPivot=DP_MiddleRight,PosX=1.000000,OffsetX=-60,OffsetY=35,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     mySpread=(RenderStyle=STY_Alpha,TextureScale=0.300000,DrawPivot=DP_MiddleLeft,OffsetX=30,OffsetY=170,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     myRank=(RenderStyle=STY_Alpha,TextureScale=0.300000,DrawPivot=DP_MiddleLeft,OffsetX=30,OffsetY=132,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MyScore=(RenderStyle=STY_Alpha,TextureScale=0.490000,DrawPivot=DP_MiddleLeft,PosX=0.015000,OffsetX=70,OffsetY=94,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TimerHours=(RenderStyle=STY_Alpha,TextureScale=0.320000,DrawPivot=DP_MiddleLeft,OffsetX=90,OffsetY=45,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TimerMinutes=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.320000,DrawPivot=DP_MiddleLeft,OffsetX=170,OffsetY=45,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255),bPadWithZeroes=1)
     TimerSeconds=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.320000,DrawPivot=DP_MiddleLeft,OffsetX=250,OffsetY=45,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255),bPadWithZeroes=1)
     TimerDigitSpacer(0)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=495,Y1=91,X2=503,Y2=112),TextureScale=0.400000,DrawPivot=DP_MiddleLeft,OffsetX=194,OffsetY=36,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TimerDigitSpacer(1)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=495,Y1=91,X2=503,Y2=112),TextureScale=0.400000,DrawPivot=DP_MiddleLeft,OffsetX=130,OffsetY=36,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TimerIcon=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=150,Y1=356,X2=184,Y2=389),TextureScale=0.550000,OffsetX=10,OffsetY=9,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TimerBackground=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=168,Y1=211,X2=334,Y2=255),TextureScale=0.400000,OffsetX=60,OffsetY=14,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     TimerBackgroundDisc=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.530000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     LevelActionFontColor=(B=255,G=255,R=255,A=255)
     LevelActionPositionX=0.500000
     LevelActionPositionY=0.250000
     DigitsHealth=(RenderStyle=STY_Alpha,TextureScale=0.490000,DrawPivot=DP_MiddleRight,PosY=1.000000,OffsetX=174,OffsetY=-29,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     DigitsVehicleHealth=(RenderStyle=STY_Alpha,TextureScale=0.490000,DrawPivot=DP_MiddleRight,PosX=0.139000,PosY=1.000000,OffsetX=174,OffsetY=-29,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     DigitsAmmo=(RenderStyle=STY_Alpha,TextureScale=0.490000,DrawPivot=DP_MiddleLeft,PosX=1.000000,PosY=1.000000,OffsetX=-174,OffsetY=-29,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     DigitsShield=(RenderStyle=STY_Alpha,TextureScale=0.490000,DrawPivot=DP_MiddleRight,PosY=1.000000,OffsetX=174,OffsetY=-83,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     UDamageTime=(RenderStyle=STY_Alpha,TextureScale=0.490000,DrawPivot=DP_MiddleMiddle,PosX=0.950000,PosY=0.750000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     UDamageIcon=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=164,X2=73,Y2=246),TextureScale=0.750000,DrawPivot=DP_MiddleMiddle,PosX=0.950000,PosY=0.750000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     AdrenalineIcon=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=113,Y1=38,X2=165,Y2=106),TextureScale=0.330000,DrawPivot=DP_UpperRight,PosX=1.000000,OffsetX=-15,OffsetY=17,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     AdrenalineBackground=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=168,Y1=211,X2=334,Y2=255),TextureScale=0.530000,DrawPivot=DP_UpperRight,PosX=1.000000,OffsetY=10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     AdrenalineBackgroundDisc=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=119,Y1=258,X2=173,Y2=313),TextureScale=0.530000,DrawPivot=DP_UpperRight,PosX=1.000000,OffsetY=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     AdrenalineAlert=(WidgetTexture=FinalBlend'HUDContent.Generic.fb_Pulse001',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.530000,DrawPivot=DP_UpperRight,PosX=1.000000,OffsetX=6,OffsetY=1,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MyScoreIcon=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=104,Y1=44,X2=153,Y2=101),TextureScale=0.530000,OffsetY=72,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MyScoreBackground=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=168,Y1=211,X2=334,Y2=255),TextureScale=0.530000,OffsetY=64,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HudHealthALERT=(WidgetTexture=FinalBlend'HUDContent.Generic.HUDPulse',RenderStyle=STY_Alpha,TextureCoords=(X1=125,Y1=458,X2=291,Y2=511),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HudVehicleHealthALERT=(WidgetTexture=FinalBlend'HUDContent.Generic.HUDPulse',RenderStyle=STY_Alpha,TextureCoords=(X1=125,Y1=458,X2=291,Y2=511),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.139000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HudAmmoALERT=(WidgetTexture=FinalBlend'HUDContent.Generic.HUDPulse',RenderStyle=STY_Alpha,TextureCoords=(X1=125,Y1=458,X2=291,Y2=511),TextureScale=0.530000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HudBorderShield=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=110,X2=166,Y2=163),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosY=1.000000,OffsetY=-54,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HudBorderHealth=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=110,X2=166,Y2=163),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HudBorderVehicleHealth=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=110,X2=166,Y2=163),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.139000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HudBorderAmmo=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=110,X2=166,Y2=163),TextureScale=0.530000,DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HudBorderShieldIcon=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=248,X2=68,Y2=310),TextureScale=0.500000,DrawPivot=DP_LowerLeft,PosY=1.000000,OffsetY=-55,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     HudBorderHealthIcon=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=74,Y1=165,X2=123,Y2=216),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosY=1.000000,OffsetX=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     HudBorderVehicleHealthIcon=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=227,Y1=406,X2=280,Y2=448),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.139000,PosY=1.000000,OffsetX=5,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarWeaponIcon(0)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=169,Y1=39,X2=241,Y2=77),TextureScale=0.530000,DrawPivot=DP_LowerMiddle,PosX=0.139000,PosY=1.000000,OffsetY=-12,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BarWeaponIcon(1)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=245,Y1=39,X2=329,Y2=79),TextureScale=0.530000,DrawPivot=DP_LowerMiddle,PosX=0.219000,PosY=1.000000,OffsetY=-8,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BarWeaponIcon(2)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=179,Y1=127,X2=241,Y2=175),TextureScale=0.530000,DrawPivot=DP_LowerMiddle,PosX=0.300000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BarWeaponIcon(3)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=250,Y1=110,X2=330,Y2=145),TextureScale=0.530000,DrawPivot=DP_LowerMiddle,PosX=0.380000,PosY=1.000000,OffsetY=-12,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BarWeaponIcon(4)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=169,Y1=78,X2=244,Y2=124),TextureScale=0.530000,DrawPivot=DP_LowerMiddle,PosX=0.460000,PosY=1.000000,OffsetY=-4,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BarWeaponIcon(5)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=246,Y1=80,X2=332,Y2=106),TextureScale=0.530000,DrawPivot=DP_LowerMiddle,PosX=0.540000,PosY=1.000000,OffsetY=-18,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BarWeaponIcon(6)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=169,Y1=172,X2=245,Y2=208),TextureScale=0.530000,DrawPivot=DP_LowerMiddle,PosX=0.621000,PosY=1.000000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BarWeaponIcon(7)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=253,Y1=146,X2=333,Y2=181),TextureScale=0.530000,DrawPivot=DP_LowerMiddle,PosX=0.700000,PosY=1.000000,OffsetY=-13,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BarWeaponIcon(8)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(X1=246,Y1=182,X2=331,Y2=210),TextureScale=0.530000,DrawPivot=DP_LowerMiddle,PosX=0.780000,PosY=1.000000,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BarBorder(0)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=39,X2=94,Y2=93),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.139000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorder(1)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=39,X2=94,Y2=93),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.219000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorder(2)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=39,X2=94,Y2=93),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.300000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorder(3)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=39,X2=94,Y2=93),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.380000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorder(4)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=39,X2=94,Y2=93),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.460000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorder(5)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=39,X2=94,Y2=93),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.540000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorder(6)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=39,X2=94,Y2=93),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.621000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorder(7)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=39,X2=94,Y2=93),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.700000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorder(8)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=39,X2=94,Y2=93),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.780000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorderAmmoIndicator(0)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=94,X2=94,Y2=109),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.139000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorderAmmoIndicator(1)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=94,X2=94,Y2=109),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.219000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorderAmmoIndicator(2)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=94,X2=94,Y2=109),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.300000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorderAmmoIndicator(3)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=94,X2=94,Y2=109),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.380000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorderAmmoIndicator(4)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=94,X2=94,Y2=109),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.460000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorderAmmoIndicator(5)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=94,X2=94,Y2=109),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.540000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorderAmmoIndicator(6)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=94,X2=94,Y2=109),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.621000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorderAmmoIndicator(7)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=94,X2=94,Y2=109),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.700000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorderAmmoIndicator(8)=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=94,X2=94,Y2=109),TextureScale=0.530000,DrawPivot=DP_LowerLeft,PosX=0.780000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200))
     BarBorderScaledPosition(0)=0.320000
     BarBorderScaledPosition(1)=0.360000
     BarBorderScaledPosition(2)=0.400000
     BarBorderScaledPosition(3)=0.440000
     BarBorderScaledPosition(4)=0.480000
     BarBorderScaledPosition(5)=0.521000
     BarBorderScaledPosition(6)=0.561000
     BarBorderScaledPosition(7)=0.601000
     BarBorderScaledPosition(8)=0.641000
     RechargeBar=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=313,X2=170,Y2=348),TextureScale=0.500000,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=1.000000,OffsetY=-93,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=220),Tints[1]=(B=255,G=255,R=255,A=220))
     bDrawTimer=True
     FadeTime=0.300000
     CountDownName(0)="one"
     CountDownName(1)="two"
     CountDownName(2)="three"
     CountDownName(3)="four"
     CountDownName(4)="five"
     CountDownName(5)="six"
     CountDownName(6)="seven"
     CountDownName(7)="eight"
     CountDownName(8)="nine"
     CountDownName(9)="ten"
     LongCountName(0)="5_minute_warning"
     LongCountName(1)="3_minutes_remain"
     LongCountName(2)="2_minutes_remain"
     LongCountName(3)="1_minute_remains"
     LongCountName(4)="30_seconds_remain"
     LongCountName(5)="20_seconds"
     BarWeaponIconAnim(0)=1
     HudColorRed=(R=200,A=255)
     HudColorBlue=(B=200,G=64,R=50,A=255)
     HudColorBlack=(A=255)
     HudColorHighLight=(G=160,R=255,A=255)
     HudColorNormal=(B=255,G=255,R=255,A=255)
     HudColorTeam(0)=(R=200,A=255)
     HudColorTeam(1)=(B=200,G=64,R=50,A=255)
     ConsoleMessagePosX=0.005000
     ConsoleMessagePosY=0.870000
}

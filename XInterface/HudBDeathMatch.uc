#exec OBJ LOAD FILE=XGameShaders.utx
#exec OBJ LOAD FILE=Crosshairs.utx
#EXEC OBJ LOAD FILE=LastManStanding.utx

class HudBDeathMatch extends HudBase
    config(User);

var() DigitSet DigitsBig;

var() SpriteWidget LHud1[4];
var() SpriteWidget LHud2[4];

var() SpriteWidget RHud1[4];
var() SpriteWidget RHud2[4];

const WEAPON_BAR_SIZE = 9;

var() SpriteWidget WeaponBarAmmoFill[WEAPON_BAR_SIZE];
var() SpriteWidget WeaponBarTint[WEAPON_BAR_SIZE];
var() SpriteWidget WeaponBarTrim[WEAPON_BAR_SIZE];
var() SpriteWidget WeaponBarIcon[WEAPON_BAR_SIZE];
var() class<Weapon> BaseWeapons[WEAPON_BAR_SIZE];

var() SpriteWidget AmmoIcon;

var() SpriteWidget ScoreBg[4];
var() SpriteWidget Adrenaline[5];

var() SpriteWidget  HealthIcon;

var() NumericWidget AdrenalineCount;
var() NumericWidget ComboCount;
var() NumericWidget HealthCount;
var() NumericWidget AmmoCount;
var() NumericWidget ShieldCount;
var() NumericWidget mySpread;
var() NumericWidget myRank;
var() NumericWidget myScore;

var() SpriteWidget ShieldIconGlow;
var() SpriteWidget ShieldIcon;
var() SpriteWidget AdrenalineIcon;
var() SpriteWidget ReloadingTeamTint;
var() SpriteWidget ReloadingTrim;
var() SpriteWidget ReloadingFill;

var() SpriteWidget UDamageTeamTint;
var() SpriteWidget UDamageTrim;
var() SpriteWidget UDamageFill;

var() Font LevelActionFontFont;
var() Color LevelActionFontColor;

var() float LevelActionPositionX, LevelActionPositionY;
var() float CurrentWeaponPositionX, CurrentWeaponPositionY;

var() Texture LogoTexture;

var() float LogoScaleX;
var() float LogoScaleY;
var() float LogoPosX;
var() float LogoPosY;

var() float testLerp;

var() float comboTime;
var() float accumData[4];
var() float growScale[4];
var() float growTrace[4];
var() int   pulse[5];

var() bool ArmorGlow;
var() bool Displaying;
var() bool growing;
var() bool LowHealthPulse;
var() bool TeamLinked;
var() bool AdrenalineReady;
var bool bRealSmallWeaponBar;

var float OldHUDScale;

var() float TransRechargeAmount;

var transient float CurHealth, LastHealth, CurShield, LastShield, CurEnergy, CurAmmoPrimary, pulseHealthIcon,pulseArmorIcon;
var transient float MaxShield, MaxEnergy, MaxAmmoPrimary;

var transient int CurScore, CurRank, ScoreDiff;

var int OldRemainingTime;
var sound CountDown[10];
var sound LongCount[6];

var PlayerReplicationInfo NamedPlayer;
var float NameTime;

var Material Portrait;
var float PortraitTime;
var float PortraitX;

var array<SceneManager> MySceneManagers;

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'InterfaceContent.HUD.SkinA');
    Level.AddPrecacheMaterial(Material'XGameShaders.ScreenNoise');
    Level.AddPrecacheMaterial(Material'InterfaceContent.BorderBoxA1');
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

// TODO Add support for custom crosshair scale to menus
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
	local int i,j;

	if ( (CustomHUDColor.R == 0) && (CustomHUDColor.G == 0) && (CustomHUDColor.B == 0) && (CustomHUDColor.A == 0) )
		return;

	bUsingCustomHUDColor = true;
	for ( j=0; j<2; j++ )
	{
		ReloadingTeamTint.Tints[j] = CustomHUDColor;
		UDamageTeamTint.Tints[j] = CustomHUDColor;
		for ( i=1; i<3; i++ )
		{
			LHUD1[i].Tints[j] = CustomHUDColor;
			LHUD2[i].Tints[j] = CustomHUDColor;
			RHUD1[i].Tints[j] = CustomHUDColor;
			RHUD2[i].Tints[j] = CustomHUDColor;
			Adrenaline[i].Tints[j] = CustomHUDColor;
			ScoreBg[i].Tints[j] = CustomHUDColor;
		}
		for ( i=0; i<9; i++ )
			WeaponBarTint[i].Tints[j] = CustomHUDColor;
	}
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
			PlayerOwner.PlayAnnouncement(LongCount[0],1,true);
		else if ( OldRemainingTime == 180 )
			PlayerOwner.PlayAnnouncement(LongCount[1],1,true);
		else if ( OldRemainingTime == 120 )
			PlayerOwner.PlayAnnouncement(LongCount[2],1,true);
		else if ( OldRemainingTime == 60 )
			PlayerOwner.PlayAnnouncement(LongCount[3],1,true);
		return;
	}
	if ( OldRemainingTime == 30 )
		PlayerOwner.PlayAnnouncement(LongCount[4],1,true);
	else if ( OldRemainingTime == 20 )
		PlayerOwner.PlayAnnouncement(LongCount[5],1,true);
	else if ( (OldRemainingTime <= 10) && (OldRemainingTime > 0) )
		PlayerOwner.PlayAnnouncement(CountDown[OldRemainingTime - 1],1,true);
}

simulated function Tick(float deltaTime)
{
	local Material NewPortrait;

    Super.Tick(deltaTime);

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

    pulseNumber(0, HealthCount, 0.26, 0.05, deltaTime, 0.25, 0,255,CurHealth, LastHealth);
    pulseNumber(1, ShieldCount, 0.26, 0.05, deltaTime, 0.25, 0,255,CurShield, LastShield);

    ArmorPulse(deltaTime,255,0,ShieldIconGlow,TeamIndex,250);
    if(CurHealth < 50)
        LowHealth(deltaTime,255,0,LHud2[3],TeamIndex,1000);
    else
        LHud2[3].Tints[TeamIndex].A = 50;

    if(CurHealth < 25)
        pulseWidget(deltaTime, 255, 0, HealthIcon, TeamIndex, 2, 2000);
    else
        HealthIcon.Tints[TeamIndex].A = 255;

    if(AdrenalineReady)
        pulseWidget(deltaTime, 255, 0, Adrenaline[4], TeamIndex, 2, 1000);
    else
        Adrenaline[4].Tints[TeamIndex].A = 0;
}

simulated function pulseWidget(float deltaTime, float max, float min, out SpriteWidget sprite, int tIndex, int pIndex, float pRate)
{
    local float accum;

    accum = deltaTime * pRate;

    if(sprite.Tints[tIndex].A < min)
        accumData[pIndex] += accum;
    else
        accumData[pIndex] -= accum;

    if(accumData[pIndex] < min)
        accumData[pIndex] = max;

    sprite.Tints[tIndex].A = accumData[pIndex];
}

simulated function pulseNumber(int gIndex, out NumericWidget number, float nScale, float growSpeed, float deltaTime, float oScale ,float test1,float test2, float first, float last)
{
    local float growAccum;

    growAccum = deltaTime * growSpeed;

    testLerp = test1 + (deltaTime * 2) *(test2 - test1);

    if(growing)
    {
        growScale[gIndex] -= growAccum;
        growTrace[gIndex] += testLerp;

        if(growTrace[gIndex] > 255)
            growTrace[gIndex] = 255;

        if (first < last)
        {
            growTrace[gIndex] = 0;
            growScale[gIndex] = nScale;
        }
        if(growScale[gIndex] < oScale)
            growScale[gIndex] = oScale;

        if(growScale[gIndex] < oScale && growTrace[gIndex] ==255)
            growing = false;

        number.Tints[TeamIndex].B = growTrace[gIndex];
        number.TextureScale = growScale[gIndex];
    }
    else if (first < last)
    {
        growTrace[gIndex] = 0;
        growScale[gIndex] = nScale;
        growing = true;
    }
    else
    {
        growScale[gIndex] = oScale;
    }
}


simulated function ArmorPulse(float deltaTime, float max, float min, out SpriteWidget sprite, int tIndex, float pRate)
{
    local int accum;

    accum = deltaTime * pRate;

    if(ArmorGlow)
        pulseArmorIcon += accum;
    else
        pulseArmorIcon -= accum;

    if(pulseArmorIcon<= min)
    {
        pulseArmorIcon= min;
        ArmorGlow = true;
    }
    else if(pulseArmorIcon >= max)
    {
        pulseArmorIcon= max;
        ArmorGlow = false;
    }

    sprite.Tints[tIndex].A = pulseArmorIcon;
    sprite.Tints[tIndex].B = pulseArmorIcon;

}
simulated function LowHealth(float deltaTime, float max, float min, out SpriteWidget sprite, int tIndex,float pRate)
{
    local int accum;

    accum = deltaTime * pRate;

    if(LowHealthPulse)
        pulseHealthIcon += accum;
    else
        pulseHealthIcon -= accum;

    if(pulseHealthIcon<= min)
    {
        pulseHealthIcon= min;
        LowHealthPulse = true;
    }
    else if(pulseHealthIcon >= max)
    {
        pulseHealthIcon= max;
        LowHealthPulse = false;
    }
    sprite.Tints[tIndex].A = pulseHealthIcon;
}

//////////////////////////////////////////
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
        DrawNumericWidget (C, myScore, DigitsBig);
        if ( C.ClipX >= 640 )
			DrawNumericWidget (C, mySpread, DigitsBig);
        DrawNumericWidget (C, myRank, DigitsBig);
    }

    if(myRank.Value > 9)
    {
        myRank.TextureScale = 0.12;
        myRank.OffsetX = 240;
        myRank.OffsetY = 90;
    }
    else
    {
        myRank.TextureScale = 0.18;
        myRank.OffsetX = 150;
        myRank.OffsetY = 40;
    }
}

simulated function CalculateHealth()
{
    LastHealth = CurHealth;
    CurHealth = PawnOwner.Health;
}

simulated function CalculateShield()
{
    LastShield = CurShield;
    if( PawnOwner.IsA ('XPawn') )
    {
        MaxShield = XPawn(PawnOwner).ShieldStrengthMax;
        CurShield = Clamp (XPawn(PawnOwner).ShieldStrength, 0, MaxShield);
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
    AdrenalineCount.Value = CurEnergy;
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

simulated function DrawSpectatingHud (Canvas C)
{
	local string InfoString;
    local plane OldModulate;
    local float xl,yl,Full, Height, Top, TextTop, MedH, SmallH,Scale;
    local GameReplicationInfo GRI;
    local int i;

    DisplayLocalMessages (C);

	// Hack for tutorials.

	if (MySceneManagers.Length>0)
    {
    	for (i=0;i<MySceneManagers.Length;i++)
        	if (MySceneManagers[i].bIsRunning)
				return;
    }

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

simulated function DrawCrosshair (Canvas C)
{
    local float NormalScale;
    local int i, CurrentCrosshair;
    local float OldScale,OldW, CurrentCrosshairScale;
    local color CurrentCrosshairColor;
	local SpriteWidget CHtexture;

    if (!bCrosshairShow)
        return;

	if ( bUseCustomWeaponCrosshairs && (PawnOwner != None) && (PawnOwner.Weapon != None) )
	{
		CurrentCrosshair = PawnOwner.Weapon.CustomCrosshair;
		if (CurrentCrosshair == -1 || CurrentCrosshair == Crosshairs.Length)
		{
//			log("Not drawing crosshair because it's -1 or "$Crosshairs.Length);
			DrawEnemyName(C);
			return;
		}

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
    CHTexture.TextureScale *= CurrentCrosshairScale;

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

function SetSmallWeaponBar()
{
	local int i;

	bRealSmallWeaponBar = bSmallWeaponBar;

	if ( bSmallWeaponBar )
	{
		LHud1[0].TextureCoords.Y2 = 893;
		LHud1[1].TextureCoords.Y2 = 893;
		LHud1[0].PosY = 0.89;
		LHud1[1].PosY = 0.89;
		LHud1[0].TextureScale = 0.25;
		LHud1[1].TextureScale = 0.25;

		LHud2[1].PosY = 0.88;
		LHud2[0].PosY = 0.88;
		LHud1[3].PosY = 0.88;
		LHud2[3].PosY = 0.88;
		HealthIcon.PosY = 0.88;
		HealthCount.PosY = 0.88;

		LHud2[1].PosX = -0.03;
		LHud2[0].PosX = -0.03;
		LHud1[3].PosX = -0.03;
		LHud2[3].PosX = -0.03;
		HealthIcon.PosX = -0.03;
		HealthCount.PosX = -0.03;


		UDamageTrim.TextureScale = 0.27;
		UDamageTeamTint.TextureScale = 0.27;
		UDamageFill.TextureScale = 0.27;

		UDamageTrim.PosX = -0.005;
		UDamageTeamTint.PosX = -0.005;
		UDamageFill.PosX = -0.005;

		UDamageTrim.PosY = 0.88;
		UDamageTeamTint.PosY = 0.88;
		UDamageFill.PosY = 0.88;

		RHud1[0].TextureCoords.Y2 = 893;
		RHud1[1].TextureCoords.Y2 = 893;
		RHud1[0].PosY = 0.89;
		RHud1[1].PosY = 0.89;
		RHud1[0].TextureScale = 0.25;
		RHud1[1].TextureScale = 0.25;

		RHud2[1].PosY = 0.88;
		RHud2[0].PosY = 0.88;
		RHud1[3].PosY = 0.88;
		RHud2[3].PosY = 0.88;
		AmmoIcon.PosY = 0.88;
		AmmoCount.PosY = 0.88;

		RHud2[1].PosX = 1.03;
		RHud2[0].PosX = 1.03;
		RHud1[3].PosX = 1.03;
		RHud2[3].PosX = 1.03;
		AmmoIcon.PosX = 1.03;
		AmmoCount.PosX = 1.03;

		ReloadingTrim.TextureScale = 0.27;
		ReloadingTeamTint.TextureScale = 0.27;
		ReloadingFill.TextureScale = 0.27;

		ReloadingTrim.PosX = 1.005;
		ReloadingTeamTint.PosX = 1.005;
		ReloadingFill.PosX = 1.005;

		ReloadingTrim.PosY = 0.88;
		ReloadingTeamTint.PosY = 0.88;
		ReloadingFill.PosY = 0.88;
	}
	else
	{
		// reset to defaults
		for ( i=0; i<4; i++ )
		{
			LHUD1[i].PosX = Default.LHUD1[i].PosX;
			LHUD1[i].PosY = Default.LHUD1[i].PosY;

			LHUD2[i].PosX = Default.LHUD2[i].PosX;
			LHUD2[i].PosY = Default.LHUD2[i].PosY;

			RHUD1[i].PosX = Default.RHUD1[i].PosX;
			RHUD1[i].PosY = Default.RHUD1[i].PosY;

			RHUD2[i].PosX = Default.RHUD2[i].PosX;
			RHUD2[i].PosY = Default.RHUD2[i].PosY;

			ShieldCount.PosY = Default.ShieldCount.PosY;
			ShieldIcon.PosY = Default.ShieldIcon.PosY;
			ShieldIconGlow.PosY = Default.ShieldIconGlow.PosY;
		}
		LHUD1[0].TextureScale = Default.LHUD1[0].TextureScale;
		LHud1[0].TextureCoords = Default.LHud1[0].TextureCoords;
		RHUD1[0].TextureScale = Default.RHUD1[0].TextureScale;
		RHUD1[0].TextureCoords = Default.RHud1[0].TextureCoords;

		LHUD1[1].TextureScale = Default.LHUD1[1].TextureScale;
		LHud1[1].TextureCoords = Default.LHud1[1].TextureCoords;
		RHUD1[1].TextureScale = Default.RHUD1[1].TextureScale;
		RHUD1[1].TextureCoords = Default.RHud1[1].TextureCoords;

		HealthIcon.PosY = Default.HealthIcon.PosY;
		HealthCount.PosY = Default.HealthCount.PosY;
		HealthIcon.PosX = Default.HealthIcon.PosX;
		HealthCount.PosX = Default.HealthCount.PosX;

		UDamageTrim.TextureScale = Default.UDamageTrim.TextureScale;
		UDamageTeamTint.TextureScale = Default.UDamageTeamTint.TextureScale;
		UDamageFill.TextureScale = Default.UDamageFill.TextureScale;

		UDamageTrim.PosX = Default.UDamageTrim.PosX;
		UDamageTeamTint.PosX = Default.UDamageTeamTint.PosX;
		UDamageFill.PosX = Default.UDamageFill.PosX;

		UDamageTrim.PosY = Default.UDamageTrim.PosY;
		UDamageTeamTint.PosY = Default.UDamageTeamTint.PosY;
		UDamageFill.PosY = Default.UDamageFill.PosY;

		AmmoIcon.PosY = Default.AmmoIcon.PosY;
		AmmoCount.PosY = Default.AmmoCount.PosY;

		AmmoIcon.PosX = Default.AmmoIcon.PosX;
		AmmoCount.PosX = Default.AmmoCount.PosX;

		ReloadingTrim.TextureScale = Default.ReloadingTrim.TextureScale;
		ReloadingTeamTint.TextureScale = Default.ReloadingTeamTint.TextureScale;
		ReloadingFill.TextureScale = Default.ReloadingFill.TextureScale;

		ReloadingTrim.PosX = Default.ReloadingTrim.PosX;
		ReloadingTeamTint.PosX = Default.ReloadingTeamTint.PosX;
		ReloadingFill.PosX = Default.ReloadingFill.PosX;

		ReloadingTrim.PosY = Default.ReloadingTrim.PosY;
		ReloadingTeamTint.PosY = Default.ReloadingTeamTint.PosY;
		ReloadingFill.PosY = Default.ReloadingFill.PosY;
	}
	SetHUDScale();
}

function SetHUDScale()
{
	local int i;
	local float NewPosX,NewPosY;

	OldHUDScale = HUDScale;

	if ( bSmallWeaponBar )
	{
		HudScale *= 0.67;
		NewPosY = Default.WeaponBarTint[0].PosY + (1 - HUDScale) * 0.043;
	}
	else
		NewPosY = Default.WeaponBarTint[0].PosY;

    for( i=0; i<WEAPON_BAR_SIZE; i++ )
	{
		NewPosX = 0.5 * (1 - HUDScale) + HUDScale * Default.WeaponBarAmmoFill[i].PosX;
		WeaponBarAmmoFill[i].PosX = newPosX;
		WeaponBarTint[i].PosX = newPosX;
		WeaponBarTrim[i].PosX = newPosX;
		WeaponBarIcon[i].PosX = newPosX;
		WeaponBarAmmoFill[i].PosY = NewPosY + 0.043 * HUDScale;
		WeaponBarTint[i].PosY = NewPosY;
		WeaponBarTrim[i].PosY = NewPosY;
		WeaponBarIcon[i].PosY = NewPosY;
	}

	HUDScale = OldHUDScale;
}

function DisplayVoiceGain(Canvas C)
{
	local Texture Tex;
	local float VoiceGain;
	local float PosY, BlockSize;
	local int i;

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
}

// Alpha Pass ==================================================================================
simulated function DrawHudPassA (Canvas C)
{
	local class<Ammunition> AmmoClass;

    ShowPointBarBottom(C);

	if ( bSmallWeaponBar != bRealSmallWeaponBar )
		SetSmallWeaponBar();
	if ( HUDScale != OldHUDScale )
		SetHUDScale();
    if( bShowPersonalInfo )
    {
        DrawSpriteWidget (C, LHud1[1]);
        DrawSpriteWidget (C, LHud2[1]);

        DrawSpriteWidget (C, Adrenaline[1] );
        DrawSpriteWidget (C, LHud1[0]);
        DrawSpriteWidget (C, LHud2[0]);
        DrawSpriteWidget (C, LHud1[3]);
        DrawSpriteWidget (C, LHud2[3]);
   }

	if ( bShowWeaponBar && (PawnOwner.Weapon != None) )
        DrawWeaponBar(C);

    if( bShowWeaponInfo && (PawnOwner.Weapon != None) )
    {
        DrawSpriteWidget (C, RHud1[1]);
        DrawSpriteWidget (C, RHud2[1]);

        DrawSpriteWidget (C, RHud1[0]);
        DrawSpriteWidget (C, RHud2[0]);

        DrawSpriteWidget (C, RHud1[3]);
        DrawSpriteWidget (C, RHud2[3]);

        if ( PawnOwner.Weapon.bShowChargingBar )
        {
            ReloadingFill.Scale = PawnOwner.Weapon.ChargeBar();

            DrawSpriteWidget (C, ReloadingFill);
            DrawSpriteWidget (C, ReloadingTeamTint);
            DrawSpriteWidget (C, ReloadingTrim);
        }

		AmmoClass = PawnOwner.Weapon.GetAmmoClass(0);
        if( (AmmoClass != None) && (AmmoClass.Default.IconMaterial != None) )
        {
            AmmoIcon.WidgetTexture = AmmoClass.Default.IconMaterial;
            AmmoIcon.TextureCoords = AmmoClass.Default.IconCoords;
            DrawSpriteWidget (C, AmmoIcon);
        }
    }

    if( bShowPersonalInfo && (ShieldCount.Value > 0) )
        DrawSpriteWidget (C, ShieldIconGlow);

	if( Level.TimeSeconds - LastVoiceGainTime < 0.333 )
		DisplayVoiceGain(C);

}

simulated function ShowPointBarTop(Canvas C)
{
    if( bShowPoints )
    {
        DrawSpriteWidget (C, ScoreBG[0]);
        DrawSpriteWidget (C, ScoreBG[3]);
    }
}
simulated function ShowPointBarBottom(Canvas C)
{
    if( bShowPoints )
    {
        DrawSpriteWidget (C, ScoreBG[2]);
        DrawSpriteWidget (C, ScoreBG[1]);
    }
}

// Alpha Pass ==================================================================================
simulated function DrawHudPassC (Canvas C)
{
	local float PortraitWidth,PortraitHeight, XL, YL, Abbrev, SmallH, NameWidth;
	local string PortraitString;

	// portrait
	if ( bShowPortrait && (Portrait != None) )
	{
		PortraitWidth = 0.125 * C.ClipY;
		PortraitHeight = 1.5 * PortraitWidth;
		C.DrawColor = WhiteColor;

		C.SetPos(-PortraitWidth*PortraitX + 0.025*PortraitWidth,0.5*(C.ClipY-PortraitHeight) + 0.025*PortraitHeight);
		C.DrawTile( Portrait, PortraitWidth, PortraitHeight, 0, 0, 256, 384);

		C.SetPos(-PortraitWidth*PortraitX,0.5*(C.ClipY-PortraitHeight));
		C.Font = GetFontSizeIndex(C,-2);
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

		C.DrawColor = C.static.MakeColor(160,160,160);
		C.SetPos(-PortraitWidth*PortraitX + 0.025*PortraitWidth,0.5*(C.ClipY-PortraitHeight) + 0.025*PortraitHeight);
		C.DrawTile( Material'XGameShaders.ModuNoise', PortraitWidth, PortraitHeight, 0.0, 0.0, 512, 512 );

		C.DrawColor = WhiteColor;
		C.SetPos(-PortraitWidth*PortraitX,0.5*(C.ClipY-PortraitHeight));
		C.DrawTileStretched(texture 'InterfaceContent.Menu.BorderBoxA1', 1.05 * PortraitWidth, 1.05*PortraitHeight);

		C.DrawColor = WhiteColor;
		C.SetPos(C.ClipY/256-PortraitWidth*PortraitX + 0.5 * (PortraitWidth - XL),0.5*(C.ClipY+PortraitHeight) + 0.06*PortraitHeight);
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
		}
	}

    // Screen
    ShowPointBarTop(C);

    if( bShowPersonalInfo )
    {
        DrawSpriteWidget (C, Adrenaline[0]);
        DrawSpriteWidget (C, Adrenaline[3]);
        DrawSpriteWidget (C, Adrenaline[4]);
        DrawNumericWidget (C, AdrenalineCount, DigitsBig);
        DrawSpriteWidget (C, AdrenalineIcon);

		if( PawnOwner.IsA ('XPawn') && (XPawn(PawnOwner).UDamageTime > Level.TimeSeconds) )
		{
			UDamageFill.Scale = FMin((XPawn(PawnOwner).UDamageTime - Level.TimeSeconds) * 0.0333,1);

			DrawSpriteWidget (C, UDamageFill);
			DrawSpriteWidget (C, UDamageTeamTint);
			DrawSpriteWidget (C, UDamageTrim);
		}
        DrawSpriteWidget (C, HealthIcon);

		if( ShieldCount.Value > 0 )
		{
			DrawSpriteWidget (C, ShieldIcon);
			DrawNumericWidget (C, ShieldCount, DigitsBig);
		}

        DrawNumericWidget (C, HealthCount, DigitsBig);
	}

    UpdateRankAndSpread(C);

    if( bShowWeaponInfo && (PawnOwner != None) && (PawnOwner.Weapon != None) )
    {
        DrawNumericWidget (C, AmmoCount, DigitsBig);
        if ( bSmallWeaponBar )
			PawnOwner.Weapon.NewDrawWeaponInfo(C, 0.87*C.ClipX);
		else
			PawnOwner.Weapon.NewDrawWeaponInfo(C, 0.705*C.ClipX);
    }

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

simulated function DrawWeaponBar( Canvas C )
{
    local int i;

    local Weapon Weapons[WEAPON_BAR_SIZE];
    local Inventory Inv;
    local Weapon W, PendingWeapon;
	local int Count;
	local float RealHUDScale;
	local float NewPosX,NewPosY, SavedPosY, AddPosX;

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

        if( W == None )
            continue;

        if( W.IconMaterial == None )
            continue;

		if ( W.InventoryGroup == 0 )
			Weapons[8] = W;
		else if ( W.InventoryGroup < 10 )
			Weapons[W.InventoryGroup-1] = W;
    }
	if ( PendingWeapon != None )
	{
		if ( PendingWeapon.InventoryGroup == 0 )
			Weapons[8] = PendingWeapon;
		else if ( PendingWeapon.InventoryGroup < 10 )
			Weapons[PendingWeapon.InventoryGroup-1] = PendingWeapon;
	}

	if ( bSmallWeaponBar )
	{
		RealHUDScale = HUDScale;
		HudScale *= 0.67;
		SavedPosY = Default.WeaponBarTint[0].PosY + (1 - HUDScale) * 0.043;
	}

    // Draw:
    for( i=0; i<WEAPON_BAR_SIZE; i++ )
    {
        W = Weapons[i];

		if ( bSmallWeaponBar )
		{
			if ( W == PendingWeapon )
			{
				NewPosX = 0.5 * (1 - HUDScale) + HUDScale * (0.095 + 0.085*i);
				NewPosY = Default.WeaponBarTint[0].PosY;
				AddPosX = 0.03;
				HUDScale = RealHUDScale;
			}
			else
			{
				HUDScale = 0.67 * RealHUDScale;
				NewPosX = AddPosX + 0.5 * (1 - HUDScale) + HUDScale * (0.095 + 0.085*i);
				NewPosY = SavedPosY;
			}
			WeaponBarAmmoFill[i].PosX = newPosX;
			WeaponBarTint[i].PosX = newPosX;
			WeaponBarTrim[i].PosX = newPosX;
			WeaponBarIcon[i].PosX = newPosX;
			WeaponBarAmmoFill[i].PosY = NewPosY + 0.043 * HUDScale;
			WeaponBarTint[i].PosY = NewPosY;
			WeaponBarTrim[i].PosY = NewPosY;
			WeaponBarIcon[i].PosY = NewPosY;
		}

		if ( bUsingCustomHUDColor )
		{
			WeaponBarTint[i].Tints[0] = CustomHUDColor;
			WeaponBarTint[i].Tints[1] = CustomHUDColor;
		}
		else
		{
			WeaponBarTint[i].Tints[0] = default.WeaponBarTint[i].Tints[0];
			WeaponBarTint[i].Tints[1] = default.WeaponBarTint[i].Tints[1];
		}
        if( W == None )
        {
            WeaponBarAmmoFill[i].Scale  = 0;

            WeaponBarIcon[i].Tints[TeamIndex].A = 50;
            WeaponBarIcon[i].Tints[TeamIndex].R = 255;
            WeaponBarIcon[i].Tints[TeamIndex].B = 0;
            WeaponBarIcon[i].Tints[TeamIndex].G = 255;

            WeaponBarIcon[i].WidgetTexture = BaseWeapons[i].default.IconMaterial;
            WeaponBarIcon[i].TextureCoords = BaseWeapons[i].default.IconCoords;
        }
        else
        {
            WeaponBarAmmoFill[i].Scale = W.AmmoStatus();

            WeaponBarIcon[i].WidgetTexture = W.IconMaterial;
            WeaponBarIcon[i].TextureCoords = W.IconCoords;

            if (W == PendingWeapon)
            {
                WeaponBarIcon[i].Tints[TeamIndex].A = 255;
                WeaponBarIcon[i].Tints[TeamIndex].R = 255;
                WeaponBarIcon[i].Tints[TeamIndex].B = 0;
                WeaponBarIcon[i].Tints[TeamIndex].G = 255;

                WeaponBarTint[i].Tints[TeamIndex].A = 50;
                WeaponBarTint[i].Tints[TeamIndex].G = 128;
            }
            else
            {
                WeaponBarIcon[i].Tints[TeamIndex].A = 255;
                WeaponBarIcon[i].Tints[TeamIndex].R = 255;
                WeaponBarIcon[i].Tints[TeamIndex].B = 255;
                WeaponBarIcon[i].Tints[TeamIndex].G = 255;
            }
        }

        DrawSpriteWidget( C, WeaponBarAmmoFill[i] );
        DrawSpriteWidget( C, WeaponBarTint[i] );
        DrawSpriteWidget( C, WeaponBarTrim[i] );
        DrawSpriteWidget( C, WeaponBarIcon[i] );
    }
	if ( bSmallWeaponBar )
		HUDScale = RealHUDScale;
}

simulated function UpdateHud()
{
    if ((PawnOwnerPRI != none) && (PawnOwnerPRI.Team != None))
        TeamIndex = Clamp (PawnOwnerPRI.Team.TeamIndex, 0, 1);
    else
        TeamIndex = 1; // Default to the blue HUD because it's sexier

    // Update values ===============================================================================

    CalculateScore();
    // Score.Value = CurScore;

    CalculateHealth();
    HealthCount.Value = CurHealth;

    HealthIcon.Tints[TeamIndex].R = 255 - ( 255 * ( FClamp( CurHealth / 100, 0.0, 1.0) ));
    HealthIcon.Tints[TeamIndex].G = 0;
    HealthIcon.Tints[TeamIndex].B = 255;

    CalculateShield();
    ShieldCount.Value = CurShield;

    CalculateEnergy();
    AdrenalineReady = (CurEnergy == MaxEnergy);

    CalculateAmmo();
    AmmoCount.Value = CurAmmoPrimary;
    if(!TeamLinked)
    {
        RHud2[3].Tints[TeamIndex].R = 255 - ( 255 * ( FClamp( CurAmmoPrimary / MaxAmmoPrimary, 0.0, 1.0) ));
        RHud2[3].Tints[TeamIndex].G = ( 255 * ( FClamp( CurAmmoPrimary / MaxAmmoPrimary, 0.0, 1.0) ));
        RHud2[3].Tints[TeamIndex].B = 0;
    }
    Super.UpdateHud ();
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

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
	Super.Message(PRI,Msg,MsgType);
    if ( PRI != None && (MsgType == 'Say') || (MsgType == 'TeamSay') )
        DisplayPortrait(PRI);
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
     DigitsBig=(DigitTexture=Texture'InterfaceContent.HUD.SkinA',TextureCoords[0]=(X1=100,Y1=400,X2=199,Y2=499),TextureCoords[1]=(X2=99,Y2=99),TextureCoords[2]=(X1=100,X2=199,Y2=99),TextureCoords[3]=(Y1=100,X2=99,Y2=199),TextureCoords[4]=(X1=100,Y1=100,X2=199,Y2=199),TextureCoords[5]=(Y1=200,X2=99,Y2=299),TextureCoords[6]=(X1=100,Y1=200,X2=199,Y2=299),TextureCoords[7]=(Y1=300,X2=99,Y2=399),TextureCoords[8]=(X1=100,Y1=300,X2=199,Y2=399),TextureCoords[9]=(Y1=400,X2=99,Y2=499),TextureCoords[10]=(X1=200,X2=299,Y2=99))
     LHud1(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=763,X2=298,Y2=1023),TextureScale=0.300000,PosY=0.835000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     LHud1(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=299,Y1=763,X2=454,Y2=1023),TextureScale=0.300000,PosY=0.835000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     LHud1(2)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=455,Y1=763,X2=610,Y2=1023),TextureScale=0.300000,PosY=0.835000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     LHud1(3)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(Y1=880,X2=142,Y2=1023),TextureScale=0.300000,PosY=0.835000,OffsetX=85,OffsetY=50,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     LHud2(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=611,Y1=900,X2=979,Y2=1023),TextureScale=0.300000,PosY=0.835000,OffsetX=180,OffsetY=60,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     LHud2(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=611,Y1=777,X2=979,Y2=899),TextureScale=0.300000,PosY=0.835000,OffsetX=180,OffsetY=60,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     LHud2(2)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=611,Y1=654,X2=979,Y2=776),TextureScale=0.300000,PosY=0.835000,OffsetX=180,OffsetY=60,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     LHud2(3)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=810,Y1=200,X2=1023,Y2=413),TextureScale=0.250000,PosY=0.835000,OffsetX=90,OffsetY=35,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=100),Tints[1]=(G=255,R=255,A=100))
     RHud1(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=298,Y1=763,X2=143,Y2=1023),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=0.835000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     RHud1(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=454,Y1=763,X2=299,Y2=1023),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=0.835000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     RHud1(2)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=610,Y1=763,X2=455,Y2=1023),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=0.835000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     RHud1(3)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=142,Y1=880,Y2=1023),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=0.835000,OffsetX=-85,OffsetY=50,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     RHud2(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=979,Y1=900,X2=611,Y2=1023),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=0.835000,OffsetX=-180,OffsetY=60,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     RHud2(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=979,Y1=777,X2=611,Y2=899),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=0.835000,OffsetX=-180,OffsetY=60,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     RHud2(2)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=979,Y1=654,X2=611,Y2=776),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=0.835000,OffsetX=-180,OffsetY=60,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     RHud2(3)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=810,Y1=200,X2=1023,Y2=413),TextureScale=0.250000,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=0.835000,OffsetX=-68,OffsetY=37,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     WeaponBarAmmoFill(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=741,X2=332,Y2=749),TextureScale=0.300000,PosX=0.095000,PosY=0.993000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=200),Tints[1]=(G=255,R=255,A=200))
     WeaponBarAmmoFill(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=741,X2=332,Y2=749),TextureScale=0.300000,PosX=0.185000,PosY=0.993000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=200),Tints[1]=(G=255,R=255,A=200))
     WeaponBarAmmoFill(2)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=741,X2=332,Y2=749),TextureScale=0.300000,PosX=0.275000,PosY=0.993000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=200),Tints[1]=(G=255,R=255,A=200))
     WeaponBarAmmoFill(3)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=741,X2=332,Y2=749),TextureScale=0.300000,PosX=0.365000,PosY=0.993000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=200),Tints[1]=(G=255,R=255,A=200))
     WeaponBarAmmoFill(4)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=741,X2=332,Y2=749),TextureScale=0.300000,PosX=0.455000,PosY=0.993000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=200),Tints[1]=(G=255,R=255,A=200))
     WeaponBarAmmoFill(5)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=741,X2=332,Y2=749),TextureScale=0.300000,PosX=0.545000,PosY=0.993000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=200),Tints[1]=(G=255,R=255,A=200))
     WeaponBarAmmoFill(6)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=741,X2=332,Y2=749),TextureScale=0.300000,PosX=0.635000,PosY=0.993000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=200),Tints[1]=(G=255,R=255,A=200))
     WeaponBarAmmoFill(7)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=741,X2=332,Y2=749),TextureScale=0.300000,PosX=0.725000,PosY=0.993000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=200),Tints[1]=(G=255,R=255,A=200))
     WeaponBarAmmoFill(8)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=741,X2=332,Y2=749),TextureScale=0.300000,PosX=0.815000,PosY=0.993000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=200),Tints[1]=(G=255,R=255,A=200))
     WeaponBarTint(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=678,X2=332,Y2=749),TextureScale=0.300000,PosX=0.095000,PosY=0.950000,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     WeaponBarTint(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=678,X2=332,Y2=749),TextureScale=0.300000,PosX=0.185000,PosY=0.950000,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     WeaponBarTint(2)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=678,X2=332,Y2=749),TextureScale=0.300000,PosX=0.275000,PosY=0.950000,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     WeaponBarTint(3)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=678,X2=332,Y2=749),TextureScale=0.300000,PosX=0.365000,PosY=0.950000,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     WeaponBarTint(4)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=678,X2=332,Y2=749),TextureScale=0.300000,PosX=0.455000,PosY=0.950000,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     WeaponBarTint(5)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=678,X2=332,Y2=749),TextureScale=0.300000,PosX=0.545000,PosY=0.950000,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     WeaponBarTint(6)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=678,X2=332,Y2=749),TextureScale=0.300000,PosX=0.635000,PosY=0.950000,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     WeaponBarTint(7)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=678,X2=332,Y2=749),TextureScale=0.300000,PosX=0.725000,PosY=0.950000,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     WeaponBarTint(8)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=678,X2=332,Y2=749),TextureScale=0.300000,PosX=0.815000,PosY=0.950000,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     WeaponBarTrim(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=533,X2=332,Y2=605),TextureScale=0.300000,PosX=0.095000,PosY=0.950000,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     WeaponBarTrim(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=533,X2=332,Y2=605),TextureScale=0.300000,PosX=0.185000,PosY=0.950000,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     WeaponBarTrim(2)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=533,X2=332,Y2=605),TextureScale=0.300000,PosX=0.275000,PosY=0.950000,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     WeaponBarTrim(3)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=533,X2=332,Y2=605),TextureScale=0.300000,PosX=0.365000,PosY=0.950000,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     WeaponBarTrim(4)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=533,X2=332,Y2=605),TextureScale=0.300000,PosX=0.455000,PosY=0.950000,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     WeaponBarTrim(5)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=533,X2=332,Y2=605),TextureScale=0.300000,PosX=0.545000,PosY=0.950000,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     WeaponBarTrim(6)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=533,X2=332,Y2=605),TextureScale=0.300000,PosX=0.635000,PosY=0.950000,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     WeaponBarTrim(7)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=533,X2=332,Y2=605),TextureScale=0.300000,PosX=0.725000,PosY=0.950000,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     WeaponBarTrim(8)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=143,Y1=533,X2=332,Y2=605),TextureScale=0.300000,PosX=0.815000,PosY=0.950000,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     WeaponBarIcon(0)=(RenderStyle=STY_Alpha,TextureCoords=(X1=169,Y1=39,X2=241,Y2=77),TextureScale=0.530000,PosX=0.139000,PosY=1.000000,OffsetX=18,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WeaponBarIcon(1)=(RenderStyle=STY_Alpha,TextureCoords=(X1=245,Y1=39,X2=329,Y2=79),TextureScale=0.530000,PosX=0.219000,PosY=1.000000,OffsetX=18,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WeaponBarIcon(2)=(RenderStyle=STY_Alpha,TextureCoords=(X1=179,Y1=127,X2=241,Y2=175),TextureScale=0.530000,PosX=0.300000,PosY=1.000000,OffsetX=18,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WeaponBarIcon(3)=(RenderStyle=STY_Alpha,TextureCoords=(X1=250,Y1=110,X2=330,Y2=145),TextureScale=0.530000,PosX=0.380000,PosY=1.000000,OffsetX=18,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WeaponBarIcon(4)=(RenderStyle=STY_Alpha,TextureCoords=(X1=169,Y1=78,X2=244,Y2=124),TextureScale=0.530000,PosX=0.460000,PosY=1.000000,OffsetX=18,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WeaponBarIcon(5)=(RenderStyle=STY_Alpha,TextureCoords=(X1=246,Y1=80,X2=332,Y2=106),TextureScale=0.530000,PosX=0.540000,PosY=1.000000,OffsetX=18,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WeaponBarIcon(6)=(RenderStyle=STY_Alpha,TextureCoords=(X1=169,Y1=172,X2=245,Y2=208),TextureScale=0.530000,PosX=0.621000,PosY=1.000000,OffsetX=18,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WeaponBarIcon(7)=(RenderStyle=STY_Alpha,TextureCoords=(X1=253,Y1=146,X2=333,Y2=181),TextureScale=0.530000,PosX=0.700000,PosY=1.000000,OffsetX=18,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     WeaponBarIcon(8)=(RenderStyle=STY_Alpha,TextureCoords=(X1=246,Y1=182,X2=331,Y2=210),TextureScale=0.530000,PosX=0.780000,PosY=1.000000,OffsetX=18,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     BaseWeapons(0)=Class'XWeapons.ShieldGun'
     BaseWeapons(1)=Class'XWeapons.AssaultRifle'
     BaseWeapons(2)=Class'XWeapons.BioRifle'
     BaseWeapons(3)=Class'XWeapons.ShockRifle'
     BaseWeapons(4)=Class'XWeapons.LinkGun'
     BaseWeapons(5)=Class'XWeapons.Minigun'
     BaseWeapons(6)=Class'XWeapons.FlakCannon'
     BaseWeapons(7)=Class'XWeapons.RocketLauncher'
     BaseWeapons(8)=Class'XWeapons.SniperRifle'
     AmmoIcon=(RenderStyle=STY_Alpha,TextureScale=0.450000,PosX=1.000000,PosY=0.835000,OffsetX=-151,OffsetY=44,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ScoreBg(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=611,Y1=900,X2=979,Y2=1023),TextureScale=0.230000,OffsetX=95,OffsetY=10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     ScoreBg(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=611,Y1=777,X2=979,Y2=899),TextureScale=0.230000,OffsetX=95,OffsetY=10,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     ScoreBg(2)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=611,Y1=654,X2=979,Y2=776),TextureScale=0.230000,OffsetX=95,OffsetY=10,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     ScoreBg(3)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(Y1=880,X2=142,Y2=1023),TextureScale=0.230000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     Adrenaline(0)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=979,Y1=900,X2=611,Y2=1023),TextureScale=0.230000,DrawPivot=DP_UpperRight,PosX=1.000000,OffsetX=-95,OffsetY=10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     Adrenaline(1)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=979,Y1=777,X2=611,Y2=899),TextureScale=0.230000,DrawPivot=DP_UpperRight,PosX=1.000000,OffsetX=-95,OffsetY=10,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     Adrenaline(2)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=979,Y1=654,X2=611,Y2=776),TextureScale=0.230000,DrawPivot=DP_UpperRight,PosX=1.000000,OffsetX=-95,OffsetY=10,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     Adrenaline(3)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(Y1=880,X2=142,Y2=1023),TextureScale=0.230000,DrawPivot=DP_UpperRight,PosX=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     Adrenaline(4)=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=810,Y1=200,X2=1023,Y2=413),TextureScale=0.200000,DrawPivot=DP_UpperRight,PosX=1.000000,OffsetX=35,OffsetY=-28,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255),Tints[1]=(G=255,R=255))
     HealthIcon=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(Y1=750,X2=142,Y2=879),TextureScale=0.300000,PosY=0.835000,OffsetX=82,OffsetY=55,Scale=1.000000,Tints[0]=(B=255,A=255),Tints[1]=(B=255,A=255))
     AdrenalineCount=(RenderStyle=STY_Alpha,TextureScale=0.180000,DrawPivot=DP_UpperRight,PosX=1.000000,OffsetX=-260,OffsetY=40,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     HealthCount=(RenderStyle=STY_Alpha,TextureScale=0.250000,DrawPivot=DP_MiddleRight,PosY=0.835000,OffsetX=620,OffsetY=145,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     AmmoCount=(RenderStyle=STY_Alpha,TextureScale=0.250000,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=0.835000,OffsetX=-340,OffsetY=95,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ShieldCount=(RenderStyle=STY_Alpha,TextureScale=0.250000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.835000,OffsetY=145,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     mySpread=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.090000,DrawPivot=DP_UpperRight,OffsetX=655,OffsetY=135,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     myRank=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.150000,DrawPivot=DP_UpperRight,OffsetX=150,OffsetY=40,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MyScore=(RenderStyle=STY_Alpha,MinDigitCount=2,TextureScale=0.180000,DrawPivot=DP_UpperRight,OffsetX=560,OffsetY=40,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ShieldIconGlow=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=333,Y1=584,X2=457,Y2=749),TextureScale=0.260000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.835000,OffsetX=-1,OffsetY=125,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ShieldIcon=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=458,Y1=584,X2=583,Y2=749),TextureScale=0.250000,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.835000,OffsetY=130,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     AdrenalineIcon=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(Y1=620,X2=142,Y2=749),TextureScale=0.230000,DrawPivot=DP_UpperRight,PosX=1.000000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     ReloadingTeamTint=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=836,Y1=454,X2=450,Y2=490),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=0.835000,OffsetX=-137,OffsetY=15,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     ReloadingTrim=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=836,Y1=415,X2=450,Y2=453),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=0.835000,OffsetX=-137,OffsetY=15,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     ReloadingFill=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=836,Y1=454,X2=450,Y2=490),TextureScale=0.300000,DrawPivot=DP_UpperRight,PosX=1.000000,PosY=0.835000,OffsetX=-137,OffsetY=15,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     UDamageTeamTint=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=836,Y1=490,X2=450,Y2=454),TextureScale=0.300000,PosY=0.835000,OffsetX=137,OffsetY=15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(R=255,A=50),Tints[1]=(B=255,G=64,A=50))
     UDamageTrim=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=836,Y1=453,X2=450,Y2=415),TextureScale=0.300000,PosY=0.835000,OffsetX=137,OffsetY=15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(G=255,R=255,A=255),Tints[1]=(G=255,R=255,A=255))
     UDamageFill=(WidgetTexture=Texture'InterfaceContent.HUD.SkinA',RenderStyle=STY_Alpha,TextureCoords=(X1=836,Y1=490,X2=450,Y2=454),TextureScale=0.300000,PosY=0.835000,OffsetX=137,OffsetY=15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,R=255,A=255),Tints[1]=(B=255,R=255,A=255))
     LevelActionFontColor=(B=255,G=255,R=255,A=255)
     LevelActionPositionX=0.500000
     LevelActionPositionY=0.250000
     CurrentWeaponPositionX=0.845000
     CurrentWeaponPositionY=0.900000
     LogoTexture=Texture'InterfaceContent.Logos.Logo'
     LogoScaleX=0.250000
     LogoScaleY=0.250000
     LogoPosX=0.490000
     LogoPosY=0.150000
     OldHUDScale=1.000000
     CountDown(0)=Sound'AnnouncerMale2K4.Generic.one'
     CountDown(1)=Sound'AnnouncerMale2K4.Generic.two'
     CountDown(2)=Sound'AnnouncerMale2K4.Generic.three'
     CountDown(3)=Sound'AnnouncerMale2K4.Generic.four'
     CountDown(4)=Sound'AnnouncerMale2K4.Generic.five'
     CountDown(5)=Sound'AnnouncerMale2K4.Generic.six'
     CountDown(6)=Sound'AnnouncerMale2K4.Generic.seven'
     CountDown(7)=Sound'AnnouncerMale2K4.Generic.eight'
     CountDown(8)=Sound'AnnouncerMale2K4.Generic.nine'
     CountDown(9)=Sound'AnnouncerMale2K4.Generic.ten'
     LongCount(0)=Sound'AnnouncerMale2K4.Generic.5_minute_warning'
     LongCount(1)=Sound'AnnouncerMale2K4.Generic.3_minutes_remain'
     LongCount(2)=Sound'AnnouncerMale2K4.Generic.2_minutes_remain'
     LongCount(3)=Sound'AnnouncerMale2K4.Generic.1_minute_remains'
     LongCount(4)=Sound'AnnouncerMale2K4.Generic.30_seconds_remain'
     LongCount(5)=Sound'AnnouncerMale2K4.Generic.20_seconds'
     ConsoleMessagePosX=0.005000
     ConsoleMessagePosY=0.825000
}

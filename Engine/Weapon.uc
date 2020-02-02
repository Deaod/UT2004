class Weapon extends Inventory
    abstract
    native
    nativereplication
    HideDropDown
	CacheExempt;

#exec Texture Import File=Textures\Weapon.tga Name=S_Weapon Mips=Off Alpha=1

replication
{
    // Things the server should send to the client.
    reliable if( Role==ROLE_Authority )
        Ammo, AmmoCharge;

    // Functions called by server on client
    reliable if( Role==ROLE_Authority )
        ClientWeaponSet, ClientWeaponThrown, ClientForceAmmoUpdate, ClientWriteStats, ClientWriteFire;

    // functions called by client on server
    reliable if( Role<ROLE_Authority )
        ServerStartFire, ServerStopFire;
}

const NUM_FIRE_MODES = 2;

var() class<WeaponFire> FireModeClass[NUM_FIRE_MODES];
var() protected WeaponFire FireMode[NUM_FIRE_MODES];
var() protected Ammunition Ammo[NUM_FIRE_MODES];

// animation //
var() Name IdleAnim;
var() Name RestAnim;
var() Name AimAnim;
var() Name RunAnim;
var() Name SelectAnim;
var() Name PutDownAnim;

var() float IdleAnimRate;
var() float RestAnimRate;
var() float AimAnimRate;
var() float RunAnimRate;
var() float SelectAnimRate;
var() float PutDownAnimRate;
var float PutDownTime;
var float BringUpTime;

var() Sound SelectSound;
var() String SelectForce;  // jdf

// AI //
var()	int		BotMode; // the fire Mode currently being used for bots
var()	float	AIRating;
var		float	CurrentRating;	// rating result from most recent RateSelf()
var()	bool	bMeleeWeapon;
var()	bool	bSniping;

// other useful stuff //
var	  bool bShowChargingBar;
var	  bool bMatchWeapons;	// OBSOLETE - see WeaponAttachment
var() bool bCanThrow;
var() bool bForceSwitch; // if true, this weapon will prevent any other weapon from delaying the switch to it (bomb launcher)
var() deprecated bool bNotInPriorityList; // Should be displayed in a GUI weapon list	-	refer to 'Description' documentation
var	  bool bNotInDemo;
var	  bool bNoVoluntarySwitch;
var	  bool bSpectated;
var	  bool bDebugging;
var	  bool bNoInstagibReplace;
var	  bool bInitOldMesh;
var config bool bUseOldWeaponMesh;
var   bool	bEndOfRound;	// don't allow firing
var bool bNoAmmoInstances;	// if true, replicated ammocount using the Weapons AmmoCharge property - true by default, included to allow mod authors to fallback to old style
var bool bBerserk;

// properties needed if no instantiated ammunition
var int AmmoCharge[2];
var class<Ammunition> AmmoClass[2];

var Mesh OldMesh;
var string OldPickup;
var(OldFirstPerson) float OldDrawScale, OldCenteredOffsetY;
var(OldFirstPerson) vector OldPlayerViewOffset, OldSmallViewOffset;
var(OldFirstPerson) rotator OldPlayerViewPivot;
var(OldFirstPerson) int	OldCenteredRoll, OldCenteredYaw;

/*
	A note about weapons & the caching system:
	You must now perform two commands on your mod's final package file:

	'ucc dumpint <PackageFileName.u>' - this exports the localized text to a localization file, which is used by the caching system to load the ItemName and Description
	'ucc exportcache <PackageName.u>' - this exports the information that will be used to load the weapon into the caching system.  Type 'ucc help exportcache' at the command-line for more info.

	Ex: (ACoolWeaponMod.u)

	ucc dumpint ACoolWeaponMod.u
	- creates 'ACoolWeaponMod.int' file, (file extension will vary if a different language is specified in the UT2004.ini file)

	ucc exportcache ACoolWeaponMod.u
	- creates an entry in the 'CacheRecords.ucl' file, containing caching information for your package

	Weapons must have values for both ItemName & Description in order to appear in the game.  The caching system will not recognize inherited values for these properties.
	If creating a custom crosshair for your weapon, it will FIXME
	-- rjp
*/
var() localized cache string Description;

var class<Weapon> DemoReplacement;
var transient bool bPendingSwitch;
var(FirstPerson) vector EffectOffset; // where muzzle flashes and smoke appear. replace by bone reference eventually
var() Localized string MessageNoAmmo;
var(FirstPerson) float DisplayFOV;
var() enum EWeaponClientState
{
    WS_None,
    WS_Hidden,
    WS_BringUp,
    WS_PutDown,
    WS_ReadyToFire
} ClientState; // this will always be None on the server

var() config byte ExchangeFireModes;
var() config byte Priority;

var() deprecated byte DefaultPriority;

var float Hand;
var float RenderedHand;
var Color HudColor;
var Weapon OldWeapon;
var(FirstPerson)	vector      SmallViewOffset;   // Offset from view center with small weapons option.
var(FirstPerson) vector SmallEffectOffset;
var(FirstPerson) float CenteredOffsetY;
var(FirstPerson) int CenteredRoll, CenteredYaw;
var config int CustomCrosshair;
var config color CustomCrossHairColor;
var config float CustomCrossHairScale;
var config string CustomCrossHairTextureName;
var texture CustomCrossHairTexture;

var float DownDelay, MinReloadPct;		// Used to delay putting down weapons which have jsut been fired

native final function InitWeaponFires();

simulated function float ChargeBar();

//=========================================================================
// Ammunition Interface (to remove the need for instantiated ammunition)

simulated function class<Ammunition> GetAmmoClass(int mode)
{
	return AmmoClass[mode];
}

simulated function MaxOutAmmo()
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = MaxAmmo(0);
		if ( (AmmoClass[1] != None) && (AmmoClass[0] != AmmoClass[1]) )
			AmmoCharge[1] = MaxAmmo(1);
		return;
	}
	if ( Ammo[0] != None )
		Ammo[0].AmmoAmount = Ammo[0].MaxAmmo;
	if ( Ammo[1] != None )
		Ammo[1].AmmoAmount = Ammo[1].MaxAmmo;
}

simulated function SuperMaxOutAmmo()
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = 999;
		if ( (AmmoClass[1] != None) && (AmmoClass[0] != AmmoClass[1]) )
			AmmoCharge[1] = 999;
		return;
	}
	if ( Ammo[0] != None )
		Ammo[0].AmmoAmount = 999;
	if ( Ammo[1] != None )
		Ammo[1].AmmoAmount = 999;
}
simulated function int MaxAmmo(int mode)
{
	if ( AmmoClass[mode] != None )
		return AmmoClass[mode].Default.MaxAmmo;

	return 0;
}

simulated function FillToInitialAmmo()
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = Max(AmmoCharge[0], AmmoClass[0].Default.InitialAmount);
		if ( (AmmoClass[1] != None) && (AmmoClass[0] != AmmoClass[1]) )
			AmmoCharge[1] = Max(AmmoCharge[1], AmmoClass[1].Default.InitialAmount);
		return;
	}

	if ( Ammo[0] != None )
		Ammo[0].AmmoAmount = Max(Ammo[0].AmmoAmount,Ammo[0].InitialAmount);
	if ( Ammo[1] != None )
		Ammo[1].AmmoAmount = Max(Ammo[1].AmmoAmount,Ammo[1].InitialAmount);
}

simulated function int AmmoAmount(int mode)
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] == AmmoClass[mode] )
			return AmmoCharge[0];
		return AmmoCharge[mode];
	}
	if ( Ammo[mode] != None )
		return Ammo[mode].AmmoAmount;

	return 0;
}

simulated function class<Pickup> AmmoPickupClass(int mode)
{
	if ( AmmoClass[mode] != None )
		return FireMode[mode].AmmoClass.Default.PickupClass;

	return None;
}

simulated function bool AmmoMaxed(int mode)
{
	if ( AmmoClass[mode] == None )
		return false;

	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] == AmmoClass[mode] )
			mode = 0;
		return AmmoCharge[mode] >= MaxAmmo(mode);
	}
	if ( Ammo[mode] == None )
		return false;
	return (Ammo[mode].AmmoAmount >= MaxAmmo(mode));
}

simulated function GetAmmoCount(out float MaxAmmoPrimary, out float CurAmmoPrimary)
{
	if ( AmmoClass[0] == None )
		return;

	if ( bNoAmmoInstances )
	{
		MaxAmmoPrimary = MaxAmmo(0);
		CurAmmoPrimary = AmmoCharge[0];
		return;
	}

	if ( Ammo[0] == None )
		return;
	MaxAmmoPrimary = Ammo[0].MaxAmmo;
	CurAmmoPrimary = Ammo[0].AmmoAmount;
}

simulated function float AmmoStatus(optional int Mode) // returns float value for ammo amount
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[Mode] == None )
			return 0;
		if ( AmmoClass[0] == AmmoClass[mode] )
			mode = 0;

		return float(AmmoCharge[Mode])/float(MaxAmmo(Mode));
	}
    if (Ammo[Mode] == None)
        return 0.0;
    else
	    return float(Ammo[Mode].AmmoAmount) / float(Ammo[Mode].MaxAmmo);
}

simulated function bool ConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
	local int AmountNeeded;

	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] == AmmoClass[mode] )
			mode = 0;
		AmountNeeded = int(load);
		if (bAmountNeededIsMax && AmmoCharge[mode] < AmountNeeded)
			AmountNeeded = AmmoCharge[mode];

		if (AmmoCharge[mode] < AmountNeeded)
		{
			CheckOutOfAmmo();
			return false;   // Can't do it
		}

		AmmoCharge[mode] -= AmountNeeded;
		NetUpdateTime = Level.TimeSeconds - 1;

		if (Level.NetMode == NM_StandAlone || Level.NetMode == NM_ListenServer)
			CheckOutOfAmmo();

		return true;
	}
    if (Ammo[Mode] != None)
        return Ammo[Mode].UseAmmo(int(load), bAmountNeededIsMax);

    return true;
}

function bool AddAmmo(int AmmoToAdd, int Mode)
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] == AmmoClass[mode] )
			mode = 0;
		if ( Level.GRI.WeaponBerserk > 1.0 )
			AmmoCharge[mode] = MaxAmmo(Mode);
		else if ( AmmoCharge[mode] < MaxAmmo(mode) )
			AmmoCharge[mode] = Min(MaxAmmo(mode), AmmoCharge[mode]+AmmoToAdd);
		NetUpdateTime = Level.TimeSeconds - 1;
		return true;
	}
    if (Ammo[Mode] != None)
		return Ammo[Mode].AddAmmo(AmmoToAdd);
}

simulated function bool HasAmmo()
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] == AmmoClass[1] )
			return ( (AmmoClass[0] != None && FireMode[0] != None && AmmoCharge[0] >= FireMode[0].AmmoPerFire) );

		return ( (AmmoClass[0] != None && FireMode[0] != None && AmmoCharge[0] >= FireMode[0].AmmoPerFire)
			|| (AmmoClass[1] != None && FireMode[1] != None && AmmoCharge[1] >= FireMode[1].AmmoPerFire) );
	}
    return ( (Ammo[0] != None && FireMode[0] != None && Ammo[0].AmmoAmount >= FireMode[0].AmmoPerFire)
          || (Ammo[1] != None && FireMode[1] != None && Ammo[1].AmmoAmount >= FireMode[1].AmmoPerFire) );
}

// for AI
simulated function bool NeedAmmo(int mode)
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] == AmmoClass[mode] )
			mode = 0;
		if ( AmmoClass[mode] == None )
			return false;

		return ( AmmoCharge[Mode] < AmmoClass[mode].default.InitialAmount );
	}
	if ( Ammo[mode] != None )
		 return (Ammo[mode].AmmoAmount < Ammo[mode].InitialAmount);

	return false;
}

simulated function float DesireAmmo(class<Inventory> NewAmmoClass, bool bDetour)
{
	local int i;
	local float curr, max;

	for ( i=0; i<2; i++ )
		if ( NewAmmoClass == AmmoClass[i] )
		{
			if ( AmmoMaxed(i) )
				return -100;
			curr = AmmoAmount(i);
			if ( curr == 0 )
				return 1;
			max = MaxAmmo(i);

			return ( FMin(0.5*(max-curr),AmmoClass[i].Default.AmmoAmount)/max );
		}
	return 0;
}

simulated function CheckOutOfAmmo()
{
	if (Instigator != None && Instigator.Weapon == self)
	{
		if ( bNoAmmoInstances )
		{
			if ( (AmmoCharge[0] <= 0) && (AmmoCharge[1] <= 0) )
				OutOfAmmo();
			return;
		}

		if ( Ammo[0] != None )
			Ammo[0].CheckOutOfAmmo();
		if ( Ammo[1] != None )
			Ammo[1].CheckOutOfAmmo();
	}
}

simulated function PostNetReceive()
{
    CheckOutOfAmmo();
}

//=========================================================================

simulated function DrawWeaponInfo(Canvas C);
simulated function NewDrawWeaponInfo(Canvas C, float YPos);

function StartDebugging()
{
}

simulated function ClientWriteStats(byte Mode, bool bMatch, bool bAllowFire, bool bDelay, bool bAlt, float wait)
{
	log(self$" Same weapon "$bMatch$" Mode "$Mode$" Allow fire "$bAllowFire$" delay start fire "$bDelay$" alt firing "$bAlt$" next fire wait "$wait);
}

function class<DamageType> GetDamageType();

function HackPlayFireSound()
{
	if ( (FireMode[0] != None) && (FireMode[0].FireSound != None) )
		PlaySound(FireMode[0].FireSound, SLOT_None, 1.0);
}

//=================================================================
// AI functions

function float RangedAttackTime()
{
	return 0;
}

function bool RecommendRangedAttack()
{
	return false;
}

function bool RecommendLongRangedAttack()
{
	return false;
}

function bool FocusOnLeader(bool bLeaderFiring)
{
	return false;
}

function FireHack(byte Mode);

// return true if weapon effect has splash damage (if significant)
// use by bot to avoid hurting self
// should be based on current firing Mode if active
function bool SplashDamage()
{
    return FireMode[BotMode].bSplashDamage;
}

// return true if weapon should be fired to take advantage of splash damage
// For example, rockets should be fired at enemy feet
function bool RecommendSplashDamage()
{
    return FireMode[BotMode].bRecommendSplashDamage;
}

function float GetDamageRadius()
{
    if (FireMode[BotMode].ProjectileClass == None)
        return 0;
    else
        return FireMode[BotMode].ProjectileClass.default.DamageRadius;
}

// Repeater weapons like minigun should be 0.99, other weapons based on likelihood
// of firing again right away
function float RefireRate()
{
    return FireMode[BotMode].BotRefireRate;
}

// tells AI that it needs to release the fire button for this weapon to do anything
function bool FireOnRelease()
{
	return FireMode[BotMode].bFireOnRelease;
}

simulated function Loaded();

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
    local int i;
    local string T;
    local name Anim;
    local float frame,rate;

    Canvas.SetDrawColor(0,255,0);
    if ( (Pawn(Owner) != None) && (Pawn(Owner).PlayerReplicationInfo != None) )
		Canvas.DrawText("WEAPON "$GetItemName(string(self))$" Owner "$Pawn(Owner).PlayerReplicationInfo.PlayerName);
    else
		Canvas.DrawText("WEAPON "$GetItemName(string(self))$" Owner "$Owner);
    YPos += YL;
    Canvas.SetPos(4,YPos);

    T = "     STATE: "$GetStateName()$" Timer: "$TimerCounter$" Client State ";

	Switch( ClientState )
	{
		case WS_None: T=T$"None"; break;
		case WS_Hidden: T=T$"Hidden"; break;
		case WS_BringUp: T=T$"BringUp"; break;
		case WS_PutDown: T=T$"PutDown"; break;
		case WS_ReadyToFire: T=T$"ReadyToFire"; break;
	}

    Canvas.DrawText(T, false);
    YPos += YL;
    Canvas.SetPos(4,YPos);

    if ( DrawType == DT_StaticMesh )
        Canvas.DrawText("     StaticMesh "$GetItemName(string(StaticMesh))$" AmbientSound "$AmbientSound, false);
    else
        Canvas.DrawText("     Mesh "$GetItemName(string(Mesh))$" AmbientSound "$AmbientSound, false);
    YPos += YL;
    Canvas.SetPos(4,YPos);
    if ( Mesh != None )
    {
        // mesh animation
        GetAnimParams(0,Anim,frame,rate);
        T = "     AnimSequence "$Anim$" Frame "$frame$" Rate "$rate;
        if ( bAnimByOwner )
            T= T$" Anim by Owner";

        Canvas.DrawText(T, false);
        YPos += YL;
        Canvas.SetPos(4,YPos);

		T = "Eyeheight "$Instigator.EyeHeight$" base "$Instigator.BaseEyeheight$" landbob "$Instigator.Landbob$" just landed "$Instigator.bJustLanded$" land recover "$Instigator.bLandRecovery;
        Canvas.DrawText(T, false);
        YPos += YL;
        Canvas.SetPos(4,YPos);
    }

    for ( i=0; i<NUM_FIRE_MODES; i++ )
    {
        if ( FireMode[i] == None )
        {
            Canvas.DrawText("NO FIREMODE "$i);
            YPos += YL;
            Canvas.SetPos(4,YPos);
        }
        else
            FireMode[i].DisplayDebug(Canvas,YL,YPos);

        Canvas.DrawText("Ammunition "$i$" amount "$AmmoAmount(i));
		YPos += YL;
		Canvas.SetPos(4,YPos);
    }
}

simulated function Weapon RecommendWeapon( out float rating )
{
    local Weapon Recommended;
    local float oldRating;

    if ( (Instigator == None) || (Instigator.Controller == None) )
        rating = -2;
    else
        rating = RateSelf() + Instigator.Controller.WeaponPreference(self);

    if ( inventory != None )
    {
        Recommended = inventory.RecommendWeapon(oldRating);
        if ( (Recommended != None) && (oldRating > rating) )
        {
            rating = oldRating;
            return Recommended;
        }
    }
    return self;
}

function SetAITarget(Actor T);

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	if ( Instigator.Controller.bFire != 0 )
		return 0;
	else if ( Instigator.Controller.bAltFire != 0 )
		return 1;
	if ( FRand() < 0.5 )
		return 1;
	return 0;
}

/* BotFire()
called by NPC firing weapon. Weapon chooses appropriate firing Mode to use (typically no change)
bFinished should only be true if called from the Finished() function
FiringMode can be passed in to specify a firing Mode (used by scripted sequences)
*/
function bool BotFire(bool bFinished, optional name FiringMode)
{
    local int newmode;
    local Controller C;

    C = Instigator.Controller;
	newMode = BestMode();

	if ( newMode == 0 )
	{
		C.bFire = 1;
		C.bAltFire = 0;
	}
	else
	{
		C.bFire = 0;
		C.bAltFire = 1;
	}

	if ( bFinished )
		return true;

    if ( FireMode[BotMode].IsFiring() )
    {
    	if (BotMode == newMode)
    		return true;
    	else
			StopFire(BotMode);
    }

    if ( !ReadyToFire(newMode) || ClientState != WS_ReadyToFire )
		return false;

    BotMode = NewMode;
    StartFire(NewMode);
    return true;
}

// this returns the actual projectile spawn location or trace start
simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
    return FireMode[BotMode].GetFireStart(X,Y,Z);
}

// need to figure out modified rating based on enemy/tactical situation
simulated function float RateSelf()
{
    if ( !HasAmmo() )
        CurrentRating = -2;
	else if ( Instigator.Controller == None )
		return 0;
	else
		CurrentRating = Instigator.Controller.RateWeapon(self);
	return CurrentRating;
}

function float GetAIRating()
{
	return AIRating;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()
{
    return 0.0;
}

// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()
{
    return 0.0;
}

// return true if recommend jumping while firing to improve splash damage (by shooting at feet)
// true for R.L., for example
function bool SplashJump()
{
    return FireMode[BotMode].bSplashJump;
}

// return false if out of range, can't see target, etc.
function bool CanAttack(Actor Other)
{
    local float Dist, CheckDist;
    local vector HitLocation, HitNormal,X,Y,Z, projStart;
    local actor HitActor;
    local int m;
	local bool bInstantHit;

    if ( (Instigator == None) || (Instigator.Controller == None) )
        return false;

    // check that target is within range
    Dist = VSize(Instigator.Location - Other.Location);
    if ( (Dist > FireMode[0].MaxRange()) && (Dist > FireMode[1].MaxRange()) )
        return false;

    // check that can see target
    if ( !Instigator.Controller.LineOfSightTo(Other) )
        return false;

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
		if ( FireMode[m].bInstantHit )
			bInstantHit = true;
		else
		{
			CheckDist = FMax(CheckDist, 0.5 * FireMode[m].ProjectileClass.Default.Speed);
	        CheckDist = FMax(CheckDist, 300);
	        CheckDist = FMin(CheckDist, VSize(Other.Location - Location));
		}
	}
    // check that would hit target, and not a friendly
    GetAxes(Instigator.Controller.Rotation, X,Y,Z);
    projStart = GetFireStart(X,Y,Z);
    if ( bInstantHit )
        HitActor = Trace(HitLocation, HitNormal, Other.Location + Other.CollisionHeight * vect(0,0,0.8), projStart, true);
    else
    {
        // for non-instant hit, only check partial path (since others may move out of the way)
        HitActor = Trace(HitLocation, HitNormal,
                projStart + CheckDist * Normal(Other.Location + Other.CollisionHeight * vect(0,0,0.8) - Location),
                projStart, true);
    }

    if ( (HitActor == None) || (HitActor == Other) )
		return true;
	if ( Pawn(HitActor) == None )
		return !HitActor.BlocksShotAt(Other); 
	if ( (Pawn(HitActor).Controller == None) || !Instigator.Controller.SameTeamAs(Pawn(HitActor).Controller) )
        return true;

    return false;
}


//=================================================================

simulated function PostBeginPlay()
{
    local int m;
    Super.PostBeginPlay();
    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireModeClass[m] != None)
        {
            FireMode[m] = new(self) FireModeClass[m];
            if ( FireMode[m] != None )
				AmmoClass[m] = FireMode[m].AmmoClass;
        }
     }
     InitWeaponFires();

     for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireMode[m] != None)
        {
            FireMode[m].ThisModeNum = m;
            FireMode[m].Weapon = self;
            FireMode[m].Instigator = Instigator;
            FireMode[m].Level = Level;
            FireMode[m].Owner = self;
			FireMode[m].PreBeginPlay();
			FireMode[m].BeginPlay();
			FireMode[m].PostBeginPlay();
			FireMode[m].SetInitialState();
			FireMode[m].PostNetBeginPlay();
		}
    }

	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) )
		MaxLights = Min(4,MaxLights);

	if ( SmallViewOffset == vect(0,0,0) )
		SmallViewOffset = Default.PlayerviewOffset;

	if ( SmallEffectOffset == vect(0,0,0) )
		SmallEffectOffset = EffectOffset + Default.PlayerViewOffset - SmallViewOffset;

	if ( bUseOldWeaponMesh && (OldMesh != None) )
	{
		bInitOldMesh = true;
		LinkMesh(OldMesh);
	}
	if ( Level.GRI != None )
		CheckSuperBerserk();
}

simulated function SetGRI(GameReplicationInfo G)
{
	CheckSuperBerserk();
}

simulated function Destroyed()
{
    local int m;

    AmbientSound = None;

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
		if ( FireMode[m] != None )
			FireMode[m].DestroyEffects();
        if (Ammo[m] != None)
        {
            Ammo[m].Destroy();
            Ammo[m] = None;
        }
    }
    Super.Destroyed();
}

simulated function Reselect()
{
}

simulated function bool WeaponCentered()
{
	return ( bSpectated || (Hand > 1) );
}

simulated event RenderOverlays( Canvas Canvas )
{
    local int m;
	local vector NewScale3D;
	local rotator CenteredRotation;
	local name AnimSeq;
	local float frame,rate;

    if (Instigator == None)
        return;

	if ( Instigator.Controller != None )
		Hand = Instigator.Controller.Handedness;

    if ((Hand < -1.0) || (Hand > 1.0))
        return;

    // draw muzzleflashes/smoke for all fire modes so idle state won't
    // cause emitters to just disappear
    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireMode[m] != None)
        {
            FireMode[m].DrawMuzzleFlash(Canvas);
        }
    }

	if ( (OldMesh != None) && (bUseOldWeaponMesh != (OldMesh == Mesh)) )
	{
		GetAnimParams(0,AnimSeq,frame,rate);
		bInitOldMesh = true;
		if ( bUseOldWeaponMesh )
			LinkMesh(OldMesh);
		else
			LinkMesh(Default.Mesh);
		PlayAnim(AnimSeq,rate,0.0);
	}

    if ( (Hand != RenderedHand) || bInitOldMesh )
    {
		newScale3D = Default.DrawScale3D;
		if ( Hand != 0 )
			newScale3D.Y *= Hand;
		SetDrawScale3D(newScale3D);
		SetDrawScale(Default.DrawScale);
		CenteredRoll = Default.CenteredRoll;
		CenteredYaw = Default.CenteredYaw;
		CenteredOffsetY = Default.CenteredOffsetY;
		PlayerViewPivot = Default.PlayerViewPivot;
		SmallViewOffset = Default.SmallViewOffset;
		if ( SmallViewOffset == vect(0,0,0) )
			SmallViewOffset = Default.PlayerviewOffset;
		bInitOldMesh = false;
		if ( Default.SmallEffectOffset == vect(0,0,0) )
			SmallEffectOffset = EffectOffset + Default.PlayerViewOffset - SmallViewOffset;
		else
			SmallEffectOffset = Default.SmallEffectOffset;
		if ( Mesh == OldMesh )
		{
			SmallEffectOffset = EffectOffset + OldPlayerViewOffset - OldSmallViewOffset;
			PlayerViewPivot = OldPlayerViewPivot;
			SmallViewOffset = OldSmallViewOffset;
			if ( Hand != 0 )
			{
				PlayerViewPivot.Roll *= Hand;
				PlayerViewPivot.Yaw *= Hand;
			}
			CenteredRoll = OldCenteredRoll;
			CenteredYaw = OldCenteredYaw;
			CenteredOffsetY = OldCenteredOffsetY;
			SetDrawScale(OldDrawScale);
		}
		else if ( Hand == 0 )
		{
			PlayerViewPivot.Roll = Default.PlayerViewPivot.Roll;
			PlayerViewPivot.Yaw = Default.PlayerViewPivot.Yaw;
		}
		else
		{
			PlayerViewPivot.Roll = Default.PlayerViewPivot.Roll * Hand;
			PlayerViewPivot.Yaw = Default.PlayerViewPivot.Yaw * Hand;
		}
		RenderedHand = Hand;
	}
	if ( class'PlayerController'.Default.bSmallWeapons )
		PlayerViewOffset = SmallViewOffset;
	else if ( Mesh == OldMesh )
		PlayerViewOffset = OldPlayerViewOffset;
	else
		PlayerViewOffset = Default.PlayerViewOffset;
	if ( Hand == 0 )
		PlayerViewOffset.Y = CenteredOffsetY;
	else
		PlayerViewOffset.Y *= Hand;

    SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
    if ( Hand == 0 )
    {
		CenteredRotation = Instigator.GetViewRotation();
		CenteredRotation.Yaw += CenteredYaw;
		CenteredRotation.Roll = CenteredRoll;
	    SetRotation(CenteredRotation);
    }
    else
	    SetRotation( Instigator.GetViewRotation() );

	PreDrawFPWeapon();	// Laurent -- Hook to override things before render (like rotation if using a staticmesh)

    bDrawingFirstPerson = true;
    Canvas.DrawActor(self, false, false, DisplayFOV);
    bDrawingFirstPerson = false;
	if ( Hand == 0 )
		PlayerViewOffset.Y = 0;
}

simulated function PreDrawFPWeapon();

simulated function SetHand(float InHand)
{
    Hand = InHand;
}

simulated function GetViewAxes( out vector xaxis, out vector yaxis, out vector zaxis )
{
    if ( Instigator.Controller == None )
        GetAxes( Instigator.Rotation, xaxis, yaxis, zaxis );
    else
        GetAxes( Instigator.Controller.Rotation, xaxis, yaxis, zaxis );
}

simulated function vector CenteredEffectStart()
{
	return Instigator.Location;
}

simulated function vector GetEffectStart()
{
    local Vector X,Y,Z;

    // jjs - this function should actually never be called in third person views
    // any effect that needs a 3rdp weapon offset should figure it out itself

    // 1st person
    if (Instigator.IsFirstPerson())
    {
        if ( WeaponCentered() )
			return CenteredEffectStart();

        GetViewAxes(X, Y, Z);
        if ( class'PlayerController'.Default.bSmallWeapons )
			return (Instigator.Location +
				Instigator.CalcDrawOffset(self) +
				SmallEffectOffset.X * X  +
				SmallEffectOffset.Y * Y * Hand +
				SmallEffectOffset.Z * Z);
        else
			return (Instigator.Location +
				Instigator.CalcDrawOffset(self) +
				EffectOffset.X * X +
				EffectOffset.Y * Y * Hand +
				EffectOffset.Z * Z);
    }
    // 3rd person
    else
    {
        return (Instigator.Location +
            Instigator.EyeHeight*Vect(0,0,0.5) +
            Vector(Instigator.Rotation) * 40.0);
    }
}

simulated function IncrementFlashCount(int Mode)
{
    if ( WeaponAttachment(ThirdPersonActor) != None )
    {
        if (Mode == 0)
            WeaponAttachment(ThirdPersonActor).FiringMode = 0;
        else
            WeaponAttachment(ThirdPersonActor).FiringMode = 1;
        ThirdPersonActor.NetUpdateTime = Level.TimeSeconds - 1;
        WeaponAttachment(ThirdPersonActor).FlashCount++;
        WeaponAttachment(ThirdPersonActor).ThirdPersonEffects();
    }
}

simulated function ZeroFlashCount(int Mode)
{
    if ( WeaponAttachment(ThirdPersonActor) != None )
    {
        if (Mode == 0)
            WeaponAttachment(ThirdPersonActor).FiringMode = 0;
        else
            WeaponAttachment(ThirdPersonActor).FiringMode = 1;
        ThirdPersonActor.NetUpdateTime = Level.TimeSeconds - 1;
        WeaponAttachment(ThirdPersonActor).FlashCount = 0;
        WeaponAttachment(ThirdPersonActor).ThirdPersonEffects();
    }
}

simulated function Weapon WeaponChange( byte F, bool bSilent )
{
    local Weapon newWeapon;

    if ( InventoryGroup == F )
    {
        if ( !HasAmmo() )
        {
            if ( Inventory == None )
                newWeapon = None;
            else
                newWeapon = Inventory.WeaponChange(F,bSilent);

            if ( !bSilent && (newWeapon == None) && Instigator.IsHumanControlled() )
                Instigator.ClientMessage( ItemName$MessageNoAmmo );

            return newWeapon;
        }
        else
            return self;
    }
    else if ( Inventory == None )
        return None;
    else
        return Inventory.WeaponChange(F,bSilent);
}

simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if ( HasAmmo() )
    {
        if ( (CurrentChoice == None) )
        {
            if ( CurrentWeapon != self )
                CurrentChoice = self;
        }
        else if ( InventoryGroup == CurrentWeapon.InventoryGroup )
        {
            if ( (GroupOffset < CurrentWeapon.GroupOffset)
                && ((CurrentChoice.InventoryGroup != InventoryGroup) || (GroupOffset > CurrentChoice.GroupOffset)) )
                CurrentChoice = self;
		}
        else if ( InventoryGroup == CurrentChoice.InventoryGroup )
        {
            if ( GroupOffset > CurrentChoice.GroupOffset )
                CurrentChoice = self;
        }
        else if ( InventoryGroup > CurrentChoice.InventoryGroup )
        {
			if ( (InventoryGroup < CurrentWeapon.InventoryGroup)
                || (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup) )
                CurrentChoice = self;
        }
        else if ( (CurrentChoice.InventoryGroup > CurrentWeapon.InventoryGroup)
                && (InventoryGroup < CurrentWeapon.InventoryGroup) )
            CurrentChoice = self;
    }
    if ( Inventory == None )
        return CurrentChoice;
    else
        return Inventory.PrevWeapon(CurrentChoice,CurrentWeapon);
}

simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if ( HasAmmo() )
    {
        if ( (CurrentChoice == None) )
        {
            if ( CurrentWeapon != self )
                CurrentChoice = self;
        }
        else if ( InventoryGroup == CurrentWeapon.InventoryGroup )
        {
            if ( (GroupOffset > CurrentWeapon.GroupOffset)
                && ((CurrentChoice.InventoryGroup != InventoryGroup) || (GroupOffset < CurrentChoice.GroupOffset)) )
                CurrentChoice = self;
        }
        else if ( InventoryGroup == CurrentChoice.InventoryGroup )
        {
			if ( GroupOffset < CurrentChoice.GroupOffset )
                CurrentChoice = self;
        }

        else if ( InventoryGroup < CurrentChoice.InventoryGroup )
        {
            if ( (InventoryGroup > CurrentWeapon.InventoryGroup)
                || (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup) )
                CurrentChoice = self;
        }
        else if ( (CurrentChoice.InventoryGroup < CurrentWeapon.InventoryGroup)
                && (InventoryGroup > CurrentWeapon.InventoryGroup) )
            CurrentChoice = self;
    }
    if ( Inventory == None )
        return CurrentChoice;
    else
        return Inventory.NextWeapon(CurrentChoice,CurrentWeapon);
}


function HolderDied()
{
    local int m;

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireMode[m].bIsFiring)
        {
            StopFire(m);
            if (FireMode[m].bFireOnRelease)
                FireMode[m].ModeDoFire();
        }
    }
}

simulated function bool CanThrow()
{
	local int Mode;

    for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
    {
        if ( FireMode[Mode].bFireOnRelease && FireMode[Mode].bIsFiring )
            return false;
        if ( FireMode[Mode].NextFireTime > Level.TimeSeconds)
			return false;
    }
    return (bCanThrow && (ClientState == WS_ReadyToFire || (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer))
			&& HasAmmo() );
}

function DropFrom(vector StartLocation)
{
    local int m;
	local Pickup Pickup;

    if (!bCanThrow || !HasAmmo())
        return;

    ClientWeaponThrown();

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (FireMode[m].bIsFiring)
            StopFire(m);
    }

	if ( Instigator != None )
	{
		DetachFromPawn(Instigator);
	}

	Pickup = Spawn(PickupClass,,, StartLocation);
	if ( Pickup != None )
	{
    	Pickup.InitDroppedPickupFor(self);
	    Pickup.Velocity = Velocity;
        if (Instigator.Health > 0)
            WeaponPickup(Pickup).bThrown = true;
    }

    Destroy();
}

simulated function DetachFromPawn(Pawn P)
{
	Super.DetachFromPawn(P);
	P.AmbientSound = None;
}

simulated function ClientWeaponThrown()
{
    local int m;

    AmbientSound = None;
    Instigator.AmbientSound = None;

    if( Level.NetMode != NM_Client )
        return;

    Instigator.DeleteInventory(self);
    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if (Ammo[m] != None)
            Instigator.DeleteInventory(Ammo[m]);
    }
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
    local int m;
    local weapon w;
    local bool bPossiblySwitch, bJustSpawned;

    Instigator = Other;
    W = Weapon(Instigator.FindInventoryType(class));
    if ( W == None || W.Class != Class ) // added class check because somebody made FindInventoryType() return subclasses for some reason
    {
		bJustSpawned = true;
        Super.GiveTo(Other);
        bPossiblySwitch = true;
        W = self;
    }
    else if ( !W.HasAmmo() )
	    bPossiblySwitch = true;

    if ( Pickup == None )
        bPossiblySwitch = true;

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if ( FireMode[m] != None )
        {
            FireMode[m].Instigator = Instigator;
            W.GiveAmmo(m,WeaponPickup(Pickup),bJustSpawned);
        }
    }

	if ( Instigator.Weapon != W )
		W.ClientWeaponSet(bPossiblySwitch);

    if ( !bJustSpawned )
	{
        for (m = 0; m < NUM_FIRE_MODES; m++)
            Ammo[m] = None;
		Destroy();
	}
}

function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned)
{
    local bool bJustSpawnedAmmo;
    local int addAmount, InitialAmount;

    if ( FireMode[m] != None && FireMode[m].AmmoClass != None )
    {
        Ammo[m] = Ammunition(Instigator.FindInventoryType(FireMode[m].AmmoClass));
		bJustSpawnedAmmo = false;

		if ( bNoAmmoInstances )
		{
			if ( (FireMode[m].AmmoClass == None) || ((m != 0) && (FireMode[m].AmmoClass == FireMode[0].AmmoClass)) )
				return;

			InitialAmount = FireMode[m].AmmoClass.Default.InitialAmount;
			if ( (WP != None) && ((WP.AmmoAmount[0] > 0) || (WP.AmmoAmount[1] > 0))  )
			{
				InitialAmount = WP.AmmoAmount[m];
			}

			if ( Ammo[m] != None )
			{
				addamount = InitialAmount + Ammo[m].AmmoAmount;
				Ammo[m].Destroy();
			}
			else
				addAmount = InitialAmount;

			AddAmmo(addAmount,m);
		}
		else
		{
			if ( (Ammo[m] == None) && (FireMode[m].AmmoClass != None) )
			{
				Ammo[m] = Spawn(FireMode[m].AmmoClass, Instigator);
				Instigator.AddInventory(Ammo[m]);
				bJustSpawnedAmmo = true;
			}
			else if ( (m == 0) || (FireMode[m].AmmoClass != FireMode[0].AmmoClass) )
				bJustSpawnedAmmo = ( bJustSpawned || ((WP != None) && !WP.bWeaponStay) );

			if ( (WP != None) && ((WP.AmmoAmount[0] > 0) || (WP.AmmoAmount[1] > 0))  )
			{
				addAmount = WP.AmmoAmount[m];
			}
			else if ( bJustSpawnedAmmo )
			{
				addAmount = Ammo[m].InitialAmount;
			}

			Ammo[m].AddAmmo(addAmount);
			Ammo[m].GotoState('');
		}
    }
}

simulated function ClientWeaponSet(bool bPossiblySwitch)
{
    local int Mode;

    Instigator = Pawn(Owner);

    bPendingSwitch = bPossiblySwitch;

    if( Instigator == None )
    {
        GotoState('PendingClientWeaponSet');
        return;
    }

    for( Mode = 0; Mode < NUM_FIRE_MODES; Mode++ )
    {
        if( FireModeClass[Mode] != None )
        {
			// laurent -- added check for vehicles (ammo not replicated but unlimited)
            if( ( FireMode[Mode] == None ) || ( FireMode[Mode].AmmoClass != None ) && !bNoAmmoInstances && Ammo[Mode] == None && FireMode[Mode].AmmoPerFire > 0 )
            {
                GotoState('PendingClientWeaponSet');
                return;
            }
        }

        FireMode[Mode].Instigator = Instigator;
        FireMode[Mode].Level = Level;
    }

    ClientState = WS_Hidden;
    GotoState('Hidden');

    if( Level.NetMode == NM_DedicatedServer || !Instigator.IsHumanControlled() )
        return;

    if( Instigator.Weapon == self || Instigator.PendingWeapon == self ) // this weapon was switched to while waiting for replication, switch to it now
    {
		if (Instigator.PendingWeapon != None)
            Instigator.ChangedWeapon();
        else
            BringUp();
        return;
    }

    if( Instigator.PendingWeapon != None && Instigator.PendingWeapon.bForceSwitch )
        return;

    if( Instigator.Weapon == None )
    {
        Instigator.PendingWeapon = self;
        Instigator.ChangedWeapon();
    }
    else if ( bPossiblySwitch && !Instigator.Weapon.IsFiring() )
    {
		if ( PlayerController(Instigator.Controller) != None && PlayerController(Instigator.Controller).bNeverSwitchOnPickup )
			return;
        if ( Instigator.PendingWeapon != None )
        {
            if ( RateSelf() > Instigator.PendingWeapon.RateSelf() )
            {
                Instigator.PendingWeapon = self;
                Instigator.Weapon.PutDown();
            }
        }
        else if ( RateSelf() > Instigator.Weapon.RateSelf() )
        {
            Instigator.PendingWeapon = self;
            Instigator.Weapon.PutDown();
        }
    }
}

// jdf ---
simulated function ClientPlayForceFeedback( String EffectName )
{
    local PlayerController PC;

    PC = PlayerController(Instigator.Controller);
    if ( PC != None && PC.bEnableWeaponForceFeedback )
    {
        PC.ClientPlayForceFeedback( EffectName );
    }
}

simulated function StopForceFeedback( String EffectName )
{
    local PlayerController PC;

    PC = PlayerController(Instigator.Controller);
    if ( PC != None && PC.bEnableWeaponForceFeedback )
    {
        PC.StopForceFeedback( EffectName );
    }
}
// --- jdf

simulated function BringUp(optional Weapon PrevWeapon)
{
   local int Mode;

    if ( ClientState == WS_Hidden )
    {
        PlayOwnedSound(SelectSound, SLOT_Interact,,,,, false);
		ClientPlayForceFeedback(SelectForce);  // jdf

        if ( Instigator.IsLocallyControlled() )
        {
            if ( (Mesh!=None) && HasAnim(SelectAnim) )
                PlayAnim(SelectAnim, SelectAnimRate, 0.0);
        }

        ClientState = WS_BringUp;
        SetTimer(BringUpTime, false);
    }
    for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
	{
		FireMode[Mode].bIsFiring = false;
		FireMode[Mode].HoldTime = 0.0;
		FireMode[Mode].bServerDelayStartFire = false;
		FireMode[Mode].bServerDelayStopFire = false;
		FireMode[Mode].bInstantStop = false;
	}
	   if ( (PrevWeapon != None) && PrevWeapon.HasAmmo() && !PrevWeapon.bNoVoluntarySwitch )
		OldWeapon = PrevWeapon;
	else
		OldWeapon = None;

}

simulated function bool PutDown()
{
    local int Mode;

    if (ClientState == WS_BringUp || ClientState == WS_ReadyToFire)
    {
        if ( (Instigator.PendingWeapon != None) && !Instigator.PendingWeapon.bForceSwitch )
        {
            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
            {
                if ( FireMode[Mode].bFireOnRelease && FireMode[Mode].bIsFiring )
                    return false;
                if ( FireMode[Mode].NextFireTime > Level.TimeSeconds + FireMode[Mode].FireRate*(1.f - MinReloadPct))
					DownDelay = FMax(DownDelay, FireMode[Mode].NextFireTime - Level.TimeSeconds - FireMode[Mode].FireRate*(1.f - MinReloadPct));
            }
        }

        if (Instigator.IsLocallyControlled())
        {
            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
            {
                if ( FireMode[Mode].bIsFiring )
                    ClientStopFire(Mode);
            }

            if (  DownDelay <= 0 )
            {
				if ( ClientState == WS_BringUp )
					TweenAnim(SelectAnim,PutDownTime);
				else if ( HasAnim(PutDownAnim) )
					PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
			}
        }
        ClientState = WS_PutDown;
        if ( Level.GRI.bFastWeaponSwitching )
			DownDelay = 0;
        if ( DownDelay > 0 )
			SetTimer(DownDelay, false);
		else
			SetTimer(PutDownTime, false);
    }
    for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
    {
		FireMode[Mode].bServerDelayStartFire = false;
		FireMode[Mode].bServerDelayStopFire = false;
	}
    Instigator.AmbientSound = None;
    OldWeapon = None;
    return true; // return false if preventing weapon switch
}

simulated function Fire(float F)
{
}

simulated function AltFire(float F)
{
}

simulated event WeaponTick(float dt); // only called on currently held weapon

simulated function OutOfAmmo()
{
    if ( Instigator == None || !Instigator.IsLocallyControlled() || HasAmmo() )
        return;

    DoAutoSwitch();
}

simulated function DoAutoSwitch()
{
    Instigator.Controller.SwitchToBestWeapon();
}

//// client only ////
simulated event ClientStartFire(int Mode)
{
    if ( Pawn(Owner).Controller.IsInState('GameEnded') || Pawn(Owner).Controller.IsInState('RoundEnded') )
        return;
    if (Role < ROLE_Authority)
    {
        if (StartFire(Mode))
        {
            ServerStartFire(Mode);
        }
    }
    else
    {
        StartFire(Mode);
    }
}

simulated event ClientStopFire(int Mode)
{
    if (Role < ROLE_Authority)
    {
        //Log("ClientStopFire"@Level.TimeSeconds);
        StopFire(Mode);
    }
    ServerStopFire(Mode);
}

simulated function ClientWriteFire(string Result)
{
	log(self$" ServerStartFire! "$Result);
}

//// server only ////
event ServerStartFire(byte Mode)
{
	if ( (Instigator != None) && (Instigator.Weapon != self) )
	{
		if ( Instigator.Weapon == None )
			Instigator.ServerChangedWeapon(None,self);
		else
			Instigator.Weapon.SynchronizeWeapon(self);
		return;
	}

    if ( (FireMode[Mode].NextFireTime <= Level.TimeSeconds + FireMode[Mode].PreFireTime)
		&& StartFire(Mode) )
    {
        FireMode[Mode].ServerStartFireTime = Level.TimeSeconds;
        FireMode[Mode].bServerDelayStartFire = false;
    }
    else if ( FireMode[Mode].AllowFire() )
    {
        FireMode[Mode].bServerDelayStartFire = true;
	}
	else
		ClientForceAmmoUpdate(Mode, AmmoAmount(Mode));
}

simulated function ClientForceAmmoUpdate(int Mode, int NewAmount)
{
	log(self$" ClientForceAmmoUpdate mode "$Mode$" newamount "$NewAmount);
	if ( bNoAmmoInstances )
		AmmoCharge[Mode] = NewAmount;
	else if ( Ammo[mode] != None )
		Ammo[mode].AmmoAmount = NewAmount;
}

function SynchronizeWeapon(Weapon ClientWeapon)
{
	Instigator.ServerChangedWeapon(self,ClientWeapon);
}

function ServerStopFire(byte Mode)
{
    // if a stop was received on the same frame as a start then we need to delay the stop for one frame
    if (FireMode[Mode].bServerDelayStartFire || FireMode[Mode].ServerStartFireTime == Level.TimeSeconds)
    {
        //log("Stop Delayed");
        FireMode[Mode].bServerDelayStopFire = true;
    }
    else
    {
        //Log("ServerStopFire"@Level.TimeSeconds);
        StopFire(Mode);
    }
}

simulated function bool ReadyToFire(int Mode)
{
    local int alt;

    if ( Mode == 0 )
        alt = 1;
    else
        alt = 0;

    if ( ((FireMode[alt] != FireMode[Mode]) && FireMode[alt].bModeExclusive && FireMode[alt].bIsFiring)
		|| !FireMode[Mode].AllowFire()
		|| (FireMode[Mode].NextFireTime > Level.TimeSeconds + FireMode[Mode].PreFireTime) )
    {
        return false;
    }

	return true;
}

//// client & server ////
simulated function bool StartFire(int Mode)
{
    local int alt;

    if (!ReadyToFire(Mode))
        return false;

    if (Mode == 0)
        alt = 1;
    else
        alt = 0;

    FireMode[Mode].bIsFiring = true;
    FireMode[Mode].NextFireTime = Level.TimeSeconds + FireMode[Mode].PreFireTime;

    if (FireMode[alt].bModeExclusive)
    {
        // prevents rapidly alternating fire modes
        FireMode[Mode].NextFireTime = FMax(FireMode[Mode].NextFireTime, FireMode[alt].NextFireTime);
    }

    if (Instigator.IsLocallyControlled())
    {
        if (FireMode[Mode].PreFireTime > 0.0 || FireMode[Mode].bFireOnRelease)
        {
            FireMode[Mode].PlayPreFire();
        }
        FireMode[Mode].FireCount = 0;
    }

    return true;
}

simulated event StopFire(int Mode)
{
	if ( FireMode[Mode].bIsFiring )
	    FireMode[Mode].bInstantStop = true;
    if (Instigator.IsLocallyControlled() && !FireMode[Mode].bFireOnRelease)
        FireMode[Mode].PlayFireEnd();

    FireMode[Mode].bIsFiring = false;
    FireMode[Mode].StopFiring();
    if (!FireMode[Mode].bFireOnRelease)
        ZeroFlashCount(Mode);
}

//hack to stop all firing and release any charging firemodes RIGHT THIS INSTANT
//used when getting into vehicles
simulated function ImmediateStopFire()
{
	local int i;

	for (i = 0; i < NUM_FIRE_MODES; i++)
	{
		ClientStopFire(i);
		if (FireMode[i].bFireOnRelease)
		{
        		if (Level.TimeSeconds > FireMode[i].NextFireTime && (FireMode[i].bInstantStop || !FireMode[i].bNowWaiting))
				FireMode[i].ModeDoFire();
			if (FireMode[i].bWaitForRelease)
				FireMode[i].bNowWaiting = true;
		}
	}
}

simulated function Timer()
{
	local int Mode;
	local float OldDownDelay;

	OldDownDelay = DownDelay;
	DownDelay = 0;

    if (ClientState == WS_BringUp)
    {
		for( Mode = 0; Mode < NUM_FIRE_MODES; Mode++ )
	       FireMode[Mode].InitEffects();
        PlayIdle();
        ClientState = WS_ReadyToFire;
    }
    else if (ClientState == WS_PutDown)
    {
        if ( OldDownDelay > 0 )
        {
            if ( HasAnim(PutDownAnim) )
                PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
			SetTimer(PutDownTime, false);
			return;
		}
		if ( Instigator.PendingWeapon == None )
		{
			PlayIdle();
			ClientState = WS_ReadyToFire;
		}
		else
		{
			ClientState = WS_Hidden;
			Instigator.ChangedWeapon();
			if ( Instigator.Weapon == self )
			{
				PlayIdle();
				ClientState = WS_ReadyToFire;
			}
			else
			{
				for( Mode = 0; Mode < NUM_FIRE_MODES; Mode++ )
					FireMode[Mode].DestroyEffects();
			}
		}
    }
}


simulated function bool IsFiring() // called by pawn animation, mostly
{
    if (Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer)
        return (FireMode[0].IsFiring() || FireMode[1].IsFiring());

    return  ( ClientState == WS_ReadyToFire && (FireMode[0].IsFiring() || FireMode[1].IsFiring()) );
}

function bool IsRapidFire() // called by pawn animation
{
    if (FireMode[1] != None && FireMode[1].bIsFiring)
        return FireMode[1].bPawnRapidFireAnim;
    else if (FireMode[0] != None)
        return FireMode[0].bPawnRapidFireAnim;
    else
        return false;
}

// called every time owner takes damage while holding this weapon - used by shield gun
function AdjustPlayerDamage( out int Damage, Pawn InstigatedBy, Vector HitLocation,
                             out Vector Momentum, class<DamageType> DamageType)
{
}


simulated function CheckSuperBerserk()
{
	if ( Level.GRI.WeaponBerserk > 1.0 )
	{
		if (FireMode[0] != None)
			FireMode[0].StartSuperBerserk();
		if (FireMode[1] != None)
			FireMode[1].StartSuperBerserk();
	}
}
simulated function StartBerserk()
{
	if ( (Level.GRI != None) && Level.GRI.WeaponBerserk > 1.0 )
		return;
	bBerserk = true;
    if (FireMode[0] != None)
        FireMode[0].StartBerserk();
    if (FireMode[1] != None)
        FireMode[1].StartBerserk();
}

simulated function StopBerserk()
{
	bBerserk = false;
	if ( (Level.GRI != None) && Level.GRI.WeaponBerserk > 1.0 )
		return;
    if (FireMode[0] != None)
        FireMode[0].StopBerserk();
    if (FireMode[1] != None)
        FireMode[1].StopBerserk();
}

simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

    if (ClientState == WS_ReadyToFire)
    {
        if (anim == FireMode[0].FireAnim && HasAnim(FireMode[0].FireEndAnim)) // rocket hack
        {
            PlayAnim(FireMode[0].FireEndAnim, FireMode[0].FireEndAnimRate, 0.0);
        }
        else if (anim== FireMode[1].FireAnim && HasAnim(FireMode[1].FireEndAnim))
        {
            PlayAnim(FireMode[1].FireEndAnim, FireMode[1].FireEndAnimRate, 0.0);
        }
        else if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
        {
            PlayIdle();
        }
    }
}

simulated function PlayIdle()
{
    LoopAnim(IdleAnim, IdleAnimRate, 0.2);
}

state PendingClientWeaponSet
{
    simulated function Timer()
    {
        if ( Pawn(Owner) != None )
            ClientWeaponSet(bPendingSwitch);
        if ( IsInState('PendingClientWeaponSet') )
			SetTimer(0.05, false);
    }

    simulated function BeginState()
    {
        SetTimer(0.05, false);
    }

    simulated function EndState()
    {
    }
}

state Hidden
{
}

function bool CheckReflect( Vector HitLocation, out Vector RefNormal, int AmmoDrain )
{
    return false;
}

function DoReflectEffect(int Drain)
{

}

function bool HandlePickupQuery( pickup Item )
{
    local WeaponPickup wpu;
	local int i;

	if ( bNoAmmoInstances )
	{
		// handle ammo pickups
		for ( i=0; i<2; i++ )
		{
			if ( (item.inventorytype == AmmoClass[i]) && (AmmoClass[i] != None) )
			{
				if ( AmmoCharge[i] >= MaxAmmo(i) )
					return true;
				item.AnnouncePickup(Pawn(Owner));
				AddAmmo(Ammo(item).AmmoAmount, i);
				item.SetRespawn();
				return true;
			}
		}
	}

	if (class == Item.InventoryType)
    {
        wpu = WeaponPickup(Item);
        if (wpu != None)
            return !wpu.AllowRepeatPickup();
        else
            return false;
    }

    if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

simulated function bool WantsZoomFade()
{
	return false;
}

/* CanHeal()
used by bot AI
should return true if this weapon is able to heal Other
*/
function bool CanHeal(Actor Other)
{
	return false;
}

//called by AI when camping/defending
//return true if it is useful to fire this weapon even though bot doesn't have a target
//for example, a weapon that launches turrets or mines
function bool ShouldFireWithoutTarget()
{
	return false;
}

// ugly hack for tutorial
function bool ShootHoop(Controller B, Vector ShootLoc)
{
	return false;
}

simulated function PawnUnpossessed();


// FIXME - hack to get classes building again after fixing the bug that was allowing all protected variables to
// be referenced in other classes - maybe there's already an accessor that does this and I just don't know about it
// ...in that case, just remove this function -- rjp
simulated function WeaponFire GetFireMode( byte Mode )
{
	if ( Mode < NUM_FIRE_MODES )
		return FireMode[Mode];

	return None;
}

defaultproperties
{
     IdleAnim="Idle"
     RestAnim="rest"
     AimAnim="Aim"
     RunAnim="Run"
     SelectAnim="Select"
     PutDownAnim="Down"
     IdleAnimRate=1.000000
     RestAnimRate=1.000000
     AimAnimRate=1.000000
     RunAnimRate=1.000000
     SelectAnimRate=1.363600
     PutDownAnimRate=1.363600
     PutDownTime=0.330000
     BringUpTime=0.330000
     AIRating=0.500000
     CurrentRating=0.500000
     bCanThrow=True
     bNoAmmoInstances=True
     OldDrawScale=1.000000
     OldCenteredOffsetY=-10.000000
     OldCenteredRoll=2000
     MessageNoAmmo=" has no ammo"
     DisplayFOV=90.000000
     HudColor=(G=255,R=255,A=255)
     CenteredOffsetY=-10.000000
     CenteredRoll=2000
     CustomCrossHairColor=(B=255,G=255,R=255,A=255)
     CustomCrossHairScale=1.000000
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Cross1"
     MinReloadPct=0.500000
     InventoryGroup=1
     AttachmentClass=Class'Engine.WeaponAttachment'
     DrawType=DT_Mesh
     NetUpdateFrequency=2.000000
     NetPriority=3.000000
     AmbientGlow=20
     MaxLights=6
     ScaleGlow=1.500000
     SoundVolume=255
     bNetNotify=True
}

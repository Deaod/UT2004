//=============================================================================
// DamageType, the base class of all damagetypes.
// this and its subclasses are never spawned, just used as information holders
//=============================================================================
class DamageType extends Actor
	native
	abstract;

// Description of a type of damage.
var() localized string     DeathString;	 // string to describe death by this type of damage
var() localized string		FemaleSuicide, MaleSuicide;
var() float                ViewFlash;    // View flash to play.
var() vector               ViewFog;      // View fog to play.
var() class<effects>       DamageEffect; // Special effect.
var() string			   DamageWeaponName; // weapon that caused this damage
var() bool					bArmorStops;	// does regular armor provide protection against this damage
var() bool					bInstantHit;	// done by trace hit weapon
var() bool					bFastInstantHit;	// done by fast repeating trace hit weapon
var() bool                  bAlwaysGibs;
var() bool                  bLocationalHit;
var() bool                  bAlwaysSevers;
var() bool                  bSpecial;
var() bool                  bDetonatesGoop;
var() bool                  bSkeletize;         // swap model to skeleton
var() bool					bCauseConvulsions;
var() bool					bSuperWeapon;		// if true, also damages teammates even if no friendlyfire
var() bool					bCausesBlood;
var() bool					bKUseOwnDeathVel;	// For ragdoll death. Rather than using default - use death velocity specified in this damage type.
var() bool					bKUseTearOffMomentum;	// For ragdoll death. Add entirety of killing hit's momentum to ragdoll's initial velocity.
var	  bool					bDelayedDamage;		// for delayed damage damagetypes that set Pawn's DelayedDamageInstigatorController
var   bool					bNeverSevers;
var   bool					bThrowRagdoll;
var   bool					bRagdollBullet;
var	  bool					bLeaveBodyEffect;
var   bool					bExtraMomentumZ;	// Add extra Z to momentum on walking pawns
var	  bool					bFlaming;
var	  bool					bRubbery;
var   bool					bCausedByWorld;		//this damage was caused by the world (falling off level, into lava, etc)
var	  bool					bDirectDamage;
var   bool                  bBulletHit;
var	  bool					bVehicleHit;		// caused by vehicle running over you

var() float					GibModifier;

// these effects should be none if should use the pawn's blood effects
var() class<Effects>		PawnDamageEffect;	// effect to spawn when pawns are damaged by this damagetype
var() class<Emitter>		PawnDamageEmitter;	// effect to spawn when pawns are damaged by this damagetype
var() array<Sound>			PawnDamageSounds;	// Sound Effect to Play when Damage occurs

var() class<Effects>		LowGoreDamageEffect; // effect to spawn when low gore
var() class<Emitter>		LowGoreDamageEmitter;	// Emitter to use when it's low gore
var() array<Sound>			LowGoreDamageSounds;	// Sound Effects to play with Damage occurs with low gore

var() class<Effects>		LowDetailEffect;		// Low Detail effect
var() class<Emitter>		LowDetailEmitter;		// Low Detail emitter

var() float					FlashScale;		//for flashing victim's screen
var() vector				FlashFog;

var() int					DamageDesc;			// Describes the damage
var() int					DamageThreshold;	// How much damage much occur before playing effects
var() vector				DamageKick;
var() Material              DamageOverlayMaterial;    // for changing player's shader when hit
var() Material              DeathOverlayMaterial;    // for changing player's shader when hit
var() float                 DamageOverlayTime;        // timing for this
var() float                 DeathOverlayTime;        // timing for this

var() float                 GibPerterbation;    // When gibbing, the chunks will fly off in random directions.

var(Karma)	float			KDamageImpulse;		// magnitude of impulse applied to KActor due to this damage type.
var(Karma)  float			KDeathVel;			// How fast ragdoll moves upon death
var(Karma)  float			KDeathUpKick;		// Amount of upwards kick ragdolls get when they die

var float VehicleDamageScaling;		// multiply damage by this for vehicles
var float VehicleMomentumScaling;

static function IncrementKills(Controller Killer);

static function ScoreKill(Controller Killer, Controller Killed)
{
	IncrementKills(Killer);
}

static function string DeathMessage(PlayerReplicationInfo Killer, PlayerReplicationInfo Victim)
{
	return Default.DeathString;
}

static function string SuicideMessage(PlayerReplicationInfo Victim)
{
	if ( Victim.bIsFemale )
		return Default.FemaleSuicide;
	else
		return Default.MaleSuicide;
}

static function class<Effects> GetPawnDamageEffect( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	if ( class'GameInfo'.static.UseLowGore() )
	{
		if ( Default.LowGoreDamageEffect != None )
			return Default.LowGoreDamageEffect;
		else
			return Victim.LowGoreBlood;
	}
	else if ( bLowDetail )
	{
		if ( Default.LowDetailEffect != None )
			return Default.LowDetailEffect;
		else
			return Victim.BloodEffect;
	}
	else
	{
		if ( Default.PawnDamageEffect != None )
			return Default.PawnDamageEffect;
		else
			return Victim.BloodEffect;
	}
}

static function class<Emitter> GetPawnDamageEmitter( vector HitLocation, float Damage, vector Momentum, Pawn Victim, bool bLowDetail )
{
	if ( class'GameInfo'.static.UseLowGore() )
	{
		if ( Default.LowGoreDamageEmitter != None )
			return Default.LowGoreDamageEmitter;
		else
			return none;
	}
	else if ( bLowDetail )
	{

		if ( Default.LowDetailEmitter != None )
			return Default.LowDetailEmitter;
		else
			return none;
	}
	else
	{
		if ( Default.PawnDamageEmitter != None )
			return Default.PawnDamageEmitter;
		else
			return none;
	}
}

static function Sound GetPawnDamageSound()
{
	if ( class'GameInfo'.static.UseLowGore() )
	{
		if (Default.LowGoreDamageSounds.Length>0)
			return Default.LowGoreDamageSounds[Rand(Default.LowGoreDamageSounds.Length)];
		else
			return none;
	}
	else
	{
		if (Default.PawnDamageSounds.Length>0)
			return Default.PawnDamageSounds[Rand(Default.PawnDamageSounds.Length)];
		else
			return none;
	}
}

static function bool IsOfType(int Description)
{
	local int result;

	result = Description & Default.DamageDesc;
	return (result == Description);
}

static function GetHitEffects( out class<xEmitter> HitEffects[4], int VictemHealth );

static function string GetWeaponClass()
{
	return "";
}

defaultproperties
{
     DeathString="%o was killed by %k."
     FemaleSuicide="%o killed herself."
     MaleSuicide="%o killed himself."
     bArmorStops=True
     bLocationalHit=True
     bCausesBlood=True
     bExtraMomentumZ=True
     GibModifier=1.000000
     FlashScale=0.300000
     FlashFog=(X=900.000000)
     DamageDesc=1
     DeathOverlayTime=6.000000
     GibPerterbation=0.060000
     KDamageImpulse=8000.000000
     VehicleDamageScaling=1.000000
     VehicleMomentumScaling=1.000000
}

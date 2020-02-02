//=============================================================================
// Weapon_Turret
//=============================================================================

class Weapon_Turret extends Weapon
    config(user)
    HideDropDown
	CacheExempt;

#exec OBJ LOAD FILE=..\Animations\AS_VehiclesFull_M.ukx

replication
{
	reliable if ( Role == ROLE_Authority )
        ClientTakeHit;
}

function AdjustPlayerDamage( out int Damage, Pawn InstigatedBy, Vector HitLocation,
						         out Vector Momentum, class<DamageType> DamageType)
{
    local int		Drain;
	local vector	Reflect;
    local vector	HitNormal;
    local float		DamageMax;

	DamageMax = Instigator.HealthMax;

	if ( DamageType != None && !DamageType.default.bArmorStops )
        return;

    if ( CheckReflect(HitLocation, HitNormal, 0) )
    {
        Drain = Min( AmmoAmount(1)*2, Damage );
		Drain = Min(Drain,DamageMax);
	    Reflect = MirrorVectorByNormal( Normal(Location - HitLocation), Vector(Instigator.Rotation) );
        Damage -= Drain;
        Momentum *= 1.25;
        ConsumeAmmo( 1, Drain/2 );
        DoReflectEffect( Drain/2 );
    }
}

function DoReflectEffect(int Drain)
{
    //PlaySound(ShieldHitSound, SLOT_None);
    FM_Turret_AltFire_Shield(FireMode[1]).TakeHit( Drain );
    ClientTakeHit( Drain );
}

simulated function ClientTakeHit(int Drain)
{
	//ClientPlayForceFeedback( ShieldHitForce );
    FM_Turret_AltFire_Shield(FireMode[1]).TakeHit( Drain );
}

function bool CheckReflect( Vector HitLocation, out Vector RefNormal, int AmmoDrain )
{
    local Vector HitDir;
    local Vector FaceDir;

    if ( !FireMode[1].bIsFiring || AmmoAmount(0) == 0 )
		return false;

    FaceDir = Vector(Instigator.Controller.Rotation);
    HitDir = Normal(Instigator.Location - HitLocation + Vect(0,0,8));

    RefNormal = FaceDir;

    if ( FaceDir dot HitDir < -0.37 ) // 68 degree protection arc
    {
        if ( AmmoDrain > 0 )
            ConsumeAmmo( 0, AmmoDrain );
        return true;
    }
    return false;
}

simulated function bool HasAmmo()
{
    return true;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     FireModeClass(0)=Class'UT2k4AssaultFull.FM_BallTurret_Fire'
     FireModeClass(1)=Class'UT2k4AssaultFull.FM_Turret_AltFire_Shield'
     AIRating=0.680000
     CurrentRating=0.680000
     bCanThrow=False
     bNoInstagibReplace=True
     Priority=1
     SmallViewOffset=(Z=-40.000000)
     CenteredRoll=0
     PlayerViewOffset=(Z=-40.000000)
     AttachmentClass=Class'UT2k4AssaultFull.WA_Turret'
     ItemName="Turret weapon"
     Mesh=SkeletalMesh'AS_VehiclesFull_M.SkTurretFP'
     DrawScale=3.000000
     AmbientGlow=64
}

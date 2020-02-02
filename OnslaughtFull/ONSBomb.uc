//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSBomb extends Projectile;

var xEmitter Trail;

simulated function Destroyed()
{
    if ( Trail != None )
        Trail.mRegen = false; // stop the emitter from regenerating
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer)
    {
        Trail = Spawn(class'GrenadeSmokeTrail', self,, Location, Rotation);
    }

    if ( Role == ROLE_Authority )
    {
        RandSpin(25000);
    }
}

simulated function Landed( vector HitNormal )
{
    HitWall( HitNormal, None );
}

simulated function HitWall( vector HitNormal, actor Wall )
{
    Explode(Location, vect(0,0,1));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    BlowUp(HitLocation);
	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(class'ONSBombDropExplosion',,, HitLocation, rotator(vect(0,0,1)));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }
    Destroy();
}

defaultproperties
{
     TossZ=0.000000
     Damage=70.000000
     DamageRadius=600.000000
     MomentumTransfer=75000.000000
     MyDamageType=Class'XWeapons.DamTypeAssaultGrenade'
     ImpactSound=ProceduralSound'WeaponSounds.PGrenFloor1.P1GrenFloor1'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.GrenadeMesh'
     Physics=PHYS_Falling
     DrawScale=8.000000
     AmbientGlow=100
     bFixedRotationDir=True
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}

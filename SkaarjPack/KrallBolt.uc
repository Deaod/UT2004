class KrallBolt extends Projectile;

var xEmitter Trail;
var texture TrailTex;

simulated function Destroyed()
{
    if (Trail != None)
        Trail.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
    local Rotator R;

	Super.PostBeginPlay();

    if ( EffectIsRelevant(vect(0,0,0),false) )
    {
		Trail = Spawn(class'LinkProjEffect',self);
		if ( Trail != None ) 
			Trail.Skins[0] = TrailTex;
	}
	
	Velocity = Speed * Vector(Rotation);

    R = Rotation;
    R.Roll = Rand(65536);
    SetRotation(R);
    
	if ( Level.bDropDetail || Level.DetailMode == DM_Low )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
} 

simulated function Explode(vector HitLocation, vector HitNormal)
{
    if ( EffectIsRelevant(Location,false) )
		Spawn(class'LinkProjSparksYellow',,, HitLocation, rotator(HitNormal));
    PlaySound(Sound'WeaponSounds.BioRifle.BioRifleGoo2');
	Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    local Vector X, RefNormal, RefDir;

	if (Other == Instigator) return;
    if (Other == Owner) return;
	
    if (Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, Damage*0.25))
    {
        if (Role == ROLE_Authority)
        {
            X = Normal(Velocity);
            RefDir = X - 2.0*RefNormal*(X dot RefNormal);
            Spawn(Class, Other,, HitLocation+RefDir*20, Rotator(RefDir));
        }
        Destroy();
    }
    else if ( Other.bProjTarget )
	{
		if ( Role == ROLE_Authority )
			Other.TakeDamage(Damage,Instigator,HitLocation,MomentumTransfer * Normal(Velocity),MyDamageType);
		Explode(HitLocation, vect(0,0,1));
	}
}

defaultproperties
{
     TrailTex=Texture'XEffectMat.Link.link_muz_yellow'
     Speed=1500.000000
     MaxSpeed=1500.000000
     Damage=17.000000
     MomentumTransfer=25000.000000
     MyDamageType=Class'SkaarjPack.DamTypeKrallBolt'
     ExplosionDecal=Class'XEffects.LinkBoltScorch'
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=40
     LightSaturation=100
     LightBrightness=255.000000
     LightRadius=3.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.LinkProjectile'
     bDynamicLight=True
     AmbientSound=Sound'WeaponSounds.LinkGun.LinkGunProjectile'
     LifeSpan=4.000000
     DrawScale3D=(X=2.550000,Y=1.700000,Z=1.700000)
     PrePivot=(X=10.000000)
     Skins(0)=FinalBlend'XEffectMat.Link.LinkProjYellowFB'
     AmbientGlow=217
     Style=STY_Additive
     SoundVolume=255
     SoundRadius=50.000000
     bFixedRotationDir=True
     RotationRate=(Roll=80000)
     ForceType=FT_Constant
     ForceRadius=30.000000
     ForceScale=5.000000
}

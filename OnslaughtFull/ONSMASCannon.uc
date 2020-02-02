//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSMASCannon extends ONSWeapon;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx
#exec OBJ LOAD FILE=..\Textures\Lev_Particles.utx

var class<Emitter>              BeamEffectClass;
var Emitter                     Beam;
var vector                      GHitLocation, GHitNormal;
var float                       DamageRadius;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.LeviathanParticleEffects.LEVmainPartBeam');
    L.AddPrecacheMaterial(Material'VMParticleTextures.LeviathanParticleEffects.LeviathanMGUNFlare');
    L.AddPrecacheMaterial(Material'Lev_Particles.Suck.PrismShard');
    L.AddPrecacheMaterial(Material'Lev_Particles.Suck.HardBurn3');
    L.AddPrecacheMaterial(Material'Lev_Particles.Suck.CoreShine');
    L.AddPrecacheMaterial(Material'Lev_Particles.bLow.LevShell');
    L.AddPrecacheMaterial(Material'VMParticleTextures.LeviathanParticleEffects.dotz');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.BurnFlare');
    L.AddPrecacheMaterial(Material'EpicParticles.Flares.BurnFlare1');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.PlasmaStar2');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.LeviathanParticleEffects.LEVmainPartBeam');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.LeviathanParticleEffects.LeviathanMGUNFlare');
    Level.AddPrecacheMaterial(Material'Lev_Particles.Suck.PrismShard');
    Level.AddPrecacheMaterial(Material'Lev_Particles.Suck.HardBurn3');
    Level.AddPrecacheMaterial(Material'Lev_Particles.Suck.CoreShine');
    Level.AddPrecacheMaterial(Material'Lev_Particles.bLow.LevShell');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.LeviathanParticleEffects.dotz');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.BurnFlare');
    Level.AddPrecacheMaterial(Material'EpicParticles.Flares.BurnFlare1');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels1');

    Super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
//	Level.AddPrecacheStaticMesh(StaticMesh'Lev_Particles.bLow.LevSphere');
	Super.UpdatePrecacheStaticMeshes();
}

simulated function SetFireRateModifier(float Modifier)
{
	//unfortunately, this gun doesn't work with a really high fire rate :(
	FireInterval = FMax(default.FireInterval / Modifier, 4.5);
	AltFireInterval = FireInterval;
}

function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;
    local Actor Other;

    X = Vector(Dir);
    End = Start + TraceRange * X;

    //skip past vehicle driver
    if (Vehicle(Instigator) != None && Vehicle(Instigator).Driver != None)
    {
      	Vehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
       	Other = Trace(HitLocation, HitNormal, End, Start, True);
       	Vehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
    }
    else
       	Other = Trace(HitLocation, HitNormal, End, Start, True);

    if (Other == None)
    	HitLocation = End;

    // Pull the HitLocation back a bit along the beam
    HitLocation += vect(-500,0,0) >> Dir;

    HitCount++;
    LastHitLocation = HitLocation;
    SpawnHitEffects(Other, HitLocation, HitNormal);
}

function CeaseFire(Controller C)
{
    FlashCount = 0;

    if (AmbientEffectEmitter != None)
    {
        AmbientEffectEmitter.SetEmitterStatus(false);
    }

    if (bAmbientFireSound)
    {
        AmbientSound = None;
    }
}

function rotator AdjustAim(bool bAltFire)
{
	//because this is a REALLY BIG GUN, it's very obvious if the player/bot isn't shooting in exactly the direction it's pointing
	//(due to player autoaim or bot aiming), so don't adjust the aim at all for this weapon
	return WeaponFireRotation;
}

function Destroyed()
{
    Super.Destroyed();

    if (Beam != None)
        Beam.Destroy();
}

simulated state InstantFireMode
{
	simulated function SpawnHitEffects(actor HitActor, vector HitLocation, vector HitNormal)
	{
		if (Level.NetMode != NM_DedicatedServer)
		{
            CalcWeaponFire();
			Beam = Spawn(BeamEffectClass,,, WeaponFireLocation, rotator(WeaponFireLocation - HitLocation));
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Min = VSize(HitLocation - WeaponFireLocation);
			BeamEmitter(Beam.Emitters[1]).BeamDistanceRange.Max = VSize(HitLocation - WeaponFireLocation);
		}

        GHitLocation = HitLocation;
        GHitNormal = HitNormal;
        GotoState(,'ImplodeExplode');
	}

	function Explosion(float DamRad)
	{
    	local actor Victims;
    	local float damageScale, dist;
    	local vector Dir;

    	if (Role < ROLE_Authority)
    	   return;

    	foreach VisibleCollidingActors(class 'Actor', Victims, DamRad, GHitLocation)
    	{
    		if( (Victims != self) && (Victims != Instigator) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')) )
    		{
    			Dir = Victims.Location - GHitLocation;
     			dist = FMax(1,VSize(Dir));
    			Dir = Dir/dist;
    			Dir.Z *= 5.0;
    			Dir = Normal(Dir);
    			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamRad);
                //log(Victims$" receives "$damageScale * DamageMax$" from "$dist$" units away...");

                if (Pawn(Victims) != None && Pawn(Victims).GetTeamNum() == Instigator.GetTeamNum())
                    damageScale = 0;

    			Victims.TakeDamage(
                    				damageScale * DamageMax,
                    				Instigator,
                    				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * Dir,
                    				(damageScale * Momentum * Dir),
                    				DamageType
                    			  );
    		}
    	}
	}

    function AltFire(Controller C)
    {
    }

ImplodeExplode:
    Sleep(0.8);
    if (Level.NetMode != NM_DedicatedServer)
        Spawn(class'ONSMASCannonImplosionEffect',,, GHitLocation, rotator(GHitNormal));
    Sleep(2.3);
    Explosion(DamageRadius*0.125);
    Sleep(0.5);
    Explosion(DamageRadius*0.300);
    Sleep(0.2);
    Explosion(DamageRadius*0.475);
    Sleep(0.2);
    Explosion(DamageRadius*0.650);
    Sleep(0.2);
    Explosion(DamageRadius*0.825);
    Sleep(0.2);
    Explosion(DamageRadius*1.000);
}

defaultproperties
{
     BeamEffectClass=Class'OnslaughtFull.ONSMASCannonBeamEffect'
     DamageRadius=2200.000000
     YawBone="MainGunBase"
     PitchBone="MainGunBase"
     PitchUpLimit=10000
     WeaponFireAttachmentBone="maingunBarrel"
     WeaponFireOffset=25.000000
     RotationsPerSecond=0.400000
     bInstantFire=True
     bForceCenterAim=True
     FireIntervalAimLock=0.600000
     FireInterval=6.000000
     FireSoundClass=Sound'ONSVehicleSounds-S.MAS.MASBIGFire01'
     FireSoundVolume=512.000000
     FireForce="MASBIGFire"
     DamageType=Class'OnslaughtFull.DamTypeMASCannon'
     DamageMin=1000
     DamageMax=1000
     TraceRange=25000.000000
     Momentum=2000000.000000
     AIInfo(0)=(aimerror=0.000000,RefireRate=0.990000)
     AIInfo(1)=(aimerror=0.000000,RefireRate=0.990000)
     bReplicateAnimations=True
     Mesh=SkeletalMesh'ONSFullAnimations.MASmainGun'
}

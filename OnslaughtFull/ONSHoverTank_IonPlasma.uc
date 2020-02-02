//=============================================================================
// ONSHoverTank_IonPlasma
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ONSHoverTank_IonPlasma extends ONSHoverTank;

#exec OBJ LOAD FILE=AS_Vehicles_TX.utx

function AltFire(optional float F)
{
	super(ONSVehicle).AltFire( F );
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	super(ONSVehicle).ClientVehicleCeaseFire( bWasAltFire );
}

simulated function SetupTreads()
{
    LeftTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
    RightTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
    LeftTreadPanner.Material = Skins[1];
 	RightTreadPanner.Material = Skins[2];
 	LeftTreadPanner.PanRate = 0;
 	RightTreadPanner.PanRate = 0;
 	//LeftTreadPanner.PanDirection = rot(0, 16384, 0);
 	//RightTreadPanner.PanDirection = rot(0, 16384, 0);
 	Skins[1] = LeftTreadPanner;
 	Skins[2] = RightTreadPanner;
}

state VehicleDestroyed
{
    function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
    {
    }

Begin:
    DestroyAppearance();
    VehicleExplosion(vect(0,0,1), 1.0);
    sleep(3.0);
    Destroy();
}

static function StaticPrecache(LevelInfo L)
{
    super(ONSTreadCraft).StaticPrecache(L);

	L.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankBody');
	L.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTread');
	L.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTurret');
	L.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankBodyDead');
	L.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTreadDead');
	L.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTurretDead');

	L.AddPrecacheMaterial(Texture'AS_FX_TX.HUD.AssaultHUD');

	// FX
	L.AddPrecacheMaterial( Material'AW-2004Particles.Weapons.HardSpot' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Energy.AirBlastP' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Energy.PurpleSwell' );
	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp2_framesP' );
	L.AddPrecacheMaterial( Texture'EpicParticles.Flares.SoftFlare' );
	L.AddPrecacheMaterial( Texture'EpicParticles.Beams.WhiteStreak01aw' );
	L.AddPrecacheMaterial( Texture'AW-2004Particles.Energy.EclipseCircle' );
	L.AddPrecacheMaterial( Texture'EpicParticles.Flares.HotSpot' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Weapons.GrenExpl' );
	L.AddPrecacheMaterial( Material'AS_FX_TX.Flares.Laser_Flare' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Weapons.PlasmaStar' );

	L.AddPrecacheStaticMesh( StaticMesh'AW-2004Particles.Weapons.PlasmaSphere' );
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh( StaticMesh'AW-2004Particles.Weapons.PlasmaSphere' );

	super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankBody');
	Level.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTread');
	Level.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTurret');
	Level.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankBodyDead');
	Level.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTreadDead');
	Level.AddPrecacheMaterial(Material'AS_Vehicles_TX.IonPlasmaTank.IonTankTurretDead');

	// FX
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Weapons.HardSpot' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Energy.AirBlastP' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Energy.PurpleSwell' );
	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp2_framesP' );
	Level.AddPrecacheMaterial( Texture'EpicParticles.Flares.SoftFlare' );
	Level.AddPrecacheMaterial( Texture'EpicParticles.Beams.WhiteStreak01aw' );
	Level.AddPrecacheMaterial( Texture'AW-2004Particles.Energy.EclipseCircle' );
	Level.AddPrecacheMaterial( Texture'EpicParticles.Flares.HotSpot' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Weapons.GrenExpl' );
	Level.AddPrecacheMaterial( Material'AS_FX_TX.Flares.Laser_Flare' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Weapons.PlasmaStar' );

	super.UpdatePrecacheMaterials();
}

defaultproperties
{
     DriverWeapons(0)=(WeaponClass=Class'OnslaughtFull.ONSHoverTank_IonPlasma_Weapon')
     PassengerWeapons(0)=(WeaponPawnClass=Class'OnslaughtFull.ONSTankSecondaryTurretPawn_IonPlasma')
     bHasAltFire=True
     RedSkin=None
     BlueSkin=None
     DestroyedVehicleMesh=StaticMesh'AS_Vehicles_SM.Vehicles.IonTankDestroyed'
     DestructionEffectClass=Class'Onslaught.ONSVehicleIonExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     bKeyVehicle=True
     bShowChargingBar=True
     FPCamPos=(X=-80.000000,Z=150.000000)
     FPCamViewOffset=(X=25.000000)
     VehiclePositionString="in an Ion Plasma Tank"
     VehicleNameString="Ion Plasma Tank"
     RanOverDamageType=Class'OnslaughtFull.DamTypeIonTankRoadkill'
     CrushedDamageType=Class'OnslaughtFull.DamTypeIonTankPancake'
     VehicleIcon=(Material=Texture'AS_FX_TX.Icons.OBJ_IonTank',bIsGreyScale=True)
     Mesh=SkeletalMesh'AS_VehiclesFull_M.IonTankChassisSimple'
     Skins(0)=Combiner'AS_Vehicles_TX.IonPlasmaTank.IonTankBody_C'
     Skins(1)=Texture'AS_Vehicles_TX.IonPlasmaTank.IonTankTread'
     Skins(2)=Texture'AS_Vehicles_TX.IonPlasmaTank.IonTankTread'
}

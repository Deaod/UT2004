//=============================================================================
// xWeaponBase
//=============================================================================
class xWeaponBase extends xPickUpBase
    placeable;

#exec OBJ LOAD FILE=2k4ChargerMeshes.usx

var() class<Weapon> WeaponType;

function bool CheckForErrors()
{
	if ( (WeaponType == None) || WeaponType.static.ShouldBeHidden() )
	{
		log(self$" ILLEGAL WEAPONTYPE "$Weapontype);
		return true;
	}
	return Super.CheckForErrors();
}

function byte GetInventoryGroup()
{
	if (WeaponType != None)
		return WeaponType.Default.InventoryGroup;
	return 999;
}

simulated function PostBeginPlay()
{
	if (WeaponType != None)
	{
		PowerUp = WeaponType.default.PickupClass;
		if ( WeaponType.Default.InventoryGroup == 0 )
			bDelayedSpawn = true;
	}
    Super.PostBeginPlay();
	SetLocation(Location + vect(0,0,-2)); // adjust because reduced drawscale
}

defaultproperties
{
     SpiralEmitter=Class'XEffects.Spiral'
     NewStaticMesh=StaticMesh'2k4ChargerMeshes.ChargerMeshes.WeaponChargerMesh-DS'
     NewPrePivot=(Z=3.700000)
     NewDrawScale=0.500000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XGame_rc.WildcardChargerMesh'
     Texture=None
     DrawScale=0.500000
     Skins(0)=Texture'XGameTextures.WildcardChargerTex'
     Skins(1)=Texture'XGameTextures.WildcardChargerTex'
     CollisionRadius=60.000000
     CollisionHeight=3.000000
}

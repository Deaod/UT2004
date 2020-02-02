//=============================================================================
// Minigun.
//=============================================================================
class MinigunPickup extends UTWeaponPickup;

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Texture'XEffects.ShellCasingTex');
    L.AddPrecacheMaterial(Texture'AW-2004Explosions.Part_explode2s');
    L.AddPrecacheMaterial(Texture'AW-2004Particles.TracerShot');
	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.MinigunPickup');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Texture'XEffects.ShellCasingTex');
    Level.AddPrecacheMaterial(Texture'AW-2004Explosions.Part_explode2s');
    Level.AddPrecacheMaterial(Texture'AW-2004Particles.TracerShot');

	super.UpdatePrecacheMaterials();
}

defaultproperties
{
     MaxDesireability=0.730000
     InventoryType=Class'XWeapons.Minigun'
     PickupMessage="You got the Minigun."
     PickupSound=Sound'PickupSounds.MinigunPickup'
     PickupForce="MinigunPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.MinigunPickup'
     DrawScale=0.500000
}

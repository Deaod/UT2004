//=============================================================================
// UDamagePack
//=============================================================================
class UDamagePack extends TournamentPickUp
	notplaceable;

#exec OBJ LOAD FILE=E_Pickups.usx
#exec OBJ LOAD FILE=XGameShaders.utx

static function StaticPrecache(LevelInfo L)
{
	L.AddPrecacheStaticMesh(StaticMesh'E_Pickups.Udamage');
	L.AddPrecacheMaterial(Material'XGameShaders.PlayerShaders.WeaponUDamageShader');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'XGameShaders.PlayerShaders.WeaponUDamageShader');
	super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'E_Pickups.Udamage');
	Super.UpdatePrecacheStaticMeshes();
}

auto state Pickup
{
	function Touch( actor Other )
	{
        local Pawn P;

		if ( ValidTouch(Other) )
		{
            P = Pawn(Other);
            P.EnableUDamage(30);
			AnnouncePickup(P);
            SetRespawn();
		}
	}
}

defaultproperties
{
     MaxDesireability=2.000000
     bPredictRespawns=True
     RespawnTime=90.000000
     PickupMessage="DOUBLE DAMAGE!"
     PickupSound=Sound'PickupSounds.UDamagePickup'
     PickupForce="UDamagePickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'E_Pickups.General.Udamage'
     Physics=PHYS_Rotating
     DrawScale=0.900000
     AmbientGlow=254
     ScaleGlow=0.600000
     Style=STY_AlphaZ
     TransientSoundRadius=600.000000
     CollisionRadius=32.000000
     CollisionHeight=23.000000
     Mass=10.000000
     RotationRate=(Yaw=24000)
}

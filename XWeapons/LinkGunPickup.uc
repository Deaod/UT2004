//=============================================================================
// LinkGunPickup.
//=============================================================================
class LinkGunPickup extends UTWeaponPickup;

#exec OBJ LOAD FILE=NewWeaponPickups.usx

static function StaticPrecache(LevelInfo L)
{
	if ( class'LinkGun'.Default.bUseOldWeaponMesh )
		L.AddPrecacheMaterial(Texture'WeaponSkins.Skins.LinkTex0');
    L.AddPrecacheMaterial(Texture'XEffectMat.link_muz_green');
    L.AddPrecacheMaterial(Texture'XEffectMat.link_muzmesh_green');
    L.AddPrecacheMaterial(Texture'XEffectMat.link_beam_green');
	L.AddPrecacheMaterial(Texture'XEffectMat.link_spark_green');
	L.AddPrecacheMaterial(Texture'AW-2004Particles.Weapons.PlasmaShaft');
	L.AddPrecacheMaterial(Texture'XEffectMat.Link.link_muz_blue');
	L.AddPrecacheMaterial(Texture'XEffectMat.Link.link_beam_blue');
	L.AddPrecacheMaterial(Texture'XEffectMat.Link.link_muz_red');
	L.AddPrecacheMaterial(Texture'XEffectMat.Link.link_beam_red');
    L.AddPrecacheMaterial(Texture'XEffectMat.link_muz_yellow');
    L.AddPrecacheMaterial(Texture'XEffectMat.link_muzmesh_yellow');
    L.AddPrecacheMaterial(Texture'XEffectMat.link_beam_yellow');
	L.AddPrecacheMaterial(Texture'XEffectMat.link_spark_yellow');
	L.AddPrecacheMaterial(Texture'UT2004Weapons.NewWeaps.LinkPowerBlue');
	L.AddPrecacheMaterial(Texture'UT2004Weapons.NewWeaps.LinkPowerRed');
	L.AddPrecacheMaterial(Texture'EpicParticles.Flares.FlickerFlare');


	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.linkprojectile');
	L.AddPrecacheStaticMesh(StaticMesh'NewWeaponPickups.LinkPickupSM');
}

simulated function UpdatePrecacheMaterials()
{
	if ( class'LinkGun'.Default.bUseOldWeaponMesh )
		Level.AddPrecacheMaterial(Texture'WeaponSkins.Skins.LinkTex0');
    Level.AddPrecacheMaterial(Texture'XEffectMat.link_muz_green');
    Level.AddPrecacheMaterial(Texture'XEffectMat.link_muzmesh_green');
    Level.AddPrecacheMaterial(Texture'XEffectMat.link_beam_green');
	Level.AddPrecacheMaterial(Texture'XEffectMat.link_spark_green');
	Level.AddPrecacheMaterial(Texture'XEffectMat.Link.link_muz_blue');
	Level.AddPrecacheMaterial(Texture'XEffectMat.Link.link_beam_blue');
	Level.AddPrecacheMaterial(Texture'XEffectMat.Link.link_muz_red');
	Level.AddPrecacheMaterial(Texture'XEffectMat.Link.link_beam_red');
	Level.AddPrecacheMaterial(Texture'AW-2004Particles.Weapons.PlasmaShaft');
    Level.AddPrecacheMaterial(Texture'XEffectMat.link_muz_yellow');
    Level.AddPrecacheMaterial(Texture'XEffectMat.link_muzmesh_yellow');
    Level.AddPrecacheMaterial(Texture'XEffectMat.link_beam_yellow');
	Level.AddPrecacheMaterial(Texture'XEffectMat.link_spark_yellow');
	Level.AddPrecacheMaterial(Texture'UT2004Weapons.NewWeaps.LinkPowerBlue');
	Level.AddPrecacheMaterial(Texture'UT2004Weapons.NewWeaps.LinkPowerRed');
	Level.AddPrecacheMaterial(Texture'EpicParticles.Flares.FlickerFlare');

	super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.linkprojectile');
	Super.UpdatePrecacheStaticMeshes();
}

function float BotDesireability(Pawn Bot)
{
	local Bot B;
	local DestroyableObjective O;

	B = Bot(Bot.Controller);
	if (B != None && B.Squad != None)
	{
		O = DestroyableObjective(B.Squad.SquadObjective);
		if ( O != None && O.TeamLink(B.GetTeamNum()) && O.Health < O.DamageCapacity && VSize(Bot.Location - O.Location) < 2000
		     && (AllowRepeatPickup() || Bot.FindInventoryType(InventoryType) == None) )
			return MaxDesireability * 2;
	}

	return Super.BotDesireability(Bot);
}

defaultproperties
{
     StandUp=(Y=0.250000,Z=0.000000)
     MaxDesireability=0.700000
     InventoryType=Class'XWeapons.LinkGun'
     PickupMessage="You got the Link Gun."
     PickupSound=Sound'PickupSounds.LinkGunPickup'
     PickupForce="LinkGunPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'NewWeaponPickups.LinkPickupSM'
     DrawScale=0.650000
}

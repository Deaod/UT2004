class TransAttachment extends xWeaponAttachment;

function InitFor(Inventory I)
{
    Super.InitFor(I);
}

simulated event ThirdPersonEffects()
{
    Super.ThirdPersonEffects();
}

simulated event BaseChange()
{
	if ( (Pawn(Base) != None) && (Pawn(Base).PlayerReplicationInfo != None) && (Pawn(Base).PlayerReplicationInfo.Team != None) )
	{
		if ( Pawn(Base).PlayerReplicationInfo.Team.TeamIndex == 1 )
			Skins[1] = Material'WeaponSkins.NEWTranslocatorBlue';
		else
			Skins[1] = Material'WeaponSkins.NEWTranslocatorTEX';
	}
}

defaultproperties
{
     bHeavy=True
     Mesh=SkeletalMesh'NewWeapons2004.NEWTranslauncher_3rd'
     Skins(0)=FinalBlend'EpicParticles.JumpPad.NewTransLaunBoltFB'
     Skins(1)=Texture'WeaponSkins.Skins.NEWTranslocatorTEX'
     Skins(2)=Texture'WeaponSkins.AmmoPickups.NEWTranslocatorPUCK'
     Skins(3)=FinalBlend'WeaponSkins.AmmoPickups.NewTransGlassFB'
}

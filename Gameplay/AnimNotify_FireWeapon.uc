class AnimNotify_FireWeapon extends AnimNotify_Scripted;

event Notify( Actor Owner )
{
	// fake fire - play weapon effect, but no real shot
	Pawn(Owner).bIgnorePlayFiring = true;
	WeaponAttachment(Pawn(Owner).Weapon.ThirdPersonActor).ThirdPersonEffects();
	Pawn(Owner).Weapon.HackPlayFireSound();
}

defaultproperties
{
}

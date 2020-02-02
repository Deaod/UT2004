class Redeemer extends Weapon
    config(user);

function PrebeginPlay()
{
	Super.PreBeginPlay();
}

simulated function SuperMaxOutAmmo()
{}

simulated event ClientStopFire(int Mode)
{
    if (Role < ROLE_Authority)
    {
        StopFire(Mode);
    }
    if ( Mode == 0 )
		ServerStopFire(Mode);
}

simulated event WeaponTick(float dt)
{
	if ( (Instigator.Controller == None) || HasAmmo() )
		return;
	Instigator.Controller.SwitchToBestWeapon();
}


// AI Interface
function float SuggestAttackStyle()
{
    return -1.0;
}

function float SuggestDefenseStyle()
{
    return -1.0;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	return 0;
}

function float GetAIRating()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return 0.4;

	if ( B.IsShootingObjective() )
		return 1.0;

	if ( (B.Enemy == None) || B.Enemy.bCanFly || VSize(B.Enemy.Location - Instigator.Location) < 2400 )
		return 0.4;

	return AIRating;
}

defaultproperties
{
     FireModeClass(0)=Class'XWeapons.RedeemerFire'
     FireModeClass(1)=Class'XWeapons.RedeemerGuidedFire'
     SelectAnim="Pickup"
     PutDownAnim="PutDown"
     SelectAnimRate=0.667000
     PutDownAnimRate=1.000000
     PutDownTime=0.450000
     BringUpTime=0.675000
     SelectSound=Sound'WeaponSounds.Misc.redeemer_change'
     SelectForce="SwitchToFlakCannon"
     AIRating=1.500000
     CurrentRating=1.500000
     bNotInDemo=True
     Description="The first time you witness this miniature nuclear device in action, you'll agree it is the most powerful weapon in the Tournament.|Launch a slow-moving but utterly devastating missile with the primary fire; but make sure you're out of the Redeemer's impressive blast radius before it impacts. The secondary fire allows you to guide the nuke yourself with a rocket's-eye view.||Keep in mind, however, that you are vulnerable to attack when steering the Redeemer's projectile. Due to the extreme bulkiness of its ammo, the Redeemer is exhausted after a single shot."
     DemoReplacement=Class'XWeapons.RocketLauncher'
     DisplayFOV=60.000000
     Priority=30
     SmallViewOffset=(X=26.000000,Y=6.000000,Z=-34.000000)
     CustomCrosshair=3
     CustomCrossHairColor=(B=128)
     CustomCrossHairScale=2.000000
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Circle2"
     InventoryGroup=0
     GroupOffset=1
     PickupClass=Class'XWeapons.RedeemerPickup'
     PlayerViewOffset=(X=14.000000,Z=-28.000000)
     PlayerViewPivot=(Pitch=1000,Yaw=-400)
     BobDamping=1.400000
     AttachmentClass=Class'XWeapons.RedeemerAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=4,Y1=350,X2=110,Y2=395)
     ItemName="Redeemer"
     Mesh=SkeletalMesh'Weapons.Redeemer_1st'
     DrawScale=1.200000
}

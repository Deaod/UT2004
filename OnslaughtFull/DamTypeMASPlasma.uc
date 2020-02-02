//-----------------------------------------------------------
//
//-----------------------------------------------------------
class DamTypeMASPlasma extends VehicleDamageType
    abstract;

defaultproperties
{
     VehicleClass=Class'OnslaughtFull.ONSMASSideGunPawn'
     DeathString="%k's Leviathan turret plasmanated %o."
     FemaleSuicide="%o wasted herself."
     MaleSuicide="%o wasted himself."
     bDetonatesGoop=True
     bDelayedDamage=True
     FlashFog=(X=700.000000)
}

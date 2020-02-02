class ShockAmmo extends Ammunition;

#EXEC OBJ LOAD FILE=InterfaceContent.utx

defaultproperties
{
     MaxAmmo=50
     InitialAmount=20
     PickupClass=Class'XWeapons.ShockAmmoPickup'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=400,Y1=130,X2=426,Y2=179)
     ItemName="Shock Core"
}

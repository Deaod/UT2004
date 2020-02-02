class RocketAmmo extends Ammunition;

#EXEC OBJ LOAD FILE=InterfaceContent.utx

defaultproperties
{
     MaxAmmo=30
     InitialAmount=12
     PickupClass=Class'XWeapons.RocketAmmoPickup'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=458,Y1=34,X2=511,Y2=78)
     ItemName="Rockets"
}

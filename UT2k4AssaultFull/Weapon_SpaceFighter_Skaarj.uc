//=============================================================================
// Weapon_SpaceFighter_Skaarj
//=============================================================================

class Weapon_SpaceFighter_Skaarj extends Weapon_SpaceFighter
    config(user)
    HideDropDown
	CacheExempt;

#exec OBJ LOAD FILE=..\StaticMeshes\AS_Vehicles_SM.usx


//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     SmallViewOffset=(X=50.000000,Z=-25.000000)
     PlayerViewOffset=(X=50.000000,Z=-25.000000)
     StaticMesh=StaticMesh'AS_Vehicles_SM.Vehicles.SpaceFighter_Skaarj_FP'
}

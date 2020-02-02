class FlakMuzFlash1st extends MinigunMuzFlash1st;
 
#exec OBJ LOAD FILE=xGameShaders.utx
#exec STATICMESH IMPORT NAME=FlakMuzFlashMesh FILE=Models\FlakMuzFlash.lwo COLLISION=0

defaultproperties
{
     mGrowthRate=7.000000
     mTileAnimation=False
     mNumTileColumns=1
     mNumTileRows=1
     mMeshNodes(0)=StaticMesh'XEffects.FlakMuzFlashMesh'
     DrawScale=2.200000
     Skins(0)=FinalBlend'XGameShaders.WeaponShaders.flakflashfinal'
}

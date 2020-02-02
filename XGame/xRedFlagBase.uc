//=============================================================================
// xRedFlagBase.
//=============================================================================
class xRedFlagBase extends xRealCTFBase
	placeable;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    if ( Level.NetMode != NM_DedicatedServer )
    {
        Spawn(class'XGame.xCTFBase',self,,Location-BaseOffset,rot(0,0,0));
    }
}

defaultproperties
{
     FlagType=Class'XGame.xRedFlag'
     DefenseScriptTags="DefendRedFlag"
     ObjectiveName="Red Flag"
     Skins(0)=FinalBlend'XGameShaders2004.CTFShaders.RedFlagShader_F'
}

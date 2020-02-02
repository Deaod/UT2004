//=============================================================================
// banner.
//=============================================================================
class banner_red extends uTeamBanner;

#exec OBJ LOAD FILE=SC_Volcano_T.utx

simulated function PostBeginPlay()
{    
    Super.PostBeginPlay();    

    LoopAnim('banner');
    SimAnim.bAnimLoop = true;  
}

defaultproperties
{
     Skins(0)=FinalBlend'SC_Volcano_T.Banners.SC_BannerRed_F'
}

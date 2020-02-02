//=============================================================================
// banner.
//=============================================================================
class banner_blue extends uTeamBanner;

simulated function PostBeginPlay()
{    
    Super.PostBeginPlay();    

    LoopAnim('banner');
    SimAnim.bAnimLoop = true;  
}

defaultproperties
{
     Team=1
     Skins(0)=FinalBlend'SC_Volcano_T.Banners.SC_BannerBlue_F'
}

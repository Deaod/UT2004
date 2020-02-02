class LinkMuzFlashBeam1st extends xEmitter;

#exec TEXTURE   IMPORT      NAME=LinkMuzFlashTex FILE=textures\muzzleflashlink.tga GROUP=Effects LODSET=3
#exec OBJ LOAD FILE=XEffectMat.utx

event Trigger( Actor Other, Pawn EventInstigator )
{
    mStartParticles += 1;
}

defaultproperties
{
     mStartParticles=0
     mMaxParticles=5
     mLifeRange(0)=0.250000
     mLifeRange(1)=0.250000
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mPosRelative=True
     mRandOrient=True
     mSpinRange(0)=-100.000000
     mSpinRange(1)=100.000000
     mSizeRange(0)=24.000000
     mSizeRange(1)=24.000000
     mColorRange(0)=(B=200,G=200,R=200)
     mColorRange(1)=(B=200,G=200,R=200)
     mAttenKa=0.000000
     bHidden=True
     bOnlyOwnerSee=True
     Skins(0)=Texture'XEffectMat.Link.link_muz_green'
     Style=STY_Translucent
}

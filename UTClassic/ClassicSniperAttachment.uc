class ClassicSniperAttachment extends xWeaponAttachment;

var xEmitter            mMuzFlash3rd;
var float SmokeOffsetZ;

simulated function Destroyed()
{
    if (mMuzFlash3rd != None)
        mMuzFlash3rd.Destroy();
    Super.Destroyed();
}

simulated event ThirdPersonEffects()
{
	local vector SmokeLoc, SmokeOffset;
	local coords	C;

    if ( (FlashCount != 0) && (Level.NetMode != NM_DedicatedServer) )
	{
        if (FiringMode == 0)
 			WeaponLight();

 		if ( Instigator.IsFirstPerson() )
 		{
	 		SmokeLoc = Instigator.Location + Instigator.Eyeheight * vect(0,0,1) + Instigator.CollisionRadius * vector(Instigator.Controller.Rotation);
			SmokeLoc.Z += SmokeOffsetZ;
			Spawn(class'ClassicSniperSmoke',,,SmokeLoc);
		}
		else if ( Level.TimeSeconds - Instigator.LastRenderTime < 0.2 )
		{
			if (mMuzFlash3rd == None)
				mMuzFlash3rd = Spawn(class'XEffects.AssaultMuzFlash3rd');

			C = Instigator.GetBoneCoords('righthand');
			SmokeOffset =  -1 * C.ZAxis * (Instigator.CollisionRadius + 35);
			mMuzFlash3rd.SetLocation( C.Origin + SmokeOffset + C.ZAxis * 23 + C.YAxis*4.5);
			mMuzFlash3rd.SetDrawScale(1.0);
			mMuzFlash3rd.SetRotation(rotator(-1 * C.ZAxis));
			mMuzFlash3rd.mStartParticles++;
	 		SmokeLoc = C.Origin + SmokeOffset;
			Spawn(class'ClassicSniperSmoke',,,SmokeLoc);
		}
     }

    Super.ThirdPersonEffects();
}


simulated function Vector GetTipLocation()
{
    return Location -  vector(Rotation) * 100;
}

defaultproperties
{
     SmokeOffsetZ=10.000000
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=170
     LightBrightness=255.000000
     LightRadius=5.000000
     LightPeriod=3
     Mesh=SkeletalMesh'NewWeapons2004.Sniper3rd'
     RelativeLocation=(X=-30.000000,Z=4.000000)
     RelativeRotation=(Pitch=32768)
     DrawScale=0.160000
}

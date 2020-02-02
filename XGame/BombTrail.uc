class BombTrail extends SpeedTrail;

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	
	if ( bNetNotify )
		PostNetReceive();
}

simulated event PostNetReceive()
{
	local Actor OldBase;
	
	if ( Base != None )
	{
		OldBase = Base;
		SetLocation(Base.Location);
		SetBase(OldBase);
		SetRelativeLocation(vect(0,0,0));
		bNetNotify = false;
	}	
}

defaultproperties
{
     mDirDev=(X=0.000000,Y=0.000000,Z=0.000000)
     mPosDev=(X=0.000000,Y=0.000000,Z=0.000000)
     bHardAttach=True
     bNetNotify=True
}

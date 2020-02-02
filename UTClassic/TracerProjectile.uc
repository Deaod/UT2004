class TracerProjectile extends Projectile;

var xEmitter Trail;

simulated function Destroyed()
{
    if ( Trail !=None )
		Trail.mRegen=False;
	Super.Destroyed();
}

simulated function bool CanSplash()
{
	return (bReadyToSplash && (Level.NetMode != NM_Standalone));
}

simulated function PostNetBeginPlay()
{
	local PlayerController PC;
	local vector Dir,LinePos,LineDir, OldLocation;
	
	if ( (Level.NetMode == NM_Client) && (Level.GetLocalPlayerController() == Owner) )
	{
		Destroy();
		return;
	}

    if ( Level.NetMode != NM_DedicatedServer )
    {
        if ( !PhysicsVolume.bWaterVolume )
        {
            Trail = Spawn(class'FlakTrail',self);
            Trail.Lifespan = Lifespan;
        }
    }
    Velocity = Vector(Rotation) * (Speed);
    Super.PostNetBeginPlay();

 	// see if local player controller near bullet, but missed
	PC = Level.GetLocalPlayerController();
	if ( (PC != None) && (PC.Pawn != None) )
	{
		Dir = Normal(Velocity);
		LinePos = (Location + (Dir dot (PC.Pawn.Location - Location)) * Dir);
		LineDir = PC.Pawn.Location - LinePos;
		if ( VSize(LineDir) < 150 )
		{
			OldLocation = Location;
			SetLocation(LinePos);
			if ( FRand() < 0.5 )
				PlaySound(sound'Impact3Snd',,,,80);
			else
				PlaySound(sound'Impact7Snd',,,,80);
			SetLocation(OldLocation);
		}
	}
}

simulated singular function Touch(Actor Other)
{
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
}

simulated function Landed( Vector HitNormal )
{
    Destroy();
}

simulated function HitWall( vector HitNormal, actor Wall )
{
    Destroy();
}

defaultproperties
{
     Speed=20000.000000
     MaxSpeed=20000.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.FlakChunk'
     bReplicateInstigator=False
     LifeSpan=2.000000
     DrawScale=5.000000
     Style=STY_Alpha
     bOwnerNoSee=True
}

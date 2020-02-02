class ONSRVWebProjectileLeader extends  ONSRVWebProjectile
	native
	nativereplication;

var() float			SpringLength;
var() float			SpringStiffness;
var() float			StuckSpringStiffness; //when a projectile in this web gets stuck, SpringStiffness is set to this
var() float			SpringDamping;
var() float			SpringMaxForce;
var() float			SpringExplodeLength; // Max stretch length before web explodes.
var() float			ProjVelDamping; //
var() float			ProjStuckNeighbourVelDamping; // Extra damping applied when a neighbour is attached to something.
var() InterpCurve	ProjGravityScale; // Function of time since launched.

// To make the web stuff particularly effective against Mantas, it is sucked into the top of the fans.
var() bool						bEnableSuckTargetForce;
var() bool						bSymmetricSuckTarget; // Suck to SuckTargetOffset mirrored across Y as well (eg. for manta fans)
var() bool						bSuckFriendlyActor; // Don't get sucked towards actors on own team.
var() bool						bNoSuckFromBelow; // If the projectile is 'below' the suck target (ie. negative local Z) it won't get sucked.
var() bool						bOnlySuckToDriven; // Only suck to an actor if bDriving is true.
var() array< class<Vehicle> >	SuckTargetClasses; // Class of actors that projectile should get sucked towards.
var() float						SuckTargetRange; // Distance from SuckTarget before projectile starts getting sucked.
var() float						SuckTargetForce; // Force applied to suck projectile towards target.
var() vector					SuckTargetOffset; // Location in target ref frame that projectile will be sucked too
var() float						SuckReduceVelFactor; // Once a particle is getting sucked, how much to kill velocity that is not in the suck direction.

var byte						ProjTeam;
var float						FireTime;
var	array<ONSRVWebProjectile>	Projectiles;


// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		ProjTeam;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	FireTime = Level.TimeSeconds;
}

// Walk over entire web, detonating projectiles. Only called on server.
event DetonateWeb()
{
	local int i;

	// We want to destroy ourself last!
	for(i=1; i<Projectiles.Length; i++)
	{
		if( Projectiles[i] != None )
			Projectiles[i].Explode( Projectiles[i].Location, Projectiles[i].StuckNormal );
	}

	self.Explode( self.Location, self.StuckNormal );
}

//one of the projectiles just got stuck to something
simulated function NotifyStuck()
{
	SpringStiffness = StuckSpringStiffness;
}

defaultproperties
{
     SpringLength=50.000000
     SpringStiffness=5.000000
     StuckSpringStiffness=50.000000
     SpringDamping=6.000000
     SpringMaxForce=4500.000000
     SpringExplodeLength=1250.000000
     ProjStuckNeighbourVelDamping=2.000000
     ProjGravityScale=(Points=(,(InVal=4.000000),(InVal=5.000000,OutVal=0.500000),(InVal=1000000.000000,OutVal=0.500000)))
     bEnableSuckTargetForce=True
     bSymmetricSuckTarget=True
     bOnlySuckToDriven=True
     SuckTargetClasses(0)=Class'Onslaught.ONSHoverBike'
     SuckTargetRange=275.000000
     SuckTargetForce=6500.000000
     SuckTargetOffset=(X=25.000000,Y=80.000000,Z=-10.000000)
     SuckReduceVelFactor=0.900000
}

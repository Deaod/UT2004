class ConvoyPhysicsVolume extends PhysicsVolume;

simulated event PawnEnteredVolume(Pawn Other)
{
	if ( Other.Role == ROLE_Authority )
		Other.Died(None, class'ConvoyGibbed', Location);
	if ( PainTimer == None )
	{
		PainTimer = spawn(class'VolumeTimer', self);
		PainTimer.TimerRate = 0.1;
	}
}

simulated function TimerPop(VolumeTimer T)
{
	local Actor A;
	local int i;

	ForEach DynamicActors(class'Actor', A)
	{
		if ( !A.bNoDelete && (A.PhysicsVolume == self) )
		{
			if ( (A.Role == ROLE_Authority) && (Pawn(A) != None) )
				Pawn(A).ChunkUp(A.Rotation, class'Gibbed'.Default.GibPerterbation);
			else if ( (A.Base == None) && (A.Physics == PHYS_None) )
			{
				if ( Emitter(A) != None )
				{
					A.SetPhysics(PHYS_Projectile);
					A.Velocity = ZoneVelocity;
					A.LifeSpan = FMin(A.Lifespan, 2);
					for( i=0; i<Emitter(A).Emitters.Length; i++ )
					{
						if( Emitter(A).Emitters[i] != None )
							Emitter(A).Emitters[i].AddVelocityFromOwner = true;
					}
				}
				else if ( xEmitter(A) != None )
				{
					A.SetPhysics(PHYS_Projectile);
					A.Velocity = ZoneVelocity;
					A.LifeSpan = FMin(A.Lifespan, 2);
					xEmitter(A).mPosRelative = true;
				}
			}
			else
				A.LifeSpan = FMin(A.Lifespan,2);
		}
	}
	T.Destroy();
}

function Trigger( actor Other, pawn EventInstigator )
{
}

simulated event PostTouch(Actor Other)
{
	if (Other == None)
		return;

	Other.LifeSpan = FMin(Other.Lifespan,2);
	if ( Other.Physics == PHYS_Projectile )
		Other.Velocity += ZoneVelocity;
	else
	{
		Other.SetPhysics(PHYS_Falling);
		Other.Velocity = ZoneVelocity;
		Other.Velocity.Z = 200;
	}
}

simulated event touch(Actor Other)
{
	Other.LifeSpan = FMin(Other.Lifespan,2);
	if ( Pickup(Other) != None )
	{
		PendingTouch = Other.PendingTouch;
		Other.PendingTouch = self;
		return;
	}
	if ( Pawn(Other) != None )
		return;
	if ( Other.IsA('BioGlob') )
	{
		Other.Destroy();
		return;
	}

	if ( Other.Physics == PHYS_Projectile )
	{
		PendingTouch = Other.PendingTouch;
		Other.PendingTouch = self;
		if ( PainTimer == None )
		{
			PainTimer = spawn(class'VolumeTimer', self);
			PainTimer.TimerRate = 0.1;
		}
	}
	else if ( (Other.Base == None) && Other.IsA('Emitter') && (Other.Physics == PHYS_None) )
	{
		Other.SetPhysics(PHYS_Projectile);
		Other.Velocity = ZoneVelocity;
	}
	else if ( Other.Physics == PHYS_Falling )
	{
		PendingTouch = Other.PendingTouch;
		Other.PendingTouch = self;
		if ( PainTimer == None )
		{
			PainTimer = spawn(class'VolumeTimer', self);
			PainTimer.TimerRate = 0.1;
		}
	}
}

defaultproperties
{
     bNoDecals=True
     RemoteRole=ROLE_SimulatedProxy
}

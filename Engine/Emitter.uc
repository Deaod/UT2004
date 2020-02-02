//=============================================================================
// Emitter: An Unreal Emitter Actor.
//=============================================================================
class Emitter extends Actor
	native
	placeable;

#exec Texture Import File=Textures\S_Emitter.pcx  Name=S_Emitter Mips=Off MASKED=1


var()	export	editinline	array<ParticleEmitter>	Emitters;

var		(Global)	rangevector			GlobalOffsetRange;
var		(Global)	range				TimeTillResetRange;
var		(Global)	bool				AutoDestroy;
var		(Global)	bool				AutoReset;
var		(Global)	bool				DisableFogging;

var		transient	vector				OldLocation;		// Laurent -- for ptcl location interpolation
var		transient	vector				GlobalOffset;
var		transient	vector				AbsoluteVelocity;
var		transient	int					Initialized;
var		transient	box					BoundingBox;
var		transient	float				EmitterRadius;
var		transient	float				EmitterHeight;
var		transient	float				TimeTillReset;
var		transient	bool				UseParticleProjectors;
var		transient	bool				DeleteParticleEmitters;
var		transient	bool				ActorForcesEnabled;
var		transient	ParticleMaterial	ParticleMaterial;

// shutdown the emitter and make it auto-destroy when the last active particle dies.
native function Kill();
 
simulated function UpdatePrecacheMaterials()
{
	local int i;

	super.UpdatePrecacheMaterials();

	for( i=0; i<Emitters.Length; i++ )
	{
		if( Emitters[i] != None )
		{
			if( Emitters[i].Texture != None )
				Level.AddPrecacheMaterial(Emitters[i].Texture);
		}
	}
}

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
	local int i;
	for( i=0; i<Emitters.Length; i++ )
	{
		if( Emitters[i] != None )
			Emitters[i].Trigger();
	}
}

simulated event SpawnParticle( int Amount )
{
	local int i;
	for( i=0; i<Emitters.Length; i++ )
	{
		if( Emitters[i] != None )
			Emitters[i].SpawnParticle(Amount);
	}
}

simulated function Reset()
{
	local int i;

	for( i=0; i<Emitters.Length; i++ )
	{
		if ( Emitters[i] != None )
			Emitters[i].Reset();
	}	
}

defaultproperties
{
     DrawType=DT_Particle
     bNoDelete=True
     RemoteRole=ROLE_None
     Texture=Texture'Engine.S_Emitter'
     Style=STY_Particle
     bUnlit=True
     bNotOnDedServer=True
}

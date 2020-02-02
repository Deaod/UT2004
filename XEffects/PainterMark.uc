//=============================================================================
// PainterMark.
//=============================================================================
class PainterMark extends Effects;

var rotator RealRotation;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		RealRotation;
}
 

simulated function SpawnEffects()
{

}

Auto State StartUp
{

	simulated function Tick(float DeltaTime)
	{
		local PainterMark Marks;

		// Destroy any other PainterMarks
		foreach VisibleActors(class'PainterMark', Marks)
			if (Marks != Self)
				Marks.Destroy();

		if ( Instigator != None )
			MakeNoise(0.3);
		if ( Role == ROLE_Authority )
			RealRotation = Rotation;
		else
			SetRotation(RealRotation);
		
		if ( Level.NetMode != NM_DedicatedServer )
			SpawnEffects();
		Disable('Tick');
	}
}

defaultproperties
{
     DrawType=DT_None
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=10.000000
}

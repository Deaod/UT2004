//=============================================================================
// PressureZone.
//=============================================================================
class PressureVolume extends PhysicsVolume;

var() float  KillTime;					// How long to kill the player?
var() float  StartFlashScale;			// Fog values for client death sequence
var() Vector StartFlashFog;
var() float  EndFlashScale;
var() Vector EndFlashFog;
var   float  DieFOV;					// Field of view when dead (interpolates)
var   float  DieDrawScale;				// Drawscale when dead
var   float  TimePassed;
var   bool   bTriggered;				// Ensure that it doesn't update until it should
var	  bool	 bScreamed;

function Trigger( actor Other, pawn EventInstigator )
{
	local Controller P;

	// The pressure zone has been triggered to kill something

	Instigator = EventInstigator;

	if ( (Instigator.Controller != None) && Instigator.Controller.IsA('Bot') )
	{
		// taunt the victim
		for ( P=Level.ControllerList; P!=None; P=P.NextController )
			if( (P.Pawn != None) && (P.Pawn.PhysicsVolume == self) && (P.Pawn.Health > 0) )
			{
				Instigator.Controller.Target = P.Pawn;
				Instigator.Controller.GotoState('VictoryDance');
			}
	}

	// Engage Tick so that death may be slow and dramatic
	TimePassed = 0;
	bTriggered = true;
	bScreamed = false;
	Disable('Trigger');
	Enable('Tick');
}

function Tick( float DeltaTime )
{
	local float  		ratio, curScale;
	local vector 		curFog;
	local PlayerController	PC;
	local Controller P, Killer;
	local bool bActive;

	if( !bTriggered ) 
	{
		Disable('Tick');
		return;
	}

	TimePassed += DeltaTime;
	ratio = TimePassed/KillTime;
	if( ratio > 1.0 ) ratio = 1.0;

	for ( P=Level.ControllerList; P!=None; P=P.NextController )
	{
		// Ensure player hasn't been dispatched through other means already (suicide?)
		if( (P.Pawn.PhysicsVolume == self) && (P.Pawn.Health > 0) && !P.Pawn.IsA('Spectator') )
		{
			bActive = true;
			P.Pawn.SetDrawScale(1 + (DieDrawScale-1) * ratio);

			// Maybe scream?
			if( !bScreamed && P.bIsPlayer && (Ratio > 0.2) && (FRand() < 2 * DeltaTime) )
			{
				// Scream now (from the terrible pain)
				bScreamed = true;
				P.Pawn.PlayDyingSound();
			}
		
			// Fog & Field of view
			PC = PlayerController(P);
			if( PC != None )
			{
				curScale = (EndFlashScale-StartFlashScale)*ratio + StartFlashScale;
				curFog   = (EndFlashFog  -StartFlashFog  )*ratio + StartFlashFog;
				PC.ClientFlash( curScale, 1000 * curFog );

				PC.SetFOVAngle( (DieFOV-PC.default.FOVAngle)*ratio + PC.default.FOVAngle);
			}
			if ( ratio == 1.0 )
			{	
				if ( Instigator != None )
					Killer = Instigator.Controller;
				P.Pawn.Died(Killer, class'Depressurized', P.Pawn.Location);
				MakeNormal(P.Pawn);
			}
		}
	}	
	
	if( !bActive && (TimePassed >= KillTime) )
	{
		Disable('Tick');
		Enable('Trigger');
		bTriggered = false;
	}
}

function MakeNormal(Pawn P)
{
	local PlayerController PC;

	P.SetDrawScale(P.Default.DrawScale);
	PC = PlayerController(P.Controller);
	if( PC != None )
		PC.SetFOVAngle( PC.Default.FOVAngle );
}

// When an actor leaves this zone.
event PawnLeavingVolume(Pawn Other)
{
	MakeNormal(Other);
	Super.PawnLeavingVolume(Other);
}

defaultproperties
{
     DieFOV=150.000000
     DamageType=Class'Gameplay.Depressurized'
}

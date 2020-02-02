//==============================================================================
//  Created on: 12/20/2003
//  Checks all dying pawns for UDamage time, and spawns a new pickup if the pawn
//   still had time remaining
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UDamageRules extends GameRules;

// This is called whenever a player is killed by another player
// Check if the dying player had any UDamage time remaining
function ScoreKill(Controller Killer, Controller Killed)
{
	local xPawn Dying;

	if ( Killer != None && Killer != Killed && HasUDamage(Killed) )
	{
		Dying = xPawn(Killed.Pawn);

		// If the player had UDamage time remaining, toss out another
		// UDamage pickup that is worth the remaining time
		if ( Dying != None && Dying.UDamageTime > Level.TimeSeconds + 3 )
			ThrowUDamage(Killer, Dying);
	}

	Super.ScoreKill(Killer, Killed);
}

function bool HasUDamage(Controller Killed)
{
	if ( Killed != None && Killed.Pawn != None && Killed.Pawn.HasUDamage() )
		return true;

	return false;
}

function ThrowUDamage( Controller Killer, xPawn Killed )
{
	local vector tossdir, x, y, z;
	local UDamageReward Reward;

	if ( Killer == None || Killed == None )
		return;

	// This chain of events based on the way that weapon pickups are dropped when a pawn dies
	// See Pawn.Died()
	Reward = Spawn( class'UDamageReward', , , Killed.Location );

	// Find out which direction the new pickup should be thrown
	tossdir = GetThrowVector(Killer, Killed);

	Killed.GetAxes(Killed.Rotation, X,Y,Z);

	// Set the pickup's location to a realistic position outside of the dying pawn's collision cylinder
	Reward.SetLocation( Killed.Location + 0.8 * Killed.CollisionRadius * X + -0.5 * Killed.CollisionRadius * Y );

	// Now apply the throwing velocity to the position of the pickup
	Reward.velocity = tossdir;

	// Since we are spawning this pickup on the server only, tweak the pickup's replication-related properties
	// so that the new pickup appears for clients
	Reward.InitDrop(Killed.UDamageTime - Level.TimeSeconds);
}

// based from the way weapons are thrown when a player dies ( see Pawn.Died() )
function vector GetThrowVector( Controller Killer, xPawn Killed )
{
	local vector v;

	if ( Killer == None || Killed == None )
		return v;

	// Get a vector indicating direction the dying pawn was looking
    v = Vector(Killed.GetViewRotation());

	// Adding coordinates to the directional vector
    v = v *

	// Clamp the "aiming spot" to a point that is in the dying pawn's point of view (I think)
	((Killed.Velocity Dot v)

	// this controls how far away we're aiming for
	+ 100) +

	// And this controls how high to aim the throw
	Vect(0,0,200);


    return v;
}

defaultproperties
{
}

//==============================================================================
//  Created on: 12/29/2003
//  A UDamage pickup that has been dropped by a dead player
//  When picked up, gives player any UDamage time that was left when the original player died
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class UDamageReward extends UDamagePack;

var() float FadeTime;

// This is a modified version of InitDroppedPickupFor - since UDamagePacks don't have associated inventory,
// we don't care about that here....but I *do* need to know how much time is remaining to the UDamage charge
function InitDrop( float RemainingCharge )
{
	// This is when the original UDamage time will expire
	FadeTime = RemainingCharge + Level.TimeSeconds;

	// We're falling
	SetPhysics(PHYS_Falling);
	GotoState('FallingPickup');

	// Only need to know about me if I'm in your area
	bAlwaysRelevant = false;

	// set this flag to indicate that this pickup is not on a pickup base (and thus should be destroyed when picked up)
    bDropped = true;

	bIgnoreEncroachers = false; // handles case of dropping stuff on lifts etc
	bIgnoreVehicles = true;

	// Bots care less about pickups with less udamage time remaining
	MaxDesireability *= (RemainingCharge / 30);

	// TODO - what does these do (or why do we need them in dropped pickups)
	NetUpdateFrequency = RemainingCharge;
	bUpdateSimulatedPosition = true;
	bOnlyReplicateHidden = false;
    LifeSpan = RemainingCharge * 2;
}

// Simple overrides that modify the amount of UDamage time given to a pawn that runs over this pickup
auto state Pickup
{
	function Touch( actor Other )
	{
        local Pawn P;
        local float NewTime;

		if ( ValidTouch(Other) )
		{
			NewTime = FadeTime - Level.TimeSeconds;
            P = Pawn(Other);

            // Add this pickup's remaining time to any UDamage time the pawn already had
            if ( xPawn(P) != None )
            	NewTime += Max( xPawn(P).UDamageTime - Level.TimeSeconds, 0);

            P.EnableUDamage(NewTime);
			AnnouncePickup(P);
            SetRespawn();
		}
	}

	function BeginState()
	{
		if ( bDropped )
        {
			AddToNavigation();
		    SetTimer(FadeTime - Level.TimeSeconds, false);
        }
	}
}

state FallingPickup
{
	function BeginState()
	{
		SetTimer(FadeTime - Level.TimeSeconds,false);
	}
}

defaultproperties
{
     RespawnTime=0.000000
}

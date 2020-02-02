//==============================================================================
//  Created on: 12/20/2003
//  All functionality is handled by the game rules class 'UDamageRules'
//  Gamerules cannot appear in mutator lists, however, so I use a mutator class
//  to add my gamerules class to the game
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class MutUDamageReward extends Mutator;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( !bDeleteMe )
		Level.Game.AddGameModifier(Spawn(class'UDamageRules'));
}

defaultproperties
{
     FriendlyName="UDamage Reward"
     Description="Any remaining UDamage powerup is thrown from players when they are fragged."
}

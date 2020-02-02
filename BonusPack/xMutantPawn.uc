// ====================================================================
//  Class: BonusPack.xMutantPawn
//
//  New pawn class. Allows for Mutant skin/particles etc.
//
//  Written by James Golding
//  (c) 2002, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class xMutantPawn extends xPawn;

var				MutantGameReplicationInfo	MutantGRI; // This is so the pawn can know if its the mutant...

var				bool		bMutantEffect;
var         	bool		bOldMutantEffect;

var			    Emitter		MutantFX;

replication
{
	reliable if(Role == ROLE_Authority)
		MutantGRI;
}

// Disable invis combo in mutant game type
//function DoCombo( class<Combo> ComboClass )
//{
//	if( ComboClass == class'XGame.ComboInvis' )
//		return;
//
//	Super.DoCombo( ComboClass );
//}

event PostBeginPlay()
{
	// Send GRI to Pawn
	if(Role == ROLE_Authority && Level.Game != None)
	{
		MutantGRI = MutantGameReplicationInfo(Level.Game.GameReplicationInfo);
	}
}

function MutantDamage()
{
	local bool bAlreadyDead;

	if ( Role < ROLE_Authority )
		return;

	bAlreadyDead = (Health <= 0);

	Health -= 1.0;
	if( bAlreadyDead )
		return;

	if ( Health <= 0 )
	{
		// pawn died
		TearOffMomentum = vect(0, 0, 0);
		Died( None, class'DamTypeMutant', Location);
	}
}

simulated function TickFX(float DeltaTime)
{
	Super.TickFX(DeltaTime);

	// See if there is a mutant, and this is the mutant pawn
	if( MutantGRI.MutantPRI != None && MutantGRI.MutantPRI == PlayerReplicationInfo )
		bMutantEffect = true;
	else
		bMutantEffect = false;

	bScriptPostRender = ((Level.GRI != None) && (PlayerReplicationInfo == MutantGameReplicationInfo(Level.GRI).BottomFeederPRI));
	if(bMutantEffect && !bOldMutantEffect)
	{
		// Spawn funky glowy effect
		MutantFX = Spawn(class'BonusPack.MutantGlow', self, , Location);
		if ( MutantFX != None )
		{
			MutantFX.Emitters[0].SkeletalMeshActor = self;
			MutantFX.SetLocation(Location - vect(0, 0, 49));
			MutantFX.SetRotation(Rotation + rot(0, -16384, 0));
			MutantFX.SetBase(self);
		}
	}
	else if(!bMutantEffect && bOldMutantEffect)
	{
		// Remove funky glowy effect
		if( MutantFX != None )
		{
			MutantFX.Emitters[0].SkeletalMeshActor = None;
			MutantFX.Kill();
			MutantFX = None;
		}
	}

	bOldMutantEffect = bMutantEffect;
}

simulated function Destroyed()
{
    if( MutantFX != None )
	{
		MutantFX.Emitters[0].SkeletalMeshActor = None;
		MutantFX.Kill();
		MutantFX = None;
	}

	Super.Destroyed();
}

defaultproperties
{
     InvisMaterial=FinalBlend'MutantSkins.Shaders.MutantGlowFinal'
}

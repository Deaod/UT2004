class MutBerserk extends Mutator;

auto state startup
{
	function tick(float deltatime)
	{
		local Weapon W;
		local Ammunition A;
		local Vehicle V;

		Level.GRI.WeaponBerserk = 3;
		ForEach DynamicActors(class'Weapon', W)
			W.CheckSuperBerserk();
		ForEach DynamicActors(class'Vehicle', V)
			V.CheckSuperBerserk();
		ForEach DynamicActors(class'Ammunition', A)
			A.AddAmmo(1);
		GotoState('BegunPlay');
	}
}

function ModifyPlayer(Pawn Other)
{
	if ( Other.ShieldStrength < 100 )
		Other.AddShieldStrength(100 - Other.ShieldStrength); 
	Super.ModifyPlayer(Other);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (Vehicle(Other) != None)
	{
		Vehicle(Other).Health *= 2;
		Vehicle(Other).HealthMax *= 2;
	}

	return true;
}

state BegunPlay
{
	ignores tick;
}

defaultproperties
{
     GroupName="Berserk"
     FriendlyName="Super Berserk"
     Description="Weapons are insanely fast and powerful."
}

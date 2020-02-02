class DamTypeDestroyedVehicleRoadKill extends DamageType
	abstract;

defaultproperties
{
     DeathString="A vehicle %k destroyed crushed %o"
     FemaleSuicide="%o couldn't avoid the vehicle she destroyed."
     MaleSuicide="%o couldn't avoid the vehicle he destroyed."
     bLocationalHit=False
     bKUseTearOffMomentum=True
     bNeverSevers=True
     bExtraMomentumZ=False
     GibModifier=2.000000
     GibPerterbation=0.500000
}

class TranslocatorBeacon extends Projectile;

var TranslocatorBeacon NextBeacon;

function PostBeginPlay()
{
	local UnrealMPGameInfo G;
	
	Super.PostBeginPlay();
	if ( !bDeleteMe )
	{
		// add to beacon list
		G = UnrealMPGameInfo(Level.Game);
		if ( G == None )
			return;
		NextBeacon = G.BeaconList;
		G.BeaconList = self;
	}
}

function bool Disrupted()
{
	return false;
}

function Destroyed()
{
	local UnrealMPGameInfo G;
	local TranslocatorBeacon T;

	Super.Destroyed();

	G = UnrealMPGameInfo(Level.Game);
	if ( G == None )
		return;

	// remove from beacon list
	if ( G.BeaconList == self )
		G.BeaconList = NextBeacon;
	else
	{
		for ( T=G.BeaconList; T!=None; T=T.NextBeacon )
		{
			if ( T.NextBeacon == self )
			{
				T.NextBeacon = NextBeacon;
				return;
			}
		}
	}		
}

defaultproperties
{
     LifeSpan=0.000000
}

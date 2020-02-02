//=============================================================================
// xBombDelivery.
// For Bombing Run matches.
//=============================================================================
class xBombDelivery extends GameObjective
	placeable;

#exec OBJ LOAD File=WeaponSounds.uax

var(Team) int Team;
var xBombDeliveryHole MyHole;
var int ExplosionCounter,ExplodeNow,LastExplodeNow;
var() float TouchDownDifficulty;

replication
{
    reliable if( Role==ROLE_Authority )
        ExplodeNow;
}

function bool CanDoubleJump(Pawn Other)
{
	return true;
}

function bool CanMakeJump(Pawn Other, Float JumpHeight, Float GroundSpeed, Int Num, Actor Start, bool bForceCheck)
{
	if ( !bForceCheck && (JumpHeight > Other.JumpZ) && (PhysicsVolume.Gravity.Z >= CalculatedGravityZ[Num]) && (NeededJump[Num].Z < 2 * Other.JumpZ) )
		return true;

	return Super.CanMakeJump(Other,JumpHeight,GroundSpeed,Num,Start,bForceCheck);
}

function float GetDifficulty()
{
	return TouchDownDifficulty;
}

simulated function PostBeginPlay()
{
	local NavigationPoint N;
	
	Super.PostBeginPlay();

	if ( Role == ROLE_Authority )
	{
		DefenderTeamIndex = Team;
		NetUpdateTime = Level.TimeSeconds - 1;

		// spawn my scoring hole
		MyHole = Spawn(class'xBombDeliveryHole',self,,Location,Rotation);
	    
		// check if has shootspots
		for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			if ( (ShootSpot(N) != None) && (ShootSpot(N).TeamNum == Team) )
			{
				bHasShootSpots = true;
				break;
			}
	}		
	SetTeamColors();
}
    
function ScoreEffect(bool touchdown)
{
    ExplodeNow++;
    // spawn some explosions
    PlaySound(sound'WeaponSounds.BExplosion3');
    Spawn(class'NewExplosionA',,,Location+VRand()*Vect(50,50,50));
    ExplosionCounter = 1;    
    SetTimer(0.25,true);
}

simulated function Timer()
{
	PlaySound(sound'WeaponSounds.BExplosion3');
    Spawn(class'NewExplosionA',,,Location+VRand()*Vect(50,50,50));    
    ExplosionCounter++;

    if (ExplosionCounter > 5)
        SetTimer(0.0,false);
}

simulated function SetTeamColors()
{
    if (Team == 0)
    {
        LightHue = 0;
        Skins[1] = Combiner'XGameTextures.superpickups.BombgatePulseRC';
    }
    else
    {
        LightHue = 170;
        Skins[1] = Combiner'XGameTextures.superpickups.BombgatePulseBC';
	}
}

simulated event PostNetReceive()
{
    Super.PostNetReceive();

    if (LastExplodeNow != ExplodeNow)
    {
        LastExplodeNow = ExplodeNow;
        PlaySound(sound'WeaponSounds.BExplosion3');
        Spawn(class'NewExplosionA',,,Location+VRand()*Vect(50,50,50));
        ExplosionCounter = 1;    
        SetTimer(0.25,true);
    }
}

defaultproperties
{
     TouchDownDifficulty=0.500000
     ObjectiveStringSuffix=" Goal"
     bNotBased=True
     bDestinationOnly=True
     LightType=LT_SubtlePulse
     LightEffect=LE_QuadraticNonIncidence
     LightHue=255
     LightSaturation=55
     LightBrightness=255.000000
     LightRadius=6.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XGame_StaticMeshes.GameObjects.BombGate'
     bStatic=False
     bHidden=False
     bDynamicLight=True
     bWorldGeometry=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     NetUpdateFrequency=40.000000
     DrawScale=0.800000
     Skins(0)=Texture'XGameTextures.SuperPickups.BombGate'
     Skins(1)=Combiner'XGameTextures.SuperPickups.BombgatePulseRC'
     bUnlit=True
     SoundRadius=255.000000
     TransientSoundVolume=1.000000
     CollisionRadius=16.000000
     CollisionHeight=16.000000
     bCollideActors=True
     bBlockActors=True
     bProjTarget=True
     bBlockKarma=True
     bNetNotify=True
     bPathColliding=True
}

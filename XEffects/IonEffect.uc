class IonEffect extends Actor;

#exec OBJ LOAD FILE=XEffectMat.utx

var Vector HitLocation, HitNormal;
var IonShaft IonShaft;
var IonLightBeam IonLightBeam;
var IonCore IonCore;
var float StartTime;
var() float DropTime;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        HitLocation, HitNormal;
}

function AimAt(Vector hl, Vector hn)
{
    HitLocation = hl;
    HitNormal = hn;
    if (Level.NetMode != NM_DedicatedServer)
        SpawnEffects();
}

simulated function PostNetBeginPlay()
{
    if (Role < ROLE_Authority)
        SpawnEffects();
}

simulated function SpawnEffects()
{
    IonCore = Spawn(class'IonCore',,, Location, Rotation);
    IonShaft = Spawn(class'IonShaft',,, Location, Rotation);
    IonShaft.mSpawnVecA = Location;
    IonLightBeam = Spawn(class'IonLightBeam',,, Location, Rotation);
    IonLightBeam.mSpawnVecA = HitLocation;
    GotoState('Drop');
}

state Drop
{
    simulated function BeginState()
    {
        StartTime = Level.TimeSeconds;
        SetTimer(DropTime, false);
    }

    simulated function Tick(float dt)
    {
        local float Delta;
        Delta = FMin((Level.TimeSeconds - StartTime) / DropTime, 1.0);
        IonCore.SetLocation(Location*(1.0-Delta) + HitLocation*delta);
        IonShaft.SetLocation(IonCore.Location);
    }

    simulated function Timer()
    {
        local Rotator NormalRot;
        local Actor A;
		
        IonShaft.SetLocation(IonCore.Location);
        IonCore.Destroy();
        IonShaft.mAttenuate = true;
        IonLightBeam.mAttenuate = true;

        if (Abs(HitNormal.Z) < 0.8)
            NormalRot = Rotator(HitLocation - Location);
        else
            NormalRot = Rotator(HitNormal);

       A = Spawn(class'NewIonEffect',,, HitLocation+Vect(0,0,100), Rot(0,16384,0));
       A.RemoteRole = ROLE_None;
       GotoState('');
    }
}

defaultproperties
{
     DropTime=0.500000
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=160
     LightSaturation=140
     LightBrightness=255.000000
     LightRadius=12.000000
     DrawType=DT_None
     bDynamicLight=True
     bNetTemporary=True
     bAlwaysRelevant=True
     bReplicateMovement=False
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=5000.000000
}

class Combo extends Info;

#exec OBJ LOAD FILE=GameSounds.uax

var localized string ExecMessage;
var float AdrenalineCost;
var float Duration;
var Sound ActivateSound;
var Material Icon;
var class<xEmitter> ActivationEffectClass;
var sound ComboAnnouncement; // OBSOLETE
var name ComboAnnouncementName;
var int keys[4];
var class<SpeciesType> species;

// CK_Up      = 1;
// CK_Down    = 2;
// CK_Left    = 4;
// CK_Right   = 8;

function PostBeginPlay()
{
    local xPawn P;

    P = xPawn(Owner);
    if (P == None)
    {
        Destroy();
        return;
    }

    if (ActivateSound != None)
        PlaySound(ActivateSound, SLOT_None, 2*TransientSoundVolume);

    if (ActivationEffectClass != None)
        Spawn(ActivationEffectClass, P,, P.Location, P.Rotation); // it's responsible for killing itself

    StartEffect(P);
}

// called when Adrenaline has been drained empty
function AdrenalineEmpty()
{
    Destroy();
}

function Destroyed()
{
    local xPawn P;
    P = xPawn(Owner);

    if (P != None)
    {
        StopEffect(P);

        if (P.CurrentCombo == self)
            P.CurrentCombo = None;
    }
}

function StartEffect(xPawn P);
function StopEffect(xPawn P);

simulated function Tick(float DeltaTime)
{
    local Pawn P;
    
    P = Pawn(Owner);

    if ( (P == None) || (P.Controller == None) )
	{
        Destroy();
        return;
    }
    if ( (P.Controller.PlayerReplicationInfo != None) && (P.Controller.PlayerReplicationInfo.HasFlag != None) )
		DeltaTime *= 2;
    P.Controller.Adrenaline -= AdrenalineCost*DeltaTime/Duration;
    if (P.Controller.Adrenaline <= 0.0)
    {
        P.Controller.Adrenaline = 0.0;
        Destroy();
    }
}

defaultproperties
{
     AdrenalineCost=100.000000
     Duration=30.000000
     ActivateSound=Sound'GameSounds.Combo.ComboActivated'
     ActivationEffectClass=Class'XEffects.ComboActivation'
}

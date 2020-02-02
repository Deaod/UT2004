class RedeemerWarhead extends Pawn;

#EXEC OBJ LOAD FILE=2K4Hud.utx

var float Damage, DamageRadius, MomentumTransfer;
var class<DamageType> MyDamageType;
var Pawn OldPawn;
var	RedeemerTrail SmokeTrail;
var float YawAccel, PitchAccel;


// banking related
var Shader InnerScopeShader, OuterScopeShader, OuterEdgeShader;
var FinalBlend AltitudeFinalBlend;
var float YawToBankingRatio, BankingResetRate, BankingToScopeRotationRatio;
var int Banking, BankingVelocity, MaxBanking, BankingDamping;

var float VelocityToAltitudePanRate, MaxAltitudePanRate;

// camera shakes //
var() vector ShakeRotMag;           // how far to rot view
var() vector ShakeRotRate;          // how fast to rot view
var() float  ShakeRotTime;          // how much time to rot the instigator's view
var() vector ShakeOffsetMag;        // max view offset vertically
var() vector ShakeOffsetRate;       // how fast to offset view vertically
var() float  ShakeOffsetTime;       // how much time to offset view

var bool	bStaticScreen;
var bool	bFireForce;

var TeamInfo MyTeam;

replication
{
    reliable if (Role == ROLE_Authority && bNetOwner)
        bStaticScreen;

    reliable if ( Role < ROLE_Authority )
		ServerBlowUp;
}

function PlayerChangedTeam()
{
	Died( None, class'DamageType', Location );
	OldPawn.Died(None, class'DamageType', OldPawn.Location);
}

function TeamInfo GetTeam()
{
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.Team;
	return MyTeam;
}

simulated function Destroyed()
{
	RelinquishController();
	if ( SmokeTrail != None )
		SmokeTrail.Destroy();
	Super.Destroyed();
}

simulated function bool IsPlayerPawn()
{
	return false;
}

event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry )
		return true;

	return false;
}

event EncroachedBy( actor Other )
{
	BlowUp(Location);
}

function RelinquishController()
{
	if ( Controller == None )
		return;
	Controller.Pawn = None;
	if ( !Controller.IsInState('GameEnded') )
	{
		if ( (OldPawn != None) && (OldPawn.Health > 0) )
			Controller.Possess(OldPawn);
		else
		{
			if ( OldPawn != None )
				Controller.Pawn = OldPawn;
			else
				Controller.Pawn = self;
			Controller.PawnDied(Controller.Pawn);
		}
	}
	RemoteRole = Default.RemoteRole;
	Instigator = OldPawn;
	Controller = None;
}

simulated function PostBeginPlay()
{
	local vector Dir;

	Dir = Vector(Rotation);
    Velocity = AirSpeed * Dir;
    Acceleration = Velocity;

	if ( Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrail = Spawn(class'RedeemerTrail',self,,Location - 40 * Dir);
		SmokeTrail.SetBase(self);
	}
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if ( PlayerController(Controller) != None )
	{
		Controller.SetRotation(Rotation);
		PlayerController(Controller).SetViewTarget(self);
		Controller.GotoState(LandMovementState);
		PlayOwnedSound(Sound'WeaponSounds.redeemer_shoot',SLOT_Interact,1.0);
	}
}

simulated function FaceRotation( rotator NewRotation, float DeltaTime )
{
}

function UpdateRocketAcceleration(float DeltaTime, float YawChange, float PitchChange)
{
    local vector X,Y,Z;
	local float PitchThreshold;
	local int Pitch;
    local rotator TempRotation;
    local TexRotator ScopeTexRotator;
    local VariableTexPanner AltitudeTexPanner;

	YawAccel = (1-2*DeltaTime)*YawAccel + DeltaTime*YawChange;
	PitchAccel = (1-2*DeltaTime)*PitchAccel + DeltaTime*PitchChange;
	SetRotation(rotator(Velocity));

	GetAxes(Rotation,X,Y,Z);
	PitchThreshold = 3000;
	Pitch = Rotation.Pitch & 65535;
	if ( (Pitch > 16384 - PitchThreshold) && (Pitch < 49152 + PitchThreshold) )
	{
		if ( Pitch > 49152 - PitchThreshold )
			PitchAccel = Max(PitchAccel,0);
		else if ( Pitch < 16384 + PitchThreshold )
			PitchAccel = Min(PitchAccel,0);
	}
	Acceleration = Velocity + 5*(YawAccel*Y + PitchAccel*Z);
	if ( Acceleration == vect(0,0,0) )
		Acceleration = Velocity;

	Acceleration = Normal(Acceleration) * AccelRate;

    BankingVelocity += DeltaTime * (YawToBankingRatio * YawChange - BankingResetRate * Banking - BankingDamping * BankingVelocity);
    Banking += DeltaTime * (BankingVelocity);
    Banking = Clamp(Banking, -MaxBanking, MaxBanking);
	TempRotation = Rotation;
	TempRotation.Roll = Banking;
	SetRotation(TempRotation);
    ScopeTexRotator = TexRotator(OuterScopeShader.Diffuse);
    if (ScopeTexRotator != None)
        ScopeTexRotator.Rotation.Yaw = Rotation.Roll;
    AltitudeTexPanner = VariableTexPanner(Shader(AltitudeFinalBlend.Material).Diffuse);
    if (AltitudeTexPanner != None)
        AltitudeTexPanner.PanRate = FClamp(Velocity.Z * VelocityToAltitudePanRate, -MaxAltitudePanRate, MaxAltitudePanRate);
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
}

simulated function Landed( vector HitNormal )
{
	BlowUp(Location);
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	BlowUp(Location);
}

function UnPossessed()
{
	BlowUp(Location);
}

simulated singular function Touch(Actor Other)
{
	if ( Other.bBlockActors )
		BlowUp(Location);
}

simulated singular function Bump(Actor Other)
{
	if (Other.bBlockActors)
		BlowUp(Location);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType)
{
	if ( (Damage > 0) && ((InstigatedBy == None) || (InstigatedBy.Controller == None) || (Instigator == None) || (Instigator.Controller == None) || !InstigatedBy.Controller.SameTeamAs(Instigator.Controller)) )
	{
		if ( (InstigatedBy == None) || DamageType.Default.bVehicleHit || (DamageType == class'Crushed') )
			BlowUp(Location);
		else
		{
			if ( PlayerController(Controller) != None )
				PlayerController(Controller).PlayRewardAnnouncement('Denied',1, true);
			if ( PlayerController(InstigatedBy.Controller) != None )
				PlayerController(InstigatedBy.Controller).PlayRewardAnnouncement('Denied',1, true);
	 		Spawn(class'SmallRedeemerExplosion');
		    RelinquishController();
		    SetCollision(false,false,false);
		    HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
		    Destroy();
		}
	}
}

function Fire( optional float F )
{
	ServerBlowUp();
	if ( F == 1 )
	{
		OldPawn.Health = -1;
		OldPawn.KilledBy(OldPawn);
	}
}

function ServerBlowUp()
{
	BlowUp(Location);
}

function BlowUp(vector HitLocation)
{
	local Emitter E;

	if ( Role == ROLE_Authority )
	{
		bHidden = true;
        E = Spawn(class'RedeemerExplosion',,, HitLocation - 100 * Normal(Velocity), Rot(0,16384,0));
		if ( Level.NetMode == NM_DedicatedServer )
		{
			E.LifeSpan = 0.7;
		}
		GotoState('Dying');
	}
}

function bool DoJump( bool bUpdating )
{
	return false;
}

singular event BaseChange()
{
}

simulated function DrawHUD(Canvas Canvas)
{
    local float Offset;
    local Plane SavedCM;
    
    SavedCM = Canvas.ColorModulate;
    Canvas.ColorModulate.X = 1;
    Canvas.ColorModulate.Y = 1;
    Canvas.ColorModulate.Z = 1;
    Canvas.ColorModulate.W = 1;
    Canvas.Style = 255;
	Canvas.SetPos(0,0);
	Canvas.DrawColor = class'Canvas'.static.MakeColor(255,255,255);
	if ( bStaticScreen )
		Canvas.DrawTile( Material'ScreenNoiseFB', Canvas.SizeX, Canvas.SizeY, 0.0, 0.0, 512, 512 );
	else if ( !Level.IsSoftwareRendering() )
	{
	    if (Canvas.ClipX >= Canvas.ClipY)
	    {
            Offset = Canvas.ClipX / Canvas.ClipY;
	        Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512 * (1 - Offset), 0, Offset * 512, 512 );
     	    Canvas.SetPos(0.5*Canvas.SizeX,0);
      	    Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 0, -512 * Offset, 512 );
         	Canvas.SetPos(0,0.5* Canvas.SizeY);
            Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512 * (1 - Offset), 512, Offset * 512, -512);
            Canvas.SetPos(0.5*Canvas.SizeX,0.5* Canvas.SizeY);
            Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 512, -512 * Offset, -512 );
            Canvas.SetPos(0, 0);
	        Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512 * (1 - Offset), 0, Offset * 512, 512 );
     	    Canvas.SetPos(0.5* Canvas.SizeX,0);
      	    Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 0, -512 * Offset, 512 );
       	    Canvas.SetPos(0,0.5* Canvas.SizeY);
            Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512 * (1 - Offset), 512, Offset * 512, -512 );
            Canvas.SetPos(0.5* Canvas.SizeX,0.5* Canvas.SizeY);
            Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 512, -512 * Offset, -512 );
            Canvas.SetPos(0.5 * (Canvas.SizeX - Canvas.SizeY), 0);
            Canvas.DrawTile( OuterScopeShader, Canvas.SizeX, Canvas.SizeY, 0, 0, 1024 * Offset, 1024 );
            Canvas.SetPos((512 * (Offset - 1) + 383) * (Canvas.SizeX / (1024 * Offset)), Canvas.SizeY *(451.0/(1024.0)));
            Canvas.DrawTile( AltitudeFinalBlend, Canvas.SizeX / (8 * Offset), Canvas.SizeY / 8, 0, 0, 128, 128);
            Canvas.SetPos((512 * (Offset - 1) + 383 + 2*(512-383) - 128) * (Canvas.SizeX / (1024 * Offset)), Canvas.SizeY *(451.0/1024.0));
            Canvas.DrawTile( AltitudeFinalBlend, Canvas.SizeX / (8 * Offset), Canvas.SizeY / 8, 128, 0, -128, 128);
        }
        else
        {
            Offset = Canvas.ClipY / Canvas.ClipX;
	        Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 0, 512 * (1 - Offset), 512, 512 * Offset);
     	    Canvas.SetPos(0.5*Canvas.SizeX,0);
      	    Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 512 * (1 - Offset), -512, 512 * Offset);
         	Canvas.SetPos(0,0.5* Canvas.SizeY);
            Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 0, 512, 512, -512 * Offset);
            Canvas.SetPos(0.5*Canvas.SizeX,0.5* Canvas.SizeY);
            Canvas.DrawTile( OuterEdgeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 512, -512, -512 * Offset);
            Canvas.SetPos(0, 0);
	        Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 0, 512 * (1 - Offset), 512, 512 * Offset);
     	    Canvas.SetPos(0.5*Canvas.SizeX,0);
      	    Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 512 * (1 - Offset), -512, 512 * Offset);
         	Canvas.SetPos(0,0.5* Canvas.SizeY);
            Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 0, 512, 512, -512 * Offset);
            Canvas.SetPos(0.5*Canvas.SizeX,0.5* Canvas.SizeY);
            Canvas.DrawTile( InnerScopeShader, 0.5 * Canvas.SizeX, 0.5 * Canvas.SizeY, 512, 512, -512, -512 * Offset);
            Canvas.SetPos(0, 0.5 * (Canvas.SizeY - Canvas.SizeX));
            Canvas.DrawTile( OuterScopeShader, Canvas.SizeX, Canvas.SizeY, 0, 0, 1024, 1024 * Offset );
            Canvas.SetPos(Canvas.SizeX * (383.0/1024.0), (512 * (Offset - 1) + 451) * (Canvas.SizeY / (1024 * Offset)));
            Canvas.DrawTile( AltitudeFinalBlend, Canvas.SizeX / 8, Canvas.SizeY / (8 * Offset), 0, 0, 128, 128);
            Canvas.SetPos(Canvas.SizeX * ((383 + 2*(512-383) - 128)) / 1024, (512 * (Offset - 1) + 451) * (Canvas.SizeY / (1024 * Offset)));
            Canvas.DrawTile( AltitudeFinalBlend, Canvas.SizeX / 8, Canvas.SizeY / (8 * Offset), 128, 0, -128, 128);
        }
   	}
   	Canvas.ColorModulate = SavedCM;
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc);

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	BlowUp(Location);
}

function bool CheatWalk()
{
	return false;
}

function bool CheatGhost()
{
	return false;
}

function bool CheatFly()
{
	return false;
}

function ShouldCrouch(bool Crouch) {}

event SetWalking(bool bNewIsWalking) {}

function Suicide()
{
	Blowup(Location);
	if ( (OldPawn != None) && (OldPawn.Health > 0) )
		OldPawn.KilledBy(OldPawn);
}

auto state Flying
{
	function Tick(float DeltaTime)
	{
		if ( !bFireForce && (PlayerController(Controller) != None) )
		{
			bFireForce = true;
			PlayerController(Controller).ClientPlayForceFeedback("FlakCannonAltFire");  // jdf
		}
		if ( (OldPawn == None) || (OldPawn.Health <= 0) )
			BlowUp(Location);
		else if ( Controller == None )
		{
			if ( OldPawn.Controller == None )
				OldPawn.KilledBy(OldPawn);
			BlowUp(Location);
		}
	}
}

state Dying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	function Fire( optional float F ) {}
	function BlowUp(vector HitLocation) {}
	function ServerBlowUp() {}
	function Timer() {}
	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
							Vector momentum, class<DamageType> damageType) {}

    function BeginState()
    {
		bHidden = true;
		bStaticScreen = true;
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		Spawn(class'IonCore',,, Location, Rotation);
		if ( SmokeTrail != None )
			SmokeTrail.Destroy();
		ShakeView();
    }

    function ShakeView()
    {
        local Controller C;
        local PlayerController PC;
        local float Dist, Scale;

        for ( C=Level.ControllerList; C!=None; C=C.NextController )
        {
            PC = PlayerController(C);
            if ( PC != None && PC.ViewTarget != None )
            {
                Dist = VSize(Location - PC.ViewTarget.Location);
                if ( Dist < DamageRadius * 2.0)
                {
                    if (Dist < DamageRadius)
                        Scale = 1.0;
                    else
                        Scale = (DamageRadius*2.0 - Dist) / (DamageRadius);
                    C.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
                }
            }
        }
    }

Begin:
	Instigator = self;
    PlaySound(sound'WeaponSounds.redeemer_explosionsound');
    HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
    Sleep(0.5);
    HurtRadius(Damage, DamageRadius*0.300, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.475, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    RelinquishController();
    HurtRadius(Damage, DamageRadius*0.650, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.825, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);
    Destroy();
}

defaultproperties
{
     Damage=250.000000
     DamageRadius=2000.000000
     MomentumTransfer=200000.000000
     MyDamageType=Class'XWeapons.DamTypeRedeemer'
     InnerScopeShader=Shader'2K4Hud.ZoomFX.RDM_InnerScopeShader'
     OuterScopeShader=Shader'2K4Hud.ZoomFX.RDM_OuterScopeShader'
     OuterEdgeShader=Shader'2K4Hud.ZoomFX.RDM_OuterEdgeShader'
     AltitudeFinalBlend=FinalBlend'2K4Hud.ZoomFX.RDM_AltitudeFinal'
     YawToBankingRatio=60.000000
     BankingResetRate=15.000000
     BankingToScopeRotationRatio=8.000000
     MaxBanking=20000
     BankingDamping=10
     VelocityToAltitudePanRate=0.001750
     MaxAltitudePanRate=10.000000
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     bSimulateGravity=False
     bDirectHitWall=True
     bHideRegularHUD=True
     bSpecialHUD=True
     bNoTeamBeacon=True
     bCanUse=False
     AirSpeed=1000.000000
     AccelRate=2000.000000
     BaseEyeHeight=0.000000
     EyeHeight=0.000000
     LandMovementState="PlayerRocketing"
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=28
     LightBrightness=255.000000
     LightRadius=6.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RedeemerMissile'
     bDynamicLight=True
     bStasis=False
     bReplicateInstigator=True
     bNetInitialRotation=True
     Physics=PHYS_Flying
     NetPriority=3.000000
     AmbientSound=Sound'WeaponSounds.Misc.redeemer_flight'
     DrawScale=0.500000
     AmbientGlow=96
     bGameRelevant=True
     bCanTeleport=False
     SoundRadius=100.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=5000.000000
     CollisionRadius=24.000000
     CollisionHeight=12.000000
     bBlockActors=False
     ForceType=FT_DragAlong
     ForceRadius=100.000000
     ForceScale=5.000000
}

//=============================================================================
// Trigger_ASTurretControlPanel
//=============================================================================
//	Created by Laurent Delayen
//	© 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================
// Specific "Turret Controller" version of the trigger.
// Features default mesh and special effects.
//=============================================================================

class Trigger_ASTurretControlPanel extends Trigger_ASUseAndPossess
	placeable;

#exec obj load file=Dom-Goose.utx

var(MonitorEffects) Material StatusTex[4];

var	byte Status, OldStatus;

var FX_TurretControlPanel_Lights	LightFX;
var FX_DamageSmoke					DamageEffect;

replication
{
	unreliable if ( bNetDirty && (Role==ROLE_Authority) )
		Status;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	// Setup for skin work

	Skins.Length	= 2;
    Skins[0]		= None;
    Skins[1]		= StatusTex[0];

	UpdateCapacity();
}

simulated event Destroyed()
{
	if ( LightFX != None )
		LightFX.Destroy();

	if ( DamageEffect !=None)
    	DamageEffect.Destroy();

	super.Destroyed();
}


event VehicleSpawned()
{
	UpdateCapacity();
}

event VehicleDestroyed()
{
	UpdateCapacity();
}

event VehiclePossessed()
{
	UpdateCapacity();
}

event VehicleUnPossessed()
{
	UpdateCapacity();
}


function UpdateCapacity()
{
	local Vehicle	V;
	local bool		bOldCapacity, bdead;
	local int		i;

	bOldCapacity	= bFullCapacity;
	bFullCapacity	= true;
    bDead			= true;

	// Check if there is a Pawn left to possess...
	for (i=0; i<FactoryList.Length; i++)
	{
		V = FactoryList[i].Child;
        if ( V != None )
        {
        	if ( V.Health>0 && !V.bDeleteMe )
            {
            	bDead = false;
				if ( V.Controller == None || !V.Controller.IsA('PlayerController') )
					bFullCapacity = false;
            }
        }
	}

	if ( bEnabled )
    {
    	if ( !bDead )
        {
        	if ( bOldCapacity != bFullCapacity )
            	NotifyAvailability( !bFullCapacity );
        }
        else
        	ChangeStatus( 1 );	// Dead
    }
    else
    	ChangeStatus( 0 );		// Disabled;

}


/* Called when the controller changes its status from "FULL or DISABLED" to "AVAILABLE" */
event NotifyAvailability( bool bAvailableSpace )
{
	if ( bAvailableSpace )
		TriggerEvent( EventNonFull, Self, None);
	else
		TriggerEvent( EventFull, Self, None);

	if ( bAvailableSpace )
    	ChangeStatus( 2 );		// Has Space
    else
    	ChangeStatus( 3 );		// Full
}

function ChangeStatus(byte NewStatus)
{
	if ( Status == NewStatus )
		return;

	Status = NewStatus;
    if ( Level.NetMode != NM_DedicatedServer )		// Fake replication on a listen server
    	PostNetReceive();
}

simulated function PostNetReceive()
{
	local Rotator	R;
    local vector    v;

	if ( Level.NetMode != NM_DedicatedServer && Status != OldStatus )
    {
    	if ( Status <= 1 )	// Disabled or Dead
        {
			if ( LightFX != None )
			{
           		LightFX.Destroy();
				LightFX = None;
			}

			if ( Status == 1 )
            {
            	V = Location + (vect(40,0,0) << Rotation);
				if ( DamageEffect == None )
					DamageEffect = Spawn(class'FX_DamageSmoke', Self,, V, Rotation);
            }

        }
        else if ( LightFX == None )
        {
			R = Rotation;
			R.Yaw = R.Yaw + 32768;
			LightFX = Spawn(class'FX_TurretControlPanel_Lights',,, Location, R);

			if ( DamageEffect != None )
            	DamageEffect.Destroy();

		}

        if ( Status == 2 )	 // Space Available
		{
			if ( LightFX != None )	
        		LightFX.SetColorGreen();
		}

        if ( Status == 3 )  // Full
		{
			if ( LightFX != None )
        		LightFX.SetColorRed();
		}

		OldStatus	= Status;
		Skins[1]	= StatusTex[Status];

    }
}

function Reset()
{
	super.Reset();

    if ( LightFX != None )
    	LightFX.Destroy();

	if ( DamageEffect != None )
    	DamageEffect.Destroy();

	Status = 0;
	UpdateCapacity();
}



//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     StatusTex(0)=Texture'Engine.BlackTexture'
     StatusTex(1)=Combiner'dom-goose.Anim.monitor-screen'
     StatusTex(2)=Shader'UT2004Weapons.Shaders.PowerPulseShader'
     StatusTex(3)=Shader'UT2004Weapons.Shaders.PowerPulseShaderRed'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AS_Weapons_SM.Turret.TurretPanel'
     bHidden=False
     bOnlyAffectPawns=False
     bReplicateMovement=False
     bSkipActorPropertyReplication=True
     bOnlyDirtyReplication=True
     RemoteRole=ROLE_DumbProxy
     DrawScale=0.500000
     PrePivot=(X=-48.000000,Z=160.000000)
     AmbientGlow=32
     bMovable=False
     CollisionHeight=80.000000
     bCollideWorld=True
     bBlockActors=True
     bBlockKarma=True
     bNetNotify=True
     bEdShouldSnap=True
}

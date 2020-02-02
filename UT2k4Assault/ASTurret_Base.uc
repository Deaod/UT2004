//=============================================================================
// ASTurret_Base
//=============================================================================

class ASTurret_Base extends Actor
	Abstract;

var	float LastUpdateFreq;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	if ( bMovable || (Level.NetMode != NM_DedicatedServer && DrawType == DT_Mesh) )
		SetTimer( 0.02 + FRand()*0.1, false);
}

simulated function UpdateSwivelRotation( Rotator TurretRotation );

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType) 
{
	// Defer damage to Turret...
	if ( Owner.Role == Role_Authority && InstigatedBy != Owner )
	{
		//log("ASTurret_Base::TakeDamage - Deferring damage to Pawn...");
		Owner.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType) ;
	}
}

simulated event Timer()
{
	local float		UpdateFreq;

	UpdateFreq = 0.15;

	// hack to fix a hack :)
	if ( PlayerController(Vehicle(Owner).Controller) != None && PlayerController(Vehicle(Owner).Controller).ViewTarget != Owner )
		Vehicle(Owner).Controller = None;

	if ( Vehicle(Owner).Controller == None || PlayerController(Vehicle(Owner).Controller) == None 
		|| !Vehicle(Owner).IsLocallyControlled() )
	{
		if ( Level.NetMode != NM_DedicatedServer && DrawType == DT_Mesh )
			UpdateOverlay();

		if ( bMovable )
			UpdateSwivelRotation( Owner.Rotation );

		if ( EffectIsRelevant(Location, true) )
			UpdateFreq = 0.02;
		else
			UpdateFreq = 0.1;

		if ( Level.bDropDetail || Level.DetailMode == DM_Low )
			UpdateFreq += 0.02;
	}
	// else Update is performed every frame from ASTurret.UpdateRocketAcceleration()
		
	LastUpdateFreq = UpdateFreq;
	SetTimer( UpdateFreq, false );
}

simulated function UpdateOverlay()
{
	if ( Owner.OverlayMaterial != OverlayMaterial || Owner.OverlayTimer != OverlayTimer )
		SetOverlayMaterial( Owner.OverlayMaterial, Owner.OverlayTimer, false );
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AS_Weapons_SM.Turret.ASTurret_Base'
     bIgnoreEncroachers=True
     RemoteRole=ROLE_None
     DrawScale=5.000000
     AmbientGlow=64
     bMovable=False
     bCollideActors=True
     bBlockActors=True
     bBlockKarma=True
}

//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPowerCoreShield extends Actor;

var Material TeamSkins[2];

//wake up call to fools shooting invalid target
var sound ShieldHitSound;
var float ImmediateWarningEndTime;
var int DamageCounter;
var PlayerController LastDamagedBy;

simulated function SetTeam(byte Team)
{
	ImmediateWarningEndTime = Level.TimeSeconds + 5;
	if (Team < 2)
		Skins[0] = TeamSkins[Team];
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	local PlayerController PC;

	if (Damage <= 0 || EventInstigator == None || EventInstigator.Role < ROLE_Authority)
		return;

	Owner.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
	PC = PlayerController(EventInstigator.Controller);
	if (PC != None)
	{
		if (Level.TimeSeconds < ImmediateWarningEndTime)
			PC.ClientPlaySound(ShieldHitSound);
		else
		{
			if (PC != LastDamagedBy)
			{
				DamageCounter = Damage;
				LastDamagedBy = PC;
			}
			else
				DamageCounter += Damage;
			if (DamageCounter > 200)
			{
				PC.ClientPlaySound(ShieldHitSound);
				DamageCounter -= 200;
			}
		}
	}
}

simulated function bool TeamLink(int TeamNum)
{
	if (Owner != None)
		return Owner.TeamLink(TeamNum);

	return false;
}

simulated function Touch(Actor Other)
{
	if (Projectile(Other) != None)
	{
		TakeDamage(1, Other.Instigator, Other.Location, vect(0,0,0), Projectile(Other).MyDamageType);
		Projectile(Other).Explode(Other.Location, Normal(Other.Velocity));
	}
}

function bool BlocksShotAt(Actor Other)
{
	if ( (Other == Owner) || (Other == ONSPowerCore(Owner).ShootTarget) )
		return false;
	return true;
}

defaultproperties
{
     TeamSkins(1)=FinalBlend'AW-ShieldShaders.Shaders.BlueShieldFinal'
     ShieldHitSound=Sound'ONSVehicleSounds-S.ShieldHit'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AW-ShieldShaders.ONS.EnergonShield'
     bHidden=True
     bStasis=True
     bAcceptsProjectors=False
     bIgnoreEncroachers=True
     RemoteRole=ROLE_None
     DrawScale3D=(X=2.000000,Y=2.000000)
     PrePivot=(Z=-250.000000)
     bMovable=False
     CollisionRadius=215.000000
     CollisionHeight=190.000000
     bProjTarget=True
     bUseCylinderCollision=True
}

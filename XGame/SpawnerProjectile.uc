class SpawnerProjectile extends Projectile;

var xEmitter Trail;
var ProjectileSpawner Spawner;

replication
{
	reliable if( Role==ROLE_Authority )
        Spawner;
}

simulated function Destroyed()
{
    if (Trail != None)
    {   
        if (Trail.mRegen)
            Trail.mRegen = false;
        else
            Trail.Destroy();
    }
	Super.Destroyed();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

    Spawner = ProjectileSpawner(Owner);
    Speed = Spawner.ProjectileSpeed;
    MaxSpeed = Spawner.ProjectileSpeed;
	Velocity = Speed * Vector(Rotation);
    if (Spawner.GravityAffected)
        SetPhysics(PHYS_Falling);

    if (Level.NetMode != NM_DedicatedServer)
    {
        //PostNetBeginPlay();
    }
} 

simulated function PostNetBeginPlay()
{
    if (Spawner == None)
    {
        Destroy();
        return;
    }

    if (Spawner.ProjectileLifeSpan > 0)
        LifeSpan = Spawner.ProjectileLifeSpan;

    if (Spawner.ProjectileMesh != None)
    {
        SetDrawType(DT_Mesh);
        LinkMesh(Spawner.ProjectileMesh);
        SetDrawScale(Spawner.ProjectileMeshScale);
    }

    if (Spawner.TrailEmitter != None)
    {
        Trail = Spawn(Spawner.TrailEmitter, self,, Location, Rotation);
        Trail.RemoteRole = ROLE_None;
        Trail.SetPhysics(PHYS_Trailer);
        Trail.bTrailerSameRotation = true;
    }
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    if (Role == ROLE_Authority && Spawner.DamageRadius == 0 && Spawner.Damage > 0)
    {
        Other.TakeDamage(Spawner.Damage, None, HitLocation, Vect(0,0,0), Spawner.DamageType);
    }

    Explode(HitLocation, Normal(HitLocation-Other.Location));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local xEmitter Exp;

    if (Role == ROLE_Authority && Spawner.DamageRadius > 0 && Spawner.Damage > 0)
    {
        HurtRadius(Spawner.Damage, Spawner.DamageRadius, Spawner.DamageType, 0, HitLocation);
    }

    if (Spawner.ExplosionEmitter != None && Level.NetMode != NM_DedicatedServer)
    {
        Exp = Spawn(Spawner.ExplosionEmitter,,, HitLocation+HitNormal*8, Rotator(HitNormal));
        Exp.RemoteRole = ROLE_None;
    }

	Destroy();
}

simulated function Landed( vector HitNormal )
{
    HitWall( HitNormal, None );
}

defaultproperties
{
     DrawType=DT_None
     LifeSpan=30.000000
}

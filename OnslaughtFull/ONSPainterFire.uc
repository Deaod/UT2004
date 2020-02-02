class ONSPainterFire extends PainterFire;

var class<ONSAutoBomber> BomberClass;
var float MinZDist, MaxZDist;

function bool SpawnBomber(rotator BombDirection)
{
	local vector BomberStart, BomberStart2, BombTargetCenter, HitNormal, Extent, Temp;
	local ONSAutoBomber Bomber;

	BombDirection.Pitch = 0;
	Extent = BomberClass.default.CollisionRadius * vect(1,1,0);
	Extent.Z = BomberClass.default.CollisionHeight;
	if (Weapon.Trace(BombTargetCenter, HitNormal, MarkLocation + MaxZDist * vect(0,0,1), MarkLocation + Extent.Z * vect(0,0,2), false, Extent) == None)
		BombTargetCenter = MarkLocation + MaxZDist * vect(0,0,1);
	BombTargetCenter.Z -= BomberClass.default.CollisionHeight;
	if (VSize(BombTargetCenter - MarkLocation) < MinZDist)
		return false;

	if (Weapon.Trace(BomberStart, HitNormal, BombTargetCenter - vector(BombDirection) * 100000, BombTargetCenter, false, Extent) == None)
		BomberStart = BombTargetCenter - vector(BombDirection) * 100000;
	if (Weapon.Trace(BomberStart2, HitNormal, BombTargetCenter + vector(BombDirection) * 100000, BombTargetCenter, false, Extent) == None)
		BomberStart2 = BombTargetCenter + vector(BombDirection) * 100000;
	if (VSize(BomberStart - BombTargetCenter) < VSize(BomberStart2 - BombTargetCenter))
	{
		Temp = BomberStart;
		BomberStart = BomberStart2;
		BomberStart2 = Temp;
	}

	Bomber = Weapon.spawn(BomberClass, Instigator,, BomberStart, rotator(BombTargetCenter - BomberStart));
	if (Bomber == None)
		return false;
	Bomber.Bomb(BombTargetCenter);
	return true;
}

state Paint
{
    function BeginState()
    {
        IonCannon = None;

        if (Weapon.Role == ROLE_Authority)
        {
            if (Beam == None)
            {
                Beam = Weapon.Spawn(class'PainterBeamEffect', Instigator);
                Beam.bOnlyRelevantToOwner = true;
                Beam.EffectOffset = vect(-25, 35, 14);
            }
            bInitialMark = true;
            bValidMark = false;
            MarkTime = Level.TimeSeconds;
            SetTimer(0.25, true);
        }

        ClientPlayForceFeedback(TAGFireForce);
    }

    function ModeTick(float dt)
    {
        local Vector StartTrace, EndTrace, X,Y,Z;
        local Vector HitLocation, HitNormal;
        local Actor Other;
        local Rotator Aim;

        if (!bIsFiring)
        {
            StopFiring();
        }

        Weapon.GetViewAxes(X,Y,Z);

        // the to-hit trace always starts right in front of the eye
        StartTrace = Instigator.Location + Instigator.EyePosition() + X*Instigator.CollisionRadius;

	Aim = AdjustAim(StartTrace, AimError);
        X = Vector(Aim);
        EndTrace = StartTrace + TraceRange * X;

        Other = Weapon.Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

        if (Other != None && Other != Instigator)
        {
            if ( bDoHit )
            {
                bValidMark = false;

                if (Other.bWorldGeometry)
                {
                    if (VSize(HitLocation - MarkLocation) < 50.0)
                    {
			Instigator.MakeNoise(3.0);
                        if (Level.TimeSeconds - MarkTime > 0.3)
                        {
			    bValidMark = ONSPainter(Weapon).CanBomb(HitLocation, BomberClass.default.CollisionRadius);

			    if (bValidMark)
			    {
                                if (Level.TimeSeconds - MarkTime > PaintDuration && SpawnBomber(Instigator.Rotation))
                                {
				    Instigator.PendingWeapon = None;
                                    Painter(Weapon).ReallyConsumeAmmo(ThisModeNum, 1);
                                    Instigator.Controller.ClientSwitchToBestWeapon();

                                    if (Beam != None)
                                        Beam.SetTargetState(PTS_Aquired);

                                    StopForceFeedback(TAGMarkForce);
                                    ClientPlayForceFeedback(TAGAquiredForce);

                                    StopFiring();
                                }
                                else
                                {
                                    if (!bMarkStarted)
                                    {
					bMarkStarted = true;
					ClientPlayForceFeedback(TAGMarkForce);
				    }
                                }
                            }
                            else
                            {
                                MarkTime = Level.TimeSeconds;
                                bMarkStarted = false;
                                if ( Bot(Instigator.Controller) != None )
                                {
					Instigator.Controller.Focus = Instigator.Controller.Enemy;
					MarkLocation = Bot(Instigator.Controller).Enemy.Location - Bot(Instigator.Controller).Enemy.CollisionHeight * vect(0,0,2);
				}
                            }
                        }
                    }
                    else
                    {
			bAlreadyMarked = true;
                        MarkTime = Level.TimeSeconds;
                        MarkLocation = HitLocation;
                        bValidMark = false;
                        bMarkStarted = false;
                    }
                }
                else
                {
                    MarkTime = Level.TimeSeconds;
                    bValidMark = false;
                    bMarkStarted = false;
                }
                bDoHit = false;
            }

            EndEffect = HitLocation;
        }
        else
        {
            EndEffect = EndTrace;
        }

        Painter(Weapon).EndEffect = EndEffect;

        if (Beam != None)
        {
            Beam.EndEffect = EndEffect;
            if (bValidMark)
                Beam.SetTargetState(PTS_Marked);
            else
                Beam.SetTargetState(PTS_Aiming);
        }
    }
}

defaultproperties
{
     BomberClass=Class'OnslaughtFull.ONSAutoBomber'
     MinZDist=5000.000000
     MaxZDist=10000.000000
     TraceRange=15000.000000
}

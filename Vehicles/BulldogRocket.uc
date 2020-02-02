class BulldogRocket extends SeekingRocketProj;

// Seeks harder than normal homing rockets
simulated function Timer()
{
    local vector ForceDir;
    local float VelMag;

    if ( InitialDir == vect(0,0,0) )
        InitialDir = Normal(Velocity);
    
	Acceleration = vect(0,0,0);
    Super.Timer();
    if ( (Seeking != None) && (Seeking != Instigator) ) 
    {
		// Do normal guidance to target.
		ForceDir = Normal(Seeking.Location - Location);
		
		if( (ForceDir Dot InitialDir) > -0.5 )
		{
			VelMag = VSize(Velocity);
			ForceDir = Normal( (ForceDir * 0.5 * VelMag) + (0.8 * Velocity) );
			Velocity = VelMag * ForceDir;  
			Acceleration += 5 * ForceDir; 
		}

		// Update rocket so it faces in the direction its going.
		SetRotation(rotator(Velocity));
    }
}

defaultproperties
{
}

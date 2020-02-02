class LinkTurretController extends TurretController;


auto state Searching
{
	function ScanRotation()
	{
		local Rotator OldDesired;
		
		if ( ASTurret_LinkTurret(Pawn) == None )
		{
			Super.ScanRotation();
			return;
		}
		
		OldDesired = DesiredRotation;
		DesiredRotation = ASTurret_LinkTurret(Pawn).OriginalRotation;
		DesiredRotation.Yaw = DesiredRotation.Yaw + 8192;
		if ( (DesiredRotation.Yaw & 65535) == (OldDesired.Yaw & 65535) )
			DesiredRotation.Yaw -= 16384;
	}	
}

defaultproperties
{
}

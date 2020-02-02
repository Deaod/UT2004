class ComboMiniMe extends Combo;

function StartEffect(xPawn P)
{
    if (P.Role == ROLE_Authority)
    {
		P.SetDrawscale(0.5 * P.Default.DrawScale);
		P.bCanCrouch = false;
		P.SetCollisionSize(P.CollisionRadius, 0.5*P.CollisionHeight);
		P.BaseEyeheight = 0.8 * P.CollisionHeight;
	}
}

function StopEffect(xPawn P)
{
    if (P.Role == ROLE_Authority)
    {
		P.SetDrawscale(P.Default.DrawScale);
		P.bCanCrouch = P.default.bCanCrouch;
		P.BaseEyeheight = P.Default.BaseEyeheight;
		P.ForceCrouch();
	}
}

defaultproperties
{
     ExecMessage="Pint-sized!"
     ComboAnnouncementName="Pint_sized"
     keys(0)=8
     keys(1)=8
     keys(2)=8
     keys(3)=8
}

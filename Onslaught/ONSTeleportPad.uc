//for node teleporting
class ONSTeleportPad extends Actor
	placeable;

var array<Material> RedSkins, BlueSkins;

function UsedBy(Pawn user)
{
	if (Owner != None)
		Owner.UsedBy(user);
}

simulated function SetTeam(byte Team)
{
	if (Team == 0)
		Skins = RedSkins;
	else if (Team == 1)
		Skins = BlueSkins;
	else
		Skins.length = 0;
}

defaultproperties
{
     RedSkins(0)=Texture'ONSstructureTextures.CoreGroup.PowerNodeTEX'
     RedSkins(1)=FinalBlend'ONSstructureTextures.CoreGroup.powerNodeUpperFLAREredFinal'
     RedSkins(2)=FinalBlend'AW-2004Particles.Energy.BeamHitFinal'
     BlueSkins(0)=Texture'ONSstructureTextures.CoreGroup.PowerNodeTEX'
     BlueSkins(1)=FinalBlend'ONSstructureTextures.CoreGroup.powerNodeUpperFLAREblueFinal'
     BlueSkins(2)=FinalBlend'AW-2004Particles.Energy.BeamHitFinal'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'VMStructures.CoreGroup.BaseNodeSM'
     bStatic=True
     bStasis=True
     bAcceptsProjectors=False
     RemoteRole=ROLE_None
     DrawScale=2.000000
     bCollideActors=True
     bBlockActors=True
     bProjTarget=True
}

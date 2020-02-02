class CrateActor extends Actor;

#exec OBJ LOAD FILE=TowerStatic.usx
#exec OBJ LOAD FILE=Egypt_techmeshes_Epic.usx
#exec OBJ LOAD FILE=HumanoidHardware.usx

function PostBeginPlay()
{
	local Actor OwnerBase;
	local vector HitNormal, HitLocation;
	
	SetBase(Owner);
	if ( Owner.Base != None )
		OwnerBase = Owner.Base;
	else
		OwnerBase = Trace(HitLocation, HitNormal, Owner.Location - vect(0,0,300), Owner.Location, false);

	if ( TerrainInfo(OwnerBase) != None )
		SetTerrainMesh();
	else
		SetIndoorMesh();
}

function SetTerrainMesh()
{
	if ( Level.OutdoorCamouflageMesh == None )
	{
		if ( (Level.Title ~= "Facing Worlds 3") || (Level.Title ~= "Temple Of Anubis") || (Level.Title ~= "Sun Temple") )
		{
			Level.OutdoorCamouflageMesh = StaticMesh'Egypt_techmeshes_Epic.Deco.egypt_techpassagesec6';
			Level.OutdoorMeshDrawScale = 0.8;
		}
		else
		{
			Level.OutdoorCamouflageMesh = StaticMesh'TowerStatic.TowerStoneC';
			Level.OutDoorMeshDrawScale = 0.235;
		}
	}	
	SetStaticMesh(Level.OutdoorCamouflageMesh);
	SetDrawScale(Level.OutDoorMeshDrawScale);
}

function SetIndoorMesh()
{
	if ( Level.IndoorCamouflageMesh == None )
	{
		if ( (Level.Title ~= "Facing Worlds 3") || (Level.Title ~= "Temple Of Anubis") || (Level.Title ~= "Sun Temple") )
		{
			Level.IndoorCamouflageMesh = StaticMesh'Egypt_techmeshes_Epic.Deco.egypt_techpassagesec6';
			Level.IndoorMeshDrawScale = 0.8;
		}			
		else
		{
			Level.IndoorCamouflageMesh = StaticMesh'HumanoidHardware.jribbedcolumn01HA';
			Level.IndoorMeshDrawScale = 0.45;
		}			
	}
	SetStaticMesh(Level.IndoorCamouflageMesh);
	SetDrawScale(Level.IndoorMeshDrawScale);
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'TowerStatic.Rock.TowerStoneC'
     bStasis=True
     bAlwaysZeroBoneOffset=True
     NetUpdateFrequency=10.000000
     DrawScale=0.235000
     bOwnerNoSee=True
     bHardAttach=True
}

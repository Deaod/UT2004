//==============================================================================
//  Created on: 01/30/2004
//  Link between two power nodes
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class PowerLink extends Info;

struct LinkInfo
{
	var ONSPowerCore Node;
	var byte Team, Stage;
};

var LinkInfo Nodes[2];
var color LinkColor[3];
delegate UpdateNode0(ONSPowerCore Node);
delegate UpdateNode1(ONSPowerCore Node);

private function SetNode( ONSPowerCore Node, bool bZero )
{
	local int i;

	if ( bZero )
	{
		i = 0;
		UpdateNode0 = Node.UpdateLinkState;
	}
	else
	{
		i = 1;
		UpdateNode1 = Node.UpdateLinkState;
	}

	Node.UpdateLinkState = UpdateNode;
	Nodes[i].Node = Node;
	Nodes[i].Team = Node.DefenderTeamIndex;
	Nodes[i].Stage = Node.CoreStage;
}

function bool SetNodes( ONSPowerCore A, ONSPowerCore B )
{
	if ( A == None || B == None )
		return False;

	SetNode(A,true);
	SetNode(B,false);

	A.AddPowerLink(B);
	A.PowerCoreReset();
	B.PowerCoreReset();

//	log(Name@"Nodes are now     "$A.Name@"and"@B.Name);
	return True;
}

function GetNodes( out ONSPowerCore A, out ONSPowerCore B )
{
	A = Nodes[0].Node;
	B = Nodes[1].Node;
}

function bool HasNodes( ONSPowerCore A, ONSPowerCore B )
{
	if ( A == None || B == None )
		return false;
	return (A == Nodes[0].Node && B == Nodes[1].Node) || (A == Nodes[1].Node && B == Nodes[0].Node);
}

simulated event Destroyed()
{
	Super.Destroyed();

	UpdateNode0 = None;
	UpdateNode1 = None;

	Nodes[0].Node.RemovePowerLink(Nodes[1].Node);
	Nodes[1].Node.RemovePowerLink(Nodes[0].Node);

	ClearNode(true);
	ClearNode(false);
}

private function ClearNode( bool bZero )
{
	local int i;

	if ( bZero )
		i = 0;
	else i = 1;

	if ( Nodes[i].Node != None )
	{
		Nodes[i].Node.PowerCoreReset();
		Nodes[i].Node.UpdateLinkState = None;
		Nodes[i].Node = None;
	}
}

function UpdateNode( ONSPowerCore Node )
{
	local int i;

	if ( Node == None )
		return;

//	log(Name@"UpdateNode:"@Node.Name@"Team:"$Node.DefenderTeamIndex@"Stage:"$Node.CoreStage);
	if ( Node == Nodes[0].Node )
	{
		i = 0;
		UpdateNode0(Node);
	}
	else if ( Node == Nodes[1].Node )
	{
		i = 1;
		UpdateNode1(Node);
	}
	else return;

	Nodes[i].Team = Min(Node.DefenderTeamIndex,2);
	Nodes[i].Stage = Node.CoreStage;
}

function Render( Canvas C, float ColorPercent, bool bShowDisabledNodes )
{
	local color Color0, Color1, DrawColor;

	if ( C == None || Nodes[0].Node == None || Nodes[1].Node == None )
		return;

	if ( !bShowDisabledNodes && Nodes[0].Stage == 255 || Nodes[1].Stage == 255 )
		return;

	Color0 = LinkColor[Nodes[0].Team];
	Color1 = LinkColor[Nodes[1].Team];

	if ( Nodes[0].Stage == 4 && Nodes[1].Stage == 0 )
		DrawColor = Color1;

	else if ( Nodes[1].Stage == 4 && Nodes[0].Stage == 0 )
		DrawColor = Color0;

	else
	{
		if ( Nodes[0].Stage == 2 || Nodes[0].Stage == 5 )
		{
			Color0 = Color0 * ColorPercent;
			Color1 = Color1 * (1.0 - ColorPercent);
		}

		else if ( Nodes[1].Stage == 2 || Nodes[0].Stage == 5 )
		{
			Color0 = Color0 * (1.0 - ColorPercent);
			Color1 = Color1 * ColorPercent;
		}

		DrawColor = Color0 + Color1;
	}

	class'HUD'.static.StaticDrawCanvasLine(C,
			Nodes[0].Node.HUDLocation.X, Nodes[0].Node.HUDLocation.Y,
			Nodes[1].Node.HUDLocation.X, Nodes[1].Node.HUDLocation.Y,
			DrawColor);
}

defaultproperties
{
     Nodes(0)=(Team=2,Stage=255)
     Nodes(1)=(Team=2,Stage=255)
     LinkColor(0)=(R=255,A=255)
     LinkColor(1)=(B=255,A=255)
     LinkColor(2)=(B=255,G=255,R=255,A=255)
}

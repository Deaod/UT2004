//=============================================================================
// Attract-mode camera points
// Copyright 2001 Digital Extremes - All Rights Reserved.
// Confidential.
//=============================================================================

class AttractCamera extends Keypoint;

var() float ViewAngle;
var() float MinZoomDist;
var() float MaxZoomDist;

defaultproperties
{
     ViewAngle=100.000000
     MinZoomDist=600.000000
     MaxZoomDist=1200.000000
     bStasis=True
}

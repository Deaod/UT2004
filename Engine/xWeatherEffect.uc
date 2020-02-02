//=============================================================================
// xWeatherEffect 
// Copyright 2001 Digital Extremes - All Rights Reserved.
// Confidential.
//=============================================================================

class xWeatherEffect extends Actor
    native
    exportstructs
    placeable;

#exec Texture Import File=Textures\S_Wind.tga Name=S_Wind Mips=Off

struct WeatherPcl
{
    var Vector	Pos;
    var Vector	Vel;
    var float	Life;
    var float	Size;
    var float   HitTime;
    var float	InvLifeSpan;
    var float   DistAtten;
    var byte	frame;
    var byte	Dummy1;
    var byte	Visible;
	var byte	Dummy2;
};

var() enum EWeatherType
{
    WT_Rain,
    WT_Snow,
    WT_Dust,
} WeatherType;

var() int               numParticles;
var transient int       numActive;
var transient Box		box;
var transient Vector    eyePos;
var transient Vector    eyeDir;
var transient Vector    spawnOrigin;
var transient Vector    eyeMoveVec;
var transient float     eyeVel;
var() float             deviation;

var() float             maxPclEyeDist;

var() float		        numCols;
var() float		        numRows;
var transient float		numFrames;
var transient float		texU;
var transient float		texV;

var transient bool      noReference;       // this effect isn't referenced by any volume

var Vector              spawnVecU;
var Vector              spawnVecV;
var() Vector            spawnVel;

var() RangeVector       Position;
var() Range             Speed;
var() Range             Life;
var() Range             Size;
var() Range             EyeSizeClamp;
var(Force) bool bForceAffected;

var transient array<WeatherPcl>	pcl;
var transient array<Volume>     pclBlockers;

defaultproperties
{
     WeatherType=WT_Snow
     numParticles=1024
     deviation=0.400000
     maxPclEyeDist=590.000000
     numCols=4.000000
     numRows=4.000000
     spawnVel=(Z=-1.000000)
     Position=(X=(Min=-300.000000,Max=300.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-100.000000,Max=300.000000))
     Speed=(Min=100.000000,Max=200.000000)
     Life=(Min=3.000000,Max=4.000000)
     Size=(Min=4.000000,Max=5.000000)
     DrawType=DT_Particle
     bNoDelete=True
     bHighDetail=True
     RemoteRole=ROLE_SimulatedProxy
     DrawScale=4.000000
     Style=STY_Translucent
     bUnlit=True
     bGameRelevant=True
}

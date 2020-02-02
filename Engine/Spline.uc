//=============================================================================
// Spline: A simple Hermite Spline for interpolation with position and 
//         velocity continuity.
//=============================================================================

class Spline extends Object
    native;

const mMaxTimes=5;

var vector  SplineA, SplineB, SplineC, SplineD;
var rotator SplineE, SplineF, SplineG, SplineH;
var float   mStartT, mEndT;
var bool    mbInit;
var float   mTime;
var float   maDeltaTimes[mMaxTimes];
var int     mIndex;
var float   mTotalTime;
var bool    mbRotatorSpline;
var int     mCnt;
 
native final simulated function bool   InitSplinePath(float     t0, 
                                                      vector    d0, 
                                                      vector    v0, 
                                                      float     t1, 
                                                      vector    d1, 
                                                      vector    v1);

native final simulated function bool   InitSplineRot( float     t0, 
                                                      rotator   d0, 
                                                      rotator   v0, 
                                                      float     t1, 
                                                      rotator   d1, 
                                                      rotator   v1);

native final simulated function bool   NextSplinePos( float         dt, 
                                                      out vector    d, 
                                                      out vector    v, 
                                                      out vector    a, 
                                                      out float     outdt, 
                                                      optional bool bSmoothDt, 
                                                      optional bool bAccumDeltas); // gam

native final simulated function bool   NextSplineRot( float         dt, 
                                                      out rotator   d, 
                                                      out rotator   v, 
                                                      out rotator   a, 
                                                      out float     outdt, 
                                                      optional bool bSmoothDt, 
                                                      optional bool bAccumDeltas); // gam

defaultproperties
{
}

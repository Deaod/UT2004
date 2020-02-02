class MeshEffect extends Actor
    placeable;

enum InterpStyle
{
    IS_Flat,
    IS_Linear,
    IS_Exp,
    IS_InvExp,
    IS_S
};

struct Interpomatic
{
    var() float Start;
    var() float Mid;
    var() float End;
    var() float InTime;
    var() float OutTime;
    var() InterpStyle InStyle;
    var() InterpStyle OutStyle;
};

var() float LifeTime;
var() Interpomatic FadeInterp;
var() Interpomatic ScaleInterp;

event PostBeginPlay()
{
    LifeSpan = LifeTime;
}

event Tick(float dt)
{
    local float t;
    t = 1.0 - LifeSpan/LifeTime;
    SetDrawScale( InterpInterp(ScaleInterp, t) );
    ScaleGlow = InterpInterp(FadeInterp, t);
    //SetRotation(Rotation + RotationRate*dt);
}

function float InterpInterp(Interpomatic Interp, float t)
{
    if (t < Interp.InTime)
    {
        t = t / Interp.InTime;
        switch (Interp.InStyle)
        {
        case IS_Linear:
            return Lerp(t, Interp.Start, Interp.Mid);
        case IS_Exp:
            return Lerp(t*t*t, Interp.Start, Interp.Mid);
        case IS_InvExp:
            return Lerp(1-(1-t)*(1-t)*(1-t), Interp.Start, Interp.Mid);
        case IS_S:
            return Smerp(t, Interp.Start, Interp.Mid);
        default:
            return Interp.Start;
        }
    }
    else if (t <= Interp.OutTime)
    {
        return Interp.Mid;
    }
    else
    {
        t = (t - Interp.OutTime) / (1.0 - Interp.OutTime);
        switch (Interp.OutStyle)
        {
        case IS_Linear:
            return Lerp(t, Interp.Mid, Interp.End);
        case IS_Exp:
            return Lerp(1-(1-t)*(1-t)*(1-t), Interp.Mid, Interp.End);
        case IS_InvExp:
            return Lerp(t*t*t, Interp.Mid, Interp.End);
        case IS_S:
            return Smerp(t, Interp.Mid, Interp.End);
        default:
            return Interp.Mid;
        }
    }
}

/*const MAX_KEYS = 8;

struct EffectAnimKey
{
    var float Time;
    var float DrawScale;
    var float Alpha;
    var Name  AnimSeq;
    var float AnimSpeed;
    var bool  bAnimLoop;
    var bool  bHidden;
};

var EffectAnimKey Keys[MAX_KEYS];
var int NextKey;
var int NumKeys;
var int Loops;


event PostBeginPlay()
{
    NextKey = -1;
    Timer();
}

event Timer()
{
    NextKey++;
    if (NextKey >= NumKeys)
    {
        if (Loops > 0)
        {
            NextKey = 0;
            Loops--;
        }
        else
        {
            Destroy();
            return;
        }
    }
    DoKey(Keys[NextKey]);
    SetTimer(Keys[NextKey].Time, false);
}

event Tick(float dt)
{
}

function DoKey(EffectAnimKey Key)
{
    SetDrawScale(Key.DrawScale);
    ScaleGlow = Key.Alpha;
    if (Key.AnimSeq != '')
    {
        if (Key.bAnimLoop)
            LoopAnim(Key.AnimSeq, Key.AnimSpeed, 0);
        else
            PlayAnim(Key.AnimSeq, Key.AnimSpeed, 0);
    }
    bHidden = Key.bHidden;
}*/

defaultproperties
{
     Lifetime=1.000000
     FadeInterp=(Mid=1.000000,OutTime=1.000000,InStyle=IS_Linear,OutStyle=IS_Linear)
     ScaleInterp=(Mid=1.000000,OutTime=1.000000,InStyle=IS_Linear,OutStyle=IS_Linear)
}

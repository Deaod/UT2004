// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class CoolImage extends GUIComponent
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

struct native init AnimInfo
{
	var	float cX,cY;							// Current X,Y;
    var float Scale;							// How big is the image
    var float FadeTime,Alpha, TargetAlpha;		// How quick is the fade
    var float ResetDelay;						// How long before it appears again
	var float TravelTime;
};

var() Material 			Image;				// The Material to Render
var array<AnimInfo> 	Anims;
var int					NoAnims;
var float				MaxScale, MinScale;
var	float				MinFadeTime, MaxFadeTime;
var float				MinResetDelay, MaxResetDelay;
var	int					FullAlpha;

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	Super.InitComponent(MyController,MyOwner);

	if (Image==None || NoAnims==0)
    	return;

    Anims.Length = NoAnims;
    for (i=0;i<NoAnims;i++)
		ResetItem(i);
}

function GetPos(float Scale, out float X, out float y)
{

	local float AW, AH;
	
	AW = ActualWidth();
	AH = ActualHeight();

	switch (Rand(2))
    {
    	case 0:		// Left Edge
			X = 0;
            Y = AH * 1.5 * frand();
            if ( y > AH )
            	Y = y - (AH/2);
            break;
        case 1:
        	Y = AH;
            X = AW * 1.5 * frand();
            if ( x>AW )
            	x = x - AW;
            break;
    }
}

function bool DoCollisionTest(int i)
{
	local int j;
    for (j=0;j<NoAnims;j++)
    {
    	if ( j!=i && TestCollision(i,j) )
        	return true;
    }
    return false;
}

function bool TestCollision(int i,int j)
{
    local float w,h,l1,l2,r1,r2,t1,t2,b1,b2;

	w = Image.MaterialUSize();
    h = Image.MaterialVSize();

	l1 = Anims[i].cX;
    t1 = Anims[i].cY;
    r1 = l1 + (W*Anims[i].Scale);
    b1 = t1 + (H*Anims[i].Scale);

    l2 = Anims[j].cX;
    t2 = Anims[j].cY;
    r2 = l2 + (W*Anims[j].Scale);
    b2 = t2 + (H*Anims[j].Scale);

    if (t1 > b2) return false;
    if (t2 > b1) return false;
    if (l1 > r2) return false;
    if (l2 > r1) return false;

	return true;
}
event ResetItem(int i)
{

	local bool Collide;
    local int cnt;

    Anims[i].Scale = MinScale + (frand()*(MaxScale-MinScale));
    Anims[i].FadeTime = MinFadeTime + (frand()*(MaxFadeTime-MinFadeTime));
    Anims[i].ResetDelay = 0; // MinResetDelay + ( frand()*(MaxResetDelay - MinResetDelay));
    Anims[i].TargetAlpha = FullAlpha;
    Anims[i].Alpha = 0;
	Anims[i].TravelTime = 0.25 + (0.25*frand());

	Collide = true;
    while (Collide)
    {
	    GetPos(Anims[i].Scale,Anims[i].cX,Anims[i].cY);
        Collide = DoCollisionTest(i);
		if (Collide)
        {
        	cnt++;
            if (cnt>20)	// Setup for a reset in 1/2 a sec
            {
            	Anims[i].ResetDelay=0.5;
                Anims[i].FadeTime=0;
                Anims[i].Alpha=0;
                Anims[i].TargetAlpha=0;
                Collide = false;
            }
        }
    }

}

defaultproperties
{
}

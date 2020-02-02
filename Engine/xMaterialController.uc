class xMaterialController extends Actor placeable;

var() Material	Target;
var() Material	SwapMaterialA;
var() Material	SwapMaterialB;

var() enum EMatAction
{
	MTA_SwapShaderDiffuse,
	MTA_SwapShaderSelfIllum,
	MTA_SwapShaderSpecular,
	MTA_SwapCombinerMat1,
	MTA_SwapCombinerMat2,
	MTA_NoAction,
} MatTriggerAction;

var() enum EMatTickFunc
{
	MTF_PulseConstantColor,
	MTF_FadeConstantColor,
	MTF_NoAction,
} MatTickFunc;

var() float	MatTickValue;

var transient float tickAccum;
var transient float tickPtA;
var transient float tickPtB;
var transient bool triggerOn;

simulated function float Pulse( float x )
{
	if ( x < 0.5 )
	{
		return 2.0 * ( x * x * (3.0 - 2.0 * x) );
	}
	else
	{
		return 2.0 * (1.0 - ( x * x * (3.0 - 2.0 * x) ));
	}
}

simulated function PostBeginPlay()
{
	tickPtA = 255.0;
	tickPtB = 255.0;
}

simulated function TickConstantColor( ConstantColor cc, float t )
{
	local float f;
    local float alpha;

    tickAccum += t;
    if ( tickAccum >= 1.0 )
	{
        tickAccum = 1.0;
    }

	if ( MatTickFunc == MTF_FadeConstantColor )
	{
		if ( tickAccum >= 1.0 )
		{
			Disable('Tick');
		}
		alpha = tickPtA + tickAccum * ( tickPtB-tickPtA );
	}
	else if ( MatTickFunc == MTF_PulseConstantColor )
	{
        alpha = tickPtA + tickAccum * ( tickPtB-tickPtA );
		f = Level.TimeSeconds * MatTickValue;
		f = f - int(f);
		alpha = Pulse(f) * alpha;
	}

    cc.Color.A = alpha;
	//log("TickConst alpha:" $ alpha );
}

simulated function Tick( float t )
{
	Super.Tick(t);

	if ( MatTickFunc == MTF_NoAction )
		return;
	
	if( Target.IsA('Shader') && Shader(Target).SpecularityMask.IsA('ConstantColor') )
		TickConstantColor( ConstantColor(Shader(Target).SpecularityMask), t );
	else if ( Target.IsA('ConstantColor'))
		TickConstantColor( ConstantColor(Target), t );
}

simulated function ShaderAction( Shader sh )
{
	//log("ShaderAction " $ sh );

	switch( MatTriggerAction )
	{
		case MTA_SwapShaderSpecular:
			sh.Specular = SwapMaterialA;
			break;
	}

}

simulated function CombinerAction( Combiner cb )
{
	//log("CombinerAction " $ cb );

}

simulated event Trigger( Actor Other, Pawn EventInstigator )
{
	local Material	tmp;

	if ( MatTriggerAction == MTA_NoAction )
		return;

	tmp = SwapMaterialA;
	SwapMaterialA = SwapMaterialB;
	SwapMaterialB = tmp;

    triggerOn = !triggerOn;


	if(Target.IsA('Shader'))
	{
		ShaderAction(Shader(Target));
	}
	else if (Target.IsA('Combiner'))
	{
		CombinerAction(Combiner(Target));
	}
	else
	{
		log("Incompatible material in xMaterialTrigger",'Warning');
	}

	if( Target.IsA('Shader') && Shader(Target).SpecularityMask.IsA('ConstantColor') )
	{
        if( triggerOn )
        {
            // fade up
            tickPtA = ConstantColor(Shader(Target).SpecularityMask).Color.A;
			tickPtB = 255.0;
        }
        else
        {
            // fade down
            tickPtA = ConstantColor(Shader(Target).SpecularityMask).Color.A;
			tickPtB = 0.0;
        }
		tickAccum = 0.0;
		switch( MatTickFunc )
		{
			case MTF_FadeConstantColor:
			case MTF_PulseConstantColor:
				Enable('Tick');
				break;
		}
	}
}

defaultproperties
{
     MatTriggerAction=MTA_NoAction
     MatTickValue=1.000000
     bNoDelete=True
     RemoteRole=ROLE_SimulatedProxy
}

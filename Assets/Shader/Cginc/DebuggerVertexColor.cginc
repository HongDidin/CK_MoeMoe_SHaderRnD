#ifndef _MYCGINCLUDE_
#define _MYCGINCLUDE_

#ifdef USE_DEBUGGE
    float _Enable_R;            
    float _Enable_G;            
    float _Enable_B;            
#else
#endif

inline float4 LightingDebuggeVertexColor(Input IN, SurfaceOutput s, fixed3 lightDir, fixed atten)
{
    float4 verColor = IN.color;
    return ss;
}
#endif
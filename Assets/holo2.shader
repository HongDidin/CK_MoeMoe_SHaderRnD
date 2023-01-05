Shader "Custom/holo2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _EmisColor ("EmisColor", Color) = (1,1,1,1)
        _BumpMap ("NormalMap", 2D) = "white" {}
        _FresnelPow("FresnelPow", float) = 3.0
        _ClipingSinSpeed("ClipingSpeed", float) = 1.0
        _RimBrightness("RimMinBrightness", float) = 0.2
        _linePow ("linePow", float) = 30.0
        _lineSpace ("lineSpace", float) = 2.0
        _lineSpeed ("lineSpeed", float) = 2.0

    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf nolight noambient alpha:fade

        sampler2D _BumpMap;

        struct Input
        {
            float2 uv_BumpMap;
            float3 viewDir;
            float3 worldPos;
        };

        fixed4 _Color;
        fixed4 _EmisColor;
        float _FresnelPow;
        float _ClipingSinSpeed;
        float _RimBrightness;
        float _lineSpace;
        float _linePow;
        float _lineSpeed;


        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Emission = _EmisColor.rgb;
            float rim = saturate(dot(o.Normal, IN.viewDir));
            rim = pow(1-rim, _FresnelPow) + pow(frac(IN.worldPos.g * _lineSpace - (_Time.y * _lineSpeed)), _linePow);
            o.Alpha = rim * (sin(_Time.y * _ClipingSinSpeed) * 0.5f + 0.5f + _RimBrightness);
           
        }

        float4 Lightingnolight(SurfaceOutput s, float3 lightDir, float atten)
        {
            return float4(0, 0, 0, s.Alpha);
        }
        ENDCG
    }
    FallBack "Transparent/Diffuse"
}

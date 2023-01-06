Shader "Custom/Warp"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("NormalMap", 2D) = "bump" {}
        _RampTex ("RampTex (RGB)", 2D) = "white" {}
        _RampYaxis ("Ramp_Y_Control", Range(0,1))= 0
        _RampStr ("Ramp_Intensity", Range(0,1))= 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Warp noambient 


        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _RampTex;
        float _RampYaxis;
        float _RampStr;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };


        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }

        float4 LightingWarp ( SurfaceOutput s, float3 lightDir, float atten)
        {

            //ramp
            float ndot1 = dot(s.Normal, lightDir);
            ndot1 = ndot1 * 0.5 + 0.5; //0~1로 바꿔줌.
            float4 ramp = tex2D(_RampTex, float2(ndot1 , _RampYaxis));

            //final
            float4 final;
            final.rgb = lerp(s.Albedo.rgb,s.Albedo.rgb * ramp.rgb,_RampStr);
            final.a = s.Alpha;
            return final;
        }

        ENDCG
    }
    FallBack "Diffuse"
}

Shader "Custom/WarpSpecular"
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

        float4 LightingWarp ( SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)
        {
            float rim = abs(dot(s.Normal, viewDir));
            float3 H = normalize(lightDir + viewDir);
            float spec = saturate(dot(s.Normal, H));//make Phong Specular
            float ndot1 = dot(s.Normal, lightDir) * 0.5 + 0.5; // HalfLanbert
            float4 specRamp = tex2D(_RampTex, float2(ndot1, spec));
            float4 rimRamp = tex2D(_RampTex, float2(ndot1, rim));

            //final
            float4 final;
            final.rgb = (s.Albedo.rgb * specRamp.rgb) + (specRamp.rgb * 0.1) + (rimRamp.rgb * 0.1); //ramp 텍스쳐를 10%정도 더 강하게.
            final.a = s.Alpha;
            return final;

        }

        ENDCG
    }
    FallBack "Diffuse"
}

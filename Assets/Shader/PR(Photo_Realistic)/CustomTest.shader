Shader "Custom/CustomTest"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("NormalMap", 2D) = "bump" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf CustomTest

        sampler2D _MainTex;
        sampler2D _BumpMap;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };


        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            o.Alpha = c.a;
        }
        float4 LightingCustomTest(SurfaceOutput s, float3 lightDir, float atten)
        {
            float ndot1 = dot(s.Normal, lightDir) * 0.5 +0.5;
            //return ndot1;
            //float ndot1 = saturate(dot(s.Normal, lightDir));
            float4 final;
            final.rgb = ndot1 * s.Albedo * _LightColor0.rgb * atten;
            final.a = s.Alpha;
            return final;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

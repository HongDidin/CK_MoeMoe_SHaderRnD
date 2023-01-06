Shader "Custom/FresnelToon"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("NormalMap", 2D) = "bump" {}
        _FresnelPow ("FresnelPow", float) = 1
        _FresnelMul ("FresnelMul", float) = 1

    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }

        //1st pass
        cull back
        CGPROGRAM
       
        #pragma surface surf Toon

        sampler2D _MainTex;
        sampler2D _BumpMap;
        float _FresnelPow;
        float _FresnelMul;

        struct Input
        {
           float2 uv_MainTex;
           float2 uv_BumpMap;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
           // Albedo comes from a texture tinted by color
           fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
           o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
           o.Albedo = c.rgb;
           o.Alpha = c.a;
        }

        float4 LightingToon ( SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)
        {
            
            //fresnel Outline
            float rim = abs(pow(dot(s.Normal, viewDir)*_FresnelMul,_FresnelPow)); //make fresnel
            if (rim > 0.3){
                rim = 1;
            }
            else{
                rim = -1; // -1 value is to make more Deep black to prepare the ambient
            }

            //cell Shading
            float ndot1 = dot(s.Normal, lightDir) * 0.5 + 0.5; // half lambert
            //ndot1 = ceil(ndot1*5)/5;
            if(ndot1 > 0.76) ndot1 = 1;
            else if ( ndot1 > 0.6) ndot1 = 0.35;
            else ndot1 = 0.09;

            //final
            float4 final;
            final.rgb = s.Albedo * ndot1 * _LightColor0.rgb * rim;
            final.a = s.Alpha;

            return final;
        }

        ENDCG
    }
    FallBack "Diffuse"
}

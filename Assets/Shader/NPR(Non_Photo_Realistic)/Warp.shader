Shader "Custom/Warp"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("NormalMap", 2D) = "bump" {}
        _RampTex ("RampTex (RGB)", 2D) = "white" {}
        _RampYaxis ("Ramp_Y_Control", Range(0,1))= 0
        _RampStr ("RampRender_Intensity", Range(0,1))= 1

        _OutlineSize ("OutlineSize", float) = 1.0
        _OutlineColor ("OutlineColor", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        cull front //면을 뒤집음.

        //1st pass
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Nolight vertex:vert noshadow noambient


        sampler2D _MainTex;
        float _OutlineSize;
        float4 _OutlineColor;

        struct Input
        {
            float4 color : COLOR;
            float2 uv_MainTex;
        };

        // appdata_full : is Structure of VertexData (Position, color, tangent, normal texcoord...) 
        void vert( inout appdata_full v)
        {
            v.vertex.xyz = v.vertex.xyz + v.normal.xyz * 0.0005 *_OutlineSize * v.color.a; //VertexColor
        }



        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }

        //Custom Shade Nolight
        float4 LightingNolight ( SurfaceOutput s, float3 lightDir, float atten)
        {
            float4 final;

            //Color
            float3 OutlineColor2;
            OutlineColor2 = _OutlineColor.rgb * s.Albedo.rgb;

            //final
            final.rgb = OutlineColor2;
            final.a = s.Alpha;
            return final;
        }
        ENDCG


        cull back //아웃라인을 위해 뒤집은 면을 다시 되돌림.

        //2nd pass
        CGPROGRAM
        #pragma surface surf Warp noambient 


        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _RampTex;
        float _RampYaxis;
        float _RampStr;

        float _OutlineSize;
        float4 _OutlineColor;

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
            //ramp tex shader
            float ndot1 = dot(s.Normal, lightDir);
            ndot1 = ndot1 * 0.5 + 0.5; //0~1로 바꿔줌. make half lambert
            float4 ramp = tex2D(_RampTex, float2(ndot1 , _RampYaxis));

            //Make ToonLighting 
            float ndot2 = ndot1;//hlafLambert caching
            if(ndot2 > 0.76) ndot2 = 1;
            else if ( ndot2 > 0.6) ndot2 = 0.35;
            else ndot2 = 0.09;
            float4 ToonLighting;
            ToonLighting.rgb = s.Albedo * ndot2 * _LightColor0.rgb;

            //final
            float4 final;
            final.rgb = lerp(ToonLighting.rgb, s.Albedo.rgb * ramp.rgb,_RampStr);
            final.a = s.Alpha;
            return final;
        }

        ENDCG
    }
    FallBack "Diffuse"
}

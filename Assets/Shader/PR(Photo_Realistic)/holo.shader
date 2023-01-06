Shader "Custom/holo"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _EmisColor ("EmisColor", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _ClipingSinSpeed ("ClipingSpeed", float) = 1.0
        _RimPow ("RimPow", float) = 3.0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert noambient alpha:fade

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
        };

        fixed4 _Color;
        fixed4 _EmisColor;
        float _ClipingSinSpeed;
        float _RimPow;


        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            //o.Albedo = c.rgb;
            o.Emission = _EmisColor.rgb;
            float rim = saturate(dot(o.Normal, IN.viewDir));
            rim = pow(1-rim, _RimPow);
            o.Alpha = rim * (sin(_Time.y * _ClipingSinSpeed)*0.5f+0.5f);
           
        }
        ENDCG
    }
    FallBack "Diffuse"
}

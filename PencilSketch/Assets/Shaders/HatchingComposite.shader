// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/HatchingComposite"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Hatch0("Hatch 0 (light)", 2D) = "white" {}
		_Hatch1("Hatch 1", 2D) = "white" {}

	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uvFlipY : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uvFlipY = o.uv;
#if defined(UNITY_UV_STARTS_AT_TOP) && !defined(SHADER_API_MOBILE)
				o.uvFlipY.y = 1.0 - o.uv.y;
#endif
				return o;
			}
			sampler2D _Hatch0;
			sampler2D _Hatch1;

			fixed3 Hatching(float2 _uv, half _intensity)
			{
				half3 hatch0 = tex2D(_Hatch0, _uv).rgb;
				half3 hatch1 = tex2D(_Hatch1, _uv).rgb;

				half3 overbright = max(0, _intensity - 1.0);

				half3 weightsA = saturate((_intensity * 6.0) + half3(-0, -1, -2));
				half3 weightsB = saturate((_intensity * 6.0) + half3(-3, -4, -5));

				weightsA.xy -= weightsA.yz;
				weightsA.z	-= weightsB.x;
				weightsB.xy -= weightsB.yz;

				hatch0 = hatch0 * weightsA;
				hatch1 = hatch1 * weightsB;

				half3 hatching = overbright + hatch0.r +
								 hatch0.g	+ hatch0.b +
								 hatch1.r	+ hatch1.g +
								 hatch1.b;

				return hatching;

			}

			sampler2D _MainTex;
			sampler2D _UVBuffer;
			
			sampler2D _HatchTex1;
			sampler2D _HatchTex2;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				float4 uv = tex2D(_UVBuffer, i.uvFlipY);

				half intensity = dot(col.rgb, float3(0.2326, 0.7152, 0.0722));
				
				fixed3 hatch =  Hatching(uv.xy * 8, intensity);
				
				col.rgb = hatch;
				
				return col;
			}
			ENDCG
		}
	}
}

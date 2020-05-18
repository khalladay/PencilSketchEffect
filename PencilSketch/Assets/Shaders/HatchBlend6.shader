// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unlit/SingleObjectHatch"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Hatch0("Hatch 0", 2D) = "white" {}
		_Hatch1("Hatch 1", 2D) = "white" {}

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
						
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 norm : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 nrm : TEXCOORD1;
				float3 wPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _Hatch0;
			sampler2D _Hatch1;
			float4 _LightColor0;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
				o.nrm = mul(float4(v.norm, 0.0), unity_WorldToObject).xyz;
				o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}


			//this blends between two samples of the texture, to allow for tiling the texture when you zoom in. 
			//the floored_log_dist selects powers of two based on your current distance.
			//I added a min to uv_scale because it looks awful when it tries to select less of the texture when you're far away
			//also likely too expensive to do unless you really need it. 
			fixed3 HatchingConstantScale(float2 _uv, half _intensity, float _dist) // _dist is distance from camera, multiplied by unity_CameraInvProjection[0][0]
			{
				float log2_dist = log2(_dist);
				
				float2 floored_log_dist = floor( (log2_dist + float2(0.0, 1.0) ) * 0.5) *2.0 - float2(0.0, 1.0);				
				float2 uv_scale = min(1, pow(2.0, floored_log_dist));
				
				float uv_blend = abs(frac(log2_dist * 0.5) * 2.0 - 1.0);
				
				

				float2 scaledUVA = _uv / uv_scale.x; // 16
				float2 scaledUVB = _uv / uv_scale.y; // 8 

				half3 hatch0A = tex2D(_Hatch0, scaledUVA).rgb;
				half3 hatch1A = tex2D(_Hatch1, scaledUVA).rgb;

				half3 hatch0B = tex2D(_Hatch0, scaledUVB).rgb;
				half3 hatch1B = tex2D(_Hatch1, scaledUVB).rgb;

				half3 hatch0 = lerp(hatch0A, hatch0B, uv_blend);
				half3 hatch1 = lerp(hatch1A, hatch1B, uv_blend);

				half3 overbright = max(0, _intensity - 1.0);

				half3 weightsA = saturate((_intensity * 6.0) + half3(-0, -1, -2));
				half3 weightsB = saturate((_intensity * 6.0) + half3(-3, -4, -5));

				weightsA.xy -= weightsA.yz;
				weightsA.z -= weightsB.x;
				weightsB.xy -= weightsB.yz;

				hatch0 = hatch0 * weightsA;
				hatch1 = hatch1 * weightsB;

				half3 hatching = overbright + hatch0.r +
					hatch0.g + hatch0.b +
					hatch1.r + hatch1.g +
					hatch1.b;

				return hatching;
			}

			fixed3 Hatching(float2 _uv, half _intensity)
			{
				half3 hatch0 = tex2D(_Hatch0, _uv).rgb;
				half3 hatch1 = tex2D(_Hatch1, _uv).rgb;

				half3 overbright = max(0, _intensity - 1.0);

				half3 weightsA = saturate((_intensity * 6.0) + half3(-0, -1, -2));
				half3 weightsB = saturate((_intensity * 6.0) + half3(-3, -4, -5));

				weightsA.xy -= weightsA.yz;
				weightsA.z -= weightsB.x;
				weightsB.xy -= weightsB.yz;

				hatch0 = hatch0 * weightsA;
				hatch1 = hatch1 * weightsB;

				half3 hatching = overbright + hatch0.r +
					hatch0.g + hatch0.b +
					hatch1.r + hatch1.g +
					hatch1.b;

				return hatching;
			}

			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				fixed3 diffuse = color.rgb * _LightColor0.rgb * dot(_WorldSpaceLightPos0, normalize(i.nrm));

				fixed intensity = dot(diffuse, fixed3(0.2326, 0.7152, 0.0722));

				color.rgb = HatchingConstantScale(i.uv * 3, intensity, distance(_WorldSpaceCameraPos.xyz, i.wPos) * unity_CameraInvProjection[0][0]);
			//	color.rgb = Hatching(i.uv * 8, intensity);

				return color;
			}
			ENDCG
		}
	}
}

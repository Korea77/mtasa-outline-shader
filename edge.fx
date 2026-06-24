texture gTexture0;

sampler sceneTex = sampler_state
{
    Texture = (gTexture0);
};


float2 texelSize = float2(2.0/1920.0, 2.0/1024.0);
float edgeThreshold = 1; 

struct VS_OUTPUT
{
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

float time : TIME;

float4 PS_Main(VS_OUTPUT input) : COLOR
{


    

    float3 center = tex2D(sceneTex, input.Tex).rgb;

    float3 left  = tex2D(sceneTex, input.Tex + float2(-texelSize.x, 0)).rgb;
    float3 right = tex2D(sceneTex, input.Tex + float2(texelSize.x, 0)).rgb;
    float3 up    = tex2D(sceneTex, input.Tex + float2(0, -texelSize.y)).rgb;
    float3 down  = tex2D(sceneTex, input.Tex + float2(0, texelSize.y)).rgb;

    float dx = distance(left, right);
    float dy = distance(up, down);

    float edge = step(edgeThreshold, dx + dy);

    if(input.Tex.x < 0.01 || input.Tex.x > 0.99 || input.Tex.y < 0.01 || input.Tex.y > 0.99) {
        edge = 0;
    }
    
    float r = (sin(time * 2.0) + 1.0) * 0.5;
    float g = (cos(time * 1.5) + 1.0) * 0.5;
    float b = (sin(time * 3.0 + 1.0) + 1.0) * 0.5;

    return float4(r * edge, g * edge, b * edge, edge);

}

technique EdgeDetection
{
    pass P0
    {
        AlphaBlendEnable = true;
        SrcBlend = SrcAlpha;
        DestBlend = InvSrcAlpha;
        PixelShader = compile ps_2_0 PS_Main();
    }
}

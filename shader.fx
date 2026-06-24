
texture SCREEN_RT < string renderTarget = "yes"; >;

float4x4 gWorld : WORLD;
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;

texture gTexture0 < string textureState = "0,Texture"; >;

sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};



int gZEnable<string renderState = "ZENABLE";>;

int gZWriteEnable<string renderState = "ZWRITEENABLE";>;

int gAlphaBlendEnable<string renderState = "ALPHABLENDENABLE";>;

int gAlphaTestEnable<string renderState = "ALPHATESTENABLE";>;


struct VSInput
{
    float3 Position : POSITION0;
    float3 Normal   : NORMAL0;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
};


struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
};


int gLighting<string renderState="LIGHTING";>;float4 gGlobalAmbient<string renderState="AMBIENT";>;int gDiffuseMaterialSource<string renderState="DIFFUSEMATERIALSOURCE";>;int gSpecularMaterialSource<string renderState="SPECULARMATERIALSOURCE";>;int gAmbientMaterialSource<string renderState="AMBIENTMATERIALSOURCE";>;int gEmissiveMaterialSource<string renderState="EMISSIVEMATERIALSOURCE";>;float4 gMaterialAmbient<string materialState="Ambient";>;float4 gMaterialDiffuse<string materialState="Diffuse";>;float4 gMaterialSpecular<string materialState="Specular";>;float4 gMaterialEmissive<string materialState="Emissive";>;float gMaterialSpecPower<string materialState="Power";>;


float4 MTACalcGTABuildingDiffuse( float4 InDiffuse )
{
    float4 OutDiffuse;

    if ( !gLighting )
    {
        OutDiffuse = InDiffuse;
    }
    else
    {
        float4 ambient  = gAmbientMaterialSource  == 0 ? gMaterialAmbient  : InDiffuse;
        float4 diffuse  = gDiffuseMaterialSource  == 0 ? gMaterialDiffuse  : InDiffuse;
        float4 emissive = gEmissiveMaterialSource == 0 ? gMaterialEmissive : InDiffuse;
        OutDiffuse = gGlobalAmbient * saturate( ambient + emissive );
        OutDiffuse.a *= diffuse.a;
    }
    return OutDiffuse;
}


PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    float4 position = float4(VS.Position, 1.0);

    PS.Position = mul(
        position,
        gWorldViewProjection
    );

    PS.TexCoord = VS.TexCoord;

    PS.Diffuse =
        MTACalcGTABuildingDiffuse(VS.Diffuse);

    return PS;
}


struct RTPixel
{
    float4 Screen : COLOR0;
    float4 Target : COLOR1;
};


RTPixel PixelShaderToRT(PSInput PS)
{
    float4 texel =
        tex2D(Sampler0, PS.TexCoord);

    float4 finalColor =
        texel * PS.Diffuse;


    clip(finalColor.a - 0.001);

    RTPixel output;

    output.Screen = float4(1,1,1,1);


    output.Target = float4(1,1,1,1);

    return output;
}



float4 PixelShaderNormal(PSInput PS) : COLOR0
{
    float4 texel =
        tex2D(Sampler0, PS.TexCoord);

    return texel * PS.Diffuse;
}


technique tec
{

    pass P0_RenderToRT
    {
        ZEnable      = false;
        ZWriteEnable = false;

        AlphaBlendEnable = false;
        AlphaTestEnable  = false;


        ColorWriteEnable = 0;


        ColorWriteEnable1 = 15;

        VertexShader =
            compile vs_2_0 VertexShaderFunction();

        PixelShader =
            compile ps_2_0 PixelShaderToRT();
    }



    pass P1_RenderNormal
    {

        ZEnable      = gZEnable;
        ZWriteEnable = gZWriteEnable;

        AlphaBlendEnable = gAlphaBlendEnable;
        AlphaTestEnable  = gAlphaTestEnable;


        ColorWriteEnable = 15;


        ColorWriteEnable1 = 0;

        VertexShader =
            compile vs_2_0 VertexShaderFunction();

        PixelShader =
            compile ps_2_0 PixelShaderNormal();
    }
}
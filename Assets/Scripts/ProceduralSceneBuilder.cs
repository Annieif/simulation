using UnityEngine;
using System.Collections.Generic;

public class ProceduralSceneBuilder : MonoBehaviour
{
    [Header("Scene Dimensions")]
    public Vector3 roomSize = new Vector3(12f, 4f, 10f);
    public Vector3 corridorSize = new Vector3(3.5f, 3f, 24f);
    public float corridorOffset = 10f;

    [Header("Generation Options")]
    public bool addDetails = true;
    public bool addLights = true;

    private Material matDarkMetal;
    private Material matRust;
    private Material matYellowStripe;
    private Material matBlackScreen;
    private Material matEmissiveWarm;
    private Material matEmissiveCool;
    private Material matFloorGrid;
    private Material matGlowingPanel;

    private Transform roomRoot;
    private Transform corridorRoot;

    void Awake()
    {
        SetupRenderSettings();
        CreateMaterials();
        BuildRoom();
        BuildCorridor();
        if (addLights) SetupLighting();
    }

    void SetupRenderSettings()
    {
        // Ensure linear color space for better lighting
        // Note: this only takes effect after editor restart / build
        // but we set ambient here
        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Flat;
        RenderSettings.ambientLight = new Color(0.08f, 0.07f, 0.06f);
        RenderSettings.fog = true;
        RenderSettings.fogMode = FogMode.Exponential;
        RenderSettings.fogDensity = 0.02f;
        RenderSettings.fogColor = new Color(0.05f, 0.04f, 0.03f);
    }

    void CreateMaterials()
    {
        matDarkMetal = CreateMaterial("DarkMetal", new Color(0.18f, 0.15f, 0.12f), 0.7f, 0.4f);
        matRust = CreateMaterial("Rust", new Color(0.35f, 0.18f, 0.08f), 0.4f, 0.3f);
        matBlackScreen = CreateMaterial("BlackScreen", new Color(0.02f, 0.02f, 0.02f), 0.1f, 0.1f);
        matBlackScreen.EnableKeyword("_EMISSION");
        matBlackScreen.SetColor("_EmissionColor", new Color(0.05f, 0.05f, 0.06f) * 0.5f);

        matEmissiveWarm = CreateMaterial("EmissiveWarm", new Color(1f, 0.8f, 0.5f), 0f, 0f);
        matEmissiveWarm.EnableKeyword("_EMISSION");
        matEmissiveWarm.SetColor("_EmissionColor", new Color(1f, 0.7f, 0.3f) * 2.0f);

        matEmissiveCool = CreateMaterial("EmissiveCool", new Color(0.6f, 0.8f, 1f), 0f, 0f);
        matEmissiveCool.EnableKeyword("_EMISSION");
        matEmissiveCool.SetColor("_EmissionColor", new Color(0.4f, 0.6f, 1f) * 1.5f);

        matGlowingPanel = CreateMaterial("GlowingPanel", new Color(0.3f, 0.5f, 0.8f), 0.2f, 0.8f);
        matGlowingPanel.EnableKeyword("_EMISSION");
        matGlowingPanel.SetColor("_EmissionColor", new Color(0.2f, 0.5f, 1f) * 1.2f);

        // Procedural floor grid texture
        Texture2D gridTex = CreateGridTexture(256, 256, new Color(0.15f, 0.13f, 0.11f), new Color(0.22f, 0.19f, 0.16f));
        matFloorGrid = CreateMaterial("FloorGrid", Color.white, 0.6f, 0.5f);
        matFloorGrid.mainTexture = gridTex;

        // Procedural yellow-black stripe texture
        Texture2D stripeTex = CreateStripeTexture(128, 128, Color.yellow, Color.black);
        matYellowStripe = CreateMaterial("YellowStripe", Color.white, 0.3f, 0.3f);
        matYellowStripe.mainTexture = stripeTex;
    }

    Material CreateMaterial(string name, Color color, float metallic, float smoothness)
    {
        Material mat = new Material(Shader.Find("Standard"));
        mat.name = name;
        mat.color = color;
        mat.SetFloat("_Metallic", metallic);
        mat.SetFloat("_Glossiness", smoothness);
        return mat;
    }

    Texture2D CreateGridTexture(int w, int h, Color bg, Color line)
    {
        Texture2D tex = new Texture2D(w, h);
        tex.wrapMode = TextureWrapMode.Repeat;
        tex.filterMode = FilterMode.Bilinear;
        Color[] pixels = new Color[w * h];
        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x++)
            {
                bool isLine = (x % 32 == 0) || (y % 32 == 0);
                bool isSubLine = (x % 16 == 0) || (y % 16 == 0);
                Color c = bg;
                if (isLine) c = Color.Lerp(bg, line, 0.8f);
                else if (isSubLine) c = Color.Lerp(bg, line, 0.25f);
                pixels[y * w + x] = c;
            }
        }
        tex.SetPixels(pixels);
        tex.Apply();
        return tex;
    }

    Texture2D CreateStripeTexture(int w, int h, Color a, Color b)
    {
        Texture2D tex = new Texture2D(w, h);
        tex.wrapMode = TextureWrapMode.Repeat;
        tex.filterMode = FilterMode.Bilinear;
        Color[] pixels = new Color[w * h];
        for (int y = 0; y < h; y++)
        {
            for (int x = 0; x < w; x++)
            {
                // Diagonal stripes
                bool stripe = ((x + y) / 16) % 2 == 0;
                pixels[y * w + x] = stripe ? a : b;
            }
        }
        tex.SetPixels(pixels);
        tex.Apply();
        return tex;
    }

    GameObject CreateBox(string name, Vector3 pos, Vector3 scale, Material mat, Transform parent)
    {
        GameObject go = GameObject.CreatePrimitive(PrimitiveType.Cube);
        go.name = name;
        go.transform.position = pos;
        go.transform.localScale = scale;
        go.GetComponent<Renderer>().material = mat;
        go.transform.SetParent(parent, true);
        return go;
    }

    void BuildRoom()
    {
        roomRoot = new GameObject("Room_Root").transform;
        float w = roomSize.x;
        float h = roomSize.y;
        float d = roomSize.z;
        float halfW = w * 0.5f;
        float halfH = h * 0.5f;
        float halfD = d * 0.5f;

        // Floor (grid of plates)
        int floorDivX = Mathf.RoundToInt(w);
        int floorDivZ = Mathf.RoundToInt(d);
        float plateW = w / floorDivX;
        float plateD = d / floorDivZ;
        for (int x = 0; x < floorDivX; x++)
        {
            for (int z = 0; z < floorDivZ; z++)
            {
                Vector3 pos = new Vector3(
                    -halfW + plateW * 0.5f + x * plateW,
                    0f,
                    -halfD + plateD * 0.5f + z * plateD
                );
                Material m = ((x + z) % 2 == 0) ? matFloorGrid : matDarkMetal;
                GameObject plate = CreateBox($"FloorPlate_{x}_{z}", pos, new Vector3(plateW * 0.98f, 0.1f, plateD * 0.98f), m, roomRoot);
            }
        }

        // Ceiling
        CreateBox("Ceiling", new Vector3(0, h, 0), new Vector3(w + 0.2f, 0.1f, d + 0.2f), matDarkMetal, roomRoot);

        // Ceiling beams
        int beamCount = 4;
        for (int i = 0; i < beamCount; i++)
        {
            float z = -halfD + (d / (beamCount - 1)) * i;
            CreateBox($"CeilingBeam_{i}", new Vector3(0, h - 0.15f, z), new Vector3(w, 0.2f, 0.15f), matRust, roomRoot);
        }

        // Back wall (with large screen)
        BuildRoomBackWall(w, h, d, halfW, halfH, halfD);

        // Front wall (opposite screen, with corridor entrance)
        BuildRoomFrontWall(w, h, d, halfW, halfH, halfD);

        // Left wall (with panels/pipes)
        BuildRoomLeftWall(w, h, d, halfW, halfH, halfD);

        // Right wall
        BuildRoomRightWall(w, h, d, halfW, halfH, halfD);

        if (addDetails)
        {
            BuildRoomDetails(w, h, d, halfW, halfH, halfD);
        }
    }

    void BuildRoomBackWall(float w, float h, float d, float halfW, float halfH, float halfD)
    {
        float wallThick = 0.2f;
        float zBack = -halfD - wallThick * 0.5f;

        // Main back wall segments (left and right of screen)
        float screenWidth = w * 0.6f;
        float screenHeight = h * 0.55f;
        float screenBottom = h * 0.35f;

        float leftWallWidth = (w - screenWidth) * 0.5f - 0.1f;
        float rightWallWidth = leftWallWidth;

        // Left segment
        CreateBox("BackWall_Left", new Vector3(-halfW + leftWallWidth * 0.5f, halfH, zBack),
            new Vector3(leftWallWidth, h, wallThick), matDarkMetal, roomRoot);
        // Right segment
        CreateBox("BackWall_Right", new Vector3(halfW - rightWallWidth * 0.5f, halfH, zBack),
            new Vector3(rightWallWidth, h, wallThick), matDarkMetal, roomRoot);
        // Top segment
        float topHeight = h - (screenBottom + screenHeight) - 0.1f;
        CreateBox("BackWall_Top", new Vector3(0, screenBottom + screenHeight + topHeight * 0.5f + 0.05f, zBack),
            new Vector3(screenWidth + 0.2f, topHeight, wallThick), matDarkMetal, roomRoot);
        // Bottom segment
        CreateBox("BackWall_Bottom", new Vector3(0, screenBottom * 0.5f - 0.05f, zBack),
            new Vector3(screenWidth + 0.2f, screenBottom - 0.1f, wallThick), matDarkMetal, roomRoot);

        // Screen frame
        float frameThick = 0.25f;
        CreateBox("ScreenFrame", new Vector3(0, screenBottom + screenHeight * 0.5f, zBack + 0.05f),
            new Vector3(screenWidth + frameThick, screenHeight + frameThick, 0.15f), matRust, roomRoot);

        // Screen surface
        GameObject screen = CreateBox("BigScreen", new Vector3(0, screenBottom + screenHeight * 0.5f, zBack + 0.12f),
            new Vector3(screenWidth, screenHeight, 0.05f), matBlackScreen, roomRoot);

        // Yellow-black caution stripe below screen
        float stripeY = screenBottom - 0.25f;
        CreateBox("CautionStripe", new Vector3(0, stripeY, zBack + 0.15f),
            new Vector3(screenWidth + 0.4f, 0.3f, 0.05f), matYellowStripe, roomRoot);

        // Console under screen
        float consoleDepth = 1.2f;
        float consoleHeight = 0.9f;
        Vector3 consolePos = new Vector3(0, consoleHeight * 0.5f, zBack + consoleDepth * 0.5f + 0.3f);
        CreateBox("MainConsole", consolePos, new Vector3(screenWidth * 0.7f, consoleHeight, consoleDepth), matDarkMetal, roomRoot);

        // Console glowing panels
        CreateBox("ConsolePanel_Left", consolePos + new Vector3(-screenWidth * 0.2f, consoleHeight * 0.3f, consoleDepth * 0.5f + 0.01f),
            new Vector3(0.4f, 0.25f, 0.02f), matGlowingPanel, roomRoot);
        CreateBox("ConsolePanel_Right", consolePos + new Vector3(screenWidth * 0.2f, consoleHeight * 0.3f, consoleDepth * 0.5f + 0.01f),
            new Vector3(0.4f, 0.25f, 0.02f), matGlowingPanel, roomRoot);
    }

    void BuildRoomFrontWall(float w, float h, float d, float halfW, float halfH, float halfD)
    {
        float wallThick = 0.2f;
        float zFront = halfD + wallThick * 0.5f;
        float doorWidth = corridorSize.x + 0.2f;
        float doorHeight = corridorSize.y;

        float sideWidth = (w - doorWidth) * 0.5f - 0.1f;
        // Left side
        CreateBox("FrontWall_Left", new Vector3(-halfW + sideWidth * 0.5f, halfH, zFront),
            new Vector3(sideWidth, h, wallThick), matDarkMetal, roomRoot);
        // Right side
        CreateBox("FrontWall_Right", new Vector3(halfW - sideWidth * 0.5f, halfH, zFront),
            new Vector3(sideWidth, h, wallThick), matDarkMetal, roomRoot);
        // Top
        float topH = h - doorHeight - 0.1f;
        CreateBox("FrontWall_Top", new Vector3(0, doorHeight + topH * 0.5f + 0.05f, zFront),
            new Vector3(doorWidth + 0.2f, topH, wallThick), matDarkMetal, roomRoot);

        // Door frame
        float frameThick = 0.15f;
        CreateBox("DoorFrame", new Vector3(0, doorHeight * 0.5f, zFront + 0.05f),
            new Vector3(doorWidth + frameThick, doorHeight + frameThick, 0.15f), matRust, roomRoot);
    }

    void BuildRoomLeftWall(float w, float h, float d, float halfW, float halfH, float halfD)
    {
        float wallThick = 0.2f;
        float xLeft = -halfW - wallThick * 0.5f;

        CreateBox("LeftWall", new Vector3(xLeft, halfH, 0), new Vector3(wallThick, h, d), matDarkMetal, roomRoot);

        // Vertical ribs/pipes
        int ribCount = 5;
        for (int i = 0; i < ribCount; i++)
        {
            float z = -halfD + (d / (ribCount - 1)) * i;
            CreateBox($"LeftRib_{i}", new Vector3(xLeft + 0.1f, halfH, z), new Vector3(0.15f, h * 0.95f, 0.1f), matRust, roomRoot);
        }

        // Equipment boxes
        float[] boxZ = new float[] { -halfD + 1.5f, -halfD + 3.5f, halfD - 1.5f };
        for (int i = 0; i < boxZ.Length; i++)
        {
            Vector3 pos = new Vector3(xLeft + 0.3f, h * 0.3f, boxZ[i]);
            CreateBox($"LeftBox_{i}", pos, new Vector3(0.5f, h * 0.6f, 0.8f), matDarkMetal, roomRoot);
            // Small glowing indicator
            CreateBox($"LeftBoxIndicator_{i}", pos + new Vector3(0.26f, 0.1f, 0.2f),
                new Vector3(0.05f, 0.08f, 0.08f), matEmissiveWarm, roomRoot);
        }
    }

    void BuildRoomRightWall(float w, float h, float d, float halfW, float halfH, float halfD)
    {
        float wallThick = 0.2f;
        float xRight = halfW + wallThick * 0.5f;

        CreateBox("RightWall", new Vector3(xRight, halfH, 0), new Vector3(wallThick, h, d), matDarkMetal, roomRoot);

        int ribCount = 5;
        for (int i = 0; i < ribCount; i++)
        {
            float z = -halfD + (d / (ribCount - 1)) * i;
            CreateBox($"RightRib_{i}", new Vector3(xRight - 0.1f, halfH, z), new Vector3(0.15f, h * 0.95f, 0.1f), matRust, roomRoot);
        }
    }

    void BuildRoomDetails(float w, float h, float d, float halfW, float halfH, float halfD)
    {
        // Floor edge trims
        CreateBox("FloorTrim_Back", new Vector3(0, 0.05f, -halfD - 0.05f), new Vector3(w + 0.4f, 0.1f, 0.1f), matRust, roomRoot);
        CreateBox("FloorTrim_Front", new Vector3(0, 0.05f, halfD + 0.05f), new Vector3(w + 0.4f, 0.1f, 0.1f), matRust, roomRoot);
        CreateBox("FloorTrim_Left", new Vector3(-halfW - 0.05f, 0.05f, 0), new Vector3(0.1f, 0.1f, d + 0.4f), matRust, roomRoot);
        CreateBox("FloorTrim_Right", new Vector3(halfW + 0.05f, 0.05f, 0), new Vector3(0.1f, 0.1f, d + 0.4f), matRust, roomRoot);

        // Wall-mounted lights on left wall
        for (int i = 0; i < 3; i++)
        {
            float z = -halfD + 2f + i * 3f;
            Vector3 pos = new Vector3(-halfW + 0.15f, h * 0.75f, z);
            GameObject lamp = CreateBox($"WallLamp_L_{i}", pos, new Vector3(0.15f, 0.3f, 0.5f), matEmissiveWarm, roomRoot);

            if (addLights)
            {
                GameObject lightObj = new GameObject($"WallLight_L_{i}");
                lightObj.transform.SetParent(roomRoot, false);
                lightObj.transform.position = pos + new Vector3(0.2f, 0, 0);
                Light l = lightObj.AddComponent<Light>();
                l.type = LightType.Point;
                l.color = new Color(1f, 0.75f, 0.45f);
                l.intensity = 1.2f;
                l.range = 6f;
            }
        }
    }

    void BuildCorridor()
    {
        corridorRoot = new GameObject("Corridor_Root").transform;
        float cw = corridorSize.x;
        float ch = corridorSize.y;
        float cd = corridorSize.z;
        float halfCW = cw * 0.5f;
        float halfCH = ch * 0.5f;
        float halfCD = cd * 0.5f;

        // Corridor starts from room front wall
        float startZ = roomSize.z * 0.5f;

        // Floor
        int floorDivX = Mathf.RoundToInt(cw * 2);
        int floorDivZ = Mathf.RoundToInt(cd * 0.5f);
        float plateW = cw / floorDivX;
        float plateD = cd / floorDivZ;
        for (int x = 0; x < floorDivX; x++)
        {
            for (int z = 0; z < floorDivZ; z++)
            {
                Vector3 pos = new Vector3(
                    -halfCW + plateW * 0.5f + x * plateW,
                    0f,
                    startZ + plateD * 0.5f + z * plateD
                );
                Material m = ((x + z) % 2 == 0) ? matFloorGrid : matDarkMetal;
                CreateBox($"CorFloor_{x}_{z}", pos, new Vector3(plateW * 0.98f, 0.1f, plateD * 0.98f), m, corridorRoot);
            }
        }

        // Ceiling
        CreateBox("CorCeiling", new Vector3(0, ch, startZ + cd * 0.5f), new Vector3(cw + 0.1f, 0.1f, cd + 0.1f), matDarkMetal, corridorRoot);

        // Ceiling light strips
        int stripCount = Mathf.RoundToInt(cd / 4f);
        for (int i = 0; i < stripCount; i++)
        {
            float z = startZ + 2f + i * 4f;
            Vector3 pos = new Vector3(0, ch - 0.08f, z);
            GameObject strip = CreateBox($"CeilingStrip_{i}", pos, new Vector3(cw * 0.6f, 0.06f, 0.4f), matEmissiveWarm, corridorRoot);

            if (addLights)
            {
                GameObject lightObj = new GameObject($"StripLight_{i}");
                lightObj.transform.SetParent(corridorRoot, false);
                lightObj.transform.position = pos;
                Light l = lightObj.AddComponent<Light>();
                l.type = LightType.Point;
                l.color = new Color(1f, 0.85f, 0.6f);
                l.intensity = 1.5f;
                l.range = 8f;
            }
        }

        // Left and Right walls with window/door frames
        float wallThick = 0.2f;
        BuildCorridorSideWall(-1, cw, ch, cd, startZ, halfCW, wallThick);
        BuildCorridorSideWall(1, cw, ch, cd, startZ, halfCW, wallThick);

        // Far end wall (bright exit / blocked)
        float farZ = startZ + cd;
        CreateBox("CorFarWall", new Vector3(0, halfCH, farZ + wallThick * 0.5f), new Vector3(cw, ch, wallThick), matDarkMetal, corridorRoot);
        // Bright panel at far end suggesting exit
        CreateBox("FarExitPanel", new Vector3(0, halfCH, farZ + wallThick * 0.5f + 0.05f), new Vector3(cw * 0.5f, ch * 0.5f, 0.05f), matEmissiveCool, corridorRoot);
    }

    void BuildCorridorSideWall(int side, float cw, float ch, float cd, float startZ, float halfCW, float wallThick)
    {
        float x = side * (halfCW + wallThick * 0.5f);
        string sideName = side < 0 ? "Left" : "Right";

        // Main wall segments with window cutouts
        int windowCount = 4;
        float segmentLength = cd / windowCount;
        float windowWidth = cw * 0.5f;
        float windowHeight = ch * 0.5f;
        float windowBottom = ch * 0.25f;

        for (int i = 0; i < windowCount; i++)
        {
            float zCenter = startZ + segmentLength * 0.5f + i * segmentLength;

            // Wall segment before window (if not first)
            // Actually simpler: build around each window
            // Top
            float topH = ch - (windowBottom + windowHeight) - 0.1f;
            CreateBox($"CorWall_{sideName}_Top_{i}", new Vector3(x, windowBottom + windowHeight + topH * 0.5f + 0.05f, zCenter),
                new Vector3(wallThick, topH, segmentLength - 0.1f), matDarkMetal, corridorRoot);
            // Bottom
            CreateBox($"CorWall_{sideName}_Bot_{i}", new Vector3(x, windowBottom * 0.5f - 0.05f, zCenter),
                new Vector3(wallThick, windowBottom - 0.1f, segmentLength - 0.1f), matDarkMetal, corridorRoot);
            // Left of window
            float sideW = (segmentLength - windowWidth) * 0.5f - 0.05f;
            CreateBox($"CorWall_{sideName}_L_{i}", new Vector3(x, halfCW, zCenter - segmentLength * 0.5f + sideW * 0.5f),
                new Vector3(wallThick, ch, sideW), matDarkMetal, corridorRoot);
            // Right of window
            CreateBox($"CorWall_{sideName}_R_{i}", new Vector3(x, halfCW, zCenter + segmentLength * 0.5f - sideW * 0.5f),
                new Vector3(wallThick, ch, sideW), matDarkMetal, corridorRoot);

            // Window frame
            CreateBox($"CorWindowFrame_{sideName}_{i}", new Vector3(x + side * 0.05f, windowBottom + windowHeight * 0.5f, zCenter),
                new Vector3(0.1f, windowHeight + 0.1f, windowWidth + 0.1f), matRust, corridorRoot);

            // Dark interior (black void)
            CreateBox($"CorWindowVoid_{sideName}_{i}", new Vector3(x + side * 0.2f, windowBottom + windowHeight * 0.5f, zCenter),
                new Vector3(0.3f, windowHeight, windowWidth), matBlackScreen, corridorRoot);
        }

        // Vertical ribs on corridor walls
        int ribCount = 6;
        for (int i = 0; i < ribCount; i++)
        {
            float z = startZ + (cd / (ribCount - 1)) * i;
            CreateBox($"CorRib_{sideName}_{i}", new Vector3(x - side * 0.05f, halfCW, z),
                new Vector3(0.1f, ch * 0.9f, 0.08f), matRust, corridorRoot);
        }
    }

    void SetupLighting()
    {
        // Directional light (very dim, moody)
        GameObject dirLightObj = new GameObject("DirectionalLight");
        dirLightObj.transform.rotation = Quaternion.Euler(45f, -30f, 0f);
        Light dirLight = dirLightObj.AddComponent<Light>();
        dirLight.type = LightType.Directional;
        dirLight.color = new Color(0.6f, 0.65f, 0.75f);
        dirLight.intensity = 0.3f;

        // Screen glow light
        GameObject screenLight = new GameObject("ScreenGlow");
        screenLight.transform.position = new Vector3(0, roomSize.y * 0.5f, -roomSize.z * 0.5f + 1.5f);
        Light sl = screenLight.AddComponent<Light>();
        sl.type = LightType.Point;
        sl.color = new Color(0.5f, 0.6f, 0.8f);
        sl.intensity = 1.8f;
        sl.range = 10f;

        // Console area light
        GameObject consoleLight = new GameObject("ConsoleGlow");
        consoleLight.transform.position = new Vector3(0, 1.2f, -roomSize.z * 0.5f + 2f);
        Light cl = consoleLight.AddComponent<Light>();
        cl.type = LightType.Point;
        cl.color = new Color(0.3f, 0.5f, 0.9f);
        cl.intensity = 0.8f;
        cl.range = 4f;
    }
}

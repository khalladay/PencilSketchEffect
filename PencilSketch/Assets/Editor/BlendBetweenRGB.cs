using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

public class BlendBetweenRGB : EditorWindow
{

    private Texture2D[] RGB;
    private float blendVal = 1.0f;

    [MenuItem("Tools/BlendRGB")]
    public static void ShowWindow()
    {
        EditorWindow.GetWindow(typeof(BlendBetweenRGB));
    }

    private void OnGUI()
    {
        if (RGB == null)
        {
            RGB = new Texture2D[2];
        }

        GUI.enabled = true;

        RGB[0] = EditorGUILayout.ObjectField("0: ", RGB[0], typeof(Texture2D), false) as Texture2D;
        RGB[1] = EditorGUILayout.ObjectField("1: ", RGB[1], typeof(Texture2D), false) as Texture2D;
        blendVal = EditorGUILayout.FloatField("Blend", blendVal);

        if (GUILayout.Button("Blend"))
        {
            string outPath = EditorUtility.SaveFilePanel("Where to save", "", "mytexture", "png");

            Texture2D outTex = new Texture2D(RGB[0].width, RGB[0].height, TextureFormat.RGB24, false);
            {
                string fileURL = AssetDatabase.GetAssetPath(RGB[0]);
                byte[] imgByes = File.ReadAllBytes(fileURL);
                Texture2D readableTex = new Texture2D(1, 1, TextureFormat.ARGB32, false);
                readableTex.LoadImage(imgByes);

                string fileURL2 = AssetDatabase.GetAssetPath(RGB[1]);
                byte[] imgByes2 = File.ReadAllBytes(fileURL2);
                Texture2D readableTex2 = new Texture2D(1, 1, TextureFormat.ARGB32, false);
                readableTex2.LoadImage(imgByes2);

                BlendBetween(readableTex, readableTex2, outTex, blendVal);
                outTex.Apply();
            }

            byte[] b = outTex.EncodeToPNG();
            File.WriteAllBytes(outPath, b);
            AssetDatabase.Refresh();
        }
    }

    void BlendBetween(Texture2D src0, Texture2D src1, Texture2D dst, float blend)
    {
        for (int i = 0; i < src0.width; ++i)
        {
            for (int j = 0; j < src0.height; ++j)
            {
                Color s0 = src0.GetPixel(i, j);
                Color s1 = src1.GetPixel(i, j);
                Color output = (s0 * (1.0f - blend)) + (s1 * blend);
                dst.SetPixel(i, j, output);
            }
        }
    }
}

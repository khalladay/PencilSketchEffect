using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class PencilSketchPostEffect : MonoBehaviour
{
    public float bufferScale = 1.0f;
    public LayerMask effectLayer;
    public Shader uvReplacementShader;
    public Material compositeMat;

    private Camera mainCam;
    private int scaledWidth;
    private int scaledHeight;
    private Camera effectCamera;

    void Start ()
    {
        Application.targetFrameRate = 120;
        mainCam = GetComponent<Camera>();

        effectCamera = new GameObject().AddComponent<Camera>();
	}

    private void OnRenderImage(RenderTexture src, RenderTexture dst)
    {
        effectCamera.CopyFrom(mainCam);
        effectCamera.transform.position = transform.position;
        effectCamera.transform.rotation = transform.rotation;
        effectCamera.cullingMask = effectLayer;

        //redner scene into a UV buffer
        RenderTexture uvBuffer = RenderTexture.GetTemporary(scaledWidth, scaledHeight, 24, RenderTextureFormat.ARGBFloat);
        effectCamera.SetTargetBuffers(uvBuffer.colorBuffer, uvBuffer.depthBuffer);
        effectCamera.RenderWithShader(uvReplacementShader, "");

        compositeMat.SetTexture("_UVBuffer", uvBuffer);

        //Composite pass with packed TAMs 
        Graphics.Blit(src, dst, compositeMat);

        RenderTexture.ReleaseTemporary(uvBuffer);
    }

    void Update()
    {
        bufferScale = Mathf.Clamp(bufferScale, 0.0f, 1.0f);
        scaledWidth = (int)(Screen.width * bufferScale);
        scaledHeight = (int)(Screen.height * bufferScale);

    }

}

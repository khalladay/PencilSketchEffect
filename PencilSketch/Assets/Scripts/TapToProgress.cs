using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class TapToProgress : MonoBehaviour {

    public string nextLevel;
    bool fired = false;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        if (Input.GetMouseButtonDown(0) && !fired)
        {
            Debug.Log("BOOGER");
            fired = true;
            SceneManager.LoadScene(nextLevel);
        }
		
	}
}

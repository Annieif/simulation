using UnityEngine;

public class RuntimeBootstrap : MonoBehaviour
{
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    static void Init()
    {
        GameObject go = new GameObject("Bootstrap");
        go.AddComponent<RuntimeBootstrap>();
    }

    void Awake()
    {
        // Build scene procedurally
        GameObject builderObj = new GameObject("SceneBuilder");
        builderObj.AddComponent<ProceduralSceneBuilder>();

        // Create player
        GameObject player = new GameObject("Player");
        player.transform.position = new Vector3(0f, 1.6f, 4f);
        player.AddComponent<CharacterController>();
        player.AddComponent<FirstPersonController>();
    }
}

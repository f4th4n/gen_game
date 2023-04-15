using UnityEngine;
using Jumpa.Player;
using System.Threading.Tasks;
using System;

namespace Jumpa {
    namespace Spawner {
        public class PlayerSpawner : MonoBehaviour {
            public async void Start() {
                /*
                 * BridgeSpawn("{\"id\":2,\"name\":\"test\",\"color\":[1,0,0],\"posX\":3.0,\"posY\":2.0}");

                await WaitOneSecondAsync();
                BridgeDestroy(2);
                */
            }

            private async Task WaitOneSecondAsyncf() {
                await Task.Delay(TimeSpan.FromSeconds(5));
                Debug.Log("Finished waiting.");
            }

            public GameObject PlayerPrefab;

            public void BridgeSpawn(string profileStr) {
                var profileObj = JsonUtility.FromJson<PlayerProfile>(profileStr);

                GameObject player = Instantiate(PlayerPrefab, new Vector3(profileObj.posX, profileObj.posY, 0), Quaternion.identity, transform);
                player.GetComponent<PlayerProfileHandler>().UpdateProfile(profileObj);
                player.name = profileObj.id.ToString();
            }

            public void BridgeDestroy(int playerId) {
                GameObject go = GameObject.Find("Spawner/PlayerSpawner/" + playerId.ToString());
                if (go == null) return;

                Destroy(go);
            }
        }

    }
}
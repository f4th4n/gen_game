using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

namespace Jumpa {
    namespace Player {

        [System.Serializable]
        public class PlayerProfile {
            public int id;
            public string name;
            public List<int> color;
            public float posX = 0;
            public float posY = 0;
        }

        public class PlayerProfileHandler : MonoBehaviour {
            public PlayerProfile playerProfile;

            public void Start() {
                // BridgeUpdateProfile("{\"id\":1,\"name\":\"test\",\"color\":[1,0,0]}");
            }

            public void BridgeUpdateProfile(string profileStr) {
                var profileObj = JsonUtility.FromJson<PlayerProfile>(profileStr);
                UpdateProfile(profileObj);
            }

            public void UpdateProfile(PlayerProfile pp) {
                playerProfile = pp;
                changeName(pp.name);
                List<int> color = playerProfile.color;
                changeColor(color[0], color[1], color[2]);
            }

            private void changeName(string name) {
                TextMeshProUGUI playerName = transform.Find("Canvas/Player Name").GetComponent<TextMeshProUGUI>();
                playerName.SetText(name);
            }

            private void changeColor(float r, float g, float b) {
                SpriteRenderer player = GetComponent<SpriteRenderer>();
                player.color = new Color(r, g, b);
            }
        }
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Runtime.InteropServices;

namespace Jumpa {
    namespace Player {
        public class PlayerMovement : MonoBehaviour {
            public float Speed = 5f;

            [DllImport("__Internal")]
            private static extern void BridgeGetPos(int playerId, float x, float y);

            private Config config;
            private Camera mainCamera;
            private Rigidbody2D rb;
            private DynamicJoystick dynamicJoystickLeft;
            private DynamicJoystick dynamicJoystickRight;

            void Start() {
                mainCamera = Camera.main;
                rb = GetComponent<Rigidbody2D>();

                dynamicJoystickLeft = GameObject.Find("Variable Joystick Left").GetComponent<DynamicJoystick>();
                //dynamicJoystickRight = GameObject.Find("Variable Joystick Right").GetComponent<DynamicJoystick>();

                config = GameObject.Find("Config").GetComponent<Config>();

                // enable/disable joystick gameObject
                Scene scene = SceneManager.GetActiveScene();
                if(!config.IsMobile) {
                    GameObject.Find("Analog Left").SetActive(false);
                    //GameObject.Find("Analog Right").SetActive(false);
                }
            }

            void Update() {
                setDirection();
                setPosition();
            }

            private void setDirection() {
				return;
                Vector3 direction;
                if (config.IsMobile) {
                    direction = new Vector2(dynamicJoystickRight.Horizontal, dynamicJoystickRight.Vertical);
                } else {
                    direction = Input.mousePosition - mainCamera.WorldToScreenPoint(transform.position);
                }
                float angle = Mathf.Atan2(direction.y, direction.x) * Mathf.Rad2Deg;

                if(angle != 0)
                    transform.rotation = Quaternion.AngleAxis(angle - 90, Vector3.forward);
            }

            private void setPosition() {
                Vector3 Movement;
                if (config.IsMobile) {
                    Movement = new Vector3(dynamicJoystickLeft.Horizontal, dynamicJoystickLeft.Vertical, 0);
                } else {
                    Movement = new Vector3(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"), 0);
                }

                Vector3 oldPos = rb.transform.position;

                rb.transform.position += Movement * Speed * Time.deltaTime;

                Vector3 viewPos = mainCamera.WorldToViewportPoint(transform.position);
                if (viewPos.x < 0 || viewPos.x > 1 || viewPos.y < 0 || viewPos.y > 1) {
                    rb.transform.position = oldPos;
                }

                PlayerProfileHandler pp = GetComponent<PlayerProfileHandler>();

#if UNITY_WEBGL && !UNITY_EDITOR
                    Vector2 pos = rb.transform.position;
                    BridgeGetPos(pp.playerProfile.id, pos.x, pos.y);
#endif
            }

            public void BridgeUpdatePos(string ppStr) {
                var pp = JsonUtility.FromJson<PlayerProfile>(ppStr);
                Rigidbody2D rb;

                if (pp.id == -99) { // self
                    rb = GetComponent<Rigidbody2D>();
                } else {
                    GameObject go = GameObject.Find("Spawner/PlayerSpawner/" + pp.id.ToString());
                    if (go == null) return;

                    rb = go.GetComponent<Rigidbody2D>();
                }

                rb.MovePosition(new Vector2(pp.posX, pp.posY));
            }
        }
    }
}

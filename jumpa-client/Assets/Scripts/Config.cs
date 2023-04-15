using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Jumpa.Models;

namespace Jumpa {
    public class Config : MonoBehaviour {
        public bool IgnoreAllBelowValueEditConfigJSONInstead;
        public bool IsMobile;

        void Start() {
            // Load text from a JSON file (Assets/Resources/Config.json)
            string jsonString = Resources.Load<TextAsset>("Config").ToString();
            ConfigModel config = JsonUtility.FromJson<ConfigModel>(jsonString);

            IsMobile = config.IsMobile;

            prepareState();
        }

        private void prepareState() {
            if(!PlayerPrefs.HasKey("level")) {
                PlayerPrefs.SetInt("level", 1);
            }
        }
    }
}


import { NativeModules, Platform } from 'react-native';

const { VerusLightClient } = NativeModules;

export default {
  ...VerusLightClient,
  request: (reqId, method, params) => { // Minor standardization fix due to Java not handling JSON as well as Swift native modules
    return new Promise((resolve, reject) => {
      VerusLightClient.request(reqId, method, params)
      .then(res => {
        if (Platform.OS === 'android') {
          resolve(JSON.parse(res))
        } else {
          resolve(res)
        }
      })
      .catch(err => reject(err))
    })
  }
};

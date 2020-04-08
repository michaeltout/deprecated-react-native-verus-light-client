# react-native-verus-light-client

## Getting started

`$ npm install michaeltout/react-native-verus-light-client#dev --save`

### Mostly automatic installation

`$ react-native link mic
haeltout/react-native-verus-light-client`

## Usage
javascript
`import VerusLightClient from 'react-native-verus-light-client';

## Installation on Android
####Improtant: Do you have Rust installed? Without rust the library will not work

To install this on android, add this package to your package.JSON in dependancies.
make sure that the version is at least: 417f646d73bf2434c1ff64a69569dd068af07502, this commit hash.
once you have yarn installed this. Open properties.gradle. This file you can find in android/settings.gradle. Underneath the rootname line add:

`include ':react-native-verus-light-client'
project(':react-native-verus-light-client').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-verus-light-client/android')
include ':greeting'
project(':greeting').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-verus-light-client/greeting')`

Now it should compile. If you still get the error ':greeting' project not found you have not correctly done the above step. If you get the error 'compactblockprocessor' missing or something like this, it means you don't have rust installed or the arm is missing. If you get a cant find 'react-native-verus-light-cient' error you have probably done something in your settings.gralde in addtion to the step above that is having a spicy interaction with what we are doing.

Have fun with the module.

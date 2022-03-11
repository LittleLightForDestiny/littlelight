Thank you for contributing to Little Light! All suggestions and feature requests are welcome, and a lot better if they come with the workforce needed to make it happen.

Here are some tips to make sure your pull request can be merged smoothly:

1. If you want to add a feature or make some change to Little Light, consider [filing an issue](https://github.com/DestinyItemManager/DIM/issues/new) describing your idea first. This will give the Little Light community a chance to discuss the idea, offer suggestions and pointers, and make sure what you're thinking of fits with the style and direction of Little Light. If you want a more free-form chat, [join our Discord](https://discord.gg/dTKhBD).
2. Resist the temptation to change more than one thing in your PR. Keeping PRs focused on a single change makes them much easier to review and accept. If you want to change multiple things, or clean up/refactor the code, make a new branch and submit those changes as a separate PR.
3. Little Light is written in [Dart](https://www.dartlang.org/) and built in [Flutter](https://www.flutter.io)

## Developer Quick start
<!-- no toc  -->
1. [Install Pre-requisites](#pre-requisites)
2. [Clone](#clone-the-repo)
3. [Get your own API key](#get-your-own-api-key)
4. [Add API credentials](#add-api-credentials)
5. [Download third party libs](#download-third-party-libs)
6. [Run Little Light](#run-little-light-on-a-device-or-simulator)


### Pre-requisites
* Install [Flutter SDK](https://flutter.dev/docs/get-started/install).
* Make sure you're on Flutter's beta channel. To know what channel you're on, run ```flutter channel``` on Terminal/Bash.
* Setup your [favorite code editor](https://flutter.dev/docs/get-started/editor) (I recommend using [VS Code](https://code.visualstudio.com/))

### Clone the repo
```bash
git clone https://github.com/LittleLightForDestiny/LittleLight
```

### Get your own API key:

#### Bungie API
1. Goto [Bungie](https://www.bungie.net/en/Application)
2. Click `Create New App`
3. Enter any application name, and `https://github.com/YourGithubUsername/LittleLight`
4. For `Oauth Client type` select `Confidential`
5. Set your redirect url to `luzinha://littelight/login` (or whatever the IP or hostname is of your dev server)
6. Select all scopes _except_ the Administrate Groups/Clans
7. Leave `Origin Header` empty
8. Copy `assets/_env.example` to `assets/_env` and edit it to match your credentials

#### Google API
1. Goto [Firebase](https://console.firebase.google.com/u/0/) and sign in with a Google account
2. Click `Add Project`
3. Enter any application name, and click continue
   1. Optional: Disable Google Analytics
4. Add an app for Android and/or iOS and/or Web - this depends on what platforms you'll be testing for
5. Enter the details:
   1. Reverse domain name for your package (it doesn't need to be real!)
   2. Any app nickname
6. Download the config file and place it in the following location(s):
   1. Android: `google-services.json` → `./android/app/`
   2. iOS: `GoogleService-Info.plist` → `./ios/Runner/`
   3. Web: copy the JS `firebaseConfig` object into `./web/google-services.js`
7. Android:
   1. Add the following line to `./android/local.properties`
      - `applicationid=reverse.domain.name.from.step.6.1`
   2. Repeat stps 4-6, adding `.debug` to the end of the reverse domain name, and replacing the old `google-services.json` with the new one

### Download Third Party Libs
1. Run `flutter packages get` to download all the libraries used in the project

### Run Little Light on a device or simulator
* Run `flutter run` with a device attached to your computer or an open simulator
or
* Use your editor command to run the app (F5 in Visual Studio Code)
  * You can specify a target device by opening the Command Palette (<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>) and type `device`

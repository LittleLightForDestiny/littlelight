Thank you for contributing to Little Light! All suggestions and feature requests are welcome, and a lot better if they come with the workforce needed to make it happen.

Here are some tips to make sure your pull request can be merged smoothly:

1. If you want to add a feature or make some change to Little Light, consider [filing an issue](https://github.com/DestinyItemManager/DIM/issues/new) describing your idea first. This will give the Little Light community a chance to discuss the idea, offer suggestions and pointers, and make sure what you're thinking of fits with the style and direction of Little Light. If you want a more free-form chat, [join our Discord](https://discord.gg/dTKhBD).
1. Resist the temptation to change more than one thing in your PR. Keeping PRs focused on a single change makes them much easier to review and accept. If you want to change multiple things, or clean up/refactor the code, make a new branch and submit those changes as a separate PR.
1. Little Light is written in [Dart](https://www.dartlang.org/) and built in [Flutter](https://www.flutter.io)

## Developer Quick start

1. [Install Pre-requisites](#pre-requisites)
1. [Clone](#clone-the-repo)
1. [Get your own API key](#get-your-own-api-key)
1. [Add API credentials](#add-api-credentials)
1. [Download third party libs](#download-third-party-libs)
1. [Run Little Light](#run-little-light-on-a-device-or-simulator)


### Pre-requisites

* Install [Flutter SDK](https://flutter.dev/docs/get-started/install).
* Setup your [favorite code editor](https://flutter.dev/docs/get-started/editor) (I recommend using [VS Code](https://code.visualstudio.com/))

### Clone the repo
    git clone https://github.com/LittleLightForDestiny/LittleLight


### Get your own API key:

1. Goto [Bungie](https://www.bungie.net/en/Application)
1. Click `Create New App`
1. Enter any application name, and `https://github.com/YourGithubUsername/LittleLight`
1. For `Oauth Client type` select `Confidential`
1. Set your redirect url to `luzinha://login` (or whatever the IP or hostname is of your dev server)
1. Select all scopes _except_ the Administrate Groups/Clans
1. Leave `Origin Header` empty

### Add API credentials
1. copy ```.env.example``` to ```.env``` and edit it to match your credentials

### Download Third Party Libs
1. run ```flutter packages get``` to download all the librarys used in project


### Run Little Light on a device or simulator
* Run `flutter run` with a device attached to your computer or an open simulator
or
* Use your editor command to run the app (F5 in Visual Studio Code)

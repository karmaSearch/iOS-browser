KARMA for iOS 
===============

KARMA for iOS is based on a fork of the code of "Firefox for iOS".

Download on the [App Store](https://itunes.apple.com/app/firefox-web-browser/id989804926).

This branch (main)
-----------

This branch works with [Xcode 13.0](https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_13/Xcode_13.xip), Swift 5.5 and supports iOS 13 and above.

*Please note:* due to dependency issues, development of Firefox-iOS is currently only supported on Intel based Macs, and not Apple Silicon based Macs.

Please make sure you aim your pull requests in the right direction.

For bug fixes and features for a specific release, use the version branch.

Building the code
-----------------

1. Install the latest [Xcode developer tools](https://developer.apple.com/xcode/downloads/) from Apple.
1. Install Carthage, Node, and a Python 3 virtualenv for localization scripts:
    ```shell
    brew update
    brew install carthage
    brew install node
    pip3 install virtualenv
    ```
1. Clone the repository:
    ```shell
    git clone https://github.com/karmaSearch/iOS-browser/
    ```
1. Pull in the project dependencies:
    ```shell
    cd iOS-browser
    sh ./bootstrap.sh
    ```
1. Open `Client.xcodeproj` in Xcode.
1. Build the `Karma` scheme in Xcode.

Building User Scripts
-----------------

User Scripts (JavaScript injected into the `WKWebView`) are compiled, concatenated, and minified using [webpack](https://webpack.js.org/). User Scripts to be aggregated are placed in the following directories:

```none
/Client
|-- /Frontend
    |-- /UserContent
        |-- /UserScripts
            |-- /AllFrames
            |   |-- /AtDocumentEnd
            |   |-- /AtDocumentStart
            |-- /MainFrame
                |-- /AtDocumentEnd
                |-- /AtDocumentStart
```

This reduces the total possible number of User Scripts down to four. The compiled output from concatenating and minifying the User Scripts placed in these folders resides in `/Client/Assets` and are named accordingly:

* `AllFramesAtDocumentEnd.js`
* `AllFramesAtDocumentStart.js`
* `MainFrameAtDocumentEnd.js`
* `MainFrameAtDocumentStart.js`

To simplify the build process, these compiled files are checked-in to this repository. When adding or editing User Scripts, these files can be re-compiled with `webpack` manually. This requires Node.js to be installed, and all required `npm` packages can be installed by running `npm install` in the project's root directory. User Scripts can be compiled by running the following `npm` command in the root directory of the project:

```shell
npm run build
```

License
-----------------

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at https://mozilla.org/MPL/2.0/

# Error report


Uncaught Error: The module '\\?\C:\develop\NodeJS\electron-serialport\node_modules\@serialport\bindings\lib\binding\node-v70-win32-x64\bindings.node'
was compiled against a different Node.js version using
NODE_MODULE_VERSION 47. This version of Node.js requires
NODE_MODULE_VERSION 70. Please try re-compiling or re-installing
the module (for instance, using `npm rebuild` or `npm install`).

## npx prebuild-install 

npx prebuild-install --runtime electron --target 5.0.10 --arch x64 --platform win32 --tag-prefix @serialport/bindings@ --verbose
prebuild-install info begin Prebuild-install version 5.3.0
prebuild-install info looking for cached prebuild @ C:\Users\josverl\AppData\Roaming\npm-cache\_prebuilds\bde028-bindings-v2.0.8-electron-v70-win32-x64.tar.gz
prebuild-install http request GET https://github.com/node-serialport/node-serialport/releases/download/@serialport/bindings@2.0.8/bindings-v2.0.8-electron-v70-win32-x64.tar.gz
prebuild-install http 200 https://github.com/node-serialport/node-serialport/releases/download/@serialport/bindings@2.0.8/bindings-v2.0.8-electron-v70-win32-x64.tar.gz
prebuild-install info downloading to @ C:\Users\josverl\AppData\Roaming\npm-cache\_prebuilds\bde028-bindings-v2.0.8-electron-v70-win32-x64.tar.gz.16608-da68a1f0e84a4.tmp
prebuild-install info renaming to @ C:\Users\josverl\AppData\Roaming\npm-cache\_prebuilds\bde028-bindings-v2.0.8-electron-v70-win32-x64.tar.gz
prebuild-install info unpacking @ C:\Users\josverl\AppData\Roaming\npm-cache\_prebuilds\bde028-bindings-v2.0.8-electron-v70-win32-x64.tar.gz
prebuild-install info unpack resolved to C:\develop\NodeJS\electron-serialport\node_modules\@serialport\bindings\build\Release\bindings.node
prebuild-install info install Successfully installed prebuilt binary!
VERBOSE: Performing the operation "Copy File" on target "Item: C:\develop\NodeJS\electron-serialport\node_modules\@serialport\bindings\build\Release\bindings.node Destination: C:\develop\NodeJS\electron-serialport\native_modules\@serialport\bindings\lib\binding\node-v70-win32-x64\bindings.node".

NOTE: in his example the folder is named 'node-v70-win32-ia32', the binding is the electron binding.





## CheckABI on Win32 - x64 
PS C:\develop\NodeJS\electron-serialport> node .\checkABI.js
ABI 64 <- native_modules\@serialport\bindings\lib\binding\node-v64-win32-x64\bindings.node
ABI 69 <- native_modules\@serialport\bindings\lib\binding\node-v69-win32-x64\bindings.node
ABI 47 <- native_modules\@serialport\bindings\lib\binding\node-v70-win32-x64\bindings.node

## CheckABI on ubuntu - x64
jos@josverl-b1:/mnt/c/develop/NodeJS/electron-serialport$ node checkABI.js 
ABI 64 <- native_modules/@serialport/bindings/lib/binding/node-v64-linux-x64/bindings.node
ABI 69 <- native_modules/@serialport/bindings/lib/binding/node-v69-linux-x64/bindings.node
ABI 47 <- native_modules/@serialport/bindings/lib/binding/node-v70-linux-x64/bindings.node


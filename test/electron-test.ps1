
# {runtime: 'electron', target: '3.0.0', abi: '64', lts: false},
# {runtime: 'electron', target: '4.0.0', abi: '64', lts: false},
# {runtime: 'electron', target: '4.0.4', abi: '69', lts: false},
# {runtime: 'electron', target: '5.0.0', abi: '70', lts: false},
# {runtime: 'electron', target: '6.0.0', abi: '73', lts: false}
# https://github.com/lgeiger/node-abi/blob/master/index.js

# on WSL - ubunto :
# sudo apt install build-essential clang libdbus-1-dev libgtk2.0-dev \
#                        libnotify-dev libgnome-keyring-dev libgconf2-dev \
#                        libasound2-dev libcap-dev libcups2-dev libxtst-dev \
#                        libxss1 gcc-multilib g++-multilib
#                        libxss1 libnss3-dev gcc-multilib g++-multilib



foreach ($version in '4.2.5','5.0.10') {
    write-host "get ready to test on electron $version"
    # make sure  node_folders is empty 
    Remove-Item ./node_modules/* -Recurse -Force -ErrorAction SilentlyContinue
    npm install
    npm install electron@$version

    #sanity check
    npx electron --version
    # also make sure that the native modules are in place for the test 
    scripts/mp-download.ps1 -copyonly
    # use a version of bidings that provides some more output on what is loaded 
    copy-item test/bindings/bindings.js node_modules/bindings/bindings.js -force 
    #run test app 
    npx electron test/index.js

}

#todo: use nvm to switch between 32 / 64 bit on wnidows


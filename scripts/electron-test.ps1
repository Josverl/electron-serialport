
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

function HarvestNativeBinding (){
param(
    $runtime = 'electron',
    $module_name = '@serialport/bindings',
    $runtime_ver,
    $platform,
    $arch,
    $abi_ver,
    $docs_file
)

    try {
        #OK , now copy the platform folder 
        # from : \@serialport\bindings\build\Release\bindings.node
        # to a folder per "abi<ABI_ver>-<platform>-<arch>"
        switch ($runtime) {
            'node' {        # use the node version for the path ( implemended by binding) 
                            # supported by ('binding')('serialport')
                            # <root>/node_modules/@serialport/bindings/compiled/<version>/<platform>/<arch>/binding.node
                            # Note: runtime is not used in path 
                            $dest_file = Join-Path $native_folder -ChildPath "compiled/$runtime_ver/$platform/$arch/bindings.node"

                            # make sure the containing folder exists
                            $dest_folder = (split-Path $dest_file -Parent)
                            new-item dest_folder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
                            # copy all *.node native bindings
                            gci ".\node_modules\$module_name\build\Release" -Filter "*.node"       | Copy-Item -Destination (split-Path $dest_file -Parent) -Force
                            gci ".\node_modules\$module_name\build\Release" -Filter "*.forge-meta" | Copy-Item -Destination (split-Path $dest_file -Parent) -Force
                            gci ".\node_modules\$module_name\build\Release" -Filter "*.lastbuildstate" | Copy-Item -Destination (split-Path $dest_file -Parent) -Force                            
                            Write-Host "electron lib in node location -> $dest_file"
            }
            'electron' {# node-pre-gyp - use the ABIversion for the path (uses less space, better compat)
                            # ./lib/binding/{node_abi}-{platform}-{arch}`
                            # \node_modules\@serialport\bindings\lib\binding\node-v64-win32-x64\bindings.node
                            # Note: runtime is hardcoded as 'node' in path
                            $dest_file = Join-Path $native_folder -ChildPath "lib/binding/node-v$abi_ver-$platform-$arch/bindings.node" 
                            # make sure the containing folder exists
                            $dest_folder = (split-Path $dest_file -Parent)
                            new-item dest_folder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
                            # copy all *.node native bindings
                            gci ".\node_modules\$module_name\build\Release" -Filter "*.node"       | Copy-Item -Destination (split-Path $dest_file -Parent) -Force
                            gci ".\node_modules\$module_name\build\Release" -Filter "*.forge-meta" | Copy-Item -Destination (split-Path $dest_file -Parent) -Force
                            gci ".\node_modules\$module_name\build\Release" -Filter "*.lastbuildstate" | Copy-Item -Destination (split-Path $dest_file -Parent) -Force                            
                            Write-Host "electron lib in node location -> $dest_file"
            }
            'prebuildify' { # https://github.com/prebuild/node-gyp-build 
                            # <root>/node_modules/@serialport/bindings/prebuilds/<platform>-<arch>\<runtime>abi<abi>.node
                            #todo : file dest copy 
                            $dest_file = Join-Path $native_folder -ChildPath "prebuilds/$platform-$arch/($runtime)abi$abi_ver.node"  

                            # make sure the containing folder exists
                            $dest_folder = (split-Path $dest_file -Parent)
                            new-item dest_folder -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
                            #copy single file 
                            $_ = Copy-Item ".\node_modules\$module_name\build\Release\*.node" $dest_file -Force
                            Write-Host "prebuilify location: -> $dest_file" 
            }                                                        
            default {
                Write-Warning 'unknown path pattern'
            }
        }
        # todo: Generate documentation source.md
        if ($docs_file){
            # add to documentation.md
            $msg = "   - {0,-8}, {1,-4}, {2}" -f $platform, $arch , ($dest_file.Replace($root_folder,'.'))
            Out-File -InputObject $msg -FilePath $docs_file -Append 
        }
    } catch {
        Write-Warning "Error while copying prebuild bindings for runtime $runtime : $runtime_ver, abi: $abi_ver, $platform, $arch"
    } 

}


function runNodeCommand ([string]$cmd) {
    # run a simple command in Node and get the printed outout
    try { 
        if ($IsWindows) {
            $result = &node.exe --print $cmd 
        } else {
            $result = &node --print $cmd
        }
        return $result
    } catch {
        Write-Error "Unable to run NodeJS command"
        return $null
    }
}
# #########################################################################################################

function getABI([string]$runtime = "", [string]$version = "") {
    # get the abi version 
    # requires: npm install node-abi [...]
    $cmd = "var getAbi = require('node-abi').getAbi;getAbi('$version','$runtime')"
    $ABI_ver = runNodeCommand $cmd
    return $ABI_ver
}
# #########################################################################################################


# #########################################################################################################
# Test and Harvest
# #########################################################################################################

$root_folder = 'C:\develop\NodeJS\electron-serialport\'

# the (sub module = @serialport/bindings)
$module_name = '@serialport/bindings'
# this is where our (sub) module lives
$module_folder = Join-Path $root_folder -ChildPath "node_modules/$module_name"
#this is the repo storage location for the native modules
$native_modules = Join-Path $root_folder -ChildPath 'native_modules'
$native_folder = Join-Path $native_modules -ChildPath $module_name

#foreach ($version in '4.2.5','5.0.10','6.1.2') {
foreach ($version in '6.1.2') {
    cd $root_folder

    write-host "get ready to test on electron $version"
    
    # make sure  node_folders is empty 
    Remove-Item ./node_modules/* -Recurse -Force -ErrorAction SilentlyContinue
    #npm install
    npm install electron@$version

    write-host "&npx electron --version"
    #sanity check
    # &npx electron --version
    npm run version
    # also make sure that the native modules are in place for the test 
    &$root_folder/scripts/mp-download.ps1 -copyonly

    # use a version of bindings module that provides some more output on what is loaded 
    copy-item $root_folder/test/bindings/bindings.js $root_folder/node_modules/bindings/bindings.js -force -Verbose

    write-host "run test app" 
    # &npx electron test/index.js
    npm run test
    if ($LASTEXITCODE -ne 0 ){
        Write-Warning "serial port cannot be loaded, try to re-build"
        npx electron-rebuild
        # re-test
        npm run test
        Write-Host "result $LASTEXITCODE"
        if ($LASTEXITCODE -eq 0 ){
            # Success 
            $abi = getABI -runtime 'electron' -version $version
            HarvestNativeBinding -runtime 'electron' -runtime_ver $version -abi_ver $abi -platform 'win32' -arch 'x64'-native_folder "$RootPath\native_modules"
            # now copy the natives again 
            &$root_folder/scripts/mp-download.ps1 -copyonly
            # and a final test to see if the natives have been included correctly 
            # re-test
            npm run test
        } else {
            # failed 2nd time 
            Write-Warning "serialport rebuild failed"
        }
    } 

}

#todo: use nvm to switch between 32 / 64 bit on wnidows

 

#Sets up the jvmci jdk java home in order to build graal
function autojvmci {
    jdk11=$(ls -t ~/bin/graalvm | grep jvmci |grep 11|head -n 1)
    jdk8=$(ls -t ~/bin/graalvm | grep jvmci |grep 8|head -n 1)

    if [[ $1 == "8" ]] then
        export JAVA_HOME=~/bin/graalvm/$jdk8/$JAVA_BIN_LOCATION
        export EXTRA_JAVA_HOMES=~/bin/graalvm/$jdk11/$JAVA_BIN_LOCATION
    else
        export JAVA_HOME=~/bin/graalvm/$jdk11/$JAVA_BIN_LOCATION
        export EXTRA_JAVA_HOMES=~/bin/graalvm/$jdk8/$JAVA_BIN_LOCATION
    fi
    export PATH=$JAVA_HOME/bin:$NO_JAVA_PATH

    echo JDK: $JAVA_HOME
    echo EXTRA: $EXTRA_JAVA_HOMES
    java -version
}

#Download latest jvmci from github
function dl-gb-jvmci {
    local jdk=$1
    if [[ "$1" == "11" ]]; then
        url=`curl --silent "https://api.github.com/repos/graalvm/labs-openjdk-11/releases/latest" | jq -r ".assets|.[].browser_download_url"|fzf`
    else 
        url=`curl --silent "https://api.github.com/repos/graalvm/openjdk8-jvmci-builder/releases/latest" | jq -r ".assets|.[].browser_download_url"|fzf`
    fi
    echo Downloading $url
    curl -L -s $url | tar -xvf - -C ~/bin/graalvm

}

#Downloads the latest graal from github
function dl-gb-graal {
    local url=`curl --silent "https://api.github.com/repos/graalvm/graalvm-ce-builds/releases/latest" | jq -r ".assets|.[].browser_download_url"|fzf`
    echo Downloading $url
    curl -L -s $url | tar -xvf - -C ~/bin/graalvm
}


function graaldev {
    jdk=`{ ls -d ~/src/graal-workspace/graal/vm/latest_graalvm/* ; ls -d ~/src/graal-workspace2/graal/vm/latest_graalvm/* } | fzf`
    echo $jdk
    export JAVA_HOME=$jdk/$JAVA_BIN_LOCATION
    export PATH=$JAVA_HOME/bin:$NO_JAVA_PATH
    export PATH=~/src/graal/substratevm/svmbuild/vm/bin:$PATH
    java -version && native-image --version
}

function mxgit {
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    NC='\033[0m'
    (
        while [ true ];
        do
            if [[ `pwd` = "/" ]]; then
                echo Can not find workspace root
                return
            fi
            if [[ -f .graalworkspace ]]; then
                break
            fi
            cd ../
        done

        root=`pwd`
        echo "$RED On workspace $root $NC"
        for repo in $(find `pwd` -depth 1 -type d)
        do
            cd $repo
            echo "$GREEN============`pwd`==================$NC"
            sh -c "$@"
        done

        #ls -1 |xargs -I% sh -c "cd % && echo === `pwd` === && $1"
    )
}

function javaBinLocation {
    export JAVA_BIN_LOCATION=
    if [[ "$(uname -s)" == "Darwin" ]]; then
        export JAVA_BIN_LOCATION=Contents/Home
    fi
}

#Chnages jdk for the current terminal session
#Relies on the $NO_JAVA_PATH env var
function changejdk {
  local newfile=~/bin/graalvm/`cd ~/bin/graalvm && ls |fzf`
  export JAVA_HOME=$newfile/$JAVA_BIN_LOCATION
  export PATH=$JAVA_HOME/bin:$NO_JAVA_PATH
  java -version && native-image --version
}



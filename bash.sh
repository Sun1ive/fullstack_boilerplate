#!/bin/bash

PS3='Choose what do you want to install '

options=("Backend" "Frontend")
frontendOpts=("Vue" "React")
backendOpts=("Express" "Nestjs")
backend=false
frontend=false

function choose_option() {
    local _prompt="$1"
    local _result
    shift
    if test "$#" -gt 0;
    then
        _prompt="${_prompt} [$1"
        shift
    fi
    while test "$#" -gt 0;
    do
        _prompt="${_prompt}/$1"
        shift
    done
    _prompt="${_prompt}] "
    read -p "${_prompt}" _result
    local _code=$?
    if test "${_code}" -eq 0;
    then
        echo "${_result}"
    else
        return ${_code}
    fi
}

function choose_option_default() {
    local _prompt="$1"
    local _default="$2"
    local _options=()
    local i
    shift 2
    while test "$#" -gt 0;
    do
        _opts+=("$1")
        if test "$1" == "${_default}";
        then
            _options+=("${1^^}")
        else
            _options+=("${1,,}")
        fi
        shift
    done
    local _result=$(choose_option "${_prompt}" "${_options[@]}")
    if test -z "${_result}";
    then
        echo "${_default}"
        return 0
    else
        for ((i=0; i!=${#_options[@]}; ++i));
        do
            if test "${_result,,}" == "${_options[i],,}";
            then
                echo "${_opts[i],,}"
                return 0
            fi
        done
    fi
    return 1
}

function withTypescript() {
    local _ans=$(choose_option_default "Would you like to use Typescript?" y y n)
    
    case "${_ans}" in
        [Yy]|[Yy][Ee][Ss])
            echo "Yes"
        ;;
        [Nn]|[Nn][Oo])
            echo "No"
        ;;
        *)
            echo "Invalid input"
        ;;
    esac
}

function installExpress () {
    echo "installing Express"
    mkdir server
    touch server/.gitignore
    echo "node_modules/" > server/.gitignore
    rsync -avu templates/express/ server/
    cd server && /bin/bash install.sh
}

function installVue() {
    echo "Installing vue..."
    # mkdir -p client
    # rsync -auv templates/vue/ client/
    /bin/bash templates/vue/install.sh
}

function installReact() {
    # rsync -auv templates/react/ client/
    /bin/bash templates/react/install.sh $@
    echo "Installing react..."
}


select opt in "${options[@]}"
do
    case $opt in
        "Frontend")
            frontend=true;
            echo "Frontend"
            break;
        ;;
        "Backend")
            backend=true;
            echo "Backend"
            break;
        ;;
        "Quit")
            break;
        ;;
        *) echo "invalid option $REPLY";;
    esac
done

if [ "$backend" = true ]
then
    PS3='Choose what framework do you want to install '
    echo "installing backend..."
    echo "cleanup old server..."
    rm -rf server
    
    select opt in "${backendOpts[@]}"
    do
        case $opt in
            "Express")
                if [ $(withTypescript) = "Yes" ]
                then
                    echo "With typescript"
                    break;
                else
                    installExpress
                    break;
                fi
            ;;
            "Nestjs")
                echo "installing Nestjs"
                break;
            ;;
            *) echo "invalid option $REPLY";;
        esac
    done
fi

if [ "$frontend" = true ]
then
    PS3='Choose what framework do you want to install '
    echo "installing frontend..."
    echo "cleanup old client..."
    rm -rf client
    
    select opt in "${frontendOpts[@]}"
    do
        case $opt in
            "Vue")
                installVue $(withTypescript)
                break;
            ;;
            "React")
                installReact $(withTypescript)
                break;
            ;;
            *) echo "invalid option $REPLY";;
        esac
    done
fi
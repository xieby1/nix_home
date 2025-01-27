#!/usr/bin/env bash

getTitle() {
    PATHMD=$1
    head -n 3 "${PATHMD}" | awk '/^# / {$1=""; print substr($0,2); exit;}'
}
genDir() {
    Dir=$1
    for PATHMD in $(find $Dir -name "*.md" -exec ./.parent_dirs.sh {} \; | sort -n | uniq); do

        # remove tailing slash for dir
        PATHMD=${PATHMD%/}

        # README.md & index.md belongs to current folder
        NAMEMD=${PATHMD##*/}
        if [[ ${NAMEMD} =~ README.*md || ${NAMEMD} == "index.md" || ${NAMEMD} == "SUMMARY.md" ]]; then
            continue
        fi

        # ignore .
        if [[ ${PATHMD} == "." ]]; then
            continue
        fi

        # count indentation # $PATHMD = ./miao/wang/x.md
        TMP1=${PATHMD#./}   # TMP1 = miao/wang/x.md
        TMP2=${TMP1//[^\/]} # TMP2 = //
        INDENT=${#TMP2}     # INDENT = 2

        for (( i=0; i<${INDENT}; i++ )); do
            echo -n "  "
        done

        if [[ -f ${PATHMD} ]]; then
            TITLE=$(getTitle "${PATHMD}")
            if [[ -n ${TITLE} ]]; then
                echo "* [${TITLE}](${PATHMD})"
            else
                echo "* [${NAMEMD}](${PATHMD})"
            fi
        elif [[ -f ${PATHMD}/index.md ]]; then
            TITLE=$(getTitle "${PATHMD}/index.md")
            if [[ -n ${TITLE} ]]; then
                echo "* [${TITLE}](${PATHMD}/index.md)"
            else
                echo "* [${NAMEMD}/](${PATHMD}/index.md)"
            fi
        elif [[ -f ${PATHMD}/README.md ]]; then
            TITLE=$(getTitle "${PATHMD}/README.md")
            if [[ -n ${TITLE} ]]; then
                echo "* [${TITLE}](${PATHMD}/README.md)"
            else
                echo "* [${NAMEMD}/](${PATHMD}/README.md)"
            fi
        elif [[ -d ${PATHMD} ]]; then
            echo "* [${NAMEMD}/]()"
        else
            echo "* [${NAMEMD}]()"
        fi
    done
}

echo "# Summary"
echo
echo "# 🏠主页"
echo
echo "* [📔README.md](./README.md)"
echo
echo "# 🌏全局配置"
echo
echo "* [config.nix](./config.nix.md)"
echo "* [TODO: nix/nix.conf](./nix/nix.conf.md)"
echo "* [opt.nix](./opt.nix.md)"
echo
echo "# 🖥️系统配置(需sudo,用于NixOS)"
echo
echo "* [system.nix](./system.nix.md)"
genDir ./sys/
echo
echo "# 😺用户配置(无需sudo,用于Nix/NixOS)"
echo
echo "* [home.nix](./home.nix.md)"
genDir ./usr/
echo
echo "# 🤖安卓配置(无需sudo,复用\"用户配置\")"
echo
echo "* [nix-on-droid.nix](./nix-on-droid.nix.md)"
echo
echo "# 🔩通用模块"
echo
genDir ./modules/
echo
echo "# 📝文档和心得体会"
echo
genDir ./docs/
echo
echo "# 📃Nix脚本（nix-shell和打包）"
echo
genDir ./scripts/
echo
echo "# 📌其他"
echo
echo "* [shell.nix](./shell.nix.md)"

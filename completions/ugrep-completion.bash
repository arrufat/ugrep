#!/usr/bin/env bash

if ! declare -F _init_completion >/dev/null 2>&1; then
    return
fi

_comp_cmd_ugrep_file_type()
{
    # complete a file type by generating them
    COMPREPLY=( $(compgen -W "$($1 -tlist 2>&1 | sed -e "s/[ ]*\(\w\+\).*/$2\1/" -e "/FILE/d" -e "/^ /d")" -- $cur) )
    compopt +o nospace
}

_comp_cmd_ugrep_encoding()
{
    # complete encoding format by generating them
    COMPREPLY=( $(compgen -W "$($1 --encoding=list 2>&1 | sed -e "s/^.[a-z].*are//" -e "/help/d" -e "s/ '//g" -e "s/',\?/ /g")" -- $cur) )
    compopt +o nospace
}

_comp_cmd_ugrep()
{
    local IFS=$' \t\n'
    local cur prev words cword
    _init_completion -s || return

    if [[ $cword -eq 1 && "${words[1]}" == "" ]]; then
        local -a usage
        usage=( "0| usage: $1 [OPTIONS] -Q|PATTERN [PATH]" \
                "1|        $1 -iw 'hello|world' doc.txt" \
                "2|        $1 -R -C3 -w 'TODO|FIXME' src/" \
                "3|        $1 -l -j -Q" \
                "4|        $1 -o -C30 -j -Q" )
        local i
        for i in "${!usage[@]}"; do
            usage[$i]="$(printf '%*s' "-$COLUMNS" "${usage[$i]}")"
        done
        COMPREPLY=( "${usage[@]}" )
        return
    fi

    local i
    for i in "${!words[@]}"; do
        if [ "${words[$i]}" = "--" ]; then
            if [ $cword -gt $i ]; then
                _filedir
                return
            fi
            words=( "${words[@]:0:$i}" )
            break
        fi
    done

    case $prev in
    -D)
        # complete devices parameter
        COMPREPLY=( $(compgen -W "read skip" -- $cur) )
        compopt +o nospace
        return
        ;;
    -d)
        # complete directories parameter
        COMPREPLY=( $(compgen -W "read recurse skip" -- $cur) )
        compopt +o nospace
        return
        ;;
    -t)
        # complete a file type by generating them
        _comp_cmd_ugrep_file_type $1 ""
        return
        ;;
    -Z)
        # suggest fuzzy parameters
        COMPREPLY=( $(compgen -W "1 +1 -1 ~1 +-1 +~1 +-~1 -~1 best1 best+1 best-1 best~1 best+-1 best+~1 best+-~1 best-~1" -- $cur) )
        return
        ;;
    esac

    case "${words[$cword]}" in
    --binary-files=*)
        # complete binary-files parameter
        COMPREPLY=( $(compgen -W "binary hex text with-hex without-match" -- $cur) )
        compopt +o nospace
        return
        ;;
    --color=* | --colour=*)
        # complete color and pretty parameter
        COMPREPLY=( $(compgen -W "always auto never" -- $cur) )
        compopt +o nospace
        return
        ;;
    --colors=* | --colours=* | --file-magic=*)
        # add an opening quote to quote the long option argument when recommended
        COMPREPLY=( "'" )
        return
        ;;
    --devices=*)
        # complete devices parameter
        COMPREPLY=( $(compgen -W "read skip" -- $cur) )
        compopt +o nospace
        return
        ;;
    --directories=*)
        # complete directories parameter
        COMPREPLY=( $(compgen -W "read recurse skip" -- $cur) )
        compopt +o nospace
        return
        ;;
    --encoding=*)
        # complete encoding format by generating them
        _comp_cmd_ugrep_encoding $1
        return
        ;;
    --hexdump=*)
        # suggest hexdump parameters
        COMPREPLY=( $(compgen -W "1a 2a 4ah 6ah 8ah 1aC1 2aC1 4ahC1 6ahC1 8ahC1" -- $cur) )
        return
        ;;
    --hyperlink=)
        # suggest hyperlinking line and column numbers
        COMPREPLY=( "+" )
        compopt +o nospace
        return
        ;;
    --sort=*)
        # complete sort key
        COMPREPLY=( $(compgen -W "best changed created name size used rbest rchanged rcreated rname rsize rused" -- $cur) )
        compopt +o nospace
        return
        ;;
    --file-type=*)
        # complete a file type by generating them
        _comp_cmd_ugrep_file_type $1 ""
        return
        ;;
    --fuzzy=*)
        # suggest fuzzy parameters
        COMPREPLY=( $(compgen -W "1 +1 -1 ~1 +-1 +~1 +-~1 -~1 best1 best+1 best-1 best~1 best+-1 best+~1 best+-~1 best-~1" -- $cur) )
        return
        ;;
    esac

    case $cur in
    -A | -B | -C)
        # suggest a context
        COMPREPLY=( $(compgen -W "-A3 -B3 -C3" -- $cur) )
        return
        ;;
    -D*)
        # complete devices parameter
        COMPREPLY=( $(compgen -W "-Dread -Dskip" -- $cur) )
        compopt +o nospace
        return
        ;;
    -d*)
        # complete directories parameter
        COMPREPLY=( $(compgen -W "-dread -drecurse -dskip" -- $cur) )
        compopt +o nospace
        return
        ;;
    -e | -g | -M | -N | --and | --andnot | --not)
        # add an opening quote to quote the option argument when recommended
        COMPREPLY=( "${cur} '" )
        return
        ;;
    --colors | --colours)
        # add an opening quote to quote color arguments (recommended)
        COMPREPLY=( "${cur}='" )
        return
        ;;
    -K)
        # suggest a line range
        COMPREPLY=( "-K1,10" )
        return
        ;;
    -m*)
        # suggest a match count range
        COMPREPLY=( $(compgen -W "-m1 -m1, -m1,10" -- $cur) )
        return
        ;;
    -t*)
        # complete a file type by generating them
        _comp_cmd_ugrep_file_type $1 -t
        return
        ;;
    -Z*)
        # suggest fuzzy parameters
        COMPREPLY=( $(compgen -W "-Z -Z1 -Z+1 -Z-1 -Z~1 -Z+-1 -Z+~1 -Z+-~1 -Z-~1 -Zbest1 -Zbest+1 -Zbest-1 -Zbest~1 -Zbest+-1 -Zbest+~1 -Zbest+-~1 -Zbest-~1" -- $cur) )
        return
        ;;
    --*)
        # complete long options by generating them
        COMPREPLY=( $(compgen -W "$(_parse_help $1 --help="$cur")" -- $cur) )
        if [[ ! "${COMPREPLY[@]}" =~ "=" ]]; then
            # add space after long options that do not end with a =
            compopt +o nospace
        fi
        return
        ;;
    -?*)
        # add space after short option(s)
        COMPREPLY=( $cur )
        compopt +o nospace
        return
        ;;
    esac

    _filedir
} &&
    complete -o nospace -F _comp_cmd_ugrep ug ug+ ugrep ugrep+

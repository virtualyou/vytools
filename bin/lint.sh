#!/bin/bash

###################r#############################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  cd <project-directory>
  lint.sh [-x]

Perform a series of well-formedness checks on the project source files.
Eg, Mule EE usage, doc:id, whitespace, etc.

Options:
  -x   Enable command trace output (eg, to pinpoint compatibility problems)
ENDHELP
    exit
fi
################################################################################

BASH_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ignore command customizations, if any
unalias cat  2> /dev/null
unalias find 2> /dev/null
unalias grep 2> /dev/null
unalias sed  2> /dev/null
unalias tail 2> /dev/null

# parse command options
cmdTrace=+x
while [[ $# > 0 && "$1" =~ ^[-+] ]]; do
    case "$1" in
       -x|+x) cmdTrace=${1}; shift 1 ;;
           *) echo "$(basename ${BASH_SOURCE}): Unrecognized option: ${1}" >&2
              exit 1 ;;
    esac
done

if [[ ! -d .git ]]; then
    echo "This is not a project directory: $PWD" >&2
    exit 1
fi

EXC_VENDOR="--exclude=pom.xml --exclude=.project --exclude=.classpath --exclude=mule-artifact.json --exclude=Postman*.json"

# Run a provided function body, (typically as a heredoc).
# If that produces any output, echo it, preceded by the provided header message.
report_any() {
    local hdrMsg="$@"
    if [[ -t 0 ]]; then
        echo "No function body provided for: '${hdrMsg}'"
        exit 1
    fi
    eval "function do_check() ( $(cat) 2>&1 )"

    do_check > /tmp/tmp.out
    if [[ -s /tmp/tmp.out ]]; then
        echo "-- ${hdrMsg} ----------"
        cat /tmp/tmp.out
    fi
}

_grep() { ( set ${cmdTrace}; grep "$@"; ) }
_find() { ( set ${cmdTrace}; find "$@"; ) }

find_mule_xml_files() {
    # xml files that contain a mule wrapper tag
    _grep -rlE '<(mule|domain:mule-domain)\b' --include='*.xml' src/{main,test}
}

# grep -r, excluding binary file types & project metadata directories
_grep_rI() {
    _grep -r "$@" -I \
      --exclude-dir=.git \
      --exclude-dir='pipeline' \
      --exclude-dir='target*' \
      --exclude-dir=bin \
      --exclude-dir=.mule \
      --exclude-dir=.idea \
      --exclude-dir='_*' \
      --exclude='Postman*.json' \
      --exclude='*.log'
}

# find, excluding binary file types & project metadata directories
_find_prune() {
    local startDir=$1
    shift 1
    find ${startDir} \( \
           -name .git \
        -o -name .idea \
        -o -name '*.iml' \
        -o -name pipeline \
        -o -name 'target*' \
        -o -name .mule \
        -o -name bin \
        -o -name '*.jar' \
        -o -name '*.zip' \
        -o -name '*.lnk' \
        -o -name mvnw.cmd \
        -o -name mule-artifact.json \
        -o -name PostmanCollection.json \
        -o -name '_*' \
      \) -prune -o \
      "$@"
}

# ========================================

# Mule header checking
#   one item per line: (except for indentation) contains no spaces
# TODO Mac-compatibility checking

# ----------------------------------------
# character level

#report_any <<'FUNC' "Text files containing non-ASCII"
#    # characters outside of the ASCII range
#    _grep_rI -lP '[^\0-\x7f]' . --include='*'.{md,txt,yaml,yml,xml,json,sh,cmd,bat}
#FUNC

# scripts with CRLF line endings
report_any <<'FUNC' "Script files with CRLF (Windows) line endings"
    # CR character
    grep -rl -U $'\x0D' . \
      --include='*.sh' \
      --include='*.env' \
      --include='*rc'
FUNC

report_any <<'FUNC' "Contains hard tabs"
    _grep_rI -l $'\t' . ${EXC_VENDOR}
FUNC

report_any <<'FUNC' "Contains hard tabs WITHIN the indentation area"
    # space(s), followed by a tab
    _grep_rI -l -E $'^[ ]*[\t]' . ${EXC_VENDOR}
FUNC

report_any <<'FUNC' "Contains hard tabs BEYOND the indentation area"
    # whitespace, followed by non-whitespace, followed by tab
    _grep_rI -El $'^[ \t]+[^ \t]+\t' . ${EXC_VENDOR}
FUNC

report_any <<'FUNC' "Contains whitespace at end-of-line"
  _grep_rI -l '[[:blank:]]$' . ${EXC_VENDOR} 
FUNC

if [[ -z ${USERNAME} ]]; then
    report_any <<'FUNC' "Contains Windows line endings"
      _grep_rI -Ul $'\r' . ${EXC_VENDOR} 
FUNC
fi

# because version control operates on lines
report_any <<'FUNC' "end-of-file is not a LF"
    _find_prune . -type f -exec bash -c '[[ $(tail -c 1 "$0") != "" ]]' {} \; -print
FUNC

# TODO: mixed tab/space indentation

# ----------------------------------------
# pom.xml

_grep -F 'cdx.commons.version' pom.xml > /dev/null || echo "pom.xml is missing cdx.commons.version"
_grep -F 'cdx.domain.version'  pom.xml > /dev/null || echo "pom.xml is missing cdx.domain.version"

# ----------------------------------------
# mule xml file formatting

report_any <<'FUNC' "Has a flattened <mule tag"
    mule_xml_files=$(find_mule_xml_files)
    # more than one 'xmlns' on the same line
    _grep "\bxmlns\b.*\bxmlns\b" --color ${mule_xml_files}
    # more than one schemaLocation declaration on the same line
    grep -r "http://[^ ]* http://" ${mule_xml_files}
FUNC

report_any <<'FUNC' "Unused xml namespaces"
    parse_xmlns_decls() {
        # (assumes one declaration per line)
        _grep '\bxmlns:' ${1} | sed -e 's/=.*//' -e 's/^.*://'
    }

    for muleXml in $(find_mule_xml_files); do
        for ns in $(parse_xmlns_decls ${muleXml}); do
          # for each namespace, match on usages of - else report it
          _grep "\b${ns}:" ${muleXml} > /dev/null || echo "${muleXml}: ${ns}"
        done
    done
FUNC

report_any <<'FUNC' "Contains doc:id"
    dirs=( src/{main,test} )
    for dir in "${dirs[@]}"; do
        if [[ -d ${dir} ]]; then
            # 'doc:id'
            _grep -rl "\bdoc:id\b" ${dir} --include='*.xml'
        fi
    done
FUNC

#report_any <<'FUNC' "Mule EE usage"
#    dirs=( src/{main,test} )
#    for dir in "${dirs[@]}"; do
#        if [[ -d ${dir} ]]; then
#            # EE namespace declaration
#            _grep_rI -l "http://www.mulesoft.org/schema/mule/ee" ${dir} --include='*.xml'
#            # <ee:
#            _grep_rI -l "<ee:" ${dir} --include='*.xml'
#        fi
#    done
#FUNC

# ----------------------------------------
# Postman

if [[ -e PostmanCollection.json ]]; then
    echo "PostmanCollection.json found at project root"
fi

report_any <<'FUNC' "hard-coded Postman URLs"
    _grep_rI '"raw": *"http' . --include=PostmanCollection.json
FUNC

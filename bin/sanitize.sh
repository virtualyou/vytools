#!/bin/bash
###################################################################
# Copyright (c) 2023 David L. Whitehurst
# License: https://github.com/dlwhitehurst/vytools/blob/main/LICENSE
#
#
# UNDER CONSTRUCTION
#
# sanitize.sh
########################################################################
# Do a series of quality sanitization code fixes prior to pushing 
# VirtualYou projects
#
# Usage
#   sanitize.sh [options]
#

# Wishlist: 
#   +d<file> to exclude a specific file from doc:name removal

if [[ "$1" == "--help" ]]; then
  cat <<'ENDHELP'
Usage:
  cd <project-root>
  sanitize.sh <options> <fileset> # could be a single file

Options:
 -x   Show command execute trace.
 +i   Don't normalize indent expansion
 +d   Don't remove doc:id="abc123" from Mule configurations (XML)
 +l   Don't ensure line endings (\n)
 +w   Don't remove trailing whitespace on line ends

This script does a series of sanitization fixes on the MuleSoft project text fileset. 
  
  pom.xml
  README*.md
  .gitignore
  *.md
  *.xml'
  *.wsdl'
  *.properties'
  *.yml'
  *.yaml'
  *.dwl'
  *.txt'
  *.java'
  *.json'
  *.raml'
ENDHELP
    exit
fi

BASH_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

# TODO:
#   doc:id delete exclusions
#     grep "select=.#" src/main/resources/application-types.xml \
#       | sed -e 's/.*select="#\([^""]*\).*/\1/'

##########################################################################################

# ignore any command customizations via alias
unalias find 2> /dev/null
unalias grep 2> /dev/null
unalias sed  2> /dev/null
unalias cat  2> /dev/null

# parse command options
do_indent=true
do_docid=true
do_linefeed_file_end=true
do_trailing_whitespace=true

TRACE=+x
while [[ $# > 0 && "$1" =~ ^[-+] ]]; do
  case "$1" in
   -x|+x) TRACE=${1};                   shift 1 ;;
      +i) do_indent=false;              shift 1 ;;
      +d) do_docid=false;               shift 1 ;;
      +l) do_linefeed_file_end=false;   shift 1 ;;
      +w) do_trailing_whitespace=false; shift 1 ;;
       *) echo "$(basename ${BASH_SOURCE}): Unrecognized option: ${1}" >&2
          exit 1 ;;
  esac
done

##########################################################################################
# MacOS compatibility shimming

if [[ "$(uname -s)" == 'Darwin'* ]]; then
    sed_i() ( set ${TRACE}; sed -i '' "$@"; )
else
    sed_i() ( set ${TRACE}; sed -i "$@"; )
fi

##########################################################################################

find_project_files() {
    echo pom.xml
    echo README*.md
    for dir in src/{'main','test'}; do
        if [[ -d ${dir} ]]; then
            find ${dir} -name 'README*.md'
            find ${dir} -name '*.xml'
            find ${dir} -name '*.wsdl'
            find ${dir} -name '*.properties'
            find ${dir} -name '*.yml'
            find ${dir} -name '*.yaml'
            find ${dir} -name '*.dwl'
            find ${dir} -name '*.txt'
            find ${dir} -name '*.java'
            find ${dir} -name '*.json' ! -iname "Postman*.json"
            find ${dir} -name '*.raml'
        fi
    done
}

fix_trailing_whitespace() {
    if [[ ! -d $file ]]; then
        sed_i 's/[[:space:]]*$//' ${file}
    fi
}

remove_docids() {
    if [[ ! -d $file ]]; then
        # this operates on XML files, but targets an attribute, ie, this cannot span across lines
        sed_i -e 's/ doc:id="[^_][^"]*"//' ${file}
    fi
}

linefeed_file_ends() {
    if [[ ! -d $file ]]; then
        # ?? how does this work ??
        sed_i -e '$a\' ${file}
    fi
}

if [[ $# > 0 ]]; then
    FILESET=("$@")                     # as specified on command line
else
    FILESET=( $(find_project_files) )  # all standard project files
    echo $FILESET
fi

if [[ $do_indent == true ]]; then 
    if [[ ! -d $file ]]; then
        ${BASH_DIR}/indent.sh ${TRACE}
    fi
fi

for file in "${FILESET[@]}"; do
    if [[ $do_docid == true ]]; then 
        remove_docids 
    fi
    if [[ $do_trailing_whitespace == true ]]; then 
        fix_trailing_whitespace 
    fi
    if [[ $do_linefeed_file_end == true ]]; then 
        linefeed_file_ends 
    fi
done

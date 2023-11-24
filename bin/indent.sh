#!/bin/bash
###################################################################
# Copyright (c) 2023 David L. Whitehurst
# License: https://github.com/dlwhitehurst/vytools/blob/main/LICENSE
#
# This script is a front-end for expand/unexpand.
#
# Author: Chris Noe
#
################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  cd <project-root>
  indent.sh [-x] [<file-path> ...]

Options:
  -x   show execution of commands that modify files

This script is a front-end for the expand/unexpand utilities.
It applies project standards to VY-specific project files.
Works correctly even if an input file contains a mix of both tabs & spaces.

Note - this does NOT perform syntax-driven re-formatting, (eg, xml pretty printing).
It merely translates between tabs & spaces.
Anything that is incorrectly indented will still be incorrectly indented,
just using spaces instead of tabs, or vice-versa.
(This script should probably be renamed to reexpand.sh)

IMPORTANT - Intended for use on a clean working directory - files are modified in-place.

Operates on:
  pom.xml
  README*.md
  src/{main,test}/**/README*.md
  src/{main,test}/**/*.xml
  src/{main,test}/**/*.wsdl
ENDHELP
    exit
fi
################################################################################

# ignore command customizations, if any
unalias cp       2> /dev/null
unalias diff     2> /dev/null
unalias expand   2> /dev/null
unalias find     2> /dev/null
unalias mv       2> /dev/null
unalias rm       2> /dev/null
unalias unexpand 2> /dev/null

# parse command options
cmdTrace=+x
while [[ $# > 0 && "$1" =~ ^[-+] ]]; do
    case "$1" in
       -x|+x) cmdTrace=${1}; shift 1 ;;
           *) echo "$(basename ${BASH_SOURCE}): Unrecognized option: ${1}" >&2
              exit 1 ;;
    esac
done

# prescribed project files
find_project_files() {
    echo pom.xml
    echo README*.md
    
    for dir in src/{'main','test'}; do
        if [[ -d ${dir} ]]; then
            find ${dir} -name 'README*.md'
            find ${dir} -name '*.xml'
            find ${dir} -name '*.wsdl'
            find ${dir} -name '*.json' ! -name "Postman*.json"
            find ${dir} -name '*.dwl'
            find ${dir} -name '*.yml'
            find ${dir} -name '*.yaml'
            find ${dir} -name '*.raml'
        fi
    done
}

# Normalize the indentation characters in the specified file(s).
# Usage:
#   re_expand <cur-width>[,][<new-width>] <file(s)>
# Examples:
#   re_expand 4   log4j2.xml (convert tabs to 4-space indentation)
#   re_expand 4,2 log4j2.xml (change indentation from 4-space to 2-space)
#   re_expand 4,  log4j2.xml (convert 4-space indentation to tabs)
# Processing happens in 1 or 2 passes on each file:
#   1) convert spaces -> tabs
#   2) convert tabs -> spaces  (iff "<cur-width>," has been specified)
# This 2-phase approach is why a mix of both tabs & spaces will be corrected.
# If the input file currently uses ONLY the tab character, then <cur-width> width has no effect.
# Otherwise, (IMPORTANT) if <cur-width> specify incorrectly,
#   the result will be increased or decreased indentation, with likely consistency problems.
re_expand() {
    local widthSpec=$1
    shift 1
    local curWidth=${widthSpec%,*}  # left of comma
    local newWidth=${widthSpec##*,} # right of comma, if any
    for file in "$@"; do
        [[ ! -e ${file} ]] && continue
        local origFile=${file}-indent.sh.orig
        local tmpFile=${file}-indent.sh.tmp
        ( set -e
          if [[ "$cmdTrace" != '-x' ]]; then
              cp ${file} ${origFile}
          fi
          ( set ${cmdTrace}; unexpand -t${curWidth} ${file} > ${tmpFile} )  # spaces -> tabs
          if [[ ! -z "${newWidth}" ]]; then
            ( set ${cmdTrace}; expand -t${newWidth} ${tmpFile} > ${file} )  # tabs -> spaces
          else
            ( set ${cmdTrace}; mv -f ${tmpFile} ${file} )
          fi
          if [[ "$cmdTrace" != '-x' ]]; then
              if ! diff -q ${origFile} ${file} > /dev/null; then
                  echo "re-expanded: $file"
              fi
          fi
        )
        rm -f ${tmpFile} ${origFile}
    done
}

# apply indentation method by file type
re_expand_file() {
    local filepath=${1}
    local filename=$(basename ${filepath})
    case "${filename}" in
      pom.xml) re_expand 4, ${filepath} ;; # 4-spaces -> tabs
            *) re_expand 4  ${filepath} ;; # tabs -> 4-spaces
    esac
}

# --------------------
# top-level script logic
(
  if [[ $# > 0 ]]; then
      FILESET=("$@")                     # as specified on command line
  else
      FILESET=( $(find_project_files) )  # all standard project files
  fi

  for filepath in "${FILESET[@]}"; do
      re_expand_file ${filepath}
  done
)

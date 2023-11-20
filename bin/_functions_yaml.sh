# Expand hierarchically defined yaml properties to a fully qualified property per line
# Examples:
#   expand_yaml foo. sample.yaml
#   expand_yaml foo_ sample.yaml _
#   expand_yaml foo- ${CDX_CONFIGS}/domain.yaml "-" ":="
#   expand_yaml foo- ${CDX_PROJECTS}/cdx-env-tools/docker/docker-compose.yaml "-" ":="
# TODO: translate segDelimiter(s) occurring within individual name segments (eg, ttl.unit:)
# TODO: allow whitespace in prefix/separator/delimiter
expand_yaml() {
   local prefix="${1}"
   local file="${2}"
   local segDelimiter="${3:-.}"  # key name segments
   local kvDelimiter="${4:-:}"   # key/value
   local ws='[[:space:]]*'
   local key='[a-zA-Z0-9_\.]*'
   local fs=$(echo @ |tr @ '\034')

   # remove colon and whitespace around it, and re-delimit indent/name/value with ASCII FS
   sed -ne "s|^\(${ws}\)\(${key}\)${ws}:${ws}[\"\']\([^\"\']*\)[\"\'].*|\1${fs}\2${fs}\3|p" \
        -e "s|^\(${ws}\)\(${key}\)${ws}:${ws}\(.*\)${ws}\$|\1${fs}\2${fs}\3|p" ${file} \
   | awk -F${fs} '{
      indent = length($1)/2;  # determine indentation level
      name[indent] = $2;      # the leaf-level name segment, (or hierarchical-parent name segment that will be expanded in subsequent properties)
      for (i in name) {
         if (i > indent) { delete name[i] }  # drop hierarchical name segment once past it
      }
      if (length($3) > 0) {
         # construct full property name at the current hierarchy level
         kn=""
         for (i=0; i<indent; i++) {
            kn=(kn)(name[i])("'${segDelimiter}'")
         }
         printf("%s%s%s'${kvDelimiter}'\"%s\"\n", "'${prefix}'", kn, $2, $3);
      }
   }'
}

# Expand yaml with "_" key name segments, and "=" as the key/value delimiter,
# then source the result, ie, property-assignment statements
# Example:
#   ( source_yaml domain_ ${CDX_CONFIGS}/domain.yaml; set | egrep '^domain_' | sort )
#   Example: queue.consume.timeout: "2000"
#   Becomes: queue_consume_timeout="2000"
source_yaml() {
   local prefix=${1}
   local file=${2}
   source <(
      expand_yaml "${prefix}" "${file}" _ =
   )
}

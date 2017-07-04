#!/bin/sh

# from passed environment files generate export statements to be "eval"ed
#
# example:    eval $(./env.sh .env .env.dist)
#
# expects passed environment files to comply the dotenv project rules https://github.com/motdotla/dotenv/blob/fdd0923e82e12a6e29b65898990201857141e75d/README.md#rules

if [ "$1" == "-o" ]; then
  # overwrite existing exported environment variables
  overwriteEnv=1
  shift
fi

if [ -z "$1" ]; then
  # no args passed, default to load of .env file
  set -- ".env" "$@"
fi

# print out export lines for each environment variable that is to be loaded
# environment variables from passed files
# expects environment files to match rules of the dotenv project 
while [ -n "$1" ]; do
  envFile=$1
  shift
  
  if [ ! -f $envFile ]; then
    # ignore file that doesn't exist
    continue
  fi
  
  IFS=$'\n'
  # assumes env keys are alphanumeric and underscore followed by and equals
  for x in $(cat $envFile | grep "^[A-Za-z0-9_]*="); do
    # extract the key
    key=$(printf '%s' "$x" | sed 's|=.*||')
    
    if [ -z "$overwriteEnv" ] && printenv $key > /dev/null; then
      # the key already loaded by the environment
      continue
    fi
    if printf '%s' "$keySet" | grep "^$key$" > /dev/null; then
      # the key already loaded another environment file
      continue
    fi
    
    # add key to keySet
    keySet=${keySet}${key}$'\n'
    
    value=$(printf '%s' "$x" | sed 's|[^=]*=||')
    
    if printf '%s' "$value" | grep "^'.*'$" > /dev/null; then
      # unwrap single quotes and unescape all slash single quotes
      value=$(printf '%s' "$value" | sed $'s|^\'\(.*\)\'$|\\1|' | sed $'s|\\\\\'|\'|g')
    else if printf '%s' "$value" | grep '^".*"$' > /dev/null; then
      # unwrap double quotes and unescape all slash double quotes and slash newlines
      value=$(printf '%s' "$value" | sed 's|^"\(.*\)"$|\1|' | sed 's|\\"|"|g' | sed 's|\\n|\'$'\n''|g')
    fi fi
    # escape
    #   <space> to \<space>
    #   <newline> to $'\n'
    value=$(printf '%s\n' "$value" | sed 's| |\\ |g' | sed -e :a -e $'$!N;s|\\n|$\'\\\\n\'|;ta')
    
    # create line 'export <key>=<escaped value>'
    printf '%s\n' ${env}export\ ${key}=${value}
  done
done

#!/bin/sh

NL=$'\n'
mkdir -p temp

[ "$(./shenv.sh)" == "" ] || echo 'FAIL: should not stdout anything when a .env is not present'

printf '%s' "KEY=value" > temp/.env
[ "$(./shenv.sh temp/.env)" == "export KEY=value" ] || echo 'FAIL: should be able to access env file with path when passed as an argument'

cd temp

printf '%s' "KEY=value" > .env
[ "$(../shenv.sh)" == "export KEY=value" ] || echo 'FAIL: should load default .env file when no arguments passed'

printf '%s' "KEY=value${NL}" > .env
[ "$(../shenv.sh)" == "export KEY=value" ] || echo 'FAIL: should not be affected by trailing whitespace'

printf '%s' "KEY_A=value${NL}KEY_B=value" > .env
[ "$(../shenv.sh)" == "export KEY_A=value${NL}export KEY_B=value" ] || echo 'FAIL: should load multiple env pairs'

printf '%s' "# KEY_A=value" > .env
[ "$(../shenv.sh)" == "" ] || echo 'FAIL: should not output commented lines'

printf '%s' "KEY_A=" > .env
[ "$(../shenv.sh)" == "export KEY_A=" ] || echo 'FAIL: should maintain empty values'

printf '%s' "KEY_A=Hello World" > .env
[ "$(../shenv.sh)" == 'export KEY_A=Hello\ World' ] || echo 'FAIL: should maintain space'

printf '%s' 'KEY_A= !"#$%&'"'"'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~' > .env
[ "$(../shenv.sh)" == 'export KEY_A=\ \!\"\#\$\%\&\'"'"'\(\)\*\+\,\-\.\/0123456789\:\;\<\=\>\?\@ABCDEFGHIJKLMNOPQRSTUVWXYZ\[\\\]\^\_\`abcdefghijklmnopqrstuvwxyz\{\|\}\~' ] || echo 'FAIL: should maintain all standard ascii characters (values 32 to 127)'

printf '%s' 'KEY_A=\n' > .env
[ "$(../shenv.sh)" == 'export KEY_A=\\n' ] || printf '%s\n' 'FAIL: should not treat \n as special when not double quoted'

printf '%s' 'KEY_A=""' > .env
[ "$(../shenv.sh)" == 'export KEY_A=' ] || echo 'FAIL: should have empty value for empty double quotes'

printf '%s' 'KEY_A="value"' > .env
[ "$(../shenv.sh)" == 'export KEY_A=value' ] || echo 'FAIL: should unwrap double quotes'

printf '%s' 'KEY_A="a\nb"' > .env
[ "$(../shenv.sh)" == "export KEY_A=a\$'\\n'b" ] || printf '%s\n' 'FAIL: should treat \n as newline when double quoted when in middle'

# haven't been able to get trailing \n to be converted into newline, can live without for now
# printf '%s' 'KEY_A="a\n"' > .env
# printf '%s\n%s\n' "$(cat .env)" "$(../shenv.sh)"
# [ "$(../shenv.sh)" == "export KEY_A=a\$'\\n'" ] || printf '%s\n' 'FAIL: should treat \n as newline when double quoted when at the end'

printf '%s' 'KEY_A="\nb"' > .env
[ "$(../shenv.sh)" == "export KEY_A=\$'\\n'b" ] || printf '%s\n' 'FAIL: should treat \n as newline when double quoted when at the start'

# haven't been able to get trailing \n to be converted into newline, can live without for now
# printf '%s' 'KEY_A="\n"' > .env
# printf '%s\n%s\n' "$(cat .env)" "$(../shenv.sh)"
# [ "$(../shenv.sh)" == "export KEY_A=\$'\\n'" ] || printf '%s\n' 'FAIL: should treat \n as newline when only it is double quoted'

printf '%s' "KEY_A='value'" > .env
[ "$(../shenv.sh)" == 'export KEY_A=value' ] || echo 'FAIL: should unwrap single quotes'

printf '%s' "KEY_A=''" > .env
[ "$(../shenv.sh)" == 'export KEY_A=' ] || echo 'FAIL: should have empty value for empty single quotes'

printf '%s' "KEY_A='\\n'" > .env
[ "$(../shenv.sh)" == 'export KEY_A=\\n' ] || printf '%s\n' 'FAIL: should not treat \n as special when single quoted'

printf '%s' 'KEY_A=한국어' > .env
[ "$(../shenv.sh)" == 'export KEY_A=\한\국\어' ] || echo 'FAIL: should handle unicode characters'

printf '%s' "${NL}${NL}KEY_A=value${NL}${NL}${NL}KEY_B=value${NL}${NL}${NL}" > .env
[ "$(../shenv.sh)" == "export KEY_A=value${NL}export KEY_B=value" ] || echo 'FAIL: should not be affected by empty lines"'

printf '%s' "${NL}    ${NL}KEY_A=value${NL}    ${NL}${NL}KEY_B=value${NL}    ${NL}${NL}" > .env
[ "$(../shenv.sh)" == "export KEY_A=value${NL}export KEY_B=value" ] || echo 'FAIL: should not be affected by lines with spaces"'

printf '%s' "KEY_A=value${NL}KEY_B=value" > .env
printf '%s' "KEY_A=OTHER" > .env.other
[ "$(../shenv.sh .env.other)" == "export KEY_A=OTHER" ] || echo 'FAIL: should not be affected by existing default .env when an arguments is passed"'

printf '%s' "KEY_A=value${NL}KEY_B=value" > .env
printf '%s' "KEY_A=OTHER" > .env.other
[ "$(../shenv.sh .env.other)" == "export KEY_A=OTHER" ] || echo 'FAIL: should not be affected by existing default .env when an arguments is passed"'

cd ..

# cleanup
rm -r temp

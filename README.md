# shenv
Posix compatible shell script that makes loading environment variables from multiple .env files easy, while respecting ones already set.

Environment files are a handy way in local development to define the configurable values. They are important to the concept of the 12 factor app. Within node development the [npm dotenv package](https://www.npmjs.com/package/dotenv) makes loading multiple of such files easy while not overwriting values from the host environment. However loading such files in a shell environment is tricky. This utility shell script makes that easy.

## Install

```
npm install shenv
```

## Usage
Set up of example host environment and .env files.
```
export ENV_1=host

echo '
ENV_1=a
ENV_2=a
' > a.env

echo '
ENV_2=b
ENV_3=b
' > b.env
```

Load all that into the current shell context with:
```
eval $(./shenv.sh a.env b.env)
```

### Break Down
In the above example `shenv.sh` will output:
```
export ENV_2=a
export ENV_3=b
```

By executing `shenv.sh` in a subshell with `eval $(./shenv ...)` the export string above is eval'd and the values are available as environment variables in the current shell's context.

## Compatibility
The output is posix compatible shell export commands that has been tested compatible with _safe_ characters. Further testing is need for things like unicode support.

The objective is to load environment files that meet the [dotenv Rules](https://www.npmjs.com/package/dotenv#rules).

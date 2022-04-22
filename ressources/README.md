# interface-gen 

# Background
For most client-service communication we specify an interface and then have to implement both sides.
There is a general idea that every such interface should feel like a regular function call.
Also how the interface code looks like is a straightforward result of the interaface specificationa and vice-versa.

Although there appear to be projects like [swagger](https://swagger.io/) who already "fill" this gap. However it seemed much more reasonable to implement this to find the most convenient way how I may deal with my interfaces.

## Interface Files and their Purpose
First the interface will have it's `<name>`

- Documentation File: `<name>interface.md`
- Interface File: `<name>interface.coffee` - the client side interface
- Routes File: `<name>routes.coffee` - the express routes
- Handlers File: `<name>handlers.coffee`
- Local Testing File: `<name>local.http`
- Deploy Testing File: `<name>deploy.http`

The interface-gen cli-tool will take the interface name as required argument. Then it would parse all the existing files, generate the missing ones and synchronize the relevant changes.

# Usage
Requirements
------------
- [nodejs](https://nodejs.org/en/) > 14
- [npm](https://www.npmjs.com/)

Installation
------------

Current git version
```sh
npm install -g git+https://github.com/JhonnyJason/interface-gen-output.git
```

Npm Registry
```sh
npm install -g interface-gen
```

CLI 
-----
```
Usage
    $ interface-gen <arg1> <arg2> <arg3>

Options
    required:
        arg1, --name <interface-name>, -n <interface-name>
            specific interface name to be used for the generated files
            
    optional:
        arg2, --root <path-to-root-dir>, -r <path-to-root-dir>
            specific root directory where all the files would be found
            defaults to the current working directory

        arg3, --mode <operation-mode>, -m <operation-mode>
            mode how the interface could be generated
            defaults to "union"

Examples
    $  interface-gen sample ../sample-interface-dir intersect-ignore
    ...
```

Current Functionality
---------------------

## xxinterface.md parsing
- takes all the `### /route` parts as route
- takes the corresponding `#### request` to extract the JSON speficiation, so we know the arguments
- generates the networkinterface file as `<name>interface.coffee`
- generates the sciroutes file as `<name>routes.coffee`
- generates the scihandlers file as `<name>handlers.coffee`
- generates the deployrequests file as `<name>deploy.http`
- generates the localrequests file as `<name>local.http`
- does not overwrite the hanlders! only fills the gaps of missing functions
- all files will be generated in the same directory as the source file


## xxinterface.coffee parsing

## xxroutes.coffee parsing

## xxhandlers.coffee parsing


## Operation modes
We know 3 different Operation modes

- `union` or `u`
- `intersect-ignore` or `ii`
- `intersect-cut` or `ic`

### union - u
- Essentially every function will be synchronized.
- If there is a function in any of the files which do not exist in the other files, it will be added and synchronized to the other files.

### intersect-ignore
- Here only the functions which exist on all the files will be synchronized.
- The functions which are missing in one of the files are ignored.

### intersect-cut
- Here only the functions which exist on all the files will be synchronized.
- The functions which are missing in one of the files are removed.



---

# Further steps

- discover bugs
- figure out potential next steps


All sorts of inputs are welcome, thanks!

---

# License
[Unlicense JhonnyJason style](https://hackmd.io/nCpLO3gxRlSmKVG3Zxy2hA?view)
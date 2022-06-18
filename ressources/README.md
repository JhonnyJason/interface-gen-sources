# interface-gen 

# Background
For most client-service communication we specify an interface and then have to implement both sides.
There is a general idea that every such interface should feel like a regular function call.
Also how the interface code looks like is a straightforward result of the interaface specificationa and vice-versa.

Although there appear to be projects like [swagger](https://swagger.io/) who already "fill" this gap. However it seemed much more reasonable to implement this to find the most convenient way how I may deal with my interfaces.

## Interface Files and their Purpose
First the interface will have it's `<name>`

- Documentation File: `<name>interface.md` (master)
- Interface File: `<name>interface.coffee` (master) - the client side interface
- Handlers File: `<name>handlers.coffee` (master)
- Routes File: `<name>routes.coffee` (slave) - the express routes
- Local Testing File: `<name>local.http` (slave)
- Deploy Testing File: `<name>deploy.http` (slave)

The interface-gen cli-tool will take the interface name as required argument. Then it would parse all the master files, synchronize the relevant changes and write all the files with the new contents.

The important Parts to be synchronized are:

- Head - title and version
- SectionHeads - section titles and section descriptions
- Routes - route names parameters and descriptions (are also referred to as Functions in the interface or handlers file)

### The Documentation File
The Documentation File is a Master file.

Rendered as MD this is the Human Readable documentation for the Routes.
The purpose is that people have an easier time to understand how to use the SCI.

#### Structure

##### Version
We should have a title line like: `# <title-of-the-interface> v0.1.2`
Everything above this line is basicly remembered but has no meaning to the `interface-gen.

Important is the version in the title this will be used to consider which of the files contains the newest contents. So remember to increase the version in the file where you do an update.

The version is optional and will be created as v0.0.0 if it does not exist. 

##### General Description
This is the text between the title line and the first section headline. 

It is optional and will not be created if it does not exist.

##### Sections
A section is identified by the section headline, which is second level headline like: `## <section-title>`

It is optional and will not be createrd if it does not exist.

##### Section Descriptions
This is the text between the section headline and the route headline.

It is optional and will not be created if it does not exist.

##### Routes
A Route is identified by a route headline, which is a third level headline like: `### <route-name>`

This is the mandatory part as the routes are the elements which need to be defined and synchronized.

##### Route Descriptions
This is the text between the route headline and the route request headline.

This is optional and will not be created if it does not exist.

##### Sample Request
The sample request is identified by a request headline, which is the fourth level headline going exactly like: `#### request`
All content between the sample request headline and the sample response headline should be within code blocks and be valid hjson.

This is mandatory for the definition of the parameters/arguments.

##### Sample Response
The sample response is identified by a response headline, which is the fourth level headline going exactly like: `#### reponse`

This is optional and highly recommended to have it in the documentation.



### The Interface File
The Interface File is a Master file.

This is the code to be used by a client to communicate to the service.

#### Structure
TODO

### The Handlers File
The Handlers File is a Master file.

This is the code to be used by the express routes to call the specific functions of the service.

#### Structure
TODO

### The Routes File
The Routes File is a Slave file.

This is the code for the routes to be directly used by express.

#### Structure
TODO
### The Local and Deploy Testing Files
The Local and Deploy Testing files are Slave files.

These files are created for testing convenience, using the [Rest Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) extension of VSCode.

Because as slave fils they are always overwritten, purpose is rather to copy them elsewhere and edit the specifics for testing.

#### Structure
TODO

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

We do have 3 master files:

- documentation file `xxinterface.md`
- client interface file `xxinterface.coffee`
- handlers file `xxhandlers.coffee`

We also have 3 slave files:

- routes file `xxroutes.coffee`
- local testing file `testinglocal.http`
- deploy testingfile `testingdeploy.http`

Master files are defining the specific content. Any synchronization mode is only applied to these files.
The Slave files are always being overwritten by the content resulting from the master files.
There cannot be any customized content in the slave files.

## General Function
Parsing all master files to recognize:

- version of the file
- sections of routes
- descriptions of a section
- routes within its section
- the arguments and the route names
- the descriptions of the routes

## xxinterface.md parsing 
TODO
- takes all the `### /route` parts as route
- takes the corresponding `#### request` to extract the JSON speficiation, so we know the arguments


## xxinterface.coffee parsing
- lines with `############################################################` 60x`#` are separator lines marking a separate Section
- sections may have a Section headline as `# ## Title of the Section` straight after the separation line
- sections may have a Section description consisting of multiple lines essentially being a complete commentBlock like:
    ```
    #
    # some description
    # other line
    #
    ```
- critical are the structure of function headline and function body they must comply to the following template:
    ```
    export {{{routeName}}} = (sciURL, {{{args}}}) ->
        requestObject = { {{{args}}} }
        requestURL = sciURL+"/{{{routeName}}}"
        return postData(requestURL, requestObject)
    ```
- also the functions may have a description as a complete commentBlock right above the function headline like:
    ```
    #
    # some description
    # other line
    #
    export {{{routeName}}} = (sciURL, {{{args}}}) ->
    ```



## xxhandlers.coffee parsing
TODO


## Operation modes
We know 3 different Operation modes

- `union` or `u`
- `intersect-ignore` or `ii`
- `intersect-cut` or `ic`

### union - u
- Essentially every route will be synchronized. 
- If there is a function in any of the files which do not exist in the other files, it will be added and synchronized to the other files.
- If the same route has a different argument or description the content from the newest version will be applied to the others

### intersect-ignore
- Here only the functions which exist on all the files will be synchronized.
- The functions which are missing in one of the files are ignored.
- If the same route has a different argument or description the content from the newest version will be applied to the others

### intersect-cut
- Here only the functions which exist on all the files will be synchronized.
- The functions which are missing in one of the files are removed.
- If the same route has a different argument or description the content from the newest version will be applied to the others


---

# Further steps

- discover bugs
- figure out potential next steps


All sorts of inputs are welcome, thanks!

---

# License
[Unlicense JhonnyJason style](https://hackmd.io/nCpLO3gxRlSmKVG3Zxy2hA?view)
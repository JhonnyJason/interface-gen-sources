# interface-gen 

# Background
For most client-service communication we specify an interface and then have to implement both sides.
However every such interface should feel like a regular function call.
So how the interface code looks like is from the specification straightforward.
Although there appear to be projects like [swagger](https://swagger.io/) who already "fill" this gap. It seems to to a lot more I don't need and which I don't understand. So it seemed much easier to implement this than understanding how I could use their solution to my problem^^.


The interface-gen cli-tool will take a interface specification as the form of `my-nice-sci.md` file how I would naturally specify an interface. Then it would generate the `networkinterface` which is used by the client to communicate with the service. Also it would generate the `sciroutes` and `scihandlers`  which are the corresponding parts of the service.

# How?
Requirements
------------
- [nodejs](https://nodejs.org/en/)
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

Usage
-----
```
Usage
    $ interface-gen <arg1> <arg2>

Options
    required:
        arg1, --source <path/to/source>, -s <path/to/source>
            source of the interface definition in md

    optional:
        arg2, --name <interface-name>, -n <interface-name>
            specific interface name to be used for the generated files
            defaults to filename of the source.

Examples
    $  interface-gen definition.md sampleinterface
    ...
```

Current Functionality
---------------------
- takes all the `### /route` parts as route
- takes the corresponding `#### request` to extract the JSON speficiation, so we know the arguments
- generates the networkinterface file as `<name>interface.coffee`
- generates the sciroutes file as `<name>routes.coffee`
- generates the scihandlers file as `<name>handlers.coffee`
- does not overwrite the hanlders! only fills the gaps of missing functions
- all files will be generated in the same directory as the source file

---

# Further steps

- discover bugs
- figure out potential next steps


All sorts of inputs are welcome, thanks!

---

# License

## The Unlicense JhonnyJason style

- Information has no ownership.
- Information only has memory to reside in and relations to be meaningful.
- Information cannot be stolen. Only shared or destroyed.

And you wish it has been shared before it is destroyed.

The one claiming copyright or intellectual property either is really evil or probably has some insecurity issues which makes him blind to the fact that he also just connected information which was freely available to him.

The value is not in him who "created" the information the value is what is being done with the information.
So the restriction and friction of the informations' usage is exclusively reducing value overall.

The only preceived "value" gained due to restriction is actually very similar to the concept of blackmail (power gradient, control and dependency).

The real problems to solve are all in the "reward/credit" system and not the information distribution. Too much value is wasted because of not solving the right problem.

I can only contribute in that way - none of the information is "mine" everything I "learned" I actually also copied.
I only connect things to have something I feel is missing and share what I consider useful. So please use it without any second thought and please also share whatever could be useful for others. 

I also could give credits to all my sources - instead I use the freedom and moment of creativity which lives therein to declare my opinion on the situation. 

*Unity through Intelligence.*

We cannot subordinate us to the suboptimal dynamic we are spawned in, just because power is actually driving all things around us.
In the end a distributed network of intelligence where all information is transparently shared in the way that everyone has direct access to what he needs right now is more powerful than any brute power lever.

The same for our programs as for us.

It also is peaceful, helpful, friendly - decent. How it should be, because it's the most optimal solution for us human beings to learn, to connect to develop and evolve - not being excluded, let hanging and destroy oneself or others.

If we really manage to build an real AI which is far superior to us it will unify with this network of intelligence.
We never have to fear superior intelligence, because it's just the better engine connecting information to be most understandable/usable for the other part of the intelligence network.

The only thing to fear is a disconnected unit without a sufficient network of intelligence on its own, filled with fear, hate or hunger while being very powerful. That unit needs to learn and connect to develop and evolve then.

We can always just give information and hints :-) The unit needs to learn by and connect itself.

Have a nice day! :D
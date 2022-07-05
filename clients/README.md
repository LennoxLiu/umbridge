# Clients

Refer to the clients in this repository for working examples of the client integrations shown in the following.

## Python client

Using the umbridge.py module, connecting to a server is as easy as

```
import umbridge

model = umbridge.HTTPModel("http://localhost:4242")
```

Now that we have connected to a model, we can query its input and output dimensions.

```
print(model.get_input_sizes())
print(model.get_output_sizes())
```

Evaluating a model that expects an input consisting of a single 2D vector then consists of the following.

```
print(model([[0.0, 10.0]]))
```

Finally, additional configuration options may be passed to the model in a JSON-compatible Python structure.

```
print(model([[0.0, 10.0]], {"level": 0}))
```

Each time, the output of the model evaluation is an array of arrays containing the output defined by the model.

## C++ client

The c++ client abstraction is part of the umbridge.h header-only library. Note that it has some header-only dependencies by itself.

Invoking it is mostly analogous to the above. Note that HTTP headers may optionally be used, for example to include access tokens.

```
umbridge::HTTPModel client("http://localhost:4242");
```

As before, we can query input and output dimensions.

```
client.inputSizes
client.outputSizes
```

In order to evaluate the model, we first define an input. Input to a model may consist of multiple vectors, and is therefore of type std::vector<std::vector<double>>. The following example creates a single 2D vector in that structure.

```
std::vector<std::vector<double>> inputs {{100.0, 18.0}};
```

The input vector can then be passed into the model.

```
client.Evaluate(input);
```

Optionally, configuration options may be passed to the model using a JSON structure.

```
json config;
config["level"] = 0;
client.Evaluate(input, config);
```

Each time, the output of the model evaluation is an vector of vectors containing the output defined by the model.

## MUQ client

Within the [MIT Uncertainty Quantification library (MUQ)](https://mituq.bitbucket.io), there is a ModPiece available that allows embedding an HTTP model in MUQ's model graph framework.

```
auto modpiece = std::make_shared<HTTPModPiece>("http://localhost:4242");
```

The HTTPModPiece optionally allows passing a configuration to the model as in the c++ case.

```
json config;
config["level"] = 0;
auto modpiece = std::make_shared<HTTPModPiece>("http://localhost:4242", config);
```

Apart from the constructor, HTTPModPiece behaves like any ModPiece in MUQ. For example, models or benchmarks outputting a posterior density may be directly passed into a SamplingProblem, to which Markov Chain Monte Carlo methods provided by MUQ may then be applied for sampling.


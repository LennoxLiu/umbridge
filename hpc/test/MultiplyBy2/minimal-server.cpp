#include <iostream>
#include <string>
#include <chrono>
#include <thread>

#include "../../../lib/umbridge.h"

void logMessage(const std::string& message) {
    // Get the current time point
    auto currentTime = std::chrono::system_clock::now();
    
    // Convert the time point to a time_t object
    std::time_t currentTime_t = std::chrono::system_clock::to_time_t(currentTime);

    // Convert the time_t to a struct tm in local time
    std::tm* localTime = std::localtime(&currentTime_t);

    // Format the timestamp
    std::cout << "[" << std::put_time(localTime, "%Y-%m-%d %H:%M:%S") << "] server: " << message << std::endl;
}

class ExampleModel : public umbridge::Model
{
public:
    ExampleModel(int test_delay, std::string name = "forward")
        : umbridge::Model(name),
          test_delay(test_delay)
    {
    }

    // Define input and output dimensions of model (here we have a single vector of length 1 for input; same for output)
    std::vector<std::size_t> GetInputSizes(const json &config_json) const override
    {
        return {1};
    }

    std::vector<std::size_t> GetOutputSizes(const json &config_json) const override
    {
        return {1};
    }

    std::vector<std::vector<double>> Evaluate(const std::vector<std::vector<double>> &inputs, json config) override
    {
        // Do the actual model evaluation; here we just multiply the first entry of the first input vector by two, and store the result in the output.
        // In addition, we support an artificial delay here, simulating actual work being done.
        std::this_thread::sleep_for(std::chrono::milliseconds(test_delay));

        return {{inputs[0][0] * 2.0}};
    }

    // Specify that our model supports evaluation. Jacobian support etc. may be indicated similarly.
    bool SupportsEvaluate() override
    {
        return true;
    }

private:
    int test_delay;
};

// run and get the result of command
std::string getCommandOutput(const std::string command)
{
    FILE *pipe = popen(command.c_str(), "r"); // execute the command and return the output as stream
    if (!pipe)
    {
        std::cerr << "Failed to execute the command: " + command << std::endl;
        logMessage("Failed to execute the command: " + command);
        return "";
    }

    char buffer[128];
    std::string output;
    while (fgets(buffer, 128, pipe))
    {
        output += buffer;
    }
    pclose(pipe);

    return output;
}

int main(int argc, char *argv[])
{

    // Read environment variables for configuration
    char const *port_cstr = std::getenv("PORT");
    int port = 0;
    if (port_cstr == NULL)
    {
        logMessage("Environment variable PORT not set! Using port 4242 as default.");
        port = 4242;
    }
    else
    {
        logMessage("Environment variable PORT set to " + std::string(port_cstr) + ".");
        port = atoi(port_cstr);
    }

    char const *delay_cstr = std::getenv("TEST_DELAY");
    int test_delay = 0;
    if (delay_cstr != NULL)
    {
        test_delay = atoi(delay_cstr);
    }
    logMessage("Evaluation delay set to " + std::to_string(test_delay) + " ms.");

    // Set up and serve model
    ExampleModel model(test_delay);
    ExampleModel model2(15, "backward");
    ExampleModel model3(10, "inward");
    ExampleModel model4(5, "outward");

    std::string hostname = "0.0.0.0";
  
    logMessage("Hosting server at : http://" + hostname + ":" + std::to_string(port));
    
    umbridge::serveModels({&model,&model2,&model3,&model4}, hostname, port); // start server at the hostname

    logMessage("Server exit: http://" + hostname + ":" + std::to_string(port));
    return 0;
}

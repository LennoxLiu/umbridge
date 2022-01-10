import httpmodel
import scipy.stats

class Benchmark(httpmodel.Model):
    def __init__(self, model_url):
        self.model = httpmodel.HTTPModel(model_url)

    def get_input_sizes(self):
        return self.model.get_input_sizes()

    def get_output_sizes(self):
        return [1]

    def __call__(self, parameters, config={}):
        level = config["level"]

        # Cut-off prior
        if not (-239 < parameters[0][0] < 739) or not (-339 < parameters[0][1] < 339):
            return 1234

        # Likelihood definition
        model_output = self.model(parameters, config)[0]

        data = [1813.8, 0.00185232, 5278.8, 0.0006368]
        likelihood_std_dev_time = [2.5, 1.5, 0.75]
        likelihood_std_dev_height = [0.15, 0.1, 0.1]

        likelihood_cov_matrix_diag = [likelihood_std_dev_time[level]**2, likelihood_std_dev_height[level]**2] * 2

        posterior = scipy.stats.multivariate_normal.logpdf(model_output, data, likelihood_cov_matrix_diag)
        return [[posterior]]

benckmark = Benchmark("http://localhost:4242")

httpmodel.serve_model(benckmark, 4243)
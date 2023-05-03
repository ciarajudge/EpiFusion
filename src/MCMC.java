import java.util.Random;
public class MCMC {
    private final ParticleFilter particleFilter;
    private final Random random;

    public MCMC(ParticleFilter particleFilter) {
        this.particleFilter = particleFilter;
        this.random = new Random();
    }

    public void runMCMC(int numIterations) {
        double[] currentParams = this.particleFilter.getCurrentParameters();
        double[] proposalStdDevs = {0.1, 0.1, 0.1}; // example proposal standard deviations

        for (int i = 0; i < numIterations; i++) {
            // Generate a proposal for the next set of parameters
            double[] candidateParams = new double[3];
            for (int j = 0; j < 3; j++) {
                candidateParams[j] = currentParams[j] + this.random.nextGaussian() * proposalStdDevs[j];
            }

            // Run particle filter to generate logPrior and logLikelihood for new params
            particleFilter.runPF(candidateParams);

            // Evaluate the acceptance probability for the proposal
            double acceptanceProbability = this.computeAcceptanceProbability();

            // Accept or reject the proposal based on the acceptance probability
            if (this.random.nextDouble() < acceptanceProbability) {
                currentParams = candidateParams;
            }

            // Update the particle filter with the current set of parameters
            this.particleFilter.resetCurrentParameters();
        }
    }

    private double computeAcceptanceProbability() {
        // Compute the acceptance probability based on the likelihood of the data given
        // the current and candidate sets of parameters
        double logLikelihoodCurrent = this.particleFilter.getLogLikelihoodCurrent();
        double logLikelihoodCandidate = this.particleFilter.getLogLikelihoodCandidate();
        double logPriorCurrent = this.particleFilter.getLogPriorCurrent();
        double logPriorCandidate = this.particleFilter.getLogPriorCandidate();

        double logNumerator = logLikelihoodCandidate + logPriorCandidate
                - logLikelihoodCurrent - logPriorCurrent;
        return Math.min(1.0, Math.exp(logNumerator));
    }


}

import java.io.IOException;
import java.util.Arrays;
import java.util.Random;


public class MCMC {
    private final ParticleFilter particleFilter;
    private final Random random;
    public Loggers loggers;


    public MCMC(ParticleFilter particleFilter) throws IOException {
        this.particleFilter = particleFilter;
        this.random = new Random();
        this.loggers = new Loggers();
        loggers.logTrajectory(particleFilter.particles.particles[0].traj);
   }

    public void runMCMC(int numIterations) throws IOException {
        double[] currentParameters = this.particleFilter.getCurrentParameters();
        double[] proposalStdDevs = {0.00001, 0.00001, 0.0001, 0.0001, 0.0001}; // example proposal standard deviations

        for (int i = 0; i < numIterations; i++) {
            System.out.println();
            System.out.println("MCMC STEP "+i);
            // Generate a proposal for the next set of parameters
            double[] candidateParameters = new double[currentParameters.length]; //empty array for candidates
            for (int j=0; j<candidateParameters.length; j++){
                candidateParameters[j] = currentParameters[j] + this.random.nextGaussian() * proposalStdDevs[j];
            }
            System.out.println("Candidate params: "+ Arrays.toString(candidateParameters));

            // Run particle filter to generate logPrior and logLikelihood for new params
            particleFilter.runPF(candidateParameters);


            // Evaluate the acceptance probability for the proposal
            double acceptanceProbability = this.computeAcceptanceProbability();

            // Accept or reject the proposal based on the acceptance probability
            if (this.random.nextDouble() < acceptanceProbability) {
                particleFilter.particles.printTrajectories();
                System.out.println("Step Accepted");
                currentParameters = candidateParameters;
                loggers.logTrajectory(particleFilter.particles.particles[0].traj);
                this.particleFilter.resetCurrentParameters();
                break;
            } else {
                System.out.println("Step Not Accepted");
                //loggers.logTrajectory(particleFilter.particles.particles[0].traj, "notaccepted");
            }

            // Clear the pf cache
            this.particleFilter.clearCache();

        }
    }

    private double computeAcceptanceProbability() {
        // Compute the acceptance probability based on the likelihood of the data given
        // the current and candidate sets of parameters
        double logLikelihoodCurrent = this.particleFilter.getLogLikelihoodCurrent();
        double logLikelihoodCandidate = this.particleFilter.getLogLikelihoodCandidate();
        double logPriorCurrent = this.particleFilter.getLogPriorCurrent();
        double logPriorCandidate = this.particleFilter.getLogPriorCandidate();

        double acceptanceRatio = (logLikelihoodCandidate * logPriorCandidate) / (logLikelihoodCurrent * logPriorCurrent);
        return Math.min(1.0, acceptanceRatio);
    }


}

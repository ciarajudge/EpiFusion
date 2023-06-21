import java.io.IOException;
import java.util.Arrays;
import java.util.Objects;
import java.util.Random;


public class MCMC {
    private final ParticleFilter particleFilter;
    private final Random random;
    public Loggers loggers;


    public MCMC(ParticleFilter particleFilter) throws IOException {
        this.particleFilter = particleFilter;
        this.random = new Random();
        this.loggers = Objects.equals(Storage.fileBase, "null") ? new Loggers() : new Loggers(Storage.fileBase);
        loggers.logTrajectory(particleFilter.particles.particles[0].traj);
        loggers.logLogLikelihood(particleFilter.getLogLikelihoodCandidate());
   }

    public void runMCMC(int numIterations) throws IOException {
        double[] currentParameters = this.particleFilter.getCurrentParameters();

        for (int i = 0; i < numIterations; i++) {
            System.out.println();
            System.out.println("MCMC STEP "+i);
            // Generate a proposal for the next set of parameters
            double[] candidateParameters = new double[currentParameters.length]; //empty array for candidates
            do {
                for (int j = 0; j < candidateParameters.length; j++) {
                    candidateParameters[j] = outarctanh(arctanh(currentParameters[j]) + this.random.nextGaussian() * Storage.stepCoefficient);
                }
            } while (checkParams(candidateParameters) == 0);
            System.out.println("Candidate params: "+ Arrays.toString(candidateParameters));

            // Run particle filter to generate logPrior and logLikelihood for new params
            particleFilter.runPF(candidateParameters);

            for (Particle particle : particleFilter.particles.particles) {
                if (particle == null) {
                    System.out.println("Particle Null");
                }
            }


            // Evaluate the acceptance probability for the proposal
            double acceptanceProbability = this.computeAcceptanceProbability();
            loggers.logLogLikelihood(particleFilter.getLogLikelihoodCandidate());
            loggers.logTrajectory(particleFilter.particles.particles[0].traj);
            loggers.logParams(candidateParameters);
            // Accept or reject the proposal based on the acceptance probability
            if (this.random.nextDouble() < acceptanceProbability) {
                //particleFilter.particles.printTrajectories();
                System.out.println("Step Accepted");
                currentParameters = candidateParameters;
                this.particleFilter.resetCurrentParameters();
                loggers.logAcceptance(0);
            } else {
                System.out.println("Step Not Accepted");
                loggers.logAcceptance(1);
                //loggers.logTrajectory(particleFilter.particles.particles[0].traj, "notaccepted");
            }

            // Clear the pf cache
            this.particleFilter.clearCache();

        }
    }

    private double arctanh(double param) {
        return 0.5 * Math.log((1+param)/(1-param));
    }

    private double outarctanh(double param) {
        double a = Math.exp(2*param);
        double b = (a-1)/(1+a);
        return b;
    }

    public double checkParams(double[] candidateParameters) {
        double logPrior = 1.0;
        for (int d=0; d<candidateParameters.length; d++) {
            //System.out.println(Storage.priors.allPriors[d].density(currentParameters[d]));
            //System.out.println("Prior prob:"+Storage.priors.priors[d].density(candidateParameters[d]));
            logPrior *= Storage.priors.priors[d].density(candidateParameters[d]);
        }
        System.out.println(logPrior);
        return logPrior;
    }

    private double computeAcceptanceProbability() {
        // Compute the acceptance probability based on the likelihood of the data given
        // the current and candidate sets of parameters
        double logLikelihoodCurrent = this.particleFilter.getLogLikelihoodCurrent();
        System.out.println("Current log likelihood: "+logLikelihoodCurrent);
        double logLikelihoodCandidate = this.particleFilter.getLogLikelihoodCandidate();
        System.out.println("This run log likelihood: "+logLikelihoodCandidate);
        double logPriorCurrent = this.particleFilter.getLogPriorCurrent();
        System.out.println("Current log prior: "+logPriorCurrent);
        double logPriorCandidate = this.particleFilter.getLogPriorCandidate();
        System.out.println("Candidate log prior: "+logPriorCandidate);

        double logAcceptanceRatio = logLikelihoodCandidate + logPriorCandidate - (logLikelihoodCurrent + logPriorCurrent);
        System.out.println("Log acceptance ratio "+logAcceptanceRatio);
        double acceptanceRatio = Math.exp(logAcceptanceRatio);
        System.out.println("Acceptance ratio: " + acceptanceRatio);
        return Math.min(1.0, acceptanceRatio);
    }


}

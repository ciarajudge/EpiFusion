import java.io.IOException;
import java.util.Objects;
import java.util.Random;

public class Debug {
    private final ParticleFilter particleFilter;
    private final Random random;
    public Loggers loggers;
    public int acceptanceRate = 0;


    public Debug(ParticleFilter particleFilter) throws IOException {
        this.particleFilter = particleFilter;
        this.random = new Random();
        this.loggers = Objects.equals(Storage.fileBase, "null") ? new Loggers() : new Loggers(Storage.fileBase);
    }

    public void runDebug(double[] params) throws IOException {
        // Run particle filter to generate logPrior and logLikelihood for new params
            particleFilter.runPF(params);

            loggers.logLogLikelihoodAccepted(particleFilter.getLogLikelihoodCandidate());
            loggers.logAllTrajectories(particleFilter.particles);

            // Clear the pf cache
            this.particleFilter.clearCache();
    }

    private double transform(double param) {
        return Math.log(Math.abs(param));
    }

    private double untransform(double param) {
        return Math.exp(param);
    }

    public double checkParams(double[] candidateParameters) {
        double logPrior = 1.0;
        for (int d=0; d<candidateParameters.length; d++) {
            //System.out.println(Storage.priors.allPriors[d].density(currentParameters[d]));
            //System.out.println("Prior prob:"+Storage.priors.priors[d].density(candidateParameters[d]));
            logPrior *= Storage.priors.priors[d].density(candidateParameters[d]);
        }
        //System.out.println(logPrior);
        return logPrior;
    }

    private double computeAcceptanceProbability() {
        // Compute the acceptance probability based on the likelihood of the data given
        // the current and candidate sets of parameters
        double logLikelihoodCurrent = this.particleFilter.getLogLikelihoodCurrent();
        double logLikelihoodCandidate = this.particleFilter.getLogLikelihoodCandidate();
        double logPriorCurrent = this.particleFilter.getLogPriorCurrent();
        double logPriorCandidate = this.particleFilter.getLogPriorCandidate();

        double logAcceptanceRatio = logLikelihoodCandidate + logPriorCandidate - (logLikelihoodCurrent + logPriorCurrent);
        double acceptanceRatio = Math.exp(logAcceptanceRatio);
        return Math.min(1.0, acceptanceRatio);
    }

    private double[] getCandidateParameters(double[] currentParameters, double cooling) {
        double[] candidateParameters = new double[currentParameters.length]; //empty array for candidates
        do {
            for (int j = 0; j < candidateParameters.length; j++) {
                boolean negative = currentParameters[j] < 0;
                double newparam = untransform(transform(currentParameters[j]) + this.random.nextGaussian() * cooling);
                candidateParameters[j] = negative ? -newparam : newparam;
            }
        } while (checkParams(candidateParameters) == 0);
        return candidateParameters;
    }

}

import java.io.IOException;
import java.util.Arrays;

import java.util.Objects;
import java.util.Random;


public class MCMC {
    private final ParticleFilter particleFilter;
    private final Random random;
    public int acceptanceRate = 0;


    public MCMC(ParticleFilter particleFilter) throws IOException {
        this.particleFilter = particleFilter;
        this.random = new Random();
        particleFilter.loggers.logTrajectory(particleFilter.currentSampledParticle.traj);
        particleFilter.loggers.logParams(particleFilter.getCurrentParameters());
        particleFilter.loggers.logLogLikelihoodAccepted(particleFilter.getLogLikelihoodCurrent());
        //loggers.saveParticleLikelihoodBreakdown(particleFilter.currentSampledParticle.likelihoodMatrix, -1, particleFilter.getLogLikelihoodCurrent());
        if (Storage.analysisType == 1) {
            particleFilter.loggers.logBeta(particleFilter.currentSampledParticle.beta);
        }
        Storage.initialised = true;
    }

    public void runMCMC(int numIterations) throws IOException {
        double[] currentParameters = this.particleFilter.getCurrentParameters();


        for (int i = 0; i < numIterations; i++) {

            // Generate a proposal for the next set of parameters
            double[] candidateParameters = getCandidateParameters(currentParameters, Storage.stepCoefficient); //version without cooling
            //System.out.println("Candidate params " + Arrays.toString(candidateParameters));


            // Run particle filter to generate logPrior and logLikelihood for new params
            particleFilter.runPF(candidateParameters);
            //particleFilter.particles.particles[0].traj.printTrajectory();
            //System.out.println(particleFilter.getLogLikelihoodCandidate());
            //System.out.println(particleFilter.getLogPriorCandidate());


            // Evaluate the acceptance probability for the proposal
            double acceptanceProbability = this.computeAcceptanceProbability();
            //System.out.println(acceptanceProbability);
            //System.out.println();
            // Accept or reject the proposal based on the acceptance probability
            if (this.random.nextDouble() < acceptanceProbability) {
                //particleFilter.particles.printTrajectories();
                //System.out.println("Step Accepted");
                //System.out.println("Current Log Likelihood: "+particleFilter.getLogLikelihoodCurrent());
                //System.out.println("Candidate Log Likelihood: "+particleFilter.getLogLikelihoodCandidate());
                //System.out.println("Acceptance Probability: "+acceptanceProbability);
                //System.out.println();
                currentParameters = candidateParameters;
                this.particleFilter.resetCurrentParameters();
                particleFilter.loggers.logAcceptance(0);
                acceptanceRate += 1;
            } else {
                //System.out.println("Step Not Accepted");
                //System.out.println("Current Log Likelihood: "+particleFilter.getLogLikelihoodCurrent());
                //System.out.println("Candidate Log Likelihood: "+particleFilter.getLogLikelihoodCandidate());
                //System.out.println("Acceptance Probability: "+acceptanceProbability);
                //System.out.println();
                particleFilter.loggers.logAcceptance(1);

                //loggers.logTrajectory(particleFilter.particles.particles[0].traj, "notaccepted");
            }

            if (i % Storage.logEvery == 0 ) {
                System.out.println();
                System.out.println("CHAIN "+particleFilter.chainID);
                System.out.println("MCMC STEP "+i);
                System.out.println("Candidate params: "+ Arrays.toString(candidateParameters));
                System.out.println("Current likelihood: "+ particleFilter.getLogLikelihoodCurrent());
                System.out.println("Acceptance rate: "+ ((double) acceptanceRate/Storage.logEvery)*100+"%");
                System.out.println("Completed runs: "+  Storage.completedRuns);
                Storage.completedRuns = 0;
                acceptanceRate = 0;
                System.out.println("Beta: "+particleFilter.currentSampledParticle.beta);
                particleFilter.loggers.logLogLikelihoodAccepted(particleFilter.getLogLikelihoodCurrent());
                particleFilter.loggers.logTrajectory(particleFilter.currentSampledParticle.traj);
                if (Storage.analysisType != 0) {
                    particleFilter.loggers.logBeta(particleFilter.currentSampledParticle.beta);
                }
                particleFilter.loggers.logParams(currentParameters);
            }

            // Clear the pf cache
            this.particleFilter.clearCache();
        }

        System.out.println();
        System.out.println("CHAIN "+particleFilter.chainID+" COMPLETE");
        System.out.println("Final likelihood: "+ particleFilter.getLogLikelihoodCurrent());
        System.out.println("Beta: "+particleFilter.currentSampledParticle.beta);
    }

    private double transform(double param) {
        return Math.log(Math.abs(param));
    }

    private double untransform(double param) {
        return Math.exp(param);
    }

    public double checkParams(double[] candidateParameters) {
        double logPrior = 1.0;
        int d = 0;
        for (Parameter param: Storage.priors.parameters) {
            for (Prior prior:param.priors) {
                logPrior *= prior.density(candidateParameters[d]);
                d+=1;
            }
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
                if (Storage.priors.fixed[j]) {
                    candidateParameters[j] = currentParameters[j];
                    continue;
                }
                boolean negative = currentParameters[j] < 0;
                double newparam = untransform(transform(currentParameters[j]) + this.random.nextGaussian() * cooling);
                candidateParameters[j] = negative ? -newparam : newparam;
                if (Storage.priors.discrete[j]) {
                    candidateParameters[j] = Math.round(candidateParameters[j]);
                }
            }
        } while (checkParams(candidateParameters) == 0);
        return candidateParameters;
    }

    public void terminateLoggers() throws IOException {
        particleFilter.loggers.terminateLoggers();
    }

}

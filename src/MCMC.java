import java.io.IOException;
import java.util.Arrays;
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

            // Run particle filter to generate logPrior and logLikelihood for new params
            particleFilter.runPF(candidateParameters);

            //Compute acceptance probability
            double acceptanceProbability = this.computeAcceptanceProbability();

            // Accept or reject the proposal based on the acceptance probability
            if (this.random.nextDouble() < acceptanceProbability) {
                currentParameters = candidateParameters;
                this.particleFilter.resetCurrentParameters();
                particleFilter.loggers.logAcceptance(0);
                acceptanceRate += 1;
            } else {
                particleFilter.loggers.logAcceptance(1);
            }

            //If it's a log, print to terminal
            if (i % Storage.logEvery == 0 ) {
                System.out.println();
                System.out.println("CHAIN "+particleFilter.chainID);
                System.out.println("MCMC STEP "+i);
                System.out.println("Current params: "+ Arrays.toString(currentParameters));
                System.out.println("Current likelihood: "+ particleFilter.getLogLikelihoodCurrent());
                System.out.println("CurrentBeta: "+particleFilter.currentSampledParticle.beta);
                particleFilter.loggers.logLogLikelihoodAccepted(particleFilter.getLogLikelihoodCurrent());
                particleFilter.loggers.logTrajectory(particleFilter.currentSampledParticle.traj);
                if (Storage.analysisType != 0 && Storage.analysisType != 3) {
                    particleFilter.loggers.logBeta(particleFilter.currentSampledParticle.beta);
                }
                particleFilter.loggers.logParams(currentParameters);
                System.out.println("Acceptance rate: "+ ((double) acceptanceRate/Storage.logEvery)*100+"%");
                System.out.println("Completed runs: "+  Storage.completedRuns);
                Storage.completedRuns = 0;
                acceptanceRate = 0;
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

    private double[][] makeParamMatrix(int numIterations) { //this is for me when I was doing likelihood checking against BDSky
        double[][] paramMatrix = new double[numIterations][4];
        double[] betaValues = {0.005,0.0055,0.006,0.0065,0.007,0.0075,0.008,0.0085,0.009,0.0095,0.01,0.0105,0.011,0.0115,0.012,0.0125,0.013,0.0135,0.014,0.0145,0.015,0.0155,0.016,0.0165,0.017,0.0175,0.018,0.0185,0.019,0.0195,0.02,0.0205,0.021,0.0215,0.022,0.0225,0.023,0.0235,0.024,0.0245,0.025,0.0255,0.026,0.0265,0.027,0.0275,0.028,0.0285,0.029,0.0295,0.03};

        int start = 0;
        int end;
        for (int j=0; j<betaValues.length; j++) {
            double beta = betaValues[j];
            end = start + 100;
            for (int i=start; i<end; i++) {
                paramMatrix[i][0] = 0.143;
                paramMatrix[i][1] = beta;
                paramMatrix[i][2] = 0.1;
                paramMatrix[i][3] = 0.25;
            }
            start = end;
        }
        return paramMatrix;
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

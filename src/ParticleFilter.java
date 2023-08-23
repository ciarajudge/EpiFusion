import java.util.Arrays;
import java.util.ArrayList;
import java.io.IOException;

public class ParticleFilter {
    private double[][] currentRates;
    private double[][] candidateRates;
    private double[] currentParameters;
    private double[] candidateParameters;
    public Particles particles;
    private double logLikelihoodCurrent;
    private double logLikelihoodCandidate;
    private double logPriorCurrent;
    private double logPriorCandidate;
    public Tree tree;
    public Incidence caseIncidence;
    public int T;
    private final int filterSteps;
    private final int resampleEvery;
    int increments;
    private final int numParticles;
    public Particle currentSampledParticle;

    public ParticleFilter() throws IOException {
        this.numParticles = Storage.numParticles;
        this.tree = Storage.tree;
        this.caseIncidence = Storage.incidence;
        this.T = Storage.T;
        this.resampleEvery = Storage.resampleEvery;
        this.filterSteps = (int) Math.ceil(this.T / (double) Storage.resampleEvery);
        this.candidateRates = new double[this.T][5];

        particles = new Particles(numParticles);
        initialisePF(Storage.numInitialisationAttempts);
    }

    public void initialisePF(int numAttempts) throws IOException {
        double likelihood = Double.NEGATIVE_INFINITY;
        for (int i=0; i<numAttempts; i++) {
            //Storage.particleLoggers = new ParticleLoggers(i);
            System.out.println("Initialisation attempt "+(i+1));
            runPF(Storage.priors.sampleInitial());
            System.out.println("Log Likelihood: "+logLikelihoodCandidate);
            System.out.println("Parameters: "+Arrays.toString(candidateParameters));
            //System.out.println("Betas:");
            //particles.printBetas();
            particles.particles[0].traj.printTrajectory();
            //Storage.particleLoggers.saveParticleLikelihoodBreakdown(particles.particles[0].likelihoodMatrix, i, logLikelihoodCandidate);
            if (likelihood < logLikelihoodCandidate) {
                currentParameters = candidateParameters;
                logLikelihoodCurrent = logLikelihoodCandidate;
                likelihood = logLikelihoodCandidate;
                currentSampledParticle = new Particle(particles.particles[0], 0);
            }
            //Storage.particleLoggers.terminateLoggers();
        }
        System.out.println("Final parameter set: "+Arrays.toString(currentParameters));
        System.out.println("Initial LL: "+logLikelihoodCurrent);
    }

    public void runPF(double[] parameters) throws IOException {
        clearCache();
        //Convert parameters into rates
        candidateParameters = parameters;
        parametersToRates();
        //printRateVector(0);
        logLikelihoodCandidate = 0.0;
        for (int step=0; step<filterSteps; step++) {
            if (!(Storage.isPhyloOnly() && tree.treeFinished(step))){
                if (filterStep(step)) {
                    //All the particles are neg infinity so break the steps
                    logLikelihoodCandidate = Double.NEGATIVE_INFINITY;
                    //System.out.println("Full run not completed");
                    break;
                } else {
                    Storage.completedRuns++;
                }
            }
            else {
                //System.out.println("Model only running with Phylo and the tree is terminated.");
                break;
            }

        }

        logPriorCandidate = calculatePFLogPrior();
        //particles.printTrajectories();
    }


    public boolean filterStep(int step)  throws IOException {
        increments = Math.min(resampleEvery, (T-(step*resampleEvery)));
        //Epi Only Scenario
        if (Storage.isEpiOnly()) {
            particles.epiOnlyPredictAndUpdate(step, getRatesForStep(step), increments);
            particles.getEpiLikelihoods(caseIncidence.incidence[step], candidateRates[step][3]);
            if (particles.checkEpiLikelihoods()) {return true;}
        }

        //If Phylo is involved at all
        else {
            particles.predictAndUpdate(step, tree, getRatesForStep(step), increments);
            if (particles.checkPhyloLikelihoods()) {return true;}

            //If it's a combined run get the epi likelihoods and check them
            if (!Storage.isPhyloOnly()){
                particles.getEpiLikelihoods(caseIncidence.incidence[step],  candidateRates[step][3]);
                if (particles.checkEpiLikelihoods()) {return true;}
            }
        }

        particles.checkStates(Storage.maxEpidemicSize);
        if (Storage.tooBig) {return true;}


        //Scale weights and add to logP
        double logP = particles.scaleWeightsAndGetLogP();
        logLikelihoodCandidate += logP;

        //resample
        particles.resampleParticles();
        checkParticles();


        return false;
    }

    //PF Calculators
    public double calculatePFLogPrior() {
        double logPrior = 1.0;
        for (int d=0; d<candidateParameters.length; d++) {
            logPrior *= Storage.priors.priors[d].density(candidateParameters[d]);
        }
        logPrior = Math.log(logPrior);
        return logPrior;
    }


    //Getters
    public double[][] getCurrentRates() {return currentRates;}
    public double[][] getCandidateRates() {return candidateRates;}
    public double[] getCurrentParameters() {return currentParameters;}
    public double getLogLikelihoodCurrent() {return logLikelihoodCurrent; }
    public double getLogLikelihoodCandidate() {return logLikelihoodCandidate; }
    public double getLogPriorCurrent() {return logPriorCurrent; }
    public double getLogPriorCandidate() {return logPriorCandidate; }
    private double[] getRateVector(int index) {
        double[] rateVector = new double[T];
        for (int i = 0; i< T; i++) {
            rateVector[i] = candidateRates[i][index];
        }
        return rateVector;
    }
    private double[][] getRatesForStep(int step) {
        double[][] ratesForStep = new double[resampleEvery][4];
        int begin = step*resampleEvery;
        int ind = 0;
        for (int i=begin; i<begin+increments; i++){
            ratesForStep[ind] = candidateRates[i];
            ind++;
        }
        return ratesForStep;
    }


    //Setters
    public void resetCurrentParameters() { //Special case, resets current to candidates (called if MCMC step is accepted)
        this.currentParameters = this.candidateParameters;
        this.currentRates = this.candidateRates;
        this.logLikelihoodCurrent = this.logLikelihoodCandidate;
        this.logPriorCurrent = this.logPriorCandidate;
    }


    //Printers
    private void printRateVector(int index) {
        double[] rateVector = getRateVector(index);
        for (double r : rateVector) {
            System.out.print(r+",");
        }
        System.out.println();
    }

    //Other utilities
    private double inverseLogistic(int t, double[] parameters) {
        double a = parameters[0];
        double b = parameters[1];
        double c = parameters[2];
        return c/(1+(a*Math.exp(-b*t)));
    }

    private void parametersToRates() { //note for myself: rates are {beta, gamma, psi, phi}
        if (Storage.analysisType == 0) { // inverse logistic beta
            /*INVERSE LOGISTIC BETA PARAMETER ORDER
            0:gamma, 1:psi, 2:phi, 3:a, 4:b, 5:c
             */
            double[] abc = new double[] {candidateParameters[3], candidateParameters[4], candidateParameters[5]};
            candidateRates[0][0] = inverseLogistic(0, abc);
            candidateRates[0][1] = candidateParameters[0];//assign day 0
            candidateRates[0][2] = candidateParameters[1];
            candidateRates[0][3] = candidateParameters[2];

            for (int k = 1; k < T; k++) {
                candidateRates[k][0] = inverseLogistic(k, abc);
                candidateRates[k][1] = candidateParameters[0];
                candidateRates[k][2] = candidateParameters[1];
                candidateRates[k][3] = candidateParameters[2];
            }
        } else if (Storage.analysisType == 1) {
            /*RANDOM WALK BETA PARAMETER ORDER
            0:gamma, 1:psi, 2:phi, 3:initialbeta, 4:betajitter
             */
            candidateRates[0][1] = candidateParameters[0];//assign day 0
            candidateRates[0][2] = candidateParameters[1];
            candidateRates[0][3] = candidateParameters[2];
            particles.setInitialBeta(candidateParameters[3], candidateParameters[4]);
            for (int k = 1; k < T; k++) {
                candidateRates[k][1] = candidateParameters[0];
                candidateRates[k][2] = candidateParameters[1];
                candidateRates[k][3] = candidateParameters[2];
            }
        } else if (Storage.analysisType == 2) {
            double[] abc = new double[] {candidateParameters[3], candidateParameters[4], candidateParameters[5]};
            candidateRates[0][0] = inverseLogistic(0, abc);
            candidateRates[0][1] = candidateParameters[0];//assign day 0
            candidateRates[0][2] = candidateParameters[1];
            candidateRates[0][3] = candidateParameters[2];
            for (int k = 1; k < T; k++) {
                candidateRates[k][0] = inverseLogistic(k, abc);
                candidateRates[k][1] = candidateParameters[0];
                candidateRates[k][2] = candidateParameters[1];
                candidateRates[k][3] = candidateParameters[2];
            }
            particles.setInitialBeta(candidateRates[0][0], candidateParameters[6]);
        }
    }

    public void clearCache() {
        particles = new Particles(numParticles);
        logLikelihoodCandidate = 0.0;
        Storage.haveReachedTree = new boolean[numParticles];
        Storage.treeOn = new boolean[numParticles];
        Storage.tooBig = false;
    }

    private void checkParticles() {
        for (Particle particle : particles.particles) {
            if (particle == null) {
                System.out.println("Null particle");
            }
        }
    }


}

import java.util.Arrays;
import java.io.IOException;


public class ParticleFilter {
    public int chainID;
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
    public Loggers loggers;


    public ParticleFilter(int chainID) throws IOException {
        this.chainID = chainID;
        this.numParticles = Storage.numParticles;
        this.tree = Storage.tree;
        this.caseIncidence = Storage.incidence;
        this.T = Storage.T;
        this.resampleEvery = Storage.resampleEvery;
        this.filterSteps = (int) Math.ceil(Storage.end / (double) Storage.resampleEvery);
        this.candidateRates = new double[this.T][5];
        this.loggers = new Loggers(chainID);
        particles = new Particles(numParticles);
        initialisePF();
    }

    public void initialisePF() throws IOException {
        double likelihood = Double.NEGATIVE_INFINITY;
        int i = 0;
        while (Double.isInfinite(likelihood)) {
            i += 1;
            runPF(Storage.priors.sampleInitial());
            currentParameters = candidateParameters;
            logLikelihoodCurrent = logLikelihoodCandidate;
            likelihood = logLikelihoodCandidate;
            currentSampledParticle = new Particle(particles.particles[0], 0);
            System.out.println("CHAIN "+chainID+"\nInitialisation attempt "+(i)
                    +"\nLog Likelihood: "+logLikelihoodCandidate+"\nParameters: "
                    +Arrays.toString(candidateParameters)+"\nBeta: "+currentSampledParticle.beta+"\nTrajectory"+Arrays.toString(particles.particles[0].traj.getTrajArray()));
            //System.exit(0);
        }
        System.out.println("CHAIN "+chainID+"\nFinal parameter set: "+Arrays.toString(currentParameters)+"\nInitial LL: "+logLikelihoodCurrent);
    }

    public void runPF(double[] parameters) throws IOException {
        clearCache();
        //Convert parameters into rates
        candidateParameters = parameters;

        parametersToRates();

        if (Storage.firstStep > 0 ){
            int initialState = (int) parameters[Storage.priors.parameterIndexes.get("initialI")[0]];
            particles.setInitialStates(initialState);
        }

        logLikelihoodCandidate = 0.0;
        for (int step=Storage.firstStep; step<filterSteps; step++) {
            if (!(Storage.isPhyloOnly() && tree.treeFinished(step))){
                if (filterStep(step)) {
                    //All the particles are neg infinity so break the steps
                    logLikelihoodCandidate = Double.NEGATIVE_INFINITY;
                    //System.out.println("Full run not completed");
                    break;
                }
            }
            else {
                //System.out.println("Model only running with Phylo and the tree is terminated.");
                break;
            }

        }

        if (!Double.isInfinite(logLikelihoodCandidate)) {
            Storage.completedRuns[chainID] += 1;
        }

        logPriorCandidate = calculatePFLogPrior();

    }


    public boolean filterStep(int step)  throws IOException {
        increments = Math.min(resampleEvery, (Storage.end-(step*resampleEvery)));
        int phiIndex = step*increments;


        //Epi Only Scenario
        if (Storage.isEpiOnly()) {
            particles.epiOnlyPredictAndUpdate(step, getRatesForStep(step), increments);
            //particles.getEpiLikelihoods(caseIncidence.incidence[step]);
            if (particles.checkEpiLikelihoods()) {return true;}
        }

        //If Phylo is involved at all
        else {

            particles.predictAndUpdate(step, tree, getRatesForStep(step), increments);
            if (particles.checkPhyloLikelihoods()) {
                System.out.println("Quitting due to neginf particles; step "+step);
                return true;}
            //If it's a combined run get the epi likelihoods and check them
            if (!Storage.isPhyloOnly()){
                //particles.printParticles();
                //particles.getEpiLikelihoods(caseIncidence.incidence[step]);
                if (particles.checkEpiLikelihoods()) {
                    System.out.println("Epi Likelihood Issue in step "+step);
                    return true;}
            }
        }

        particles.checkStates(Storage.maxEpidemicSize);
        if (Storage.tooBig) {
            System.out.println("epidemic size too large, quitting now");
            return true;
        }
        //particles.printParticles();

        //Scale weights and add to logP
        double logP = particles.scaleWeightsAndGetLogP(Storage.confidenceSplit[phiIndex]);
        logLikelihoodCandidate += logP;

        //resample
        particles.resampleParticles();
        checkParticles();

        return false;
    }

    //PF Calculators
    public double calculatePFLogPrior() {
        double logPrior = 1.0;
        int d = 0;
        for (Parameter param: Storage.priors.parameters) {
            for (Prior prior:param.priors) {
                logPrior *= prior.density(candidateParameters[d]);
                d+=1;
            }
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
        this.currentSampledParticle = new Particle(particles.particles[0], 0);
    }

    //Utilities
    private void printRateVector(int index) {
        double[] rateVector = getRateVector(index);
        for (double r : rateVector) {
            System.out.print(r+",");
        }
        System.out.println();
    }

    public void clearCache() {
        particles = new Particles(numParticles);
        logLikelihoodCandidate = 0.0;
        Storage.tooBig = false;
    }

    private void checkParticles() {
        for (Particle particle : particles.particles) {
            if (particle == null) {
                System.out.println("Null particle");
            }
        }
    }

    private double[][] setColumn(double[][] matrix, int columnID, double[] values) {
        for (int i = 0; i< matrix.length; i++) {
            matrix[i][columnID] = values[i];
        }
        return matrix;
    }
    private double[][] setColumn(double[][] matrix, int columnID, double value) {
        for (int i = 0; i< matrix.length; i++) {
            matrix[i][columnID] = value;
        }
        return matrix;
    }

    //Parameter and Rate Things
    private void parametersToRates() { //note for myself: rates are {beta, gamma, psi, phi}
        if (Storage.analysisType == 0) { // inverse logistic beta
            candidateRates = invLogisticRateParsing();
        } else if (Storage.analysisType == 1) {
            candidateRates = randomWalkRateParsing();
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
        } else if (Storage.analysisType == 3) {
            candidateRates = fixedBetaRateParsing();
        }
    }

    private double[] getParamAcrossTime(String paramLabel) {
        int[] indexes = Storage.priors.parameterIndexes.get(paramLabel);
        double[] paramAcrossTime = new double[T];
        if (indexes.length == 1) {
            double value = candidateParameters[indexes[0]];
            for (int t = 0; t < T; t++) {
                paramAcrossTime[t] = value;
            }
        } else {
            int start = 0;
            for (int i=0; i<indexes.length-1; i+=2) {
                int changeTime = (int) candidateParameters[indexes[i+1]];
                double value = candidateParameters[indexes[i]];
                for (int k = start; k < changeTime; k++) {
                    paramAcrossTime[k] = value;
                }
                start = changeTime;
            }
            double value = candidateParameters[indexes[indexes.length-1]];
            for (int k = start; k < T; k++) {
                paramAcrossTime[k] = value;
            }
        }
        return paramAcrossTime;
    }

    private double[] rwRefactorAcrossTime() {
        int[] indexes = Storage.priors.parameterIndexes.get("betaRefactor");
        double[] paramAcrossTime = new double[T];
        int start = 0;
        for (int i=0; i<indexes.length-1; i+=2) {
            int changeTime = (int) candidateParameters[indexes[i+1]];
            double value = candidateParameters[indexes[i+2]];
            for (int k = start; k < changeTime; k++) {
                paramAcrossTime[k] = 1;
            }
            paramAcrossTime[changeTime] = value;
            start = changeTime+1;
        }
        for (int k = start; k < T; k++) {
            paramAcrossTime[k] = 1;
        }

        return paramAcrossTime;
    }

    //Inverse Logistic Things
    private double[][] invLogisticRateParsing() {
        /*RATES ORDER
            0:beta, 2:gamma, 3:psi, 4:phi
         */
        double[][] candidateRates = new double[T][4];
        candidateRates = setColumn(candidateRates, 0, invLogisticBeta(invLogisticParameters()));
        candidateRates = setColumn(candidateRates, 1, getParamAcrossTime("gamma"));
        candidateRates = setColumn(candidateRates, 2, getParamAcrossTime("psi"));
        candidateRates = setColumn(candidateRates, 3, getParamAcrossTime("phi"));
        return candidateRates;
    }

    private double[][] invLogisticParameters() {
        double[][] invLogParams = new double[T][3];

        //find the a values somehow
        invLogParams = setColumn(invLogParams, 0, getParamAcrossTime("a"));

        //find the b values somehow
        invLogParams = setColumn(invLogParams, 1, getParamAcrossTime("b"));

        //find the c values somehow lol
        invLogParams = setColumn(invLogParams, 2, getParamAcrossTime("c"));

        return invLogParams;
    }

    private double[] invLogisticBeta(double[][] abcMatrix) {
        double[] beta = new double[abcMatrix.length];
        for (int i=0; i<abcMatrix.length; i++) {
            beta[i] = inverseLogistic(i, abcMatrix[i]);
        }
        return beta;
    }

    private double inverseLogistic(int t, double[] parameters) {
        double a = parameters[0];
        double b = parameters[1];
        double c = parameters[2];
        return c/(1+(a*Math.exp(-b*t)));
    }

    //Random Walk Things
    private double[][] randomWalkRateParsing() {
                /*RATES ORDER
            0:beta, 2:gamma, 3:psi, 4:phi
         */
        double[][] cRates = new double[T][4];
        cRates = setColumn(cRates, 1, getParamAcrossTime("gamma"));
        cRates = setColumn(cRates, 2, getParamAcrossTime("psi"));
        cRates = setColumn(cRates, 3, getParamAcrossTime("phi"));
        int startIndex = Storage.priors.parameterIndexes.get("initialBeta")[0];
        int stdDevIndex = Storage.priors.parameterIndexes.get("betaJitter")[0];
        particles.setInitialBeta(candidateParameters[startIndex], candidateParameters[stdDevIndex]);
        //If there's a step change needed to be fitted, put that into the beta
        if (Storage.priors.labels.contains("betaRefactor_distribs_0")) {
            cRates = setColumn(cRates, 0, rwRefactorAcrossTime());
        } else {
            cRates = setColumn(cRates, 0, 1);
        }

        return cRates;
    }

    private double[][] fixedBetaRateParsing() {
                /*RATES ORDER
            0:beta, 2:gamma, 3:psi, 4:phi
         */
        double[][] cRates = new double[T][4];
        cRates = setColumn(cRates, 0, getParamAcrossTime("beta"));
        cRates = setColumn(cRates, 1, getParamAcrossTime("gamma"));
        cRates = setColumn(cRates, 2, getParamAcrossTime("psi"));
        cRates = setColumn(cRates, 3, getParamAcrossTime("phi"));

        return cRates;
    }

    private void printRatesOverTime() {
        for (int i = 0; i<candidateRates.length; i++) {
            System.out.println("["+i+"]"+ Arrays.toString(candidateRates[i]));
        }
    }
}

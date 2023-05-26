import java.io.IOException;
import org.apache.commons.math3.distribution.NormalDistribution;

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
    private int numParticles;
    //private final Random random;

    public ParticleFilter(int numParticles, double[] initialParameters, Tree tree, Incidence incidence, int T, int resampleEvery) throws IOException {
        this.numParticles = numParticles;
        this.currentParameters = initialParameters;
        this.candidateParameters = initialParameters;
        this.tree = tree;
        this.caseIncidence = incidence;
        this.T = T;
        //this.random = new Random();
        this.candidateRates = new double[this.T][3];
        this.filterSteps = (int) Math.ceil(this.T / (double) resampleEvery);
        this.resampleEvery = resampleEvery;

        particles = new Particles(numParticles);
        runPF(candidateParameters);

        logLikelihoodCurrent = logLikelihoodCandidate;
        System.out.println(logLikelihoodCurrent);
        logPriorCurrent = logPriorCandidate;

    }

    public void runPF(double[] parameters) {
        clearCache();
        //Convert parameters into rates
        candidateParameters = parameters;
        candidateRates[0][0] = inverseLogistic(0, parameters);
        candidateRates[0][1] = parameters[3];//assign day 0
        candidateRates[0][2] = parameters[4];
        for (int k = 1; k < T; k++) { //Random walk for gamma, inverse log for
            candidateRates[k][0] = inverseLogistic(k, parameters);
            //candidateRates[k][1] = candidateRates[k-1][1] + this.random.nextGaussian()*0.01;
            //candidateRates[k][2] = candidateRates[k-1][2] + this.random.nextGaussian()*0.0001;//assign the rest using random walk
            candidateRates[k][1] = parameters[3];
            candidateRates[k][2] = parameters[4];
        }


        logLikelihoodCandidate = 0.0;
        //particles.printParticles();
        for (int step=0; step<filterSteps; step++) {
            if (!(Storage.isPhyloOnly() && tree.treeFinished(step))){
                if (filterStep(step)) {
                    //All the particles are neg infinity so break the steps
                    logLikelihoodCandidate = Double.NEGATIVE_INFINITY;
                    logPriorCandidate = calculatePFLogPrior();
                    System.out.println("Full run not completed");
                    break;
                }
            }
            else {
                System.out.println("Model only running with Phylo and the tree is terminated.");
                break;
            }

        }
        /*
        for (int i = 0; i<numParticles; i++) {
            particles.particles[i].traj.printTrajectory(i);
        }*/

        logPriorCandidate = calculatePFLogPrior();
        //System.out.println("Log Likelihood Candidate: "+logLikelihoodCandidate);
        //System.out.println("Log Prior Candidate: "+logPriorCandidate);
    }


    public boolean filterStep(int step)  {
        //System.out.println("STEP "+step);
        //Find out how many increments (days) in this step, useful housekeeping
        increments = Math.min(resampleEvery, (T-(step*resampleEvery)));

        if (Storage.isEpiOnly()) {
            particles.epiOnlyPredictAndUpdate(step, getRatesForStep(step), increments);
            particles.getEpiLikelihoods(caseIncidence.incidence[step]);
            //particles.printLikelihoods();
            if (particles.checkEpiLikelihoods()) {
                return true;
            }
        } else {
            particles.predictAndUpdate(step, tree, getRatesForStep(step), increments);
            particles.checkPhyloLikelihoods();
            //particle likelihoods
            if (!Storage.isPhyloOnly()){
                particles.getEpiLikelihoods(caseIncidence.incidence[step]);
                //particles.printLikelihoods();
                if (particles.checkEpiLikelihoods()) {
                    return true;
                }
            }
        }

        if (particles.checkLikelihoods()) {
            return true;
        }

        //Scale weights and add to logP
        double logP = particles.scaleWeightsAndGetLogP();
        //System.out.println("STEP "+step+" logP: "+logP);
        logLikelihoodCandidate += logP;
        //particles.printWeights();
        //resample
        particles.resampleParticles();
        //print them
        //particles.printParticles();
        return false;
    }

    //PF Calculators
    public double calculatePFLogPrior() {
        double logPrior = 1.0;
        for (int d=0; d<currentParameters.length; d++) {
            //System.out.println(Storage.priors.allPriors[d].density(currentParameters[d]));
            logPrior *= Storage.priors.allPriors[d].density(currentParameters[d]);
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
        double[][] ratesForStep = new double[resampleEvery][3];
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

    private double inverseLogistic(int t, double[] parameters) {
        double a = parameters[0];
        double b = parameters[1];
        double c = parameters[2];
        return c/(1+(a*Math.exp(-b*t)));
    }


    //Printers
    private void printRateVector(int index) {
        double[] rateVector = getRateVector(index);
        for (double r : rateVector) {
            System.out.println(r);
        }
    }


    public void clearCache() {
        particles = new Particles(numParticles);
        logLikelihoodCandidate = 0.0;
    }




}

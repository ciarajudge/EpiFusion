public class ParticleFilter {
    private double[] currentParameters;
    private double[] candidateParameters;
    public Particles particles;
    private double logLikelihoodCurrent;
    private double logLikelihoodCandidate;
    private double logPriorCurrent;
    private double logPriorCandidate;
    public Tree tree;
    public Incidence caseIncidence;

    public ParticleFilter(int numParticles, double[] initialParameters, Tree tree, Incidence incidence) {
        this.currentParameters = initialParameters;
        particles = new Particles(numParticles);
        this.tree = tree;
        this.caseIncidence = incidence;
        runPF(currentParameters);
        logLikelihoodCurrent = logLikelihoodCandidate;
        logPriorCurrent = logPriorCandidate;
    }

    public void filterStep(int t)  {
        System.out.println("Week "+t);
        //predict and update
        System.out.println("Predict Step");
        particles.predictAndUpdate(t, tree, candidateParameters);
        //particle likelihoods
        particles.getEpiLikelihoods(caseIncidence.incidence[t]);
        particles.printLikelihoods();
        //particle weights
        particles.updateWeights();
        //Scale weights and add to logP
        logLikelihoodCandidate += particles.scaleWeightsAndGetLogP();
        //resample
        particles.resampleParticles();
        //print them
        particles.printParticles();
    }

    public void runPF(double[] parameters) {
        this.candidateParameters = parameters;
        logLikelihoodCandidate = 0.0;
        particles.printParticles();
        for (int t=0; t<caseIncidence.length; t++) {
            filterStep(t);
        }
        logPriorCandidate = calculatePFLogPrior();
    }

    public double calculatePFLogLikelihood() {
        return 0.0;
    }

    public double calculatePFLogPrior() {
        return 0.0;
    }

    //Getters and Setters
    public double[] getCurrentParameters() {return currentParameters;}

    public double[] getCandidateParameters() {return candidateParameters;}

    public double getLogLikelihoodCurrent() {return logLikelihoodCurrent; }

    public double getLogLikelihoodCandidate() {return logLikelihoodCandidate; }

    public double getLogPriorCurrent() {return logPriorCurrent; }

    public double getLogPriorCandidate() {return logPriorCandidate; }

    public void resetCurrentParameters() {
        this.currentParameters = this.candidateParameters;
        this.logLikelihoodCurrent = this.logLikelihoodCandidate;
        this.logPriorCurrent = this.logPriorCandidate;
    }

    private double[] selectNewParameters() {
        double[] newParameters = new double[]{0.3,0.3,0.3};
        return newParameters;
    }


}

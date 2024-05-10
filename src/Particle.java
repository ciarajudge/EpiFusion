import java.util.ArrayList;
import java.util.Collections;
import org.apache.commons.math3.distribution.NormalDistribution;
import cern.jet.random.Normal;

//import static cern.jet.random.Uniform.staticNextDouble;

public class Particle {
    int particleID;
    private int state;
    double phyloLikelihood;
    double epiLikelihood;
    double phyloWeight;
    double epiWeight;
    double weight;
    Trajectory traj;
    ArrayList<Double> beta;
    //double[][] likelihoodMatrix;
    private double stdDev;
    public boolean treeOn;
    public boolean haveReachedTree;
    ArrayList<Integer> cumInfections;
    public int todaysInfs;
    public int positiveTests;
    public ArrayList<Integer> positiveTestsFit;
    public int epiCumInfections; //Used for the epi likelihood, probably theres a more elegant way to do this someday
    //public ArrayList<Double> likelihoodVector;

    public Particle(int pID) {
        particleID = pID;
        //PoissonDistribution initialI = new PoissonDistribution(100);
        state = 1;
        setState(state);
        this.traj = new Trajectory(new Day(0, 1, 0,0));
        //this.epiLikelihood = Storage.isPhyloOnly() ? 1.0 : 0.0;
        this.epiLikelihood = 1.0;
        //this.epiWeight = Storage.isPhyloOnly() ? 1.0/Storage.numParticles : 0.0;
        this.epiWeight = 1.0;
        this.phyloLikelihood = Storage.isEpiOnly() ? 1.0 : 0.0;
        this.phyloWeight = Storage.isEpiOnly() ? 1.0/Storage.numParticles : 0.0;
        this.beta = new ArrayList<>();
        //this.likelihoodMatrix = new double[Storage.T][6];
        this.treeOn = false;
        this.haveReachedTree = false;
        this.cumInfections = new ArrayList<>();
        this.cumInfections.add(0);
        this.todaysInfs = 0;
        this.positiveTests = 0;
        this.positiveTestsFit = new ArrayList<>();
        this.epiCumInfections = 0;
        //this.likelihoodVector = new ArrayList<>();
    }

    public Particle(Particle other, int pID) {
        this.particleID = pID;
        this.state = other.state;
        //this.epiLikelihood = Storage.isPhyloOnly() ? 1.0 : 0.0;
        this.epiLikelihood = 1.0;
        this.phyloLikelihood = Storage.isEpiOnly() ? 1.0 : 0.0;
        this.weight = 0.0;
        //this.epiWeight = Storage.isPhyloOnly() ? 1.0/Storage.numParticles : 0.0;
        this.epiWeight = 1.0;
        this.phyloWeight = Storage.isPhyloOnly() ? 1.0/Storage.numParticles : 0.0;
        this.traj = new Trajectory(other.traj);
        this.beta = new ArrayList<>(other.beta);
        //this.likelihoodMatrix = copy2DArray(other.likelihoodMatrix);
        this.stdDev = other.stdDev;
        this.treeOn = other.treeOn;
        this.haveReachedTree = other.haveReachedTree;
        this.cumInfections = new ArrayList<>(other.cumInfections);
        this.todaysInfs = 0;
        this.positiveTests = other.positiveTests;
        this.positiveTestsFit = new ArrayList<>(other.positiveTestsFit);
        this.epiCumInfections = other.epiCumInfections;
        //this.likelihoodVector = new ArrayList<>(other.likelihoodVector);
    }

    public void printStatus() {
        System.out.println("Particle "+ particleID);
        System.out.println("State: "+ state);
        traj.printTrajectory();
        System.out.println("Phylo Likelihood:" + phyloLikelihood);
        System.out.println("Epi Likelihood:"+ Math.log(epiLikelihood));
        //System.out.println();
    }
    public void printBeta() {
        System.out.print("Beta: ");
        for (int i=0; i<beta.size(); i++) {
            System.out.print(beta.get(i)+",");
        }
        System.out.println();
        System.out.println();
    }

    //Setters
    public void setState(int newState) {
        this.state = newState;
    }
    public void setInitialState(int newState) {
        this.state = newState;
        this.traj.trajectory.set(0, new Day(0, newState, 0,0));
    }
    public void setPhyloWeight(double newWeight) {
        this.phyloWeight = newWeight;
    }
    public void setEpiWeight(double weight){
        this.epiWeight = weight;
    }
    public void setEpiLikelihood(double epiLikelihood){
        this.epiLikelihood = this.epiLikelihood * epiLikelihood;
        //this.epiLikelihood = epiLikelihood;
        this.epiWeight = Math.log(this.epiLikelihood);
    }
    public void setPhyloLikelihood(double newLikelihood) {
        this.phyloLikelihood = newLikelihood;
    }
    public void setWeight(double weight) {this.weight = weight;  }
    public void setBeta(Double betaT, double stdDev) {
        beta.add(betaT);
        this.stdDev = stdDev;
    }
    public void nextBeta(double reFactor) {
        //TruncatedNormalDist truncatedNormalDistribution = new TruncatedNormalDist(current, stdDev, 0.0);
        Double newBeta = Math.abs((beta.get(beta.size()-1)*reFactor) + Normal.staticNextDouble(0.0, stdDev));
        beta.add(newBeta);
    }

    public void betaLinearSpline(int numToAdd) {
        Double slope = Normal.staticNextDouble(0.0, stdDev);
        Double intercept = beta.get(beta.size()-1);
        for (int i=0; i<numToAdd; i++) {
            beta.add(Math.max((intercept+(i*slope)), 0.0));
        }
    }

    public void nextBeta(double skeleton, double reFactor) {
        Double current = beta.get(beta.size()-1);
        TruncatedNormalDist truncatedNormalDistribution = new TruncatedNormalDist(current, stdDev, 0.0);
        Double newBeta = ((truncatedNormalDistribution.sample()+skeleton)/2)*reFactor;
        beta.add(newBeta);
    }
    public void incrementCumInfections() {
        cumInfections.add(todaysInfs);
        epiCumInfections += todaysInfs;
        this.todaysInfs = 0;
    }




    //Getters
    public int getState() {
        return this.state;
    }
    public void checkState(int limit) {
        if(state < limit) {
            Storage.tooBig = false;
        }
    }
    public double getWeight() {return this.weight;}
    public double getPhyloWeight() {
        return this.phyloWeight;
    }
    public double getEpiWeight() {
        return this.epiWeight;
    }
    public double getEpiLikelihood() {
        return this.epiLikelihood;
    }
    public double getPhyloLikelihood() {
        return this.phyloLikelihood;
    }
    public double[] getVanillaPropensities(double[] rates) {
        double[] newPropensities = new double[rates.length];
        for ( int i=0; i<rates.length; i++){
            newPropensities[i] = rates[i] * state;
        }
        return newPropensities;
    }
    public double[] getSegmentPropensities(double[] rates, double deltaT) {
        double[] newPropensities = new double[rates.length];
        for ( int i=0; i<rates.length; i++){
            newPropensities[i] = rates[i] * state * deltaT;
        }
        return newPropensities;
    }

    //Copy 2d array helper function
    public static double[][] copy2DArray(double[][] source) {
        int rows = source.length;
        int columns = source[0].length;
        double[][] destination = new double[rows][columns];

        for (int i = 0; i < rows; i++) {
            for (int j = 0; j < columns; j++) {
                destination[i][j] = source[i][j];
            }
        }

        return destination;
    }

    //More complex updators
    public void updateWeight(double confidenceSplit) {
        if (Storage.isEpiOnly()) {
            weight = epiWeight; //Will be in log space
        } else if (Storage.isPhyloOnly()) {
            weight = phyloWeight; //Will be in log space
        } else {
            double epiConfidence = confidenceSplit;
            double phyloConfidence = 1 - confidenceSplit;
            if (Double.isNaN(phyloLikelihood)) {
                phyloLikelihood = Double.NEGATIVE_INFINITY;
            }
            phyloWeight = phyloLikelihood;
            weight = (phyloWeight*phyloConfidence)+(epiWeight*epiConfidence); //in log space
            if (Double.isNaN(weight)) {
                System.out.println("Weight is NaN!");
                System.out.println("PhyloWeight: "+phyloWeight);
                System.out.println("EpiWeight: "+epiWeight);
            }
        }
    }
    public void updateTrajectory(Day day) {
        traj.updateTrajectory(day);
    }

}

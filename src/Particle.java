import java.util.ArrayList;
import org.apache.commons.math3.distribution.NormalDistribution;
//import org.apache.commons.math3.distribution.PoissonDistribution;

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

    public Particle(int pID) {
        particleID = pID;
        //PoissonDistribution initialI = new PoissonDistribution(100);
        state = 1;
        setState(state);
        this.traj = new Trajectory(new Day(0, state, 0,0));
        this.epiLikelihood = Storage.isPhyloOnly() ? 1.0 : 0.0;
        this.epiWeight = Storage.isPhyloOnly() ? 1.0/Storage.numParticles : 0.0;
        this.phyloLikelihood = Storage.isEpiOnly() ? 1.0 : 0.0;
        this.phyloWeight = Storage.isEpiOnly() ? 1.0/Storage.numParticles : 0.0;
        this.beta = new ArrayList<>();
    }

    public Particle(Particle other, int pID) {
        this.particleID = pID;
        this.state = other.state;
        this.epiLikelihood = Storage.isPhyloOnly() ? 1.0 : 0.0;
        this.phyloLikelihood = Storage.isEpiOnly() ? 1.0 : 0.0;
        this.weight = 0.0;
        this.epiWeight = Storage.isPhyloOnly() ? 1.0/Storage.numParticles : 0.0;
        this.phyloWeight = Storage.isPhyloOnly() ? 1.0/Storage.numParticles : 0.0;
        this.traj = new Trajectory(other.traj);
        this.beta = new ArrayList<>(other.beta);
    }

    public void printStatus() {
        System.out.println("Particle "+ particleID);
        System.out.println("State: "+ state);
        System.out.println();
    }
    public void printBeta() {
        System.out.print("Beta: ");
        for (int i=0; i<beta.size(); i++) {
            System.out.print(beta.get(i)+",");
        }
        System.out.println();
    }

    //Setters
    public void setState(int newState) {
        this.state = newState;
    }
    public void setPhyloWeight(double newWeight) {
        this.phyloWeight = newWeight;
    }
    public void setEpiWeight(double epiWeight){
        this.epiWeight = epiWeight;
    }
    public void setEpiLikelihood(double epiLikelihood){
        this.epiLikelihood = epiLikelihood;
        this.epiWeight = Math.log(epiLikelihood);
    }
    public void setPhyloLikelihood(double newLikelihood) {
        this.phyloLikelihood = newLikelihood;
    }
    public void setWeight(double weight) {this.weight = weight;  }
    public void setBeta(Double betaT) {
        beta.add(betaT);
    }
    public void nextBeta(double stdDev) {
        Double current = beta.get(beta.size()-1);
        TruncatedNormalDist truncatedNormalDistribution = new TruncatedNormalDist(current, stdDev, 0.0);
        Double newBeta = truncatedNormalDistribution.sample();
        beta.add(newBeta);
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

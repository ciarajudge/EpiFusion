import java.util.ArrayList;
//import org.apache.commons.math3.distribution.PoissonDistribution;

public class Particle {
    int particleID;
    private int state;
    ArrayList<Integer> states;
    double phyloLikelihood;
    double epiLikelihood;
    double phyloWeight;
    double epiWeight;
    double weight;
    Trajectory traj;

    public Particle(int pID) {
        particleID = pID;
        //PoissonDistribution initialI = new PoissonDistribution(100);
        state = 1;
        states = new ArrayList<>();
        setState(state);
        this.traj = new Trajectory(new Day(0, state, 0,0));
        this.epiLikelihood = Storage.isPhyloOnly() ? 1.0 : 0.0;
        this.epiWeight = Storage.isPhyloOnly() ? 1.0/Storage.numParticles : 0.0;
    }

    public Particle(Particle other, int pID) {
        this.particleID = pID;
        this.state = other.state;
        this.states = other.states;
        this.epiLikelihood = Storage.isPhyloOnly() ? 1.0 : 0.0;
        this.phyloLikelihood = 0.0;
        this.weight = 0.0;
        this.epiWeight = Storage.isPhyloOnly() ? 1.0/Storage.numParticles : 0.0;
        this.phyloWeight = 0.0;
        this.traj = other.traj;
    }

    public void printStatus() {
        System.out.println("Particle "+ particleID);
        System.out.println("State: "+ state);
        System.out.println();
    }

    //Setters
    public void setState(int newState) {
        this.state = newState;
        this.states.add(state);
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

    //Getters
    public int getState() {
        return this.state;
    }
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

    //More complex updators
    public void updateWeight(double confidenceSplit) {
        double epiConfidence = confidenceSplit;
        double phyloConfidence = 1 - confidenceSplit;
        weight = (Math.pow(phyloWeight, phyloConfidence))*(Math.pow(epiWeight, epiConfidence));
    }
    public void updateTrajectory(Day day) {
        traj.updateTrajectory(day);
    }
}

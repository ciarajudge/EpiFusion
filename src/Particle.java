import java.util.ArrayList;
//import org.apache.commons.math3.distribution.PoissonDistribution;
import java.util.Arrays;
public class Particle {
    int particleID;
    private int state;
    ArrayList<Integer> states;
    double phyloLikelihood;
    double epiLikelihood;
    double weight;
    double[] propensities;
    Trajectory traj;

    public Particle(int pID) {
        particleID = pID;
        //PoissonDistribution initialI = new PoissonDistribution(100);
        state = 1;
        states = new ArrayList<>();
        setState(state);
        this.traj = new Trajectory(new Day(0, state, 0,0));
    }

    public Particle(Particle other) {
        this.particleID = other.particleID;
        this.state = other.state;
        this.states = other.states;
        this.epiLikelihood = other.epiLikelihood;
        this.phyloLikelihood = other.phyloLikelihood;
        this.weight = other.weight;
        this.propensities = other.propensities;
        this.traj = other.traj;
    }

    public void printStatus() {
        System.out.println("Particle "+ particleID);
        System.out.println("State: "+ state);
        System.out.println();
    }

    public void setState(int newState) {
        this.state = newState;
        this.states.add(state);
    }

    public int getState() {
        return this.state;
    }

    public void setPhyloLikelihood(double newLikelihood) {
        this.phyloLikelihood = newLikelihood;
        this.weight = newLikelihood;
    }

    public double getPhyloLikelihood() {
        return this.phyloLikelihood;
    }

    public double[] getVanillaPropensities(double[] rates) {
        Arrays.setAll(propensities, i -> rates[i] * state);
        return propensities;
    }

    public void setEpiLikelihood(double epiLikelihood){
        this.epiLikelihood = epiLikelihood;
    }

    public double getEpiLikelihood() {
        return this.epiLikelihood;
    }
    public void updateWeight(double confidenceSplit) {
        double epiConfidence = confidenceSplit;
        double phyloConfidence = 1 - confidenceSplit;
        weight = (Math.pow(phyloLikelihood, phyloConfidence))*(Math.pow(epiLikelihood, epiConfidence));
    }
}

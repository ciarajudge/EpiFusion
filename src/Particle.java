import java.util.ArrayList;
import org.apache.commons.math3.distribution.PoissonDistribution;
import java.util.Arrays;
public class Particle {
    int particleID;
    private int state;
    ArrayList<Integer> states;
    /* Might be a better way of doing that
    ArrayList<Integer> births;
    ArrayList<Integer> deaths;
    ArrayList<Integer> samples; */
    double phyloLikelihood;
    double epiLikelihood;
    double weight;
    double[] rates;
    double[] propensities;

    public Particle(int pID, double[] rates) {
        particleID = pID;
        PoissonDistribution initialI = new PoissonDistribution(100);
        state = initialI.sample();
        states = new ArrayList<>();
        setState(state);
        this.rates = rates;
    }

    public Particle(Particle other) {
        this.particleID = other.particleID;
        this.state = other.state;
        this.states = other.states;
        this.epiLikelihood = other.epiLikelihood;
        this.phyloLikelihood = other.phyloLikelihood;
        this.weight = other.weight;
        this.rates = other.rates;
        this.propensities = other.propensities;

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

    public double[] getPropensities() {
        Arrays.setAll(propensities, i -> rates[i] * state);
        return propensities;
    }

    public void setEpiLikelihood(double epiLikelihood){
        this.epiLikelihood = epiLikelihood;
    }

    public void updateWeight(double confidenceSplit) {
        double epiConfidence = confidenceSplit;
        double phyloConfidence = 1 - confidenceSplit;
        weight = (Math.pow(phyloLikelihood, phyloConfidence))*(Math.pow(epiLikelihood, epiConfidence));
    }
}

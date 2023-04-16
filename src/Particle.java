import java.util.ArrayList;
import org.apache.commons.math3.distribution.PoissonDistribution;
public class Particle {
    int particleID;
    int state;
    int fluxIn;
    int fluxOut;
    ArrayList<Integer> states;
    ArrayList<Integer> fluxIns;
    ArrayList<Integer> fluxOuts;
    double likelihood;
    double weight;

    public Particle(int pID) {
        particleID = pID;
        PoissonDistribution initialI = new PoissonDistribution(100);
        PoissonDistribution initialFluxIn = new PoissonDistribution(20);
        PoissonDistribution initialFluxOut = new PoissonDistribution(10);
        state = initialI.sample();
        states = new ArrayList<>();
        setState(state);
        fluxIn = initialFluxIn.sample();
        fluxIns = new ArrayList<>();
        fluxIns.add(fluxIn);
        fluxOut = initialFluxOut.sample();
        fluxOuts = new ArrayList<>();
        fluxOuts.add(fluxOut);
    }

    public void printStatus() {
        System.out.println("Particle "+ particleID);
        System.out.println("State: "+ state);
        System.out.println("Flux In: "+ fluxIn);
        System.out.println("Flux out: "+ fluxOut);
        System.out.println("Likelihood: "+ likelihood);
        System.out.println();
    }

    public void setState(int newState) {
        this.state = newState;
        this.states.add(state);
    }

    public int getState() {
        return this.state;
    }

    public int[] getFlux() {
        int[] flux = {this.fluxIn, this.fluxOut};
        return flux;
    }

    public void setLikelihood(double newLikelihood) {
        this.likelihood = newLikelihood;
        this.weight = 1/newLikelihood;
    }


}

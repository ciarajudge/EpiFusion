import java.util.ArrayList;
import org.apache.commons.math3.distribution.PoissonDistribution;
public class Particle {
    int particleID;
    int state;
    PoissonDistribution fluxIn;
    PoissonDistribution fluxOut;
    ArrayList<Integer> states;
    ArrayList<Integer> fluxIns;
    ArrayList<Integer> fluxOuts;
    double likelihood;
    double weight;
    int row;

    public Particle(int pID) {
        particleID = pID;
        row = pID;
        PoissonDistribution initialI = new PoissonDistribution(100);
        fluxIn = new PoissonDistribution(20);
        fluxOut = new PoissonDistribution(10);
        state = initialI.sample();
        states = new ArrayList<>();
        setState(state);
        fluxIns = new ArrayList<>();
        fluxOuts = new ArrayList<>();
    }

    public Particle(Particle other, int row) {
        this.particleID = other.particleID;
        this.state = other.state;
        this.fluxIn = other.fluxIn;
        this.fluxOut = other.fluxOut;
        this.states = other.states;
        this.fluxIns = other.fluxIns;
        this.fluxOuts = other.fluxOuts;
        this.likelihood = other.likelihood;
        this.weight = other.weight;
        this.row = row;

    }

    public void printStatus() {
        System.out.println("Particle "+ particleID);
        System.out.println("State: "+ state);
        System.out.println("Flux In: "+ fluxIn);
        System.out.println("Flux out: "+ fluxOut);
        System.out.println("Likelihood: "+ likelihood);
        System.out.println("Row: "+ row);
        System.out.println();
    }

    public void setState(int newState) {
        this.state = newState;
        this.states.add(state);
    }

    public int getState() {
        return this.state;
    }

    public PoissonDistribution[] getFlux() {
        PoissonDistribution[] flux = {this.fluxIn, this.fluxOut};
        return flux;
    }

    public void setLikelihood(double newLikelihood) {
        this.likelihood = newLikelihood;
        this.weight = 1/newLikelihood;
    }


}

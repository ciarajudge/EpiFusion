import org.apache.commons.math3.distribution.PoissonDistribution;
public class ProcessModel {

    public static int predictNext(Particle particle) {
        int currentState = particle.getState();
        PoissonDistribution[] currentFlux = particle.getFlux();
        int currentFluxIn = currentFlux[0].sample();
        int currentFluxOut = currentFlux[1].sample();

        return currentState+currentFluxIn-currentFluxOut;
    }

    public static void updateState(Particle particle) {
        particle.setState(predictNext(particle));
    }

}

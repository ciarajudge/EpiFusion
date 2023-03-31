public class ProcessModel {

    public static int predictNext(Particle particle) {
        int currentState = particle.getState();
        int[] currentFlux = particle.getFlux();

        return currentState+currentFlux[0]-currentFlux[1];
    }

    public static void updateState(Particle particle) {
        particle.setState(predictNext(particle));
    }

}

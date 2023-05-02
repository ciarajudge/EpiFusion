import org.apache.commons.math3.distribution.PoissonDistribution;
public class ProcessModel {

    public static void day(Particle particle, TreeSegment tree) {
        int state = particle.getState();
        double[] propensities = particle.getPropensities();
        int[] events = new int[3];

        for (int i=0; i<3; i++){
            events[i] = poissonSampler(propensities[i]);
        }

        state = state + events[0] - events[1] - events[2];

        double todayPhyloLikelihood = PhyloLikelihood.calculateLikelihood(tree, events, particle.rates);
        particle.setPhyloLikelihood(particle.getPhyloLikelihood()*todayPhyloLikelihood);
        particle.setState(state);
    }

    public static void week(Particle particle, TreeSegment[] treeSegments) {
        for (int i=0; i<7; i++){
            day(particle, treeSegments[i]);
        }
    }

    public static int poissonSampler(double rate) {
        PoissonDistribution poissonDistribution = new PoissonDistribution(rate);
        return poissonDistribution.sample();
    }


}

import org.apache.commons.math3.distribution.PoissonDistribution;
public class ProcessModel {

    public static void day(Particle particle, TreeSegment tree, int t, double[] rates) {
        int state = particle.getState();
        double[] propensities = particle.getVanillaPropensities(rates);

        //Divide the propensities into their bits
        double unobservedInfectProp = state > 0
                ? propensities[0] * (1.0 - tree.lineages * (tree.lineages - 1) / (double) state/state+1)
                : 0.0;
        double observedInfectProp = propensities[0] - unobservedInfectProp;
        double allowedRecovProp, forbiddenRecovProp;
        if (state > tree.lineages) {
            allowedRecovProp = propensities[1];
            forbiddenRecovProp = 0.0;
        }
        else {
            allowedRecovProp = 0.0;
            forbiddenRecovProp = propensities[1];
        }
        double sampleProp = propensities[2];

        System.out.println(unobservedInfectProp);
        //Calculate the events
        int births = poissonSampler(unobservedInfectProp);
        int deaths = poissonSampler(allowedRecovProp);

        double[] adjustedPropensities = new double[]{observedInfectProp, unobservedInfectProp, allowedRecovProp, forbiddenRecovProp, sampleProp};
        state = state + births - deaths;

        double todayPhyloLikelihood = PhyloLikelihood.calculateLikelihood(tree, state, adjustedPropensities);
        particle.setPhyloLikelihood(particle.getPhyloLikelihood()+todayPhyloLikelihood);
        particle.setState(state);
        particle.traj.updateTrajectory(new Day(t, state, births, deaths));
    }

    public static void week(Particle particle, TreeSegment[] treeSegments, int t, double[] rates) {
        System.out.println("check1");
        int weeksToDays = t*7;
        for (int i=0; i<7; i++){
            int actualDay = weeksToDays+i;
            System.out.println("Sending for day "+actualDay);
            day(particle, treeSegments[i], weeksToDays+i, rates);
        }
    }

    public static int poissonSampler(double rate) {
        PoissonDistribution poissonDistribution = new PoissonDistribution(rate);
        return poissonDistribution.sample();
    }


}

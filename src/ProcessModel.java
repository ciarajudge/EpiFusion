import org.apache.commons.math3.distribution.PoissonDistribution;

public class ProcessModel {

    public static void day(Particle particle, TreeSegment tree, int t, double[] rates) {
        int state = particle.getState();
        double[] propensities = particle.getVanillaPropensities(rates);
        //Divide the propensities into their bits
        double unobservedInfectProp = state > 0
                ? propensities[0] * (1.0 - tree.lineages * (tree.lineages - 1) / (double) state/(state+1))
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
        if (tree.lineages < 1) {
            System.out.println("No tree yet.");
            unobservedInfectProp = propensities[0];
            allowedRecovProp = 0.0;
        }
        //Calculate the events
        int births = poissonSampler(unobservedInfectProp);
        int deaths = poissonSampler(allowedRecovProp);
        state = state + births - deaths;
        particle.setState(state);
        if (tree.lineages > 0) {
            double[] adjustedPropensities = new double[]{observedInfectProp, unobservedInfectProp, allowedRecovProp, forbiddenRecovProp, sampleProp};
            double todayPhyloLikelihood = PhyloLikelihood.calculateLikelihood(tree, particle, adjustedPropensities);
            //System.out.println("Today's Phylo Likelihood: " +todayPhyloLikelihood);
            particle.setPhyloLikelihood(particle.getPhyloLikelihood()+todayPhyloLikelihood);
            //System.out.println("Overall Phylo Likelihood: "+particle.getPhyloLikelihood());
        }
        Day tmpDay = new Day(t, state, births, deaths);
        particle.updateTrajectory(tmpDay);
    }

    public static void week(Particle particle, TreeSegment[] treeSegments, int t, double[] rates) {
        int weeksToDays = t*7;
        for (int i=0; i<7; i++) {
            int actualDay = weeksToDays+i+1;
            System.out.println("Sending for day "+actualDay+", State currently: "+particle.getState());
            day(particle, treeSegments[i], actualDay, rates);
        }
    }

    public static int poissonSampler(double rate) {
        if (rate == 0.0) {
            return 0;
        }
        PoissonDistribution poissonDistribution = new PoissonDistribution(rate);
        return poissonDistribution.sample();
    }



}

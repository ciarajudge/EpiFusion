import org.apache.commons.math3.distribution.PoissonDistribution;
import java.util.Arrays;

public class ProcessModel {

    public static void day(Particle particle, TreeSegment tree, int t, double[] rates) {
        int state = particle.getState();
        double[] propensities = particle.getVanillaPropensities(rates);
        System.out.println("tree lineages: "+tree.lineages);

        System.out.println("vanilla propensities: "+Arrays.toString(propensities));
        //Divide the propensities into their bits
        double unobservedInfectProp = state > 0
                ? propensities[0] * (1.0 - tree.lineages * (tree.lineages - 1) / (double) state/(state+1))
                : 0.0;
        System.out.println("unobserved infection prop: "+unobservedInfectProp);

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
        System.out.println("allowed recov prop: "+allowedRecovProp);
        double sampleProp = propensities[2];
        if (tree.lineages < 1) {
            System.out.println("No tree yet.");
            unobservedInfectProp = propensities[0];
            allowedRecovProp = 0.0;
        }
        //Calculate the events
        int births = poissonSampler(unobservedInfectProp);
        System.out.println("births: "+births);
        int deaths = poissonSampler(allowedRecovProp);
        System.out.println("deaths: "+deaths);
        state = state + births - deaths;
        particle.setState(state);
        if (tree.lineages > 0) {
            double[] adjustedPropensities = new double[]{observedInfectProp, unobservedInfectProp, allowedRecovProp, forbiddenRecovProp, sampleProp};
            System.out.println("adjusted propensities: "+Arrays.toString(adjustedPropensities));
            double todayPhyloLikelihood = PhyloLikelihood.calculateLikelihood(tree, particle, adjustedPropensities);
            System.out.println("Today's Phylo Likelihood: " +todayPhyloLikelihood);
            particle.setPhyloLikelihood(particle.getPhyloLikelihood()+todayPhyloLikelihood);
            System.out.println("Overall Phylo Likelihood: "+particle.getPhyloLikelihood());
        } else {
            particle.setState(particle.getState()+tree.births);
        }
        Day tmpDay = new Day(t, state, births, deaths);
        particle.updateTrajectory(tmpDay);
    }

    public static void step(Particle particle, TreeSegment[] treeSegments, int step, double[][] rates) {
        int t = step*Storage.resampleEvery;
        int increments = treeSegments.length;
        for (int i=0; i<increments; i++) {
            if (Storage.isPhyloOnly() && treeSegments[i].lineages == 0 && step > 1) {
                break;
            }
            int actualDay = t+i;
            System.out.println();
            System.out.println("Sending particle "+particle.particleID+" for day "+actualDay+", State currently: "+particle.getState());
            day(particle, treeSegments[i], actualDay, rates[i]);
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

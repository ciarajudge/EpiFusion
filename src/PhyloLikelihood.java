
public class PhyloLikelihood {
    public static double calculateLikelihood(TreeSegment tree, Particle particle, double[] propensities) {
        int treeBirths = tree.births;
        int treeSamples = tree.samplings;
        double conditionalLogP;

        // Case 1: Likelihood given no events on the tree
        conditionalLogP = 0 - (propensities[4] + propensities[0] + propensities[3]);
        //System.out.println("Phylolikelihood main:" + conditionalLogP);

        if (treeBirths != 0 || treeSamples != 0) {
            // Case 2: Likelihood given something does happen
            int[] observations = tree.observationOrder;
            for (int observation : observations) {
                if (observation == 0) {
                    conditionalLogP += observedEventProbability(observation, particle, propensities[0] + propensities[1]);
                }
                else {
                    conditionalLogP += observedEventProbability(observation, particle, propensities[4]);
                }

            }
        }

        if (particle.getState() < 0) { //Sometimes the observations can make the state go negative, in which case the particle is trash
            conditionalLogP = Double.NEGATIVE_INFINITY;
        }

        return conditionalLogP;
    }

    public static double observedEventProbability(int type, Particle particle, double prop) {
        double conditionalLogP = 0.0;
        int state = particle.getState();
        //System.out.println(state);
        //System.out.println(prop);
        if (type == 0) { //Coalescence
            //System.out.println("Additional birth p: "+2.0 / (double) state / (state-1) * prop);
            //System.out.println("Additional birth logP:" + Math.log(2.0 / (double) state / (state-1) * prop));
            conditionalLogP += Math.log(2.0 / state / (state-1) * prop);
            particle.setState(state+1);
        }
        else {//sampling
            //System.out.println("Additional sampling P:" + prop);
            //System.out.println("Additional sampling logP:" + Math.log(prop));
            conditionalLogP += Math.log(prop);
            particle.setState(state-Storage.removalProbability);
        }

        return conditionalLogP;
    }


}


public class PhyloLikelihood {
    public static double calculateLikelihood(TreeSegment tree, Particle particle, double[] propensities, int t) {
        int treeBirths = tree.births;
        int treeSamples = tree.samplings;
        double conditionalLogP;

        // Case 1: Likelihood given no events on the tree
        conditionalLogP = 0 - (propensities[4] + propensities[0] + propensities[3]);
        //System.out.println("Particle: "+particle.particleID+" Phylolikelihood main:" + conditionalLogP);
        particle.likelihoodMatrix[t][0] += propensities[4];
        particle.likelihoodMatrix[t][1] += propensities[0];
        particle.likelihoodMatrix[t][2] += propensities[3];


        if (treeBirths != 0 || treeSamples != 0) {
            // Case 2: Likelihood given something does happen
            int[] observations = tree.observationOrder;
            for (int observation : observations) {
                if (observation == 0) {
                    conditionalLogP += observedEventProbability(observation, particle, propensities[0] + propensities[1], t);
                }
                else {
                    conditionalLogP += observedEventProbability(observation, particle, propensities[4], t);
                }
            }
        }

        if (particle.getState() < 0) { //Sometimes the observations can make the state go negative, in which case the particle is trash
            conditionalLogP = Double.NEGATIVE_INFINITY;
        }

        return conditionalLogP;
    }

    public static double calculateSegmentLikelihood(Particle particle, double[] propensities, int eventType, int t) {
        double conditionalLogP;

        // Case 1: Likelihood given no events on the tree
        conditionalLogP = 0 - (propensities[4] + propensities[0] + propensities[3]);
        //System.out.println("Particle: "+particle.particleID+" State "+particle.getState()+", Phylolikelihood main:" + conditionalLogP);
        if (eventType != 2) {
            double prop = eventType == 0 ? propensities[0] + propensities[1] : propensities[4];
            conditionalLogP += observedEventProbability(eventType, particle, prop, t);
        }

        if (particle.getState() < 0) { //Sometimes the observations can make the state go negative, in which case the particle is trash
            conditionalLogP = Double.NEGATIVE_INFINITY;
        }

        return conditionalLogP;
    }


    public static double observedEventProbability(int type, Particle particle, double prop, int t) {
        double conditionalLogP = 0.0;
        int state = particle.getState();

        if (type == 0) { //Coalescence
            particle.setState(state+1);
            conditionalLogP += Math.log(2.0 / state / (state-1) * prop);
            particle.likelihoodMatrix[t][3] += Math.log(2.0 / state / (state-1) * prop);
            //System.out.println("Particle: "+particle.particleID+" Phylolikelihood birth:" + conditionalLogP);
        }
        else { //sampling
            conditionalLogP += Math.log(prop);
            particle.likelihoodMatrix[t][4] += Math.log(prop);
            //particle.setState(state-Storage.removalProbability);
            //System.out.println("Particle: "+particle.particleID+" Phylolikelihood sampling:" + conditionalLogP);
        }

        return conditionalLogP;
    }


}

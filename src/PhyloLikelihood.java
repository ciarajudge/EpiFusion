

public class PhyloLikelihood {
    public static double calculateLikelihood(TreeSegment tree, int state, double[] propensities) {
        int treeBirths = tree.births;
        int treeSamples = tree.samplings;
        double conditionalLogP;

        //Case1 = Likelihood given no events on the tree
        conditionalLogP = 0-(propensities[4]+ propensities[0]+ propensities[3]);
        if (treeBirths != 0 || treeSamples != 0) { // Case2 = Likelihood given something does happen
            //Two types of possible observed events on tree for us: coalescence or sampling. We code them 0, 1
            for (int i = 0; i < treeBirths; i++) {
                conditionalLogP += observedEventProbabiltity(0, state, propensities[0] + propensities[1]);
            }
            for (int i = 0; i < treeSamples; i++) {
                conditionalLogP += observedEventProbabiltity(1, state, propensities[4]);
            }
        }
        return conditionalLogP;
    }

    public static double observedEventProbabiltity(int type, int state, double prop) {
        double conditionalLogP = 0.0;

        if (type == 0) { //Coalescence
            conditionalLogP += Math.log(2.0 / state / (state-1) * prop);
        }
        else {
            conditionalLogP += Math.log(prop);
        }

        return conditionalLogP;
    }

}

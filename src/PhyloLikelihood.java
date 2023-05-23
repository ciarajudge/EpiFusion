import java.util.Arrays;
import java.util.ConcurrentModificationException;
import java.util.List;
import java.util.Collections;

public class PhyloLikelihood {
    public static double calculateLikelihood(TreeSegment tree, Particle particle, double[] propensities) {
        int treeBirths = tree.births;
        int treeSamples = tree.samplings;
        double conditionalLogP = 0.0;

        try {
            // Case 1: Likelihood given no events on the tree
            conditionalLogP = 0 - (propensities[4] + propensities[0] + propensities[3]);

            if (treeBirths != 0 || treeSamples != 0) {
                // Case 2: Likelihood given something does happen
                int[] observations = tree.observationOrder;
                for (int observation : observations) {
                    conditionalLogP += observedEventProbability(observation, particle, propensities[0] + propensities[1]);
                }
            }
        } catch (NullPointerException e) {
            // Handle NullPointerException
            System.out.println("Null pointer exception");
            e.printStackTrace();
            // You can choose to throw the exception again if needed or return a specific value.
        } catch (ArrayIndexOutOfBoundsException e) {
            // Handle ArrayIndexOutOfBoundsException
            System.out.println("Array index out of bounds exception");
            e.printStackTrace();
            // You can choose to throw the exception again if needed or return a specific value.
        } catch (ConcurrentModificationException e) {
            // Handle ConcurrentModificationException
            System.out.println("Concurrent modification exception");
            e.printStackTrace();
            // You can choose to throw the exception again if needed or return a specific value.
        } catch (Exception e) {
            // Handle any other exception (optional)
            System.out.println("Other exception");
            e.printStackTrace();
            // You can choose to throw the exception again if needed or return a specific value.
        }

        return conditionalLogP;
    }

    public static double observedEventProbability(int type, Particle particle, double prop) {
        double conditionalLogP = 0.0;
        int state = particle.getState();
        if (type == 0) { //Coalescence
            conditionalLogP += Math.log(2.0 / state / (state-1) * prop);
            particle.setState(state+1);
        }
        else {//sampling
            conditionalLogP += Math.log(prop);
            particle.setState(state-1);
        }

        return conditionalLogP;
    }

    public static int[] randomiseObservations(int births, int samplings) { //do it in order
        Integer[] observations = new Integer[births + samplings];
        Arrays.fill(observations, 0, births, 0);
        Arrays.fill(observations, births, births + samplings, 1);

        List<Integer> list = Arrays.asList(observations);
        Collections.shuffle(list);
        list.toArray(observations);
        return Arrays.stream(observations).mapToInt(Integer::intValue).toArray();
    }

}

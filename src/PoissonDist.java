import org.apache.commons.math3.distribution.PoissonDistribution;

public class PoissonDist implements Dist {
    private final PoissonDistribution poissonDistribution;

    public PoissonDist(double mean) {
        poissonDistribution = new PoissonDistribution(mean);
    }

    @Override
    public double sample() {
        return poissonDistribution.sample();
    }

    @Override
    public double density(int candidate) {
        return poissonDistribution.probability(candidate);
    }

}

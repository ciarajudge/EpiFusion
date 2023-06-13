import org.apache.commons.math3.distribution.NormalDistribution;

public class NormalDist implements Dist {
    private final NormalDistribution normalDistribution;

    public NormalDist(double mean, double standardDeviation) {
        normalDistribution = new NormalDistribution(mean, standardDeviation);
    }

    @Override
    public double sample() {
        return normalDistribution.sample();
    }

    @Override
    public double density(double candidate) {
        return normalDistribution.density(candidate);
    }

}

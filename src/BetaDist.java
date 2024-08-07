import org.apache.commons.math3.distribution.BetaDistribution;

public class BetaDist implements Dist {
    private final BetaDistribution betaDistribution;

    public BetaDist(double alpha, double beta) {
        betaDistribution = new BetaDistribution(alpha, beta);
    }

    @Override
    public double sample() {
        return betaDistribution.sample();
    }

    @Override
    public double density(double candidate) {
        return betaDistribution.density(candidate);
    }

}


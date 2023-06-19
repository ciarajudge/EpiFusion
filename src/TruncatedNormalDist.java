import org.apache.commons.math3.distribution.NormalDistribution;

import java.util.Random;

public class TruncatedNormalDist implements Dist{
    private double mean;
    private double standardDeviation;
    private double lowerBound;
    //private double upperBound;
    private Random random;
    NormalDistribution standardNormal;

    public TruncatedNormalDist(double mean, double standardDeviation, double lowerBound){
        this.mean = mean;
        this.standardDeviation = standardDeviation;
        this.random = new Random();
        this.lowerBound = lowerBound;
        this.standardNormal = new NormalDistribution(mean, standardDeviation);
    }

    @Override
    public double sample() {
        double sample = 0.0;
        do {
            sample = standardNormal.sample();
        } while (sample < lowerBound);
        return sample;
    }

    @Override
    public double density(double candidate) {
        if (candidate < lowerBound) {
            return 0.0;
        }
        double cdfLower = standardNormal.cumulativeProbability(lowerBound);
        return standardNormal.density(candidate)/(1-cdfLower);
    }

}


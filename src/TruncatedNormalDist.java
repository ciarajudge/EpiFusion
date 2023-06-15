import org.apache.commons.math3.distribution.NormalDistribution;

import java.util.Random;

public class TruncatedNormalDist implements Dist{
    private double mean;
    private double standardDeviation;
    private double lowerBound;
    //private double upperBound;
    private Random random;

    public TruncatedNormalDist(double mean, double standardDeviation, double lowerBound){
        this.mean = mean;
        this.standardDeviation = standardDeviation;
        this.random = new Random();
        this.lowerBound = lowerBound;
    }

    @Override
    public double sample() {
        double sample = 0.0;
        for (int i = 0; i < 1; i++) {
            do {
                sample = random.nextGaussian() * standardDeviation + mean;
            } while (sample < lowerBound);
        }
        return sample;
    }

    @Override
    public double density(double candidate) {
        NormalDistribution standardNormal = new NormalDistribution(mean, standardDeviation);
        double cdfLower = standardNormal.cumulativeProbability((lowerBound-mean)/standardDeviation);
        return standardNormal.density(((candidate-mean)/standardDeviation)/(1-cdfLower));
    }

}


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

/* alternative truncnorm distribution I'd rather use, but would need to debug


import org.apache.commons.math3.random.RandomGenerator;
import org.apache.commons.math3.random.UniformRandomGenerator;
import org.apache.commons.statistics.distribution.*;
import org.apache.commons.rng.UniformRandomProvider;
import org.apache.commons.rng.simple.RandomSource;


public class TruncatedNormalDist implements Dist{
    private final double mean;
    private final double standardDeviation;
    private final double lowerBound;
    private final double upperBound;
    private UniformRandomProvider random;
    TruncatedNormalDistribution truncatedNormal;
    ContinuousDistribution.Sampler sampler;

    public TruncatedNormalDist(double mean, double standardDeviation, double lowerBound, double upperBound){
        this.mean = mean;
        this.standardDeviation = standardDeviation;
        this.random = RandomSource.create(RandomSource.MT);
        this.lowerBound = lowerBound;
        this.upperBound = upperBound;
        this.truncatedNormal = TruncatedNormalDistribution.of(mean, standardDeviation, lowerBound, upperBound);
        this.sampler = truncatedNormal.createSampler(random);
    }

    @Override
    public double sample() {
        double sample = this.sampler.sample();
        return sample;
    }

    @Override
    public double density(double candidate) {
        return truncatedNormal.density(candidate);
    }

} */


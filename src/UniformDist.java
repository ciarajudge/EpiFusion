import java.util.Random;

public class UniformDist implements Dist {
    private final Random random;
    private final double min;
    private final double max;

    public UniformDist(double min, double max) {
        this.random = new Random();
        this.min = min;
        this.max = max;
    }

    @Override
    public double sample() {
        double rand = random.nextDouble();
        double sampleValue  = min + ((max-min)*rand);
        return sampleValue;
    }

    @Override
    public double density(double candidate) {
        return 1;
    }

}

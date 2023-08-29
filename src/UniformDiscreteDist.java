import java.util.Random;

public class UniformDiscreteDist implements Dist {
    private final Random random;
    private final double min;
    private final double max;


    public UniformDiscreteDist(double min, double max) {
        this.random = new Random();
        this.min = min;
        this.max = max;
    }

    @Override
    public double sample() {
        double rand = random.nextDouble();
        double sampleValue  = min + ((max-min)*rand);
        return Math.round(sampleValue);
    }

    @Override
    public double density(double candidate) {
        if (candidate>min && candidate < max) {
            return 1;
        } else {
            return 0;
        }
    }

}

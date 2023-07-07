
public class FixedParameter implements Dist {
    private final double parameterValue;

    public FixedParameter(double value) {
        parameterValue = value;
    }

    @Override
    public double sample() {
        return parameterValue;
    }

    @Override
    public double density(double candidate) {
        return 1;
    }

}

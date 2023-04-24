public class FluxModel {
    private double mean;
    private double standardDeviation;

    public FluxModel(double mean, double standardDeviation) {
        this.mean = mean;
        this.standardDeviation = standardDeviation;
    }

    public double evaluate(double t) {
        double exponent = -0.5 * Math.pow((t - mean) / standardDeviation, 2);
        double normalizer = 1 / (standardDeviation * Math.sqrt(2 * Math.PI));
        return normalizer * Math.exp(exponent);
    }

    public double getMean() {
        return mean;
    }

    public double getStandardDeviation() {
        return standardDeviation;
    }

    public void setMean(double mean) {
        this.mean = mean;
    }

    public void setStandardDeviation(double standardDeviation) {
        this.standardDeviation = standardDeviation;
    }





}

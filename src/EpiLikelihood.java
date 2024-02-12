import org.apache.commons.math3.distribution.PoissonDistribution;

public class EpiLikelihood {

    private static double logFactorial(int n) {
        double result = 0;
        for (int i = 1; i <= n; i++) {
            result += Math.log(i);
        }
        return result;
    }

/*
    public static double poissonLikelihood(int incidence, Particle particle) {
        //System.out.println("["+particle.particleID+"] Likelihood called");
        double p;
        if (particle.positiveTests <= 0) { //if state is <=0 (and incidence is a positive number), prob is 0
            p = 0.001;
        } else {
            p = particle.positiveTests;
        }



        double logLikelihood = -p + incidence * Math.log(p) - logFactorial(incidence);
        particle.positiveTests = 0;
        return Math.exp(logLikelihood);
    }
    */
    public static double poissonLikelihood(int incidence, Particle particle) {

        double p = particle.positiveTests == 0 ? 0.001 : particle.positiveTests;
        PoissonDistribution poisson = new PoissonDistribution(p);
        double likelihood = poisson.probability(incidence);
        particle.positiveTests = 0;
        return likelihood;
    }

    public static double binomialLikelihood(int incidence, Particle particle) {
        double p = 0.1; // probability of success
        double n = particle.getState()*p; // number of trials

        // calculate the probability of the measurement given the state
        double probability = binomialProbability(incidence, n, p, particle.getState());

        // return the likelihood
        return probability;
    }

    public static double binomialProbability(int k, double n, double p, int state) {
        double q = 1 - p; // probability of failure
        double binomialCoefficient = binomialCoefficient(n, k);
        double probability = binomialCoefficient * Math.pow(p, k) * Math.pow(q, n - k);

        if (state == 0) {
            probability = 1 - probability;
        }

        return probability;
    }

    public static double binomialCoefficient(double n, int k) {
        double result = 1;

        for (int i = 1; i <= k; i++) {
            result *= (double) (n - k + i) / i;
        }

        return result;
    }

}

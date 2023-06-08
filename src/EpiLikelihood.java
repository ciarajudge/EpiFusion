
public class EpiLikelihood {

    private static double logFactorial(int n) {
        double result = 0;
        for (int i = 1; i <= n; i++) {
            result += Math.log(i);
        }
        return result;
    }


    public static double poissonLikelihood(int incidence, Particle particle, double phi) {
        if (particle.getState() == 0 && incidence == 0) { //if state and incidence are 0, prob is 1
            return 1.0;
        } else if (particle.getState() <= 0) { //if state is <=0 (and incidence is a positive number), prob is 0
            return 0.0;
        }
        double p = particle.getState() * phi;
        double logLikelihood = -p + incidence * Math.log(p) - logFactorial(incidence);
        return Math.exp(logLikelihood);
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

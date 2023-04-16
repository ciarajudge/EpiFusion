import java.math.BigInteger;

public class EpiLikelihood {
    public static int factorial(int n) {
        if (n == 0) {
            return 1;
        } else {
            return n * factorial(n-1);
        }
    }

    public static double calculateLikelihood(int incidence, Particle particle) {
        //This is currently a dud function but I'm just getting the code working
        double pDetect = 0.1; // Note that this is a constant number but I should switch to sampling from a dist to introduce noise
        double p = particle.state * pDetect;
        double likelihood = Math.abs(p-incidence);
        return likelihood;
    }

}

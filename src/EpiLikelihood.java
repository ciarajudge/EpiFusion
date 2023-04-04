

public class EpiLikelihood {
    public static int factorial(int n) {
        if (n == 0) {
            return 1;
        } else {
            return n * factorial(n-1);
        }
    }

    public static double calculateLikelihood(int incidence, Particle particle) {
        double pDetect = 0.25; // probability of detecting an infected individual
        double p = Math.pow(pDetect, incidence) * Math.pow(1 - pDetect, particle.getState() - incidence); // probability of observing the cases given the number of infected individuals
        int numCombinations = factorial(particle.getState()) / (factorial(incidence) * factorial(particle.getState() - incidence)); // number of ways to choose the cases from the infected individuals
        double likelihood = numCombinations * p; // likelihood of the particle given the observed cases
        return likelihood;
    }

}

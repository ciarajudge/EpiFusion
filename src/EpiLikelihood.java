import org.apache.commons.math3.distribution.PoissonDistribution;
import org.apache.commons.math3.distribution.PascalDistribution;

public class EpiLikelihood {

    public static double epiLikelihood(int incidence, Particle particle, double phi) {
        double likelihood;
        if (Storage.epiObservationModel.equals("poisson")) {
            likelihood = poissonLikelihood(incidence, particle);
        } else if (Storage.epiObservationModel.equals("negbinom")) {
            likelihood = negbinomLikelihood(incidence, particle, phi);
        } else {
            likelihood = 0;
            System.out.println("ERROR: Unrecognised Epi observation model! Check the 'model' block of your XML file for any mispellings or errors!");
            System.exit(0);
        }
        return likelihood;
    }

    private static double logFactorial(int n) {
        double result = 0;
        for (int i = 1; i <= n; i++) {
            result += Math.log(i);
        }
        return result;
    }


    public static double poissonLikelihood(int incidence, Particle particle) {
        //System.out.println("["+particle.particleID+"] Likelihood called");
        double p;
        if (particle.positiveTests <= 0) { //if state is <=0 (and incidence is a positive number), prob is 0
            p = 0.001;
        } else {
            p = particle.positiveTests;
        }

        double logLikelihood = -p + incidence * Math.log(p) - logFactorial(incidence);
        particle.positiveTestsFit.add(particle.positiveTests);
        particle.positiveTests = 0;
        return Math.exp(logLikelihood);
    }
    /*
     public static double poissonLikelihood(int incidence, Particle particle) {

         double p = particle.positiveTests == 0 ? 0.001 : particle.positiveTests;
         PoissonDistribution poisson = new PoissonDistribution(p);
         double likelihood = poisson.probability(incidence);
         particle.positiveTests = 0;
         return likelihood;
     }
  */
    public static double negbinomLikelihood(int incidence, Particle particle, double phi) {
        int successes = incidence;
        double probSuccess = phi;
        int failures = particle.epiCumInfections-successes;
        particle.epiCumInfections = 0;

        // make distribution
        PascalDistribution pascalDistribution = new PascalDistribution(successes, probSuccess);
        double probability = pascalDistribution.probability(failures);

        // return the likelihood
        return probability;
    }



}

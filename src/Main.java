
import java.io.FileNotFoundException;
import java.util.Arrays;

public class Main {
    public static void main(String[] args) throws FileNotFoundException, InterruptedException {
        System.out.println("EpiFusion");

        //Define params
        int T = 20;
        int numParticles = 2;

        //Read in tree


        //Read in case incidence
        Incidence caseIncidence = new Incidence("/Users/ciarajudge/Desktop/incidence.txt");
        System.out.println(Arrays.toString(caseIncidence.incidence));

        //Initialise particles
        Particles particles = new Particles(numParticles);
        particles.printParticles();


        //Particle filter
        for (int t = 0; t < T; t++) {
            System.out.println("Day "+t+", Incidence: "+caseIncidence.incidence[t]);
            //predict and update
            particles.predictAndUpdate();
            //particle likelihoods
            particles.getLikelihoods(caseIncidence.incidence[t]);
            //resample
            particles.resampleParticles();
            //estimate
            particles.printParticles();
        }


    }
}
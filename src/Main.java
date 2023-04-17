
import java.io.FileNotFoundException;
import java.util.Arrays;

public class Main {
    public static void main(String[] args) throws FileNotFoundException, InterruptedException {
        System.out.println("EpiFusion");

        //Define params
        int numParticles = 10;

        //Read in tree


        //Read in case incidence
        Incidence caseIncidence = new Incidence("/Users/ciarajudge/Desktop/incidence.txt");
        System.out.println(Arrays.toString(caseIncidence.incidence));

        //Initialise particles
        Particles particles = new Particles(numParticles, caseIncidence.length);
        particles.printParticles();

        ParticleFilter.particleFilter(caseIncidence, particles);

        particles.saveParticleHistory("/Users/ciarajudge/Desktop/particlehistory.csv");

    }
}

import java.io.FileNotFoundException;
import java.util.Arrays;

public class Main {
    public static void main(String[] args) throws FileNotFoundException {
        System.out.println("EpiFusion");


        //Define params
        int T = 20;
        int numParticles = 10;

        //Read in tree


        //Read in case incidence
        Incidence caseIncidence = new Incidence("/Users/ciarajudge/Desktop/incidence.txt");
        System.out.println(Arrays.toString(caseIncidence.incidence));

        //Initialise particles
        Particles particles = new Particles(numParticles);
        particles.printParticles();

        //Making a test edit

        //Particle filter
        for (int t = 0; t < T; t++) {
            //predit
            //update
            //resample
            //estimate
        }


    }
}
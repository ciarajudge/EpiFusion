
import java.io.IOException;
import java.util.Arrays;

public class Main {
    public static void main(String[] args) throws IOException, InterruptedException {
        System.out.println("EpiFusion");

        //Define params
        int numParticles = 10;

        //Read in tree
        Tree tree = new Tree("/Users/ciarajudge/Desktop/PhD/EpiFusionData/simulatedtree.txt");
        //tree.printTree();

        //Read in case incidence
        Incidence caseIncidence = new Incidence("/Users/ciarajudge/Desktop/PhD/EpiFusionData/weekly_incidence.txt");
        System.out.println(Arrays.toString(caseIncidence.incidence));

        //Initialise particles
        Particles particles = new Particles(numParticles, caseIncidence.length);
        //particles.printParticles();

        ParticleFilter.particleFilter(caseIncidence, particles);

        particles.saveParticleHistory("/Users/ciarajudge/Desktop/PhD/EpiFusionResults/particlehistory.csv");

    }
}
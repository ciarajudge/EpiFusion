
import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException, InterruptedException {
        System.out.println("EpiFusion");

        //Define params
        int numParticles = 100;
        int numIterations = 1000;

        //Read in tree
        Tree tree = new Tree("/Users/ciarajudge/Desktop/PhD/EpiFusionData/simulatedtree.txt");
        tree.printTree();

        //Read in case incidence
        Incidence caseIncidence = new Incidence("/Users/ciarajudge/Desktop/PhD/EpiFusionData/incidence.txt");
        //System.out.println(Arrays.toString(caseIncidence.incidence));


        ParticleFilter particleFilter = new ParticleFilter(numParticles);

        MCMC particleMCMC = new MCMC(particleFilter);
        particleMCMC.runMCMC(numIterations);
        double[] finalParams = particleFilter.getParameters();

        //particles.saveParticleHistory("/Users/ciarajudge/Desktop/PhD/EpiFusionResults/particlehistory_poisson.csv");

    }
}
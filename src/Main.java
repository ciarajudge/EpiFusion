
import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException {
        System.out.println("EpiFusion");

        //Define params
        int numParticles = 1;
        int numIterations = 0;

        //Read in tree
        Tree tree = new Tree("/Users/ciarajudge/Desktop/PhD/EpiFusionData/basesim2_simulatedtree.txt");
        tree.printTree();

        //Read in case incidence
        Incidence caseIncidence = new Incidence("/Users/ciarajudge/Desktop/PhD/EpiFusionData/basesim2_weeklyincidence.txt");

        //Initialise particle filter instance
        double[] initialParameters = {0.3,0.2,0.02};
        ParticleFilter particleFilter = new ParticleFilter(numParticles, initialParameters, tree, caseIncidence);

        //Initialise and run MCMC instance
        MCMC particleMCMC = new MCMC(particleFilter);
        particleMCMC.runMCMC(numIterations);

        //Save output
        double[] finalParams = particleFilter.getCurrentParameters();
        //particles.saveParticleHistory("/Users/ciarajudge/Desktop/PhD/EpiFusionResults/particlehistory_poisson.csv");

    }
}
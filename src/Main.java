
import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException {
        System.out.println("EpiFusion");

        //Define params
        int numParticles = 5;
        Storage.setNumParticles(numParticles);
        int numIterations = 20;
        Storage.setEpiGrainyResolution();
        //Storage.setPhyloOnly();
        Storage.setEpiOnly();
        int resampleEvery = 7;
        Storage.setResampling(resampleEvery);
        int T;

        //Read in tree
        Tree tree = new Tree("/Users/ciarajudge/Desktop/PhD/EpiFusionData/basesim2_simulatedtree.txt");

        //Read in case incidence
        Incidence caseIncidence = new Incidence("/Users/ciarajudge/Desktop/PhD/EpiFusionData/basesim2_weeklyincidence.txt");

        //Define more params based on data
        int epiLength = Storage.isEpiGrainyResolution() ? resampleEvery * caseIncidence.length : caseIncidence.length;
        double phyloLength = tree.age;
        T = Math.max(epiLength, (int) Math.round(phyloLength));

        //Initialise particle filter instance
        double[] initialParameters = Storage.priors.sampleInitial();
        ParticleFilter particleFilter = new ParticleFilter(numParticles, initialParameters, tree, caseIncidence, T, resampleEvery);

        //Initialise and run MCMC instance
        MCMC particleMCMC = new MCMC(particleFilter);
        particleMCMC.runMCMC(numIterations);

        particleMCMC.loggers.trajectories.close();

    }
}
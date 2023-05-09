import java.util.concurrent.*;
import java.util.Random;


public class Particles {
    Particle[] particles;
    int N;
    int[][] particlesHistory;

    public Particles(int numParticles){
        N = numParticles;
        particles = new Particle[numParticles];
        for (int i = 0; i< N; i++) {
            particles[i] = new Particle(i);
        }
    }

    public void printParticles() {
        for (int i = 0; i < N; i++) {
            particles[i].printStatus();
        }
    }

    public void printLikelihoods() {
        for (int i = 0; i < N; i++) {
            System.out.println("Particle: "+i);
            System.out.println("PhyloLikelihood: "+particles[i].getPhyloLikelihood());
            System.out.println("EpiLikelihood: "+Math.log(particles[i].getEpiLikelihood()));
        }
    }


    public void predictAndUpdate(int t, Tree tree, double[] rates){
        ExecutorService executor = Executors.newFixedThreadPool(4);
        try {
            int spareT = t*7;
            //Tree segments made here
            TreeSegment[] treeSegments = new TreeSegment[7];
            int ind = 0;
            for (int i=spareT; i<spareT+7; i++) {
                double end = (double) i + 1;
                treeSegments[ind] = new TreeSegment(tree, i, end);
                ind++;
            }

            for (Particle particle : particles) {
                executor.submit(() -> ProcessModel.week(particle, treeSegments, t, rates));
            }

            executor.shutdown();
            boolean done = executor.awaitTermination(Long.MAX_VALUE, TimeUnit.SECONDS);
            if (!done) {
                System.err.println("Not all tasks completed within the specified timeout.");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Interrupted while waiting", e);
        }
    }

    public void getEpiLikelihoods(int incidence) {
        try {
            ExecutorService executor = Executors.newFixedThreadPool(4);

            for (Particle particle : particles) {
                executor.submit(() -> {
                    double newLikelihood = EpiLikelihood.poissonLikelihood(incidence, particle);
                    particle.setEpiLikelihood(newLikelihood);
                });
            }

            executor.shutdown();
            boolean done = executor.awaitTermination(Long.MAX_VALUE, TimeUnit.SECONDS);
            if (!done) {
                System.err.println("Not all tasks completed within the specified timeout.");
            }
        } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
        throw new RuntimeException("Interrupted while waiting", e);
    }
    }

    public void updateWeights(double confidenceSplit) {
        try {
            ExecutorService executor = Executors.newFixedThreadPool(4);

            for (Particle particle : particles) {
                executor.submit(() -> particle.updateWeight(confidenceSplit));
            }

            executor.shutdown();
            boolean done = executor.awaitTermination(Long.MAX_VALUE, TimeUnit.SECONDS);
            if (!done) {
                System.err.println("Not all tasks completed within the specified timeout.");
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Interrupted while waiting", e);
        }
    }

    public void resampleParticles() {
        Particle[] resampledParticles = new Particle[N];
        double totalWeight = 0.0;

        // Calculate the total weight of all particles
        for (Particle particle : particles) {
            totalWeight += particle.weight;
        }

        // Generate a random number between 0 and total weight
        Random random = new Random();
        for (int i = 0; i < N; i++) {
            double randomWeight = random.nextDouble() * totalWeight;
            double runningSum = 0.0;

            // Iterate through particles and select based on weights
            for (Particle particle : particles) {
                runningSum += particle.weight;
                if (runningSum >= randomWeight) {
                    resampledParticles[i] = new Particle(particle);
                    break;
                }
            }
        }
        particles = resampledParticles;
    }

    public void scalePhyloWeights() {
        double[] particleWeights = new double[N];
        double[] logParticleWeights = new double[N];
        double maxLogWeight = Double.NEGATIVE_INFINITY;

        int iter = 0;
        for (Particle particle : particles) {
            maxLogWeight = Math.max(particle.phyloLikelihood, maxLogWeight);
            logParticleWeights[iter] = particle.phyloLikelihood;
            iter++;
        }

        double sumOfScaledWeights = 0;
        for (int p=0; p<N; p++){
            particleWeights[p] = Math.exp(logParticleWeights[p] - maxLogWeight);
            sumOfScaledWeights += particleWeights[p];
        }

        for (int p=0; p<N; p++){
            particles[p].setPhyloWeight(particleWeights[p]/sumOfScaledWeights);
        }
    }

    public void scaleEpiWeights() {
        double[] particleWeights = new double[N];
        double[] logParticleWeights = new double[N];
        double maxLogWeight = Double.NEGATIVE_INFINITY;

        int iter = 0;
        for (Particle particle : particles) {
            maxLogWeight = Math.max(particle.epiWeight, maxLogWeight);
            logParticleWeights[iter] = particle.epiWeight;
            iter++;
        }

        double sumOfScaledWeights = 0;
        for (int p=0; p<N; p++){
            particleWeights[p] = Math.exp(logParticleWeights[p] - maxLogWeight);
            sumOfScaledWeights += particleWeights[p];
        }

        for (int p=0; p<N; p++){
            particles[p].setEpiWeight(particleWeights[p]/sumOfScaledWeights);
        }
    }

    public double scaleWeightsAndGetLogP() {
        scaleEpiWeights();
        scalePhyloWeights();
        updateWeights(0.5);

        double[] particleWeights = new double[N];
        double[] logParticleWeights = new double[N];
        double maxLogWeight = Double.NEGATIVE_INFINITY;

        int iter = 0;
        for (Particle particle : particles) {
            maxLogWeight = Math.max(particle.weight, maxLogWeight);
            logParticleWeights[iter] = particle.weight;
            iter++;
        }

        double sumOfScaledWeights = 0;
        for (int p=0; p<N; p++){
            particleWeights[p] = Math.exp(logParticleWeights[p] - maxLogWeight);
            sumOfScaledWeights += particleWeights[p];
        }

        for (int p=0; p<N; p++){
            particles[p].setWeight(particleWeights[p]/sumOfScaledWeights);
        }

        double logP = Math.log(sumOfScaledWeights/N) + maxLogWeight;
        return logP;
    }

}

import java.util.concurrent.*;
import java.util.Random;

public class Particles {
    Particle[] particles;
    int N;
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

    public void predictAndUpdate() throws InterruptedException{
        ExecutorService executor = Executors.newFixedThreadPool(4);

        for (Particle particle : particles) {
            executor.submit(() -> {
                ProcessModel.updateState(particle);
            });
        }

        executor.shutdown();
        executor.awaitTermination(Long.MAX_VALUE, TimeUnit.SECONDS);
    }

    public void getLikelihoods(int incidence) throws InterruptedException{
        ExecutorService executor = Executors.newFixedThreadPool(4);

        for (Particle particle : particles) {
            executor.submit(() -> {
                double newLikelihood = EpiLikelihood.calculateLikelihood(incidence, particle);
                particle.setLikelihood(newLikelihood);
            });
        }

        executor.shutdown();
        executor.awaitTermination(Long.MAX_VALUE, TimeUnit.SECONDS);
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
                    resampledParticles[i] = particle;
                    break;
                }
            }
        }
        particles = resampledParticles;
    }

}

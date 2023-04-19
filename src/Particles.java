import java.util.concurrent.*;
import java.util.Random;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

public class Particles {
    Particle[] particles;
    int N;
    int[][] particlesHistory;

    public Particles(int numParticles, int T){
        N = numParticles;
        particles = new Particle[numParticles];
        particlesHistory = new int[numParticles][(T*2)];
        for (int i = 0; i< N; i++) {
            particles[i] = new Particle(i);
        }
    }

    public void editParticlesHistory(int row, int col, int value){
        particlesHistory[row][col] = value;
    }

    public void printParticles() {
        for (int i = 0; i < N; i++) {
            particles[i].printStatus();
        }
    }

    public void predictAndUpdate(int t) throws InterruptedException{
        ExecutorService executor = Executors.newFixedThreadPool(4);

        for (Particle particle : particles) {
            executor.submit(() -> {
                editParticlesHistory(particle.row, (t * 2), particle.state);
                ProcessModel.updateState(particle);
                editParticlesHistory(particle.row, ((t * 2) + 1), particle.state);
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

    public void resampleParticles(int t) {
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
                    resampledParticles[i] = new Particle(particle, i);
                    //System.out.println("Particle "+i+" resampled as Particle "+particle.row);
                    break;
                }
            }
        }
        particles = resampledParticles;
    }

    public void saveParticleHistory(String fileName) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(fileName))) {
            for (int i = 0; i < particlesHistory.length; i++) {
                for (int j = 0; j < particlesHistory[i].length; j++) {
                    writer.write(Integer.toString(particlesHistory[i][j])); // Write each element to the file
                    if (j < particlesHistory[i].length - 1) {
                        writer.write(","); // Add a comma as a separator between elements
                    }
                }
                writer.newLine(); // Write a new line after each row
            }
            System.out.println("Matrix has been written to " + fileName);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}

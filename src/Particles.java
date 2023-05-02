import java.util.concurrent.*;
import java.util.Random;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

public class Particles {
    Particle[] particles;
    int N;
    int[][] particlesHistory;

    public Particles(int numParticles, double[] parameters){
        N = numParticles;
        particles = new Particle[numParticles];
        for (int i = 0; i< N; i++) {
            particles[i] = new Particle(i, parameters);
        }
    }

    /*public void editParticlesHistory(int row, int col, int value){
        particlesHistory[row][col] = value;
    }*/

    public void printParticles() {
        for (int i = 0; i < N; i++) {
            particles[i].printStatus();
        }
    }

    public void predictAndUpdate(int t, Tree tree) throws InterruptedException{
        ExecutorService executor = Executors.newFixedThreadPool(4);

        //Tree segments made here
        TreeSegment[] treeSegments = new TreeSegment[7];
        int ind = 0;
        for (int i=t; i<t+7; i++) {
            double end = (double) i + 1;
            treeSegments[ind] = new TreeSegment(tree, i, end);
            ind++;
        }

        for (Particle particle : particles) {
            executor.submit(() -> ProcessModel.week(particle, treeSegments));
        }

        executor.shutdown();
        executor.awaitTermination(Long.MAX_VALUE, TimeUnit.SECONDS);
    }

    public void getEpiLikelihoods(int incidence) throws InterruptedException{
        ExecutorService executor = Executors.newFixedThreadPool(4);

        for (Particle particle : particles) {
            executor.submit(() -> {
                double newLikelihood = EpiLikelihood.poissonLikelihood(incidence, particle);
                particle.setEpiLikelihood(newLikelihood);
            });
        }

        executor.shutdown();
        executor.awaitTermination(Long.MAX_VALUE, TimeUnit.SECONDS);
    }

    public void updateWeights() throws InterruptedException {
        ExecutorService executor = Executors.newFixedThreadPool(4);

        for (Particle particle : particles) {
            executor.submit(() -> {
                particle.updateWeight(0.5);
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
                    resampledParticles[i] = new Particle(particle);
                    //System.out.println("Particle "+i+" resampled as Particle "+particle.row);
                    break;
                }
            }
        }
        particles = resampledParticles;
    }

    public void saveParticleHistory(String fileName) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(fileName))) {
            for (int[] ints : particlesHistory) {
                for (int j = 0; j < ints.length; j++) {
                    writer.write(Integer.toString(ints[j])); // Write each element to the file
                    if (j < ints.length - 1) {
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

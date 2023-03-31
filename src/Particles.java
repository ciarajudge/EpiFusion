import java.util.concurrent.*;

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

    public void updateParticles() throws InterruptedException{
        ExecutorService executor = Executors.newFixedThreadPool(4);

        for (Particle particle : particles) {
            executor.submit(() -> {
                ProcessModel.updateState(particle);
            });
        }


        executor.shutdown();
        executor.awaitTermination(Long.MAX_VALUE, TimeUnit.SECONDS);

    }
}

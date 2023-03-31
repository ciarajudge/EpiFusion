public class ParticleFilter {
    Particles particles;
    public ParticleFilter(int numParticles) {
        particles = new Particles(numParticles);
    }

    public void filterStep() throws InterruptedException {
        particles.updateParticles();

    }



}

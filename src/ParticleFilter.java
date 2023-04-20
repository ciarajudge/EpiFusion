public class ParticleFilter {

    public static void filterStep(int t, Particles particles, int incidence) throws InterruptedException {
        //System.out.println("Day "+t+", Incidence: "+incidence);
        //predict and update
        particles.predictAndUpdate(t);
        //particle likelihoods
        particles.getLikelihoods(incidence);
        //resample
        particles.resampleParticles(t);
        //estimate
        //particles.printParticles();
    }

    public static void particleFilter(Incidence caseIncidence, Particles particles) throws InterruptedException{
        //Particle filter
        for (int t = 0; t < caseIncidence.length; t++) {
                filterStep(t, particles, caseIncidence.incidence[t]);
        }
    }





}

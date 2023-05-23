public class Storage {
    private static boolean phyloOnly = false;
    private static boolean epiOnly = false;
    private static boolean epiGrainyResolution = false;
    public static int resampleEvery = 7;
    public static Priors priors = new Priors();
    public static int numParticles = 0;

    public static void setNumParticles(int N) {numParticles = N;}

    public static void setPhyloOnly() {
        phyloOnly = true;
    }

    public static void setResampling(int resampling) {
        resampleEvery = resampling;
    }

    public static void setEpiOnly() {
        epiOnly = true;
    }

    public static boolean isPhyloOnly() {
        return phyloOnly;
    }

    public static boolean isEpiOnly() {
        return epiOnly;
    }

    public static boolean isEpiGrainyResolution() {
        return epiGrainyResolution;
    }

    public static void setEpiGrainyResolution() {
        epiGrainyResolution = true;
    }

    public static void setEpiResolution(boolean resolution) {
        epiGrainyResolution = resolution;
    }
}

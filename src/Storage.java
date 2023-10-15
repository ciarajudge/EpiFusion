import org.w3c.dom.Element;

public class Storage {
    private static boolean phyloOnly = false;
    private static boolean epiOnly = false;
    private static boolean epiGrainyResolution = false;
    public static int resampleEvery = 7;
    public static Priors priors;
    public static int numParticles = 0;
    public static int numMCMCsteps = 0;
    public static int numThreads = 10;
    public static int numChains = 1;
    public static double stepCoefficient;
    public static Tree tree = null;
    public static Incidence incidence = null;
    public static int T;
    public static String fileBase;
    public static int logEvery;
    public static boolean tooBig = false;
    public static int removalProbability = 0;
    public static int maxEpidemicSize = 50000;
    public static int analysisType = 0;
    public static boolean segmentedDays = false;
    public static String folder;
    public static ParticleLoggers particleLoggers;
    public static boolean initialised = false;
    public static int completedRuns = 0;
    public static String argument = "foo";
    public static int firstStep = 0;
    public static MasterLoggers loggers = null;
    public static double[] confidenceSplit = null;

    public static void setNumParticles(int N) {numParticles = N;}

    public static void setNumMCMCsteps(int T) {numMCMCsteps = T;}

    public static void setPhyloOnly() {
        phyloOnly = true;
    }

    public static void setResampling(int resampling) {
        resampleEvery = resampling;
    }

    public static void setEpiOnly() {
        epiOnly = true;
    }

    public static void setLogEvery(int N) {logEvery = N;}

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

    public static void setTree(Tree t) {
        tree = t;
    }

    public static void setIncidence(Incidence i) {
        incidence = i;
    }

    public static void setT(int Time) {
        T = Time;
    }

    public static void setfileBase(String file) {
        fileBase = file;
    }

    public static void setPriors(Element element) {priors = new Priors(element);}

    public static void setStepCoefficient(double stepCo) {stepCoefficient = stepCo;}
}

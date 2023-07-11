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
    public static double stepCoefficient;
    public static Tree tree = null;
    public static Incidence incidence = null;
    public static int T;
    public static String fileBase;
    public static int logEvery;
    public static int numInitialisationAttempts;
    public static boolean treeOn = false;
    public static boolean haveReachedTree = false;
    public static boolean tooBig = false;
    public static int removalProbability = 0;
    public static int maxEpidemicSize = 50000;
    public static int analysisType = 0;

    public static void setNumParticles(int N) {numParticles = N;}

    public static void setNumMCMCsteps(int T) {numMCMCsteps = T;}

    public static void setNumInitialisationAttempts(int T) {numInitialisationAttempts = T;}

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

    public static void setEpiResolution(boolean resolution) {
        epiGrainyResolution = resolution;
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

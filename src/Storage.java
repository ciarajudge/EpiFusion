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
    public static boolean[] treeOn;
    public static boolean[] haveReachedTree;
    public static boolean tooBig = false;
    public static int removalProbability = 0;
    public static int maxEpidemicSize = 50000;
    public static int analysisType = 0;
    public static int[] truth = new int[] {1, 1, 2, 2, 6, 9, 10, 20, 39, 62, 118, 169, 281, 427, 641, 925, 1366, 2021, 2806, 3760, 4848, 5842, 6758, 7320, 7716, 7853, 7734, 7368, 6942, 6425, 5901, 5342, 4818, 4307, 3886, 3468, 3074, 2737, 2422, 2123, 1888, 1669, 1477, 1296, 1140, 1002, 881, 783, 679, 600, 520, 462, 398, 344, 305, 271, 240, 209, 179, 155, 129, 111, 91, 77, 65, 59, 54, 50, 43, 37, 30, 27, 25, 22, 17, 14, 11, 9, 8, 6, 5, 4, 4, 4, 3, 3, 3, 2, 1, 1, 1, 1, 0};


    public static void setNumParticles(int N) {numParticles = N;}

    public static void setTreeLogic() {
        haveReachedTree = new boolean[numParticles];
        treeOn = new boolean[numParticles];
    }

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

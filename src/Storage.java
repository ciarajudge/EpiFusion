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
    public static int[] births = new int[] {2, 0, 2, 0, 4, 3, 4, 10, 23, 35, 66, 70, 144, 206, 292, 396, 589, 902, 1110, 1442, 1678, 1806, 1882, 1660, 1512, 1292, 990, 745, 578, 472, 351, 233, 203, 150, 128, 112, 76, 69, 44, 50, 43, 32, 21, 28, 19, 22, 12, 13, 15, 7, 5, 9, 3, 4, 6, 5, 2, 2, 1, 1, 1, 1, 1, 0, 1, 2, 0, 1, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    public static int[] deaths = new int[] {1, 0, 1, 0, 0, 0, 3, 0, 4, 12, 10, 19, 32, 60, 78, 112, 148, 247, 325, 488, 590, 812, 966, 1098, 1116, 1155, 1109, 1111, 1004, 989, 875, 792, 727, 661, 549, 530, 470, 406, 359, 349, 278, 251, 213, 209, 175, 160, 133, 111, 119, 86, 85, 67, 67, 58, 45, 39, 33, 33, 31, 25, 27, 19, 21, 14, 13, 8, 5, 5, 7, 8, 7, 3, 2, 3, 5, 3, 3, 2, 1, 2, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 0, 1};
    public static int[] diff = new int[] {1, 0, 1, 0, 4, 3, 1, 10, 19, 23, 56, 51, 112, 146, 214, 284, 441, 655, 785, 954, 1088, 994, 916, 562, 396, 137, -119, -366, -426, -517, -524, -559, -524, -511, -421, -418, -394, -337, -315, -299, -235, -219, -192, -181, -156, -138, -121, -98, -104, -79, -80, -58, -64, -54, -39, -34, -31, -31, -30, -24, -26, -18, -20, -14, -12, -6, -5, -4, -7, -6, -7, -3, -2, -3, -5, -3, -3, -2, -1, -2, -1, -1, 0, 0, -1, 0, 0, -1, -1, 0, 0, 0, -1};
    public static boolean segmentedDays = false;
    public static String folder;
    public static ParticleLoggers particleLoggers;
    public static boolean initialised = false;

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

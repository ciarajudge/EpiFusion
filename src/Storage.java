public class Storage {
    private static boolean phyloOnly = false;
    private static boolean epiGrainyResolution = false;
    public static int resampleEvery = 7;

    public static void setPhyloOnly() {
        phyloOnly = true;
    }

    public static void setResampling(int resampling) {
        resampleEvery = resampling;
    }

    public static boolean isPhyloOnly() {
        return phyloOnly;
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

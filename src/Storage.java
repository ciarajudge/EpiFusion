import org.w3c.dom.Element;

import javax.print.attribute.standard.MediaSize;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Date;
import java.time.LocalDate;

public class Storage {
    public static String argument = "foo";

    //on it's own cause it's super consequential
    public static HashMap<Integer, LocalDate> dateAnchor = null;

    //Loggers things
    public static String fileBase;
    public static int logEvery;
    public static String folder;
    public static ParticleLoggers particleLoggers;
    public static MasterLoggers loggers = null;

    //Parameters things
    private static boolean phyloOnly = false;
    private static boolean epiOnly = false;
    public static int numParticles = 0;
    public static int numMCMCsteps = 0;
    public static int numThreads = 10;
    public static int numChains = 1;
    public static double stepCoefficient;
    public static int resampleEvery = 7;
    public static boolean segmentedDays = false;
    public static int maxEpidemicSize = 50000;
    public static int removalProbability = 0;
    public static double[] genTime = null;
    public static int likelihoodScaler = 1;

    //Analysis things
    public static Integer start = null;
    public static Integer end = null;
    public static int analysisType = 0;
    public static boolean inferTOI = false;

    //Model things
    public static String epiObservationModel;
    public static Double overdispersion = 10.0;

    //Data things
    public static Trees tree = null;
    public static boolean phyloUncertainty = false;
    public static Incidence incidence = null;
    public static int T; //Right now T is the length of the dataset
    public static double[] confidenceSplit = null;
    public static int maxTOI;
    public static int maxTime;


    //Priors things
    public static Priors priors;
    public static boolean pairedPsi = false;
    public static double[] psiProp;

    //Extras
    public static boolean tooBig = false;
    public static boolean initialised = false;
    public static int[] completedRuns;
    public static int firstStep = 0;
    public static boolean epiActive = false;

    //Functions
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

    public static void setTree(Trees t) {
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

    public static LocalDate getDateAnchorDate() {
        Map.Entry<Integer, LocalDate> firstEntry = dateAnchor.entrySet().iterator().next();
        return firstEntry.getValue();
    }

    public static Integer getDateAnchorInt() {
        Map.Entry<Integer, LocalDate> firstEntry = dateAnchor.entrySet().iterator().next();
        return firstEntry.getKey();
    }

    public static void printLoggersInfo() {
        System.out.println("Filebase: "+fileBase);
        System.out.println("Folder: "+folder);
        System.out.println("Log every: "+logEvery);
    }

    public static void printParametersInfo() {
        System.out.println("phyloOnly: "+phyloOnly);
        System.out.println("epiOnly: "+epiOnly);
        System.out.println("numParticles: "+numParticles);
        System.out.println("numMCMCsteps: "+numMCMCsteps);
        System.out.println("numChains: "+numChains);
        System.out.println("stepCoefficient: "+stepCoefficient);
        System.out.println("resampleEvery: "+resampleEvery);
        System.out.println("segmentedDays: "+segmentedDays);
        System.out.println("maxEpidemicSize: "+maxEpidemicSize);
        System.out.println("removalProbability: "+removalProbability);
        System.out.println("genTime: "+ Arrays.toString(genTime));
    }

    public static void printAnalysisInfo() {
        System.out.println("start: "+start);
        System.out.println("end: "+end);
    }

    public static void printDataInfo() {
        System.out.println("incidence values: "+Arrays.toString(incidence.incidence));
        System.out.println("incidence times: "+Arrays.toString(incidence.times));
    }

    public static void printPriors() {
        priors.printPriorInfo();
        System.out.println("\n");
    }

    public static void printStorage() {
        printLoggersInfo();
        printAnalysisInfo();
        printDataInfo();
        printParametersInfo();
    }

}

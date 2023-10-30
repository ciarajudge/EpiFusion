import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.xml.sax.SAXException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Objects;
import java.nio.file.Files;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException, ParserConfigurationException, SAXException {
        System.out.println("EpiFusion");

        parseXMLInput(args[0]);

        MasterLoggers loggers = Objects.equals(Storage.fileBase, "null") ? new MasterLoggers() : new MasterLoggers(Storage.fileBase);
        Storage.loggers = loggers;
        logXML(args[0]);

        ExecutorService executor = Executors.newFixedThreadPool(Storage.numChains);
        for (int i=0; i<Storage.numChains; i++) {
            int finalI = i;
            executor.submit(() -> {
                try {
                    ParticleFilter particleFilter = new ParticleFilter(finalI);
                    MCMC particleMCMC = new MCMC(particleFilter);
                    particleMCMC.runMCMC(Storage.numMCMCsteps);
                    particleMCMC.terminateLoggers();
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            });
        }
        executor.shutdown();



    }

    public static void parseXMLInput(String xmlFile) throws IOException, ParserConfigurationException, SAXException {
        Incidence incidence = null;
        Tree tree = null;
        Storage.argument = xmlFile;

        // Create a DocumentBuilder
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();

        // Load and parse the XML file
        Document document = builder.parse(xmlFile);

        // Extract the values from the XML elements
        Element root = document.getDocumentElement();
        Element dataElement = (Element) root.getElementsByTagName("data").item(0);
        Element analysisElement = (Element) root.getElementsByTagName("analysis").item(0);
        Element parametersElement = (Element) root.getElementsByTagName("parameters").item(0);
        Element loggersElement = (Element) root.getElementsByTagName("loggers").item(0);
        String fileBase = loggersElement.getElementsByTagName("fileBase").item(0).getTextContent();
        Storage.setfileBase(fileBase);

        //Analysis type
        String type = analysisElement.getElementsByTagName("type").item(0).getTextContent();
        if (type.equals("looseformbeta")) {
            Storage.analysisType = 1;
        } else if (type.equals("invlogisticbeta")) {
            Storage.analysisType = 0;
        } else if (type.equals("invlogisticwjitter")) {
            Storage.analysisType = 2;
        } else if (type.equals("fixedbeta")) {
            Storage.analysisType = 3;
        }



        // Get boolean values of epi or phylo only
        boolean epiOnly = Boolean.parseBoolean(parametersElement.getElementsByTagName("epiOnly").item(0).getTextContent());
        boolean phyloOnly = Boolean.parseBoolean(parametersElement.getElementsByTagName("phyloOnly").item(0).getTextContent());

        // if (!phyloOnly) {
        boolean incidenceFileExists = dataElement.getElementsByTagName("incidenceFile").getLength() > 0;
        if (incidenceFileExists) {
            String incidenceFile = dataElement.getElementsByTagName("incidenceFile").item(0).getTextContent();
            incidence = new Incidence(incidenceFile);
            Storage.setIncidence(incidence);
        } else {
            boolean incidenceExists = dataElement.getElementsByTagName("incidence").getLength() > 0;
            if (incidenceExists) {
                String incidenceString = dataElement.getElementsByTagName("incidence").item(0).getTextContent();
                incidence = new Incidence(incidenceString, true);
                Storage.setIncidence(incidence);
            } else {
                System.out.println("ERROR: Analysis includes epi model but no incidence data provided");
            }
        }
        // }

        //if (!epiOnly) {
        boolean treeFileExists = dataElement.getElementsByTagName("treeFile").getLength() > 0;
        if (treeFileExists) {
            String treeFile = dataElement.getElementsByTagName("treeFile").item(0).getTextContent();
            tree = new Tree(treeFile);
            Storage.setTree(tree);
        } else {
            boolean treeExists = dataElement.getElementsByTagName("tree").getLength() > 0;
            if (treeExists) {
                String treeString = dataElement.getElementsByTagName("tree").item(0).getTextContent();
                tree = new Tree(treeString, true);
                Storage.setTree(tree);
            } else {
                System.out.println("ERROR: Analysis includes phylo model but no tree data provided");
            }
        }
        //}


        // Extract parameters element values
        int numParticles = Integer.parseInt(parametersElement.getElementsByTagName("numParticles").item(0).getTextContent());
        Storage.setNumParticles(numParticles);

        int numChains = Integer.parseInt(parametersElement.getElementsByTagName("numChains").item(0).getTextContent());
        Storage.numChains = numChains;

        int numThreads = Integer.parseInt(parametersElement.getElementsByTagName("numThreads").item(0).getTextContent());
        Storage.numThreads = numThreads / numChains;

        int numSteps = Integer.parseInt(parametersElement.getElementsByTagName("numSteps").item(0).getTextContent());
        Storage.setNumMCMCsteps(numSteps);

        int logEvery = Integer.parseInt(parametersElement.getElementsByTagName("logEvery").item(0).getTextContent());
        Storage.setLogEvery(logEvery);

        int samplingsAsRemovals = Integer.parseInt(parametersElement.getElementsByTagName("samplingsAsRemovals").item(0).getTextContent());
        Storage.removalProbability = samplingsAsRemovals;

        boolean grainyEpi = Boolean.parseBoolean(parametersElement.getElementsByTagName("grainyEpi").item(0).getTextContent());
        if (grainyEpi) {
            Storage.setEpiGrainyResolution();
        }

        Storage.segmentedDays = Boolean.parseBoolean(parametersElement.getElementsByTagName("segmentedDays").item(0).getTextContent());

        double stepCoefficient = Double.parseDouble(parametersElement.getElementsByTagName("stepCoefficient").item(0).getTextContent());
        Storage.setStepCoefficient(stepCoefficient);

        if (epiOnly && phyloOnly) {
            System.out.println("ERROR: analysis cannot be both epi and phylo only!");
            System.exit(0);
        } else if (epiOnly) {
            //tree = null;
            Storage.setEpiOnly();
        } else if (phyloOnly) {
            //incidence = null;
            Storage.setPhyloOnly();
        }



        int resampleEvery = Integer.parseInt(parametersElement.getElementsByTagName("resampleEvery").item(0).getTextContent());
        Storage.setResampling(resampleEvery);

        Storage.maxEpidemicSize = Integer.parseInt(parametersElement.getElementsByTagName("maxEpidemicSize").item(0).getTextContent());

        int epiLength = Storage.isEpiGrainyResolution() ? resampleEvery * incidence.length : incidence.length;
        double phyloLength = tree.age;
        int T = Math.max(epiLength, (int) Math.round(phyloLength));
        Storage.setT(T);

        //Find out if a start and end time has been specified
        String startTime =analysisElement.getElementsByTagName("startTime").item(0).getTextContent();
        if (!(startTime.equals("null"))) {
            int firstDay = Integer.parseInt(startTime);
            int firstStep = Math.round(firstDay/resampleEvery);
            Storage.firstStep = firstStep;
        } else {
            Storage.firstStep = 0;
        }

        String endTime =analysisElement.getElementsByTagName("endTime").item(0).getTextContent();
        if (!(endTime.equals("null"))) {
            int lastDay = Integer.parseInt(endTime);
            Storage.T = lastDay;
        }

        double[] epiContrib = readDoubleArray(dataElement.getElementsByTagName("epicontrib").item(0).getTextContent());
        int[] weightChangeTimes = readIntegerArray(dataElement.getElementsByTagName("changetimes").item(0).getTextContent());
        double[] weightsOverTime = getArrayAcrossTime(epiContrib, weightChangeTimes);
        System.out.println(Arrays.toString(weightsOverTime));
        Storage.confidenceSplit = weightsOverTime;

        Element priorElement = (Element) root.getElementsByTagName("priors").item(0);
        Storage.setPriors(priorElement);


    }

    public static void logXML(String xml) throws IOException {
        Path sourcePath = Paths.get(xml);
        Path destinationDir = Paths.get(Storage.folder);
        String fileName = sourcePath.getFileName().toString();
        Path destinationPath = destinationDir.resolve(fileName);
        Files.copy(sourcePath, destinationPath);
    }

    private static double[] readDoubleArray(String incidenceString) {
        String[] stringArray = incidenceString.split(" ");
        double[] array = new double[stringArray.length];
        for (int i = 0; i<stringArray.length; i++) {
            array[i] = Double.parseDouble(stringArray[i]);
        }
        return(array);
    }

    private static int[] readIntegerArray(String incidenceString) {
        String[] stringArray = incidenceString.split(" ");
        int[] array = new int[stringArray.length];
        for (int i = 0; i<stringArray.length; i++) {
            array[i] = Integer.parseInt(stringArray[i]);
        }
        return(array);
    }

    public static double[] getArrayAcrossTime(double[] values, int[] indexes) {
        double[] arrayAcrossTime = new double[Storage.T];
        if (values.length == 0) {
            double value = values[0];
            for (int t = 0; t < Storage.T; t++) {
                arrayAcrossTime[t] = value;
            }
        } else {
            int start = 0;
            for (int i=0; i<indexes.length; i++) {
                int changeTime = indexes[i];
                double value = values[i];
                for (int k = start; k < changeTime; k++) {
                    arrayAcrossTime[k] = value;
                }
                start = changeTime;
            }
            double value = values[values.length-1];
            for (int k = start; k < Storage.T; k++) {
                arrayAcrossTime[k] = value;
            }
        }
        return arrayAcrossTime;
    }


}
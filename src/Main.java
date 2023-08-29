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

public class Main {
    public static void main(String[] args) throws IOException, ParserConfigurationException, SAXException {
        System.out.println("EpiFusion");

        parseXMLInput(args[0]);

        Loggers loggers = Objects.equals(Storage.fileBase, "null") ? new Loggers() : new Loggers(Storage.fileBase);
        logXML(args[0]);

        //Lets unpack these priors and seem if I've done them right

        //Initialise particle filter instance
        ParticleFilter particleFilter = new ParticleFilter();
        //ParticleFilterDebug particleFilter = new ParticleFilterDebug(Storage.numParticles, tree, caseIncidence, Storage.T, resampleEvery);

        //Initialise and run MCMC instance
        MCMC particleMCMC = new MCMC(particleFilter, loggers);
        particleMCMC.runMCMC(Storage.numMCMCsteps);
        particleMCMC.loggers.terminateLoggers();


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
        Storage.setTreeLogic();

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

        /*
        Debug debug = new Debug(particleFilter);
        ArrayList<Double> likelihoods = new ArrayList<>();
        double[] deathRates = new double[] {0.1, 0.1291, 0.1668, 0.2154, 0.2782, 0.3593, 0.4641, 0.5994, 0.7742, 0.9999};
        double[] sampleRates = new double[] {0.001, 0.0016, 0.0027, 0.0046, 0.0077, 0.0129, 0.0215, 0.0359, 0.0599, 0.1};
        System.out.println("Made it as far as debug");
        for (double d:sampleRates) {
            double[] trueParams = new double[] {0.233, 0.15, d, 0.6, 1,33, 0.05};
            for (int i = 0; i < 1000; i++) {
                likelihoods.add(debug.runDebug(trueParams));
            }
        }
        debug.loggers.flexiLogger("likelihoodLog.txt", likelihoods);*/

}
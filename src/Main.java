import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.xml.sax.SAXException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import java.io.IOException;
/*
import java.util.Arrays;
import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;*/

public class Main {
    public static void main(String[] args) throws IOException, ParserConfigurationException, SAXException {
        System.out.println("EpiFusion");

        parseXMLInput(args[0]);

        int resampleEvery = Storage.resampleEvery;
        Incidence caseIncidence = Storage.incidence;
        Tree tree = Storage.tree;


        //Initialise particle filter instance
        ParticleFilter particleFilter = new ParticleFilter(Storage.numParticles, tree, caseIncidence, Storage.T, resampleEvery);

        //Debug debug = new Debug(particleFilter);
        //double[] trueParams = new double[] {0.0419, -0.0593, 0.5122, 0.233, 0.0075, 0.15};
        //debug.runDebug(trueParams);
        //Initialise and run MCMC instance

        System.out.println(Storage.segmentedDays);
        MCMC particleMCMC = new MCMC(particleFilter);
        particleMCMC.runMCMC(Storage.numMCMCsteps);

        particleMCMC.loggers.terminateLoggers();
        //debug.loggers.terminateLoggers();

    }

    public static void parseXMLInput(String xmlFile) throws IOException, ParserConfigurationException, SAXException {
        Incidence incidence = null;
        Tree tree = null;

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

        int numInitialisationAttempts = Integer.parseInt(parametersElement.getElementsByTagName("numInitialisationAttempts").item(0).getTextContent());
        Storage.setNumInitialisationAttempts(numInitialisationAttempts);

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

        Element priorElement = (Element) root.getElementsByTagName("priors").item(0);
        Storage.setPriors(priorElement);

    }



}
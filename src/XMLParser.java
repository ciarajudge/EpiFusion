import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.xml.sax.SAXException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import java.time.LocalDate;
import java.util.HashMap;
import java.time.format.DateTimeFormatter;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.time.temporal.ChronoUnit;
import java.util.Objects;
import java.util.Arrays;

public class XMLParser {
    public static void parseXMLInput(String xmlFile) throws IOException, ParserConfigurationException, SAXException {
        Storage.argument = xmlFile;

        // Whittle down to what's needed
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document document = builder.parse(xmlFile);
        Element root = document.getDocumentElement();

        //Get the parent elements for the different sections
        Element loggersElement = (Element) root.getElementsByTagName("loggers").item(0);
        Element dataElement = (Element) root.getElementsByTagName("data").item(0);
        Element analysisElement = (Element) root.getElementsByTagName("analysis").item(0);
        Element modelElement = (Element) root.getElementsByTagName("model").item(0);
        Element parametersElement = (Element) root.getElementsByTagName("parameters").item(0);
        Element priorElement = (Element) root.getElementsByTagName("priors").item(0);

        //Get the date anchor first if it exists
        if (dataElement.getElementsByTagName("dateAnchor").getLength() > 0) { //File will be a table of times and values
            Storage.dateAnchor = readDateAnchor(dataElement.getElementsByTagName("dateAnchor").item(0).getTextContent());
        }

        //Send the elements to the parsing functions
        parseLoggers(loggersElement);
        parseParameters(parametersElement);
        parseAnalysis(analysisElement);
        parseModel(modelElement);
        parseData(dataElement);
        Storage.setPriors(priorElement);


        if (!(Storage.start.equals(null))) {
            int firstStep = (int) Math.floor(Storage.start/Storage.resampleEvery);
            Storage.firstStep = firstStep;
        } else {
            Storage.firstStep = 0;
        }
        //Do a dates days check here, check data generally


        // The special paried psi case, will require the creation of a fixed psi param and calculation of the proportion vector


    }

    public static void parseLoggers(Element loggersElement) {
        String fileBase = loggersElement.getElementsByTagName("fileBase").item(0).getTextContent();
        Storage.setfileBase(fileBase);

        int logEvery = Integer.parseInt(loggersElement.getElementsByTagName("logEvery").item(0).getTextContent());
        Storage.setLogEvery(logEvery);
    }

    public static void parseParameters(Element parametersElement) {
        // Get boolean values of epi or phylo only
        boolean epiOnly = Boolean.parseBoolean(parametersElement.getElementsByTagName("epiOnly").item(0).getTextContent());
        boolean phyloOnly = Boolean.parseBoolean(parametersElement.getElementsByTagName("phyloOnly").item(0).getTextContent());
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

        // Extract parameters element values
        Storage.setNumParticles(Integer.parseInt(parametersElement.getElementsByTagName("numParticles").item(0).getTextContent()));
        Storage.setNumMCMCsteps(Integer.parseInt(parametersElement.getElementsByTagName("numSteps").item(0).getTextContent()));
        Storage.numChains = Integer.parseInt(parametersElement.getElementsByTagName("numChains").item(0).getTextContent());
        Storage.completedRuns = new int[Storage.numChains];
        Storage.numThreads = Integer.parseInt(parametersElement.getElementsByTagName("numThreads").item(0).getTextContent());
        //Storage.numThreads = (Integer.parseInt(parametersElement.getElementsByTagName("numThreads").item(0).getTextContent()) - Storage.numChains )/ Storage.numChains;
        Storage.setStepCoefficient(Double.parseDouble(parametersElement.getElementsByTagName("stepCoefficient").item(0).getTextContent()));
        Storage.setResampling(Integer.parseInt(parametersElement.getElementsByTagName("resampleEvery").item(0).getTextContent()));
        Storage.segmentedDays = Boolean.parseBoolean(parametersElement.getElementsByTagName("segmentedDays").item(0).getTextContent());
        Storage.maxEpidemicSize = Integer.parseInt(parametersElement.getElementsByTagName("maxEpidemicSize").item(0).getTextContent());
        Storage.removalProbability = Integer.parseInt(parametersElement.getElementsByTagName("samplingsAsRemovals").item(0).getTextContent());
        Storage.genTime = readDoubleArray(parametersElement.getElementsByTagName("generationPMF").item(0).getTextContent());

        if (parametersElement.getElementsByTagName("likelihoodScaler").getLength() > 0) {
            Storage.likelihoodScaler = Integer.parseInt(parametersElement.getElementsByTagName("likelihoodScaler").item(0).getTextContent());
        }
    }

    public static void parseAnalysis(Element analysisElement) {
        String type = analysisElement.getElementsByTagName("type").item(0).getTextContent();
        if (type.equals("looseformbeta")) {
            Storage.analysisType = 1;
        } else if (type.equals("invlogisticbeta")) {
            Storage.analysisType = 0;
        } else if (type.equals("invlogisticwjitter")) {
            Storage.analysisType = 2;
        } else if (type.equals("fixedbeta")) {
            Storage.analysisType = 3;
        } else if (type.equals("linearsplinebeta")) {
            Storage.analysisType = 4;
        }

        if (!Objects.equals(analysisElement.getElementsByTagName("startTime").item(0).getTextContent(),"null")) { //if it's null it just stays null
            if (Storage.dateAnchor==null) { //If date anchor is null then expect times in integer
                Storage.start = Integer.parseInt(analysisElement.getElementsByTagName("startTime").item(0).getTextContent());
                Storage.end = Integer.parseInt(analysisElement.getElementsByTagName("endTime").item(0).getTextContent());
            } else {
                Storage.start = anchorDate(parseDate(analysisElement.getElementsByTagName("startTime").item(0).getTextContent()));
                Storage.end = anchorDate(parseDate(analysisElement.getElementsByTagName("endTime").item(0).getTextContent()));
            }
        }
    }

    public static void parseModel(Element modelElement) {
        String epiObservationModel = modelElement.getElementsByTagName("epiObservationModel").item(0).getTextContent();
        Storage.epiObservationModel = epiObservationModel;
        if (Storage.epiObservationModel.equals("negbinom")) {
            Storage.overdispersion = Double.parseDouble(modelElement.getElementsByTagName("overdispersion").item(0).getTextContent());
        }


    }

    public static void parseData(Element dataElement) throws IOException{
        Incidence incidence = null;
        Tree tree = null;

        if (!Storage.isPhyloOnly()) {
            if (dataElement.getElementsByTagName("incidence").getLength() > 0) { //File will be a table of times and values
                Element incidenceElement = (Element) dataElement.getElementsByTagName("incidence").item(0);
                incidence = new Incidence(incidenceElement);
                Storage.setIncidence(incidence);
            } else {
                System.out.println("ERROR: Analysis includes epi model but no incidence data provided");
            }
        }

        if (!Storage.isEpiOnly()) {
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
        }
        int masterStart, masterEnd;

        if (!(Storage.isPhyloOnly() | Storage.isEpiOnly())) {
            masterStart = Storage.start == null ? Math.min(incidence.start, tree.start) :  Storage.start;
            masterEnd = Storage.end == null ? Math.max(incidence.end, tree.end) : Storage.end;
        } else if (Storage.isPhyloOnly()){
            masterStart = Storage.start == null ? tree.start :   Storage.start;
            masterEnd = Storage.end == null ?  tree.end - 1 :  Storage.end;
        } else {
            masterStart = Storage.start == null ? incidence.start :  Storage.start;
            masterEnd = Storage.end == null ? incidence.end : Storage.end;
        }
        Storage.start = masterStart;
        Storage.end = masterEnd + 1;

        int T = masterEnd - masterStart + 1;
        Storage.setT(T);

        double[] epiContrib = readDoubleArray(dataElement.getElementsByTagName("epicontrib").item(0).getTextContent());
        int[] weightChangeTimes = readIntegerArray(dataElement.getElementsByTagName("changetimes").item(0).getTextContent());
        double[] weightsOverTime = getArrayAcrossTime(epiContrib, weightChangeTimes);
        Storage.confidenceSplit = weightsOverTime;

        //Storage.tree.printTree();

        if (!Storage.isEpiOnly()) {
            Storage.tree.segmentedTree = new TreeSegment[Storage.end];
            for (int i=0; i<Storage.end; i++) {
                double t = (double) i + 1;
                Storage.tree.segmentedTree[i] = new TreeSegment(Storage.tree, i, t);
                //segmentedTree[i].printTreeSegment();
            }
        }

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

    private static HashMap<Integer, LocalDate> readDateAnchor(String string) {
        String[] stringArray = string.split(" ");
        Integer key = Integer.parseInt(stringArray[0]);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDate val = LocalDate.parse(stringArray[1], formatter);
        HashMap<Integer, LocalDate> dateAnchor = new HashMap<>();
        dateAnchor.put(key, val);
        return(dateAnchor);
    }

    public static LocalDate parseDate(String date) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDate val = LocalDate.parse(date, formatter);
        return(val);
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

    public static int anchorDate(LocalDate date) {
        int diff = (int) ChronoUnit.DAYS.between(date, Storage.getDateAnchorDate());
        int anchor = Storage.getDateAnchorInt();
        return anchor - diff;
    }

}

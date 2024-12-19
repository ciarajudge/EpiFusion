import org.w3c.dom.*;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Arrays;

public class Priors {
    public Parameter[] parameters;
    public int numParameters;
    public int numPriors;
    public List<Element> priorNodes;
    public ArrayList<String> labels;
    public ArrayList<String> paramLabels;
    public HashMap<String, Parameter> parameterDict;
    public HashMap<String, int[]> parameterIndexes;
    public Boolean[] fixed;
    public Boolean[] discrete;

    public Priors(Element priorElement) {
        NodeList priorElementChildNodes = priorElement.getChildNodes();
        priorNodes = new ArrayList<>();
        labels = new ArrayList<>();
        int psi_and_phi = 0;

        for (int i=0; i<priorElementChildNodes.getLength(); i++) {
            org.w3c.dom.Node node = priorElementChildNodes.item(i);
            if (node.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
                Element element = (Element) node;
                priorNodes.add(element);
                String placeholderLabel = element.getTagName();
                if (placeholderLabel.equals("phi") || placeholderLabel.equals("pairedPsi") || placeholderLabel.equals("psi")) {
                    psi_and_phi += 1;
                }
            }
        }

        numParameters = priorNodes.size();
        if (psi_and_phi == 0) {
            System.out.println("Uh oh! You haven't provided any priors for sampling rates! Try adding psi or phi priors!");
            System.exit(0);
        } else if (psi_and_phi == 1) {
            parameters = new Parameter[numParameters+1];
        } else {
            parameters = new Parameter[numParameters];
        }




        for (int i = 0; i < priorNodes.size(); i++) {
            org.w3c.dom.Node node = priorNodes.get(i);
            String nodeName = node.getNodeName();
            short nodeType = node.getNodeType();
        }

        parameterDict = new HashMap<>();
        parameterIndexes = new HashMap<String, int[]>();
        numPriors = 0;
        paramLabels = new ArrayList<>();
        for (int i=0; i<numParameters; i++) {
            parameters[i] = new Parameter((Element) priorNodes.get(i));
            parameterDict.put(parameters[i].label, parameters[i]);
            paramLabels.add(parameters[i].label);
            int[] range = new int[parameters[i].numDistribs];
            for (int j = 0; j < parameters[i].numDistribs; j++) {
                range[j] = numPriors;
                labels.add(parameters[i].subLabels.get(j));
                numPriors += 1;
            }
            parameterIndexes.put(parameters[i].label, range);
        }

        //Priors checks
        //Make sure there's gamma

        if (!paramLabels.contains("gamma")) {
            System.out.println("ERROR: No gamma prior provided, this is necessary for the analysis!");
            System.exit(0);
        }

        //Make sure there's psi if !epiOnly
        if (!Storage.isEpiOnly()) {
            if (!paramLabels.contains("psi")) {
                System.out.println("ERROR: No psi prior provided, but phylo is included in the analysis");
                System.exit(0);
            }
        } else { //epi only so either create a psi that's fixed, or make psi fixed
            if (!paramLabels.contains("psi")) { //Make a psi
                numParameters += 1;
                numPriors += 1;
                labels.add("psi");
                Parameter[] temp = parameters;
                parameters = new Parameter[numParameters];
                for (int i=0; i<numParameters-1; i++) {
                    parameters[i] = temp[i];
                }
                Parameter tempParam = new Parameter("psi");
                parameters[parameters.length-1] = tempParam;
                parameterDict.put("psi", tempParam);
                parameterIndexes.put("psi", new int[] {numPriors - 1});
                //something to do with parameterindexes
            } else { //Make sure psi is fixed
                if (!parameterDict.get("psi").priors[0].isFixed()) {
                    System.out.println("ERROR: An unfixed psi prior has been provided for an epi only analysis");
                    System.exit(0);
                }
            }
        }

        //Make sure there's phi if !phyloOnly
        if (!Storage.isPhyloOnly()) {
            if (!paramLabels.contains("phi")) {
                System.out.println("ERROR: No phi prior provided, but epi is included in the analysis");
                System.exit(0);
            }
        } else { //epi only so either create a psi that's fixed, or make psi fixed
            if (!paramLabels.contains("phi")) { //Make a psi
                numParameters += 1;
                numPriors += 1;
                labels.add("phi");
                Parameter[] temp = parameters;
                parameters = new Parameter[numParameters];
                for (int i=0; i<numParameters-1; i++) {
                    parameters[i] = temp[i];
                }
                Parameter tempParam = new Parameter("phi");
                parameters[parameters.length-1] = tempParam;
                parameterDict.put("phi", tempParam);
                parameterIndexes.put("phi", new int[] {numPriors - 1});
                //something to do with parameterindexes
            } else { //Make sure psi is fixed
                if (!parameterDict.get("phi").priors[0].isFixed() & !Storage.pairedPsi) {
                    System.out.println("ERROR: An unfixed phi prior has been provided for an phylo only analysis");
                    System.exit(0);
                }
            }
        }
        getFixed();
        getDiscrete();
    }

    public double[] sampleInitial() {
        double[] initialParams = new double[numPriors];
        int ind = 0;
        for (int i=0; i<numParameters; i++) {
            double[] sampled = parameters[i].sample();
            for (int j=0; j < sampled.length; j++) {
                initialParams[ind] = sampled[j];
                ind+= 1;
            }
        }

        return initialParams;
    }

    private void getFixed() {
        int ind = 0;
        fixed = new Boolean[numPriors];
        for (Parameter param:parameters) {
            for (Prior prior:param.priors) {
                fixed[ind] = prior.isFixed();
                ind += 1;
            }
        }
    }

    private void getDiscrete() {
        int ind = 0;
        discrete = new Boolean[numPriors];
        for (Parameter param:parameters) {
            for (Prior prior:param.priors) {
                discrete[ind] = prior.isDiscrete();
                ind += 1;
            }
        }
    }

    public void printPriorInfo() {
        for (Parameter p : parameters) {
            p.printParameter();
        }
    }

}






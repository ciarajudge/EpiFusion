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
    public HashMap<String, Parameter> parameterDict;
    public HashMap<String, int[]> parameterIndexes;
    public Boolean[] fixed;

    public Priors(Element priorElement) {
        NodeList priorElementChildNodes = priorElement.getChildNodes();
        priorNodes = new ArrayList<>();
        labels = new ArrayList<>();

        for (int i=0; i<priorElementChildNodes.getLength(); i++) {
            org.w3c.dom.Node node = priorElementChildNodes.item(i);
            if (node.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
                Element element = (Element) node;
                priorNodes.add(element);
            }
        }

        numParameters = priorNodes.size();
        parameters = new Parameter[numParameters];


        for (int i = 0; i < priorNodes.size(); i++) {
            org.w3c.dom.Node node = priorNodes.get(i);
            String nodeName = node.getNodeName();
            short nodeType = node.getNodeType();
        }

        parameterDict = new HashMap<>();
        parameterIndexes = new HashMap<String, int[]>();
        numPriors = 0;
        for (int i=0; i<numParameters; i++) {
            parameters[i] = new Parameter((Element) priorNodes.get(i));
            parameterDict.put(parameters[i].label, parameters[i]);
            int[] range = new int[parameters[i].numDistribs];
            for(int j = 0; j < parameters[i].numDistribs; j++) {
                range[j] = numPriors;
                labels.add(parameters[i].subLabels.get(j));
                numPriors += 1;
            }
            parameterIndexes.put(parameters[i].label, range);
        }

        getFixed();
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



}






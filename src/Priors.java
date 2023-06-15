import org.w3c.dom.*;
import java.util.List;
import java.util.ArrayList;


public class Priors {
    public Prior[] priors;
    public int numPriors;
    public List<Element> priorNodes;

    public Priors(Element priorElement) {
        NodeList priorElementChildNodes = priorElement.getChildNodes();
        priorNodes = new ArrayList<>();

        for (int i=0; i<priorElementChildNodes.getLength(); i++) {
            org.w3c.dom.Node node = priorElementChildNodes.item(i);
            if (node.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
                Element element = (Element) node;
                priorNodes.add(element);
            }
        }

        numPriors = priorNodes.size();
        priors = new Prior[numPriors];


        for (int i = 0; i < priorNodes.size(); i++) {
            org.w3c.dom.Node node = priorNodes.get(i);
            String nodeName = node.getNodeName();
            short nodeType = node.getNodeType();

        }
        for (int i=0; i<numPriors; i++) {
            priors[i] = new Prior((Element) priorNodes.get(i));
        }
    }

    public double[] sampleInitial() {
        double[] initialParams = new double[numPriors];
        for (int i=0; i<numPriors; i++) {
            initialParams[i] = priors[i].sample();
        }

        return initialParams;
    }



}






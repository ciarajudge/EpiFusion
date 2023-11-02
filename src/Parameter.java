import org.w3c.dom.*;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import java.util.List;
import java.util.ArrayList;

public class Parameter {
    Boolean stepChange;
    int numChanges;
    int numValues;
    int numDistribs;
    Prior[] changeTimes;
    Prior[] values;
    Prior[] priors;
    ArrayList<String> subLabels;
    String label;



    public Parameter(Element element) {
        label = element.getTagName();
        stepChange = Boolean.parseBoolean(element.getElementsByTagName("stepchange").item(0).getTextContent());
        if (stepChange) {
            //Get change times
            getChangeTimes((Element) element.getElementsByTagName("changetime").item(0));
            getParams((Element) element.getElementsByTagName("distribs").item(0));
            numDistribs = numChanges + numValues;
            knitDistribs();

        } else {
            numChanges = 0;
            numValues = 1;
            numDistribs = numChanges + numValues;
            subLabels = new ArrayList<>();
            subLabels.add(label);
            values = new Prior[1];
            values[0] = new Prior((Element) element);
            priors = new Prior[1];
            priors[0] = values[0];
        }
    }

    private void getChangeTimes(Element changeTimeElement) {
        NodeList changeTimeNodes = changeTimeElement.getChildNodes();
        List<Element> changeNodes = new ArrayList<>();

        for (int i=0; i<changeTimeNodes.getLength(); i++) {
            org.w3c.dom.Node node = changeTimeNodes.item(i);
            if (node.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
                Element element = (Element) node;
                changeNodes.add(element);
            }
        }

        numChanges = changeNodes.size();
        changeTimes = new Prior[numChanges];

        for (int i=0; i<numChanges; i++) {
            changeTimes[i] = new Prior((Element) changeNodes.get(i));
        }
    }

    private void getParams(Element distribElement) {
        NodeList valueNodeList = distribElement.getChildNodes();
        List<Element> valueNodes = new ArrayList<>();

        for (int i=0; i<valueNodeList.getLength(); i++) {
            org.w3c.dom.Node node = valueNodeList.item(i);
            if (node.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
                Element element = (Element) node;
                valueNodes.add(element);
            }
        }

        numValues = valueNodes.size();
        values = new Prior[numValues];

        for (int i=0; i<numValues; i++) {
            values[i] = new Prior((Element) valueNodes.get(i));
        }
    }

    private void knitDistribs() {
        subLabels = new ArrayList<>();
        priors = new Prior[numDistribs];
        int ind = 0;
        for (int i = 0; i < numChanges; i++) {
            //Add to the priors
            priors[ind] = values[i];
            priors[ind+1] = changeTimes[i];
            ind += 2;

            //Add to the labels
            subLabels.add(label+"_distribs_"+i);
            subLabels.add(label+"_changetime_"+i);
        }

        priors[priors.length-1] = values[values.length-1];
        subLabels.add(label+"_distribs_"+(values.length-1));

    }

    public double[] sample() {
        double[] sampled = new double[numDistribs];
        for (int i=0; i<numDistribs; i++) {
            sampled[i] = priors[i].sample();
        }
        return sampled;
    }

}

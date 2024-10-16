import org.w3c.dom.*;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

import java.util.Arrays;
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
        if (label.equals("pairedPsi")) {
            if (Storage.isEpiOnly()) {
                System.out.println("Uh Oh! You've specified a paired psi parameter for an Epi Only analysis! Remove the 'pairedPsi'" +
                        "tag from the <priors> block in your XML file!");
                System.exit(0);
            }
            Storage.pairedPsi = true;
            this.label = "psi";
            double[] psiProp = getPsiProp();
            if (psiProp.length > 1) {
                stepChange = true;
            } else {stepChange = false;}

            this.numChanges = psiProp.length - 1;
            this.numValues = psiProp.length;
            this.numDistribs = numChanges + numValues;

            getPsiPropChangeTimes();
            getPsiPropParams(psiProp);
            knitDistribs();

        }
        else {
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

    }

    public Parameter(String label) {
        this.stepChange = false;
        this.numChanges = 0;
        this.numValues = 1;
        this.numDistribs = 1;
        this.subLabels = new ArrayList<>();
        subLabels.add(label);
        this.label = label;
        this.values = new Prior[1];
        values[0] = new Prior(label);
        this.priors = new Prior[1];
        priors[0] = values[0];
    }

    public Parameter(String label, double[] vals, int[] changeTimes) {
        this.stepChange = false;
        this.numChanges = 0;
        this.numValues = vals.length;
        this.numDistribs = (2 * changeTimes.length) + 1;
        this.subLabels = new ArrayList<>();
        subLabels.add(label);
        this.label = label;
        this.values = new Prior[vals.length]; //Here's where I'm at, my brain is tired
        values[0] = new Prior(label);
        this.priors = new Prior[1];
        priors[0] = values[0];
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

    public void printParameter() {
        System.out.println(label);
        System.out.println(stepChange);
        System.out.println(numChanges);
        System.out.println(numValues);
        System.out.println(numDistribs);
        for (Prior p : priors) {
            p.printPrior();
        }
    }

    private double[] getPsiProp() {
        int[] incidenceTimes = Storage.incidence.times;
        double[] psiProp = new double[incidenceTimes.length];
        int init = 0;
        for (int t = 0; t < incidenceTimes.length; t++) {
            int seqs = 0;
            for (int i = init; i < incidenceTimes[t]; i++) {
                try {
                    seqs += Storage.tree.segmentedTree[i].samplings;
                } catch (Exception e) {
                    System.out.println("Tree ends before cases, technically FYI");
                }
                init += 1;
            }
            double proportion = (double)  seqs/Storage.incidence.incidence[t];
            if (Double.isNaN(proportion) && (seqs > Storage.incidence.incidence[t])) {
                System.out.println("WARNING! You are using a paired psi parameter, but there are instances where there are \n" +
                        "observed sequences on the tree and no observed cases during the same interval. We \n" +
                        "advise that you confirm the relationship between psi and phi, to ensure using a paired \n" +
                        "psi is appropriate for this analysis.");
                proportion = 1.0;
            } else if (Double.isInfinite(proportion)){
                System.out.println("WARNING! You are using a paired psi parameter, but there are instances where there are \n" +
                        "observed sequences on the tree and no observed cases during the same interval. We \n" +
                        "advise that you confirm the relationship between psi and phi, to ensure using a paired \n" +
                        "psi is appropriate for this analysis.");
                proportion = 1.0;
            }  else if (Double.isNaN(proportion)) {
                proportion = 0.0;
            }
            psiProp[t] = proportion;
        }
        Storage.psiProp = psiProp;
        return psiProp;
    }

    private void getPsiPropChangeTimes() {
        changeTimes = new Prior[numChanges];
        for (int i=0; i<numChanges; i++) {
            changeTimes[i] = new Prior("psi", Storage.incidence.times[i]);
        }
    }

    private void getPsiPropParams(double[] psiProp) {
        values = new Prior[numValues];
        for (int i=0; i<numValues; i++) {
            values[i] = new Prior("psi", psiProp[i]);
        }
    }

}

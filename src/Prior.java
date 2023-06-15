
import org.w3c.dom.Element;

public class Prior {
    public String label;
    public Dist distrib;

    public Prior(Element element) {
        label = element.getTagName();
        String disttype = element.getElementsByTagName("disttype").item(0).getTextContent();
        if (disttype.equals("Normal")) {
            double mean = Double.parseDouble(element.getElementsByTagName("mean").item(0).getTextContent());
            double standardDeviation = Double.parseDouble(element.getElementsByTagName("standarddev").item(0).getTextContent());
            distrib = new NormalDist(mean, standardDeviation);
        }
        if (disttype.equals("TruncatedNormal")) {
            double mean = Double.parseDouble(element.getElementsByTagName("mean").item(0).getTextContent());
            double standardDeviation = Double.parseDouble(element.getElementsByTagName("standarddev").item(0).getTextContent());
            double lowerBound = Double.parseDouble(element.getElementsByTagName("lowerbound").item(0).getTextContent());
            distrib = new TruncatedNormalDist(mean, standardDeviation, lowerBound);
        }
    }

    public double sample() {
        return distrib.sample();
    }

    public double density(double candidate) {
        return distrib.density(candidate);
    }

}

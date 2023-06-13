
import org.w3c.dom.Element;

public class Prior {
    public Dist distrib;

    public Prior(Element element) {
        String disttype = element.getElementsByTagName("disttype").item(0).getTextContent();
        if (disttype.equals("Normal")) {
            double mean = Double.parseDouble(element.getElementsByTagName("mean").item(0).getTextContent());
            double standardDeviation = Double.parseDouble(element.getElementsByTagName("standarddev").item(0).getTextContent());
            distrib = new NormalDist(mean, standardDeviation);
        }
    }

    public double sample() {
        return distrib.sample();
    }

    public double density(double candidate) {
        return distrib.density(candidate);
    }

}

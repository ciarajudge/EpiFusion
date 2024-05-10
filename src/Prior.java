
import org.w3c.dom.Element;

public class Prior {
    public String label;
    public Dist distrib;
    private boolean isFixed = false;
    private boolean isDiscrete = false;

    public Prior(Element element) {
        label = element.getTagName();
        String disttype = element.getElementsByTagName("disttype").item(0).getTextContent();
        if (disttype.equals("Normal")) {
            double mean = Double.parseDouble(element.getElementsByTagName("mean").item(0).getTextContent());
            double standardDeviation = Double.parseDouble(element.getElementsByTagName("standarddev").item(0).getTextContent());
            distrib = new NormalDist(mean, standardDeviation);
        } else if (disttype.equals("TruncatedNormal")) {
            double mean = Double.parseDouble(element.getElementsByTagName("mean").item(0).getTextContent());
            double standardDeviation = Double.parseDouble(element.getElementsByTagName("standarddev").item(0).getTextContent());
            double lowerBound = Double.parseDouble(element.getElementsByTagName("lowerbound").item(0).getTextContent());
            distrib = new TruncatedNormalDist(mean, standardDeviation, lowerBound);
        } else if (disttype.equals("FixedParameter")) {
            double value = Double.parseDouble(element.getElementsByTagName("value").item(0).getTextContent());
            distrib = new FixedParameter(value);
            isFixed = true;
        } else if (disttype.equals("Uniform")) {
            double min = Double.parseDouble(element.getElementsByTagName("min").item(0).getTextContent());
            double max = Double.parseDouble(element.getElementsByTagName("max").item(0).getTextContent());
            distrib = new UniformDist(min, max);
        } else if (disttype.equals("Poisson")) {
            double mean = Double.parseDouble(element.getElementsByTagName("mean").item(0).getTextContent());
            distrib = new PoissonDist(mean);
            isDiscrete = true;
        } else if (disttype.equals("UniformDiscrete")) {
            double min = Double.parseDouble(element.getElementsByTagName("min").item(0).getTextContent());
            double max = Double.parseDouble(element.getElementsByTagName("max").item(0).getTextContent());
            distrib = new UniformDiscreteDist(min, max);
            isDiscrete = true;
        } else {
            System.out.println("You've specified a prior distribution that isn't supported by EpiFusion!\n" +
                    "First of all, check that there are no spelling errors in your prior specifications. If there's a \n" +
                    "distribution type you would like included in EpiFusion, raise an issue on the Github and we will \n" +
                    "add it asap: https://github.com/ciarajudge/EpiFusion/issues. Current distributions supported are:\n" +
                    "Normal, TruncatedNormal, FixedParameter, Poisson, Uniform, UniformDiscrete. You can find out more \n" +
                    "about how to specify them correctly on the wiki: https://github.com/ciarajudge/EpiFusion/wiki/EpiFusion-XML-Explained.\n");
            System.exit(0);
        }
    }

    public Prior() {
        double value = 1.0;
        distrib = new FixedParameter(value);
        isFixed = true;
    }

    public double sample() {
        return distrib.sample();
    }

    public double density(double candidate) {
        return distrib.density(candidate);
    }

    public boolean isFixed() {return isFixed;}

    public boolean isDiscrete() {return isDiscrete;}

    public void printPrior() {
        System.out.println(label);
        System.out.println(isFixed);
        System.out.println(distrib.getClass());
    }
}

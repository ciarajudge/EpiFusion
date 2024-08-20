
import org.w3c.dom.Element;
import java.util.Random;

public class Prior {
    public String label;
    public Dist[] distribs;
    private boolean isFixed = false;
    public int numDists = 1;
    private boolean isDiscrete = false;
    private Random rand = new Random();

    public Prior(Element element) {
        label = element.getTagName();

        if (label.equals("pairedPsi")) { //whatever tf is going in with pairedpsi lol
            isFixed = true;
            //isDiscrete = true;
            Storage.pairedPsi = true;
        } else if (element.getElementsByTagName("a").getLength() > 0) {
            numDists = Integer.parseInt(element.getElementsByTagName("numdists").item(0).getTextContent());
            distribs = new Dist[numDists];
            for (int i = 0; i < numDists; i++) {
                distribs[i] = createDist((Element) element.getElementsByTagName(Character.toString((char) ('a' + i))).item(0));
            }
            //logic here similar to below, but distrib = an array, i.e. distrib[] and it's populated in a loop
        }
        else { //original logic but is there's just one distrib so it just assigns distrib to 1 in array
            distribs = new Dist[1];
            numDists = 1;
            distribs[0] = createDist(element);
        }
    }

    public Prior() {
        double value = 1.0;
        distribs = new Dist[1];
        distribs[0] = new FixedParameter(value);
        isFixed = true;
    }

    public Prior(double value) {
        distribs = new Dist[1];
        distribs[0] = new FixedParameter(value);
        isFixed = true;
    }

    private Dist createDist(Element element) {
        String disttype = element.getElementsByTagName("disttype").item(0).getTextContent();
        if (disttype.equals("Normal")) {
            double mean = Double.parseDouble(element.getElementsByTagName("mean").item(0).getTextContent());
            double standardDeviation = Double.parseDouble(element.getElementsByTagName("standarddev").item(0).getTextContent());
            return(new NormalDist(mean, standardDeviation));
        } else if (disttype.equals("TruncatedNormal")) {
            double mean = Double.parseDouble(element.getElementsByTagName("mean").item(0).getTextContent());
            double standardDeviation = Double.parseDouble(element.getElementsByTagName("standarddev").item(0).getTextContent());
            double lowerBound = Double.parseDouble(element.getElementsByTagName("lowerbound").item(0).getTextContent());
            double upperBound = Double.parseDouble(element.getElementsByTagName("upperbound").item(0).getTextContent());
            return( new TruncatedNormalDist(mean, standardDeviation, lowerBound));
        } else if (disttype.equals("FixedParameter")) {
            double value = Double.parseDouble(element.getElementsByTagName("value").item(0).getTextContent());
            isFixed = true;
            return(new FixedParameter(value));
        } else if (disttype.equals("Uniform")) {
            double min = Double.parseDouble(element.getElementsByTagName("min").item(0).getTextContent());
            double max = Double.parseDouble(element.getElementsByTagName("max").item(0).getTextContent());
            return(new UniformDist(min, max));
        } else if (disttype.equals("Poisson")) {
            double mean = Double.parseDouble(element.getElementsByTagName("mean").item(0).getTextContent());
            return(new PoissonDist(mean));
        } else if (disttype.equals("UniformDiscrete")) {
            double min = Double.parseDouble(element.getElementsByTagName("min").item(0).getTextContent());
            double max = Double.parseDouble(element.getElementsByTagName("max").item(0).getTextContent());
            isDiscrete = true;
            return(new UniformDiscreteDist(min, max));
        } else if (disttype.equals("Beta")) {
            double alpha = Double.parseDouble(element.getElementsByTagName("alpha").item(0).getTextContent());
            double beta = Double.parseDouble(element.getElementsByTagName("beta").item(0).getTextContent());
            return(new BetaDist(alpha, beta));
        }else {
            System.out.println("You've specified a prior distribution that isn't supported by EpiFusion!\n" +
                    "First of all, check that there are no spelling errors in your prior specifications. If there's a \n" +
                    "distribution type you would like included in EpiFusion, raise an issue on the Github and we will \n" +
                    "add it asap: https://github.com/ciarajudge/EpiFusion/issues. Current distributions supported are:\n" +
                    "Normal, TruncatedNormal, FixedParameter, Poisson, Uniform, UniformDiscrete. You can find out more \n" +
                    "about how to specify them correctly on the wiki: https://github.com/ciarajudge/EpiFusion/wiki/EpiFusion-XML-Explained.\n");
            System.exit(0);
            return(null);
        }
    }


    public double sample() {
        double[] samples = new double[numDists];
        for (int i = 0; i < numDists; i++) {
            samples[i] = distribs[i].sample();
        }
        return samples[rand.nextInt(numDists)];
    }

    public double density(double candidate) {
        double densityPlaceholder = 0.0;
        for (int i = 0; i<numDists; i++) {
            double dens = distribs[i].density(candidate);
            densityPlaceholder = densityPlaceholder + dens; //not 100% sure this is the correct approach, marking this so I remember to check
        }
        return (densityPlaceholder);
    }

    public boolean isFixed() {return isFixed;}

    public boolean isDiscrete() {return isDiscrete;}

    public void printPrior() {
        System.out.println(label);
        System.out.println(isFixed);
        for (int i = 0; i < numDists; i++) {
            System.out.println(distribs[0].getClass());
        }

    }
}

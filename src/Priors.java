import org.apache.commons.math3.distribution.NormalDistribution;

public class Priors {
    public final NormalDistribution a;
    public final NormalDistribution b;
    public final NormalDistribution c;
    public final NormalDistribution gamma;
    public final NormalDistribution psi;
    public final NormalDistribution[] allPriors;

    public Priors() {
        a = new NormalDistribution(0.06, 0.01);
        b = new NormalDistribution(-0.043, 0.001);
        c = new NormalDistribution(0.4, 0.1);
        gamma = new NormalDistribution(0.233, 0.01);
        psi = new NormalDistribution(0.007, 0.001);
        allPriors = new NormalDistribution[] {a,b,c,gamma,psi};
    }

    public double[] sampleInitial() {
        double[] initialParams = {a.sample(), b.sample(), c.sample(), gamma.sample(), psi.sample()};
        return initialParams;
    }


}


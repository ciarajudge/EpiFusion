import org.apache.commons.math3.distribution.NormalDistribution;

public class Priors {
    public final NormalDistribution a;
    public final NormalDistribution b;
    public final NormalDistribution c;
    public final NormalDistribution gamma;
    public final NormalDistribution psi;
    public final NormalDistribution phi;
    public final NormalDistribution[] allPriors;

    public Priors() {
        a = new NormalDistribution(0.047, 0.03);
        b = new NormalDistribution(-0.057, 0.02);
        c = new NormalDistribution(0.5, 0.2);
        gamma = new NormalDistribution(0.233, 0.02);
        psi = new NormalDistribution(0.007, 0.001);
        phi = new NormalDistribution(0.15, 0.01);
        allPriors = new NormalDistribution[] {a,b,c,gamma,psi,phi};
    }

    public double[] sampleInitial() {
        double[] initialParams = {a.sample(), b.sample(), c.sample(), gamma.sample(), psi.sample(), phi.sample()};
        return initialParams;
    }


}


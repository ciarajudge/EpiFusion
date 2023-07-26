import java.io.FileWriter;
import java.io.IOException;

public class ParticleLoggers {
    public FileWriter particleTrajectories;
    public FileWriter particles;
    public FileWriter particleLikelihoods;

    public ParticleLoggers(int run) throws IOException {
        particleTrajectories = new FileWriter(Storage.folder+"/particletrajectories_"+run+".csv");
        particles = new FileWriter(Storage.folder+"/particles_"+run+".csv");
        particleLikelihoods = new FileWriter(Storage.folder+"/particlelikelihoods_"+run+".csv");
    }

    public void resamplingUpdate(int[] p, int[] pT, double[] pL) throws IOException {
        writeList(p, 0);
        writeList(pT, 1);
        writeList(pL);
    }

    public void writeList(int[] list, int which) throws IOException {
        String toWrite = "";
        for (int aDouble : list) {
            toWrite = toWrite + aDouble + ",";
        }
        toWrite = toWrite + "\n";

        if (which == 0) {
            particles.write(toWrite);
        } else if (which == 1) {
            particleTrajectories.write(toWrite);
        }
    }

    public void writeList(double[] list) throws IOException {
        String toWrite = "";
        for (Double aDouble : list) {
            toWrite = toWrite + aDouble + ",";
        }
        toWrite = toWrite + "\n";

        particleLikelihoods.write(toWrite);
    }

    public void terminateLoggers() throws IOException {
        particles.close();
        particleLikelihoods.close();
        particleTrajectories.close();
    }

}
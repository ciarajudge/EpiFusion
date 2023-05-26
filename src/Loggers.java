import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Loggers {
    File folder;
    public FileWriter trajectories;
    public FileWriter likelihoods;

    public Loggers(String filePath) throws IOException {
        folder = new File(filePath);
        if (!folder.exists()){
            folder.mkdir();
        }
        trajectories = new FileWriter(filePath+"/trajectories.csv");
        likelihoods = new FileWriter(filePath+"/likelihoods.txt");
    }

    public Loggers() throws IOException {
        LocalDateTime currentDateTime = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss");
        String folderName = currentDateTime.format(formatter);
        String filePath = "/Users/ciarajudge/Desktop/PhD/EpiFusionResults/"+folderName;
        folder = new File(filePath);
        if (!folder.exists()){
            folder.mkdir();
        }
        trajectories = new FileWriter(filePath+"/trajectories.csv");
        likelihoods = new FileWriter(filePath+"/likelihoods.txt");
    }

    public void logTrajectory(Trajectory trajectory) throws IOException {
        String toWrite = "";
        for (Day d : trajectory.trajectory) {
            toWrite = toWrite + d.I + ",";
        }
        toWrite = toWrite + "\n";
        System.out.println(toWrite);
        trajectories.write(toWrite);
    }

    public void logLogLikelihood(Double likelihood) throws IOException {
        String toWrite = likelihood + "\n";
        likelihoods.write(toWrite);
    }

    public void logTrajectory(Trajectory trajectory, String acceptance) throws IOException {
        String toWrite = "";
        for (Day d : trajectory.trajectory) {
            toWrite = toWrite + d.I + ",";
        }
        toWrite = toWrite + acceptance+ "\n";
        //System.out.println(toWrite);
        trajectories.write(toWrite);
    }

    public void terminateLoggers() throws IOException {
        trajectories.close();
        likelihoods.close();
    }

}

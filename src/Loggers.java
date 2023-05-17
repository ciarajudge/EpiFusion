import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class Loggers {
    File folder;
    FileWriter trajectories;

    public Loggers(String filePath) throws IOException {
        folder = new File(filePath);
        if (!folder.exists()){
            folder.mkdir();
        }
        trajectories = new FileWriter(filePath+"/trajectories.csv");
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

}

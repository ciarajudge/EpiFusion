import java.util.ArrayList;

public class Trajectory {
    ArrayList<Day> trajectory;
    public Trajectory(Day day) {
        ArrayList<Day> trajectory = new ArrayList<>();
        trajectory.add(day);

    }

    public void updateTrajectory(Day day) {
        trajectory.add(day);
    }
}

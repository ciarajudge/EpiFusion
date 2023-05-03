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

class Day {
    int t;
    int I;
    int births;
    int removals;

    public Day(int t, int I, int births, int removals) {
        this.t = t;
        this.I = I;
        this.births = births;
        this.removals = removals;
    }
}

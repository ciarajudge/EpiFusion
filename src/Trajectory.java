import java.util.ArrayList;

public class Trajectory {
    ArrayList<Day> trajectory;
    public Trajectory(Day day) {
        trajectory = new ArrayList<>();
        trajectory.add(day);

    }

    public Trajectory(Trajectory copyTrajectory) {
        this.trajectory = new ArrayList<>(copyTrajectory.trajectory);
    }

    public void updateTrajectory(Day day) {
        trajectory.add(day);
    }

    public void printTrajectory(int pID) {
        System.out.println("Particle "+pID+" trajectory");
        for (Day d : trajectory) {
            System.out.print(d.I+",");
        }
        System.out.println();
    }

    public void printTrajectory() {
        for (Day d : trajectory) {
            System.out.print(d.I+",");
        }
        System.out.println();
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

    public void printDay(){
        System.out.println("Time: "+t+", State: "+I+", Births: "+births+", Deaths: "+removals);
    }

}

import java.io.File;
import java.util.Scanner;
import java.io.FileNotFoundException;
public class Incidence {
    int [] incidence;
    int length;
    public Incidence(String filename) throws FileNotFoundException {
        Scanner scanner = new Scanner(new File(filename));
        incidence = new int [29];
        int i = 0;
        while(scanner.hasNextInt()){
            incidence[i++] = scanner.nextInt();
        }
        length = incidence.length;
    }




}

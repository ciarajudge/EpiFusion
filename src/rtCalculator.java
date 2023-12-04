import java.util.ArrayList;
import java.util.Collections;
import java.util.Arrays;
import java.util.List;

public class rtCalculator {
    public static ArrayList<Double> calculateRt(Particle particle) {
        ArrayList<Integer> infections = particle.cumInfections;
        double[] gt_distribution = Storage.genTime;
        int n_days = infections.size();
        ArrayList<Double> R_t = new ArrayList<>(Collections.nCopies(n_days, 0.0));
        int lag = gt_distribution.length - 1;
        for (int t = 0; t < n_days; t++) {
            if (t < lag) {
                double[] gt = reverseArray(Arrays.copyOfRange(gt_distribution, 0, t+1));
                double sum_gt = sumArray(gt);
                for (int i = 0; i < gt.length; i++) {
                    gt[i] /= sum_gt;
                }
                                //System.out.println(convertIntegers((ArrayList<Integer>) , gt);
                R_t.set(t, (double) infections.get(t) / sumArray(multiplyArrays(infections.subList(0, t+1), gt)));
            } else {
                R_t.set(t, (double) infections.get(t) / sumArray(multiplyArrays(infections.subList(t - lag, t+1), reverseArray(gt_distribution))));
            }
        }
        return R_t;
    }

    public static double[] reverseArray(double[] array) {
        for(int i = 0; i < array.length / 2; i++) {
            double temp = array[i];
            array[i] = array[array.length - i - 1];
            array[array.length - i - 1] = temp;
        }
        return array;
    }

    public static double sumArray(double[] array) {
        double sum = 0;
        for (double num : array) {
            sum += num;
        }
        return sum;
    }

    public static double[] multiplyArrays(List<Integer> array1, double[] array2) {
        double[] result = new double[array1.size()];
        for (int i = 0; i < array1.size(); i++) {
            result[i] = array1.get(i) * array2[i];
        }
        return result;
    }

    public static ArrayList<Double> convertIntegers(ArrayList<Integer> integers)
    {
        ArrayList<Double> ret = new ArrayList<Double>(integers.size());
        for (Integer i : integers)
        {
            ret.add(i.doubleValue());
        }
        return ret;
    }
}

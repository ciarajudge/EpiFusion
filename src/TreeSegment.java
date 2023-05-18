import java.util.List;
import java.util.ArrayList;
import java.util.Collections;


public class TreeSegment {
    public int births;
    public int samplings;
    public int lineages;
    private double startTime;
    private double endTime;
    private ArrayList<Double> birthTimes;
    private ArrayList<Double> sampleTimes;
    public int[] observationOrder;

    public TreeSegment(Tree tree, double startTime, double endTime) {
        birthTimes = new ArrayList<>();
        sampleTimes = new ArrayList<>();
        this.startTime = startTime;
        this.endTime = endTime;
        births = getNumInternalNodes(tree, startTime, endTime);
        samplings = getNumExternalNodes(tree, startTime, endTime);
        lineages = getNumLineages(tree, startTime);
        observationOrder = getObservationOrder();
    }

    public List<Node> getNodesInWindow(Tree tree, double startTime, double endTime) {
        List<Node> nodesInWindow = new ArrayList<>();
        traverseForNodesInWindow(tree.root, startTime, endTime, nodesInWindow);
        return nodesInWindow;
    }

    private void traverseForNodesInWindow(Node node, double startTime, double endTime, List<Node> nodesInWindow) {
        if (node == null) {
            return;
        }
        if (node.getTime() >= startTime && node.getTime() <= endTime) { //Might be able to quit when nodetime is more than endtime but my brain don't be working
            nodesInWindow.add(node);
        }
        if (node instanceof Internal) {
            traverseForNodesInWindow(((Internal) node).getLeft(), startTime, endTime, nodesInWindow);
            traverseForNodesInWindow(((Internal) node).getRight(), startTime, endTime, nodesInWindow);
        }
    }

    private int traverseForLineagesInWindow(Node node, double T, int lineages) {
        if (node == null || node instanceof Leaf) {
            return lineages;
        }
        Node leftChild = ((Internal) node).getLeft();
        Node rightChild = ((Internal) node).getRight();
        if (node.getTime() <= T && leftChild.getTime() >= T) { //Might be able to quit when nodetime is more than endtime but my brain don't be working
            lineages += 1;
        }
        else {
            lineages = traverseForLineagesInWindow(leftChild, T, lineages);
        }

        if (node.getTime() <= T && rightChild.getTime() >= T) {
            lineages += 1;
        }
        else {
            lineages = traverseForLineagesInWindow(rightChild, T, lineages);
        }

        return lineages;
    }

    public int getNumLineages(Tree tree, double T) {
        int numLineages = traverseForLineagesInWindow(tree.getRoot(), T, 0);
        return numLineages;
    }

    public int getNumInternalNodes(Tree tree, double startTime, double endTime) {
        List<Node> nodesInWindow = getNodesInWindow(tree, startTime, endTime);
        int numInternalNodes = 0;
        for (Node node : nodesInWindow) {
            if (node instanceof Internal) {
                numInternalNodes++;
                birthTimes.add((Double) node.getTime());
            }
        }
        return numInternalNodes;
    }

    public int getNumExternalNodes(Tree tree, double startTime, double endTime) {
        List<Node> nodesInWindow = getNodesInWindow(tree, startTime, endTime);
        int numExternalNodes = 0;
        for (Node node : nodesInWindow) {
            if (node instanceof Leaf) {
                numExternalNodes++;
                sampleTimes.add((Double) node.getTime());
            }
        }
        return numExternalNodes;
    }

    public void printTreeSegment() {
        System.out.println("Printing Tree Segment Details Between "+startTime+" and "+endTime);
        System.out.println("Lineages: "+lineages);
        System.out.println("Births: "+births);
        System.out.println("Samplings: "+samplings);
    }

    private int[] getObservationOrder() {
        int[] observationOrder = new int[births+samplings];
        ArrayList<Double> combinedList = new ArrayList<>(birthTimes);
        combinedList.addAll(sampleTimes);
        Collections.sort(combinedList);
        for (int i = 0; i < combinedList.size(); i++) {
            double value = combinedList.get(i);
            if (birthTimes.contains(value)) {
                observationOrder[i] = 0;
            } else {
                observationOrder[i] = 1;
            }
        }
        return observationOrder;
    }
}

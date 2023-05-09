import java.util.List;
import java.util.ArrayList;


public class TreeSegment {
    public int births;
    public int samplings;
    public int lineages;

    public TreeSegment(Tree tree, double startTime, double endTime) {
        births = getNumInternalNodes(tree, startTime, endTime);
        samplings = getNumExternalNodes(tree, startTime, endTime);
        lineages = getNumLineages(tree, startTime);
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
            return 0;
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
            }
        }
        return numExternalNodes;
    }

    public void printTreeSegment() {
        System.out.println(lineages);
        System.out.println(births);
        System.out.println(samplings);
    }
}

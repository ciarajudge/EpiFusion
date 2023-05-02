import java.util.List;
import java.util.ArrayList;


public class TreeSegment {
    public int births;
    public int samplings;
    public int lineages;

    public TreeSegment(Tree tree, double startTime, double endTime) {
        births = getNumInternalNodes(tree, startTime, endTime);
        samplings = getNumExternalNodes(tree, startTime, endTime);
        lineages = getNumLineages(tree, startTime, endTime);
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

    public int getNumLineages(Tree tree, double startTime, double endTime) {
        List<Node> nodesInWindow = getNodesInWindow(tree, startTime, endTime);
        int numLineages = 0;
        for (Node node : nodesInWindow) {
            if (node instanceof Leaf) {
                numLineages++;
            }
        }
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

}

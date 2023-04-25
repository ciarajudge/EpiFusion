import java.util.List;
import java.util.Stack;

public class PhyloLikelihood {
    public static double calculateLikelihood(Tree tree, Particle particle) {
        int state = particle.state;
        double likelihood = 1.0;
        Node root = tree.getRoot();

        // Traverse the tree in postorder
        Stack<Node> stack = new Stack<>();
        stack.push(root);
        while (!stack.empty()) {
            Node node = stack.pop();
            if (node.isLeaf()) {
                String label = node.getLabel();
                char stateChar = state.getState(label);
                double freq = state.getFrequency(stateChar);
                likelihood *= freq;
            } else {
                double branchLength = node.getBranchLength();
                List<Node> children = node.getChildren();
                double p = 1.0;
                for (Node child : children) {
                    stack.push(child);
                    p *= computeSubtreeProbability(child, branchLength, state);
                }
                likelihood *= p;
            }
        }

        return likelihood;
    }

    private static double computeSubtreeProbability(Node node, double parentBranchLength, int state) {
        double branchLength = node.getBranchLength();
        double t = branchLength / parentBranchLength;
        char stateChar = state.getState(node.getLabel());
        double q = state.getSubstitutionProbability(stateChar, t);
        double p = 1.0;
        List<Node> children = node.getChildren();
        for (Node child : children) {
            p *= computeSubtreeProbability(child, branchLength, state);
        }
        return q * p;
    }


}

public interface Dist {
    default double sample() {return Double.NEGATIVE_INFINITY;}

    default double density(double candidate) {return Double.NEGATIVE_INFINITY;}

    default double density(int candidate) {return Double.NEGATIVE_INFINITY;}
}

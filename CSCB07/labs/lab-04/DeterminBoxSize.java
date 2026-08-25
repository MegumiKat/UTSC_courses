public class DeterminBoxSize implements DeterSize{
    @Override
    public String determineBoxSize(double max) {
        if(max < 10)
            return "small";
        else if(max < 20)
            return "medium";
        else if(max < 30)
            return "large";
        else
            return "x-large";
    }

}

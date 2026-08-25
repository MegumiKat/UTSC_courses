public class DeterBookSize implements DeterSize{

    @Override
    public String determineBoxSize(double max){
        if(max < 5)
            return "small";
        else if(max < 15)
            return "medium";
        else
            return "large";
    }
}

public class Polynomial{
    double[] coefficients;
    public Polynomial(){
        this.coefficients = new double[]{0.0};
    }
    public Polynomial(double coefficients[]){
        this.coefficients = new double[coefficients.length];
        for(int i = 0; i < coefficients.length; i++){
            this.coefficients[i] = coefficients[i];
        }
    }

    public Polynomial add(Polynomial p){
        int maxlengthe = Math.max(this.coefficients.length, p.coefficients.length);
        double[] Newcoefficients = new double[maxlengthe];

        for(int i = 0; i < this.coefficients.length; i++){
            Newcoefficients[i] += this.coefficients[i];
        }

        for(int i = 0; i < p.coefficients.length; i++){
            Newcoefficients[i] += p.coefficients[i];
        }

        return new Polynomial(Newcoefficients);
    }

    public double evaluate(double x){
        double result = 0;
        int p = 0;
        for(int i = 0; i < this.coefficients.length; i++){
            p = i;
            double sum = this.coefficients[p];
            for(int j = 0; j < p; j++){
                sum *= x;
            }
            result += sum;
        }

            return result;
    }

    public boolean hasRoot(double y){
        return evaluate(y) == 0;
    }
}

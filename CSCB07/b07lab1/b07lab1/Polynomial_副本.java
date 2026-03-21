import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.PrintStream;
import java.util.Scanner;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

public class Polynomial{
    double[] coefficients;
    int[] exponents;
    public Polynomial(){
        this.coefficients = new double[]{0.0};
        this.exponents = new int[]{0};
    }
    public Polynomial(double[] coefficients, int[] exponents){
        this.coefficients = new double[coefficients.length];
        for(int i = 0; i < coefficients.length; i++){
            this.coefficients[i] = coefficients[i];
        }

        this.exponents = new int[exponents.length];
        for(int i = 0; i < this.exponents.length; i++){
            this.exponents[i] = exponents[i];
        }
    }

    public Polynomial add(Polynomial p){
        int maxe = Math.max(this.exponents.length, p.exponents.length);
        int a = 0;

        for(int i = 0; i < this.exponents.length; i++){

            for(int j = 0; j < p.exponents.length; j++){
                if(this.exponents[i] == p.exponents[j]) {
                    break;
                }
                a += 1;
                if(a == p.exponents.length - 1){
                    maxe += 1;
                }
            }
        }

//        compute the size of the new exponents
        int[] Newexponents = new int[maxe];
        double[] Newcoefficients = new double[maxe];
        int c = 0;

        for (int i = 0; i < this.exponents.length; i++){
            Newexponents[i] = this.exponents[i];
        }

        for(int i = 0; i < p.exponents.length; i++){
            int b = 0;
            for(int j = 0; j < this.exponents.length; j++){
                if(p.exponents[i] == this.exponents[j]){
                    break;
                }
                b += 1;
                if(b == this.exponents.length){
                    c += 1;
                    Newexponents[this.exponents.length - 1 + c] = p.exponents[i];
                }
            }
        }

        for(int i = 0; i < Newexponents.length; i++){
            for(int j = 0; j < this.exponents.length; j++){
                if(Newexponents[i] == this.exponents[j]){
                    Newcoefficients[i] += this.coefficients[j];
                }
            }
            for(int j = 0; j < p.exponents.length; j++){
                if(Newexponents[i] == p.exponents[j]){
                    Newcoefficients[i] += p.coefficients[j];
                }
            }
        }

        int k = 0;
        int o = Newcoefficients.length;
        for(int i = 0; i < Newcoefficients.length; i++){
            if(Newcoefficients[i] == 0.0){
                o -= 1;
            }
        }

        int[] d_exponents = new int[o];
        double[] d_coefficients = new double[o];
        int j = 0;
        for(int i = 0; i < Newexponents.length; i++){
            if(Newcoefficients[i] != 0){
                d_coefficients[j] = Newcoefficients[i];
                d_exponents[j] = Newexponents[i];
                j += 1;
            }
        }
        return new Polynomial(d_coefficients, d_exponents);
    }





    public double evaluate(double x){
        double result = 0;
        int p = 0;


       for(int i = 0; i < this.coefficients.length; i++){
           result += this.coefficients[i] * Math.pow(x, this.exponents[i]);
       }

            return result;
    }

    public boolean hasRoot(double y){
        return evaluate(y) == 0;
    }

    public Polynomial multiply(Polynomial p){
        int len_c = this.coefficients.length;
        int len_e = p.coefficients.length;
        double[] r_coefficients = new double[len_c * len_e];
        int[] r_exponents = new int[len_c * len_e];

        for(int i = 0; i < len_c; i++){
            for(int j = 0; j < len_e; j++){
                int NewExponent = this.exponents[i] + p.exponents[j];
                double NewCoefficient = this.coefficients[i] * p.coefficients[j];

                boolean Exist_e = false;
                //if exist such exponent
                for(int k = 0; k < r_exponents.length; k++){
                    if(NewExponent == r_exponents[k]){
                        r_coefficients[k] += NewCoefficient;
                        Exist_e = true;
                        break;
                    }
                }

                //otherwise
                if(!Exist_e){
                    for(int k = 0; k < r_coefficients.length; k++){
                        if(r_coefficients[k] == 0.0){
                            r_exponents[k] = NewExponent;
                            r_coefficients[k] = NewCoefficient;
                            break;
                        }
                    }
                }
            }
        }

        int k = 0;
        int o = r_coefficients.length;
        for(int i = 0; i < r_coefficients.length; i++){
            if(r_coefficients[i] == 0.0){
                o -= 1;
            }
        }

        int[] d_exponents = new int[o];
        double[] d_coefficients = new double[o];
        int j = 0;
        for(int i = 0; i < r_coefficients.length; i++){
            if(r_coefficients[i] != 0){
                d_coefficients[j] = r_coefficients[i];
                d_exponents[j] = r_exponents[i];
                j += 1;
            }
        }
        return new Polynomial(d_coefficients, d_exponents);
    }


    public Polynomial(File file) throws IOException{
        BufferedReader b = new BufferedReader(new FileReader(file));
        String line = b.readLine().trim();
        StringBuilder p =  new StringBuilder(line);

        //plus "+" on each "-"
        int m = p.indexOf("-", 1);
        while(m != -1 ){
            if(!p.substring(m-1, m).equals("x") || p.substring(m+1, m+2).equals("x") || p.substring(m+2, m+3).equals("x")){
                p.insert(p.indexOf("-", m), "+");
            }
            m = p.indexOf("-", m + 2);
        }

        String q = p.toString();
        String[] split_array = q.split("\\+", 0);
        int o = split_array.length;

        this.exponents = new int[o];
        this.coefficients = new double[o];

        for(int i = 0; i < o; i++){
            if(split_array[i].contains("x")){
                String[] k = split_array[i].split("x", 0);
                if(k.length == 0){
                    this.coefficients[i] = 1;
                    this.exponents[i] = 1;
                }else if(k.length == 1){
                    if(split_array[i].indexOf("x") == 0){
                        this.coefficients[i] = 1;
                        this.exponents[i] = Integer.parseInt(k[0]);
                    }else{
                        if(k[0].equals("-")){
                            this.coefficients[i] = -1;
                        }else{
                            this.coefficients[i] = Double.parseDouble(k[0]);
                        }
                        this.exponents[i] = 1;
                    }
                }else{
                    if(k[0].isEmpty() && k[1].isEmpty()){
                        this.coefficients[i] = 1;
                        this.exponents[i] = 1;
                    }else if(k[0].isEmpty()){
                        this.coefficients[i] = 1;
                        this.exponents[i] = Integer.parseInt(k[1]);
                    }else if(k[1].isEmpty()){
                        if(k[0].equals("-")){
                            this.coefficients[i] = -1;
                        }else{
                            this.coefficients[i] = Double.parseDouble(k[0]);
                        }
                        this.exponents[i] = 1;
                    }else{
                        if(k[0].equals("-")){
                            this.coefficients[i] = -1;
                        }else{
                            this.coefficients[i] = Double.parseDouble(k[0]);
                        }
                        this.exponents[i] = Integer.parseInt(k[1]);
                    }
                }
            }else{
                this.coefficients[i] = Double.parseDouble(split_array[i]);
                this.exponents[i] = 0;
            }
        }
        b.close();
    }


    public void saveToFile(String s) throws IOException{
        File file = new File(s);
        file.createNewFile();
        BufferedWriter b = new BufferedWriter(new FileWriter(file));
        for(int i = 0; i < this.exponents.length;i++){
            if(this.exponents[i] == 0 && this.coefficients[i] == 0){
                continue;
            }
            if(this.exponents[i] == 0) {
                if(this.coefficients[i] < 0){
                    b.write(String.valueOf(this.coefficients[i]));
                }else{
                    if(i==0){
                        b.write(String.valueOf(this.coefficients[i]));
                    }else{
                        b.write("+" + String.valueOf(this.coefficients[i]));
                    }
                }
            }else{
                if(this.coefficients[i] < 0){
                    if(this.coefficients[i] == -1){
                        if(this.exponents[i] == 1){
                            b.write(String.valueOf("-x"));
                        }else{
                            b.write(String.valueOf("-x" + this.exponents[i]));
                        }
                    }else{
                        if(this.exponents[i] == 1){
                            b.write(String.valueOf(this.coefficients[i]) + "x");
                        }else{
                            b.write(String.valueOf(this.coefficients[i]) + "x" + this.exponents[i]);
                        }
                    }
                }else{
                    if(i==0){
                        if(this.coefficients[i] == 1){
                            if(this.exponents[i] == 1){
                                b.write(String.valueOf("x"));
                            }else{
                                b.write(String.valueOf("x" + this.exponents[i]));
                            }
                        }else{
                            if(this.exponents[i] == 1){
                                b.write(String.valueOf(this.coefficients[i]) + "x");
                            }else{
                                b.write(String.valueOf(this.coefficients[i]) + "x" + this.exponents[i]);
                            }
                        }
                    }else{
                        if(this.coefficients[i] == 1){
                            if(this.exponents[i] == 1){
                                b.write("+" + "x");
                            }else{
                                b.write("+" + "x" + this.exponents[i]);
                            }
                        }else{
                            if(this.exponents[i] == 1){
                                b.write("+" + String.valueOf(this.coefficients[i]) + "x");
                            }else{
                                b.write("+" + String.valueOf(this.coefficients[i]) + "x" + this.exponents[i]);
                            }
                        }
                    }
                }
            }
            b.flush();
        }
        b.flush();
        b.close();
    }



}

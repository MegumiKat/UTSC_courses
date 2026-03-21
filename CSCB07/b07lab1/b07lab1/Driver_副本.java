import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.PrintStream;
import java.util.Scanner;
import java.io.IOException;
public class Driver {
    public static void main(String [] args) throws Exception {
        Polynomial p = new Polynomial();
        System.out.println(p.evaluate(3));
        double[] c1 = {1, 2, 3, 4};
        int[] e1 = {1, 2, 3, 4};
        Polynomial p1 = new Polynomial(c1, e1);
        double[] c2 = {0, -2, 3, 4};
        int[] e2 = {1, 2, 4, 5};
        Polynomial p2 = new Polynomial(c2, e2);
        Polynomial s = p1.add(p2);
        Polynomial s2 = p1.multiply(p2);
        System.out.println("s(1) = " + s.evaluate(1));
        if (s.hasRoot(1))
            System.out.println("1 is a root of s");
        else
            System.out.println("1 is not a root of s");

        s.saveToFile("test");
//        File file = new File("/Users/mark/Desktop/course/cscb07/b07lab1/b07lab1/111.txt");
//        try {
//            Polynomial d = new Polynomial(file);
//            for (int i = 0; i < d.coefficients.length; i++) {
//                System.out.println(d.coefficients[i]);
//                System.out.println(d.exponents[i]);
//            }
//        } catch (IOException e) {
//            throw new RuntimeException(e);
//        }


    }
}
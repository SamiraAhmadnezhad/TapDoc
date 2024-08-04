package controller;

import java.io.*;
import java.util.Scanner;

public class Controller {
    private String checkSignUpNFCID(String data) throws IOException {
        String NFCID = data;
        Scanner scan = new Scanner(new File("src/data/users.txt"));
        while(scan.hasNextLine()) {
            String[] s = scan.nextLine().split("#");
            if (s[0]==NFCID) {
                scan.close();
                return "NFC ID is unavailable\n";
            }
        }
        return "NFC ID is available\n";
    }

    private String checkSignUpUsername(String data) throws IOException {
        System.out.println(data);
        String username = data;
        Scanner scan = new Scanner(new File("src/data/users.txt"));
        while(scan.hasNextLine()) {
            String[] s = scan.nextLine().split("#");
            if (s[1]==username) {
                scan.close();
                return "username is unavailable\n";
            }
        }
        return "username is available\n";
    }

    private String checkLoginNFCID (String data) throws FileNotFoundException {
        String NFCID = data;
        Scanner scan = new Scanner(new File("src/data/users.txt"));
        while(scan.hasNextLine()){
            String ss=scan.nextLine();
            String[] s=ss.split("#");
            if (s[0]==NFCID)
                scan.close();
                return "Login successfully\n" + ss;
        }
        scan.close();
        return "User not found!\n";
    }
    private String signUp(String data) throws IOException {
        String info = data;
        Scanner scan = new Scanner(new File("src/data/users.txt"));
        FileWriter fileWriter=new FileWriter("src/data/users.txt" ,false);
        fileWriter.write(info);
        fileWriter.close();
        scan.close();
        return "SignUp successfully!";
    }
    public  String run (String command, String data) throws IOException {
        System.out.println(command);
        switch (command){
            case "checkSignUpUsername":
                return checkSignUpUsername(data);

            case "checkSignUpNFCID":
                return checkSignUpNFCID(data);

            case "signUp":
                return signUp(data);

            case "checkLoginNFCID":
                return checkLoginNFCID(data);
        }
        return "eshteb zadi!!!";
    }
}

package controller;

import java.io.*;
import java.util.Scanner;

public class Controller {
    private String checkSignUpNFCID(String data) throws IOException {
        String NFCID = data;
        Scanner scan = new Scanner(new File("src/data/users.txt"));
        while(scan.hasNextLine()) {
            String[] s = scan.nextLine().split("#");
            if (s[0].contains(NFCID)) {
                scan.close();
                return "NFC ID is unavailable\n";
            }
        }
        scan.close();
        scan = new Scanner(new File("src/data/admin.txt"));
        while(scan.hasNextLine()) {
            String[] s = scan.nextLine().split("#");
            if (s[0].contains(NFCID)) {
                scan.close();
                return "NFC ID is unavailable\n";
            }
        }
        scan.close();
        return "NFC ID is available\n";
    }

    private String checkSignUpUsername(String data) throws IOException {
        System.out.println(data);
        String username = data;
        Scanner scan = new Scanner(new File("src/data/users.txt"));
        while(scan.hasNextLine()) {
            String[] s = scan.nextLine().split("#");
            if (s[1].equals(username)) {
                scan.close();
                return "username is unavailable\n";
            }
        }
        scan.close();
        return "username is available\n";
    }

    private String checkLoginNFCID (String data) throws FileNotFoundException {
        //String NFCID = data;
        Scanner scan = new Scanner(new File("src/data/users.txt"));
        while(scan.hasNextLine()){
            String ss=scan.nextLine();
            String[] s=ss.split("#");
            if (s[0].contains(data)) {
                scan.close();
                return "Login successfully\n" + ss;
            }
        }
        scan.close();
        Scanner scan2 = new Scanner(new File("src/data/admin.txt"));
        while(scan2.hasNextLine()){
            String ss=scan2.nextLine();
            String[] s=ss.split("#");
            if (s[0].contains(data)) {
                scan2.close();
                return "admin Login successfully\n" + ss;
            }
        }
        scan2.close();
        return "User not found!\n";
    }
    private String signUp(String data) throws IOException {
        String info = data;
        FileWriter fileWriter=new FileWriter("src/data/users.txt" ,true);
        fileWriter.write(info+"\n");
        fileWriter.close();
        return "SignUp successfully!";
    }

    private String sendImageToBackend(String data) throws IOException {
        String[] NFCIDAndImage = data.split("#");

        Scanner scan = new Scanner(new File("src/data/users.txt"));
        String result="";
        while(scan.hasNextLine()) {
            String ss=scan.nextLine();
            String[] s=ss.split("#");
            if (s[0].contains(NFCIDAndImage[0])) {
                result+=s[0]+"#"+s[1]+"#"+s[2]+"#"+s[3]+"#"+NFCIDAndImage[1]+"\n";
                continue;
            }
            result+=ss+"\n";
        }

        FileWriter fileWriter=new FileWriter("src/data/users.txt" ,false);
        fileWriter.write(result);
        fileWriter.close();
        scan.close();
        return "change user successfully!";
    }
    public  String run (String command, String data) throws IOException {
        System.out.println(command);
        System.out.println(data);
        switch (command){
            case "checkSignUpUsername":
                return checkSignUpUsername(data);

            case "checkSignUpNFCID":
                return checkSignUpNFCID(data);

            case "signUp":
                return signUp(data);

            case "checkLoginNFCID":
                return checkLoginNFCID(data);

            case "sendImageToBackend":
                return sendImageToBackend(data);
        }
        return "eshteb zadi!!!";
    }
}

package network;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {
    public void start() throws Exception {
        ServerSocket s=new ServerSocket(8080);
        while (true){
            Socket socket=s.accept();
            new ClientHandler(socket).start();
            System.out.println("start");
        }
    }
}

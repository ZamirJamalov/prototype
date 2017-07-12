
import java.sql.CallableStatement;
import java.sql.Clob;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/**
 *
 * @author User
 */
public class OraDataGet {

    public static void main(String[] args) throws SQLException, ClassNotFoundException {
        /* 
        try {
            Class.forName("oracle.jdbc.OracleDriver");
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        
        try {
            String DBlink="jdbc:oracle:thin:@localhost:1521:XE";
            Connection con = DriverManager.getConnection(DBlink, "zamir", "zamir");
            Statement smt=con.createStatement();
            ResultSet rs=smt.executeQuery("select sysdate from dual");
            while (rs.next()){
                String data=rs.getString("sysdate");
                System.out.println(data);
            }
            con.close();
        } catch(Exception e){
            e.printStackTrace();
        }
         */

    }

    public String postGet(String text) throws SQLException, ClassNotFoundException {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        Connection conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:XE", "zamir", "zamir");
        CallableStatement cstmt = conn.prepareCall("begin ? := zamir.hub.run(?); end;");
        cstmt.registerOutParameter(1, Types.CLOB);
        cstmt.setString(2, text);
        cstmt.execute();
        String result = cstmt.getString(1);
        cstmt.close();
        conn.close();
        return result;

    }

}

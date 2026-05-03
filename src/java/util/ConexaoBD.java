/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexaoBD {

    private static final String URL = "jdbc:mysql://tramway.proxy.rlwy.net:44037/railway";
    private static final String USER = "root";
    private static final String PASSWORD = "cTahZQgvxSLweBMpkjulTZOgsIRZNxnb";

    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            System.out.println("Conexao a BD estabelecida!");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver MySQL nao encontrado!");
        } catch (SQLException e) {
            System.out.println("Erro ao conectar a BD!");
        }
        return conn;
    }
}

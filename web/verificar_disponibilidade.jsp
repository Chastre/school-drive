<%-- 
    Document   : vereficar_disponibilidade
    Created on : 15/01/2026, 11:13:09
    Author     : pmnch
--%>

<%@page import="java.sql.*"%>
<%@page import="util.ConexaoBD"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>

<%
    response.setContentType("application/json");
    
    String dataAula = request.getParameter("data");
    String idInstrutorStr = request.getParameter("idInstrutor");
    
    StringBuilder json = new StringBuilder();
    json.append("{");
    
    if (dataAula != null && idInstrutorStr != null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = ConexaoBD.getConnection();
            
            String sql = "SELECT TIME_FORMAT(dataHoraInicio, '%H:%i') as horaInicio, " +
                        "TIME_FORMAT(dataHoraFim, '%H:%i') as horaFim " +
                        "FROM aula_conducao " +
                        "WHERE idInstrutor = ? " +
                        "AND DATE(dataHoraInicio) = ? " +
                        "AND estado = 'Agendada'";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(idInstrutorStr));
            pstmt.setString(2, dataAula);
            rs = pstmt.executeQuery();
            
            json.append("\"sucesso\":true,\"ocupados\":[");
            
            boolean primeiro = true;
            while (rs.next()) {
                if (!primeiro) json.append(",");
                json.append("{\"inicio\":\"").append(rs.getString("horaInicio")).append("\",");
                json.append("\"fim\":\"").append(rs.getString("horaFim")).append("\"}");
                primeiro = false;
            }
            
            json.append("]");
            
        } catch (Exception e) {
            json = new StringBuilder();
            json.append("{\"sucesso\":false,\"erro\":\"").append(e.getMessage()).append("\"}");
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        json.append("\"sucesso\":false,\"erro\":\"Parametros invalidos\"");
    }
    
    json.append("}");
    out.print(json.toString());
%>


